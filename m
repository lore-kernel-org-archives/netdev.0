From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] userns: Add basic quota support v4
Date: Fri, 31 Aug 2012 11:17:58 +1000
Message-ID: <20120831011758.GH15292@dastard>
References: <87lih2h6i4.fsf@xmission.com>
 <87harqecvk.fsf@xmission.com>
 <20120827085034.GA8998@quack.suse.cz>
 <87wr0j7u3j.fsf_-_@xmission.com>
 <20120828090544.GC5146@quack.suse.cz>
 <87a9xe7wfn.fsf@xmission.com>
 <20120828175101.GF5146@quack.suse.cz>
 <87y5ky6dff.fsf_-_@xmission.com>
 <20120829021029.GC13691@dastard>
 <87r4qqnixd.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	"Serge E. Hallyn" <serge@hallyn.com>,
	David Miller <davem@davemloft.net>,
	Steven Whitehouse <swhiteho@redhat.com>,
	Mark Fasheh <mfasheh@suse.com>,
	Joel Becker <jlbec@evilplan.org>, Ben Myers <bpm@sgi.com>,
	Alex Elder <elder@kernel.org>,
	Dmitry Monakhov <dmonakhov@openvz.org>,
	Abhijith Das <adas@redhat.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87r4qqnixd.fsf@xmission.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 29, 2012 at 02:31:26AM -0700, Eric W. Biederman wrote:
> 
> Dave thanks for taking the time to take a detailed look at this code.
> 
> Dave Chinner <david@fromorbit.com> writes:
> 
> > On Tue, Aug 28, 2012 at 12:09:56PM -0700, Eric W. Biederman wrote:
> >> 
> >> Add the data type struct kqid which holds the kernel internal form of
> >> the owning identifier of a quota.  struct kqid is a replacement for
> >> the implicit union of uid, gid and project stored in an unsigned int
> >> and the quota type field that is was used in the quota data
> >> structures.  Making the data type explicit allows the kuid_t and
> >> kgid_t type safety to propogate more thoroughly through the code,
> >> revealing more places where uid/gid conversions need be made.
> >> 
> >> Along with the data type struct kqid comes the helper functions
> >> qid_eq, qid_lt, from_kqid, from_kqid_munged, qid_valid, make_kqid,
> >
> > I think Jan's comment about from_kqid being named id_from_kgid is
> > better, though I also think it would read better as kqid_to_id().
> > ie:
> >
> > 	id = kqid_to_id(ns, qid);
> 
> kqid and qid are the same thing just in a different encoding.
> Emphasizing the quota identifier instead of the kernel vs user encoding
> change is paying attention to the wrong thing.

Not from a quota perspective. The only thing the quota code really
cares about is the quota identifier, not the encoding.

Fundamentally, from_kqid() doen't tell me anything about what I'm
getting from the kqid. There's code all over the place that used the
"<format>_to_<other format>" convention because it's obvious what is
being converted from/to. e.g. cpu_to_beXX, compat_to_ptr,
dma_to_phys, pfn_to_page, etc.  Best practises say "follow existing
conventions".

> Using make_kqid and from_kqid follows the exact same conventions as I have
> established for kuids and kgids.  So if you learn one you have learned
> them all.

For those of us that have to look at it once every few months,
following the same conventions as all the other code in the kernel
(i.e. kqid_to_id()) tells me everything I need to know without
having to go through the process of looking up the unusual
from_kqid() function and then from_kuid() to find out what it is
actually doing....

> >> make_kqid_invalid, make_kqid_uid, make_kqid_gid.
> >
> > and these named something like uid_to_kqid()
> 
> The last two are indeed weird, and definitely not the common case,
> since there is no precedent I can almost see doing something different
> but I don't see a good case for a different name.

There's plenty of precendence in other code that converts format.
A very common convention that is used everywhere is DEFINE_...().
That would be make the code easier to grasp than "make...".

> >> Change struct dquot dq_id to a struct kqid and remove the now
> >> unecessary dq_type.
> >> 
> >> Update the signature of dqget, quota_send_warning, dquot_get_dqblk,
> >> and dquot_set_dqblk to use struct kqid.
> >> 
> >> Make minimal changes to ext3, ext4, gfs2, ocfs2, and xfs to deal with
> >> the change in quota structures and signatures.  The ocfs2 changes are
> >> larger than most because of the extensive tracing throughout the ocfs2
> >> quota code that prints out dq_id.
> >
> > How did you test that this all works?
> 
> By making it a compile error if you get a conversion wrong and making it
> a rule not to make any logic changes.
>
> That combined with code review
> and running the code a bit to make certain I did not horribly mess up.

But no actual regression testing. You're messing with code that I
will have to triage when it goes wrong for a user, so IMO your code
has to pass the same bar as the code I write has to pass for review
- please regression test your code and write new regression tests
for new functionality.

> > e.g. run xfstests -g quota on
> > each of those filesystems and check for no regressions? And if you
> > wrote any tests, can you convert them to be part of xfstests so that
> > namespace aware quotas get tested regularly?
> 
> I have not written any tests, and running the xfstests in a namespace
> should roughly be a matter of "unshare -U xfstest -g quota"  It isn't
> quite that easy because  /proc/self/uid_map and /proc/self/gid_map need

Asking people to run the entire regression test suite differently
and with special setup magic won't get the code tested regularly.
Writing a new, self contained test that exercises quota in multiple
namespaces simultaneously is what is needed - that way people who
don't even know that namespaces exist will be regression testing
it...

> >> --- a/include/linux/quota.h
> >> +++ b/include/linux/quota.h
> >> @@ -181,10 +181,161 @@ enum {
> >>  #include <linux/dqblk_v2.h>
> >>  
> >>  #include <linux/atomic.h>
> >> +#include <linux/uidgid.h>
> >>  
> >>  typedef __kernel_uid32_t qid_t; /* Type in which we store ids in memory */
> >>  typedef long long qsize_t;	/* Type in which we store sizes */
> >
> > From fs/xfs/xfs_types.h:
> >
> > typedef __uint32_t              prid_t;         /* project ID */
> >
> > Perhaps it would be better to have an official kprid_t definition
> > here, i.e:
> 
> We can always improve.  For this patch I don't see it making a
> useful difference.

If you are touching the code and introducing new types and concepts
at a global level, then this is precisely when you should be getting
the definitions of those new types correct.

> prid_t isn't exported to non xfs code.  The project id is already
> stored in an unsigned int or a qid_t.

You missed my point - that you are now making a distinction
outside XFS about project quotas. i.e. effectively making it
a first-class quota citizen. That means it needs an equivalent
global type definition and not rely implictly on some subsystem
getting the type conversion correct.

Indeed, isn't that the entire point of your patch set - using the
correct global types throughout the stack to avoid type conversion
errors?

> >> +struct kqid {			/* Type in which we store the quota identifier */
> >> +	union {
> >> +		kuid_t uid;
> >> +		kgid_t gid;
> >> +		qid_t prj;
> >
> > 		kprid_t prid;
> >
> 
> Hmm.  The naming here is interesting.  No one calls the project id prj.
> So I have an avoidable inconsistency here.  xfs most commonly uses
> projid and occassionally calls it prid.

Wrong way around. XFS uses projid in one place - xfs_set_projid() -
and prid in 30 others. The type is xfs_prid_t as well. prid is much
prefered to projid...

> So I am inclined to rename this field projid, but I don't know if it is
> worth respinning the patch for something so trivial.

I'd like to think you are joking, given that the patch series is all
about using consistent, verifiable identifiers... :/

> >> +	};
> >> +	int type; /* USRQUOTA (uid) or GRPQUOTA (gid) or XQM_PRJQUOTA (prj) */
> >> +};
> >> +
> >> +static inline bool qid_eq(struct kqid left, struct kqid right)
> >> +{
> >> +	if (left.type != right.type)
> >> +		return false;
> >> +	switch(left.type) {
> >> +	case USRQUOTA:
> >> +		return uid_eq(left.uid, right.uid);
> >> +	case GRPQUOTA:
> >> +		return gid_eq(left.gid, right.gid);
> >> +	case XQM_PRJQUOTA:
> >> +		return left.prj == right.prj;
> >> +	default:
> >> +		BUG();
> >
> > BUG()? Seriously? The most this justifies is a WARN_ON_ONCE() to
> > indicate a potential programming error, not bringing down the entire
> > machine.
> 
> Dead serious.  Any other type value is impossible and unsupported.

So make the compiler check it (use an enum, or perhaps
BUILD_BUG_ON()).  Don't bring the machine down because you haven't
thought about error handling properly.

> BUG is not panic.  BUG is an oops. BUG won't bring down the machine
> unless the sysadmin wants it too.

panic, oops, it's the same thing to most enterprise distros as they
are configured to dump the kernel or reboot when an oops occurs.

Even if they are not configured this way, any oops that occurs with
a filesystem lock held (like these will) will eventually result in a
filesystem deadlock and subsequent fatal application and/or system
hang. This most definitely is not a condition that should be
triggering a fatal error.

> Beyond that I am not interesting in supporting exploitable abuse
> of this type.

/me jumps up and down on his seat excitedly

Oh, Oh, it's Security Theatre time! Can I have a go!? Please?

If someone can cause an unsupported quota type to appear
in this field, using BUG() creates a wonderful DOS exploit...

:)

> >> +static inline bool qid_lt(struct kqid left, struct kqid right)
> >> +{
> >> +	if (left.type < right.type)
> >> +		return true;
> >> +	if (left.type > right.type)
> >> +		return false;
> >> +	switch (left.type) {
> >> +	case USRQUOTA:
> >> +		return uid_lt(left.uid, right.uid);
> >> +	case GRPQUOTA:
> >> +		return gid_lt(left.gid, right.gid);
> >> +	case XQM_PRJQUOTA:
> >> +		return left.prj < right.prj;
> >> +	default:
> >> +		BUG();
> >> +	}
> >> +}
> >
> > What is this function used for? it's not referenced at all by the
> > patch, and there's no documentation/comments explaining why it
> > exists or how it is intended to be used....
> 
> This function is introduced early, but it is needed for gfs2 as
> performs a sort of quota identifiers.

Introduce it when it is used so the correctness can be determined in
the context that uses it.

> >> +static inline qid_t from_kqid(struct user_namespace *user_ns, struct kqid qid)
> >> +{
> >> +	switch (qid.type) {
> >> +	case USRQUOTA:
> >> +		return from_kuid(user_ns, qid.uid);
> >> +	case GRPQUOTA:
> >> +		return from_kgid(user_ns, qid.gid);
> >> +	case XQM_PRJQUOTA:
> >> +		return (user_ns == &init_user_ns) ? qid.prj : -1;
> >> +	default:
> >> +		BUG();
> >> +	}
> >> +}
> >
> > Oh, this can return an error. That's only checked in a coupl eof
> > places this function is called. it needs tobe checked everywhere,
> > otherwise we now have the possibility of quota usage being accounted
> > to uid/gid/prid 0xffffffff when namespace matches are not found.
> 
> No this is not an error condition.  Returning -1 is the mapping that is
> used when there is not a mapping entry.
>
> Depending on the circumstances not having a mapping can be an error,
> but it can also be a don't care condition.

Which the XFS code would then use as the quota ID for accounting.
That's wrong. So, not having a mapping in this case is an error than
needs to be handled. You didn't add any error handling.

> All in kernel values are defined as having a mapping into the initial
> user namespace.
> 
> Looking at my tree the only calls of from_kqid not mapping the id
> into the initial user namespace are from_kqid_munged and they report
> to userspace.  from_kqid_munged returns fs_overflowuid or fs_overflowgid
> in case of a mapping failure.
>
> projects ids can only be accessed if capable(CAP_SYS_ADMIN) which
> you can only have in the initial user namespace so for now there will
> alwasy be a mapping for project ids.

from_kuid and from_kgid can return -1 when a mapping fails, so it is
not just project quotas that are at issue here. Returning -1 as a
quota id is almost always going to be an invalid ID. If you can't
account quota correctly, then the operation should not be allowed to
proceed. IOWs, no mapping is an error from a quota perspective.

And FWIW, explanations like this need to be in the code....

> >> +static inline qid_t from_kqid_munged(struct user_namespace *user_ns,
> >> +				   struct kqid qid)
> >
> > What does munging do to the return value? how is it different to
> > from_kqid()? Document your API....
> 
> This bit certainly certainly could use a bit more explanation.

Yes, the lack of comments in your code is a bit disturbing.

> Mapping of uids and gids from one domain to another is not new in linux.
> It originates with the transition from 16bit identifiers to 32bit
> identifiers.  In most places when there is a 32bit identifier that can
> not be represented we return a fs_overflowid aka (u16)-2 aka nobody.
> 
> So in general when we want to pass a value to userspace from_kqid_munged
> is called, and if there is a mapping failure we report the value that
> userspace set fs_overflowuid or fs_overflowgid to.  For project ids it
> which are restricted to the initial user namespace no mapping failures
> can occur.

Please add this as a comment to the code.

> >> +static inline struct kqid make_kqid_uid(kuid_t uid)
> >> +{
> >> +	struct kqid kqid = {
> >> +		.type = USRQUOTA,
> >> +		.uid  = uid,
> >> +	};
> >> +	return kqid;
> >> +}
> >
> > Isn't this sort of construct frowned upon? i.e. returning a
> > structure out of scope? It may be inline code and hence work, but
> > this strikes me as a landmine waiting for someone to tread on....
> 
> Not at all because I am returning the structure by value.
> 
> Return a structure by reference is the case that doesn't work.

Right, but you completely missed my point. It's unconventional,
tricky code - returning a structure by value is not something that
is commonly used. If I have to stop and think hard about why 5 lines
of apparently simple code is really OK, then IMO you are doing
something wrong. I might only look at this once every 6 months - I
don't want to have to spend time working this tricky stuff out
every time I look at it...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
