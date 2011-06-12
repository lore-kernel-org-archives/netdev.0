From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC] breakage in sysfs_readdir() and s_instances abuse in sysfs
Date: Sun, 12 Jun 2011 19:35:34 +0100
Message-ID: <20110612183534.GG11521@ZenIV.linux.org.uk>
References: <20110604001518.GT11521@ZenIV.linux.org.uk>
 <m1k4cy6auf.fsf@fess.ebiederm.org>
 <20110607215834.GR11521@ZenIV.linux.org.uk>
 <20110607225902.GS11521@ZenIV.linux.org.uk>
 <20110609012646.GV11521@ZenIV.linux.org.uk>
 <m1y617wmeb.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1y617wmeb.fsf@fess.ebiederm.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 12, 2011 at 12:15:40AM -0700, Eric W. Biederman wrote:

> I honestly hate the pattern that is being used here.  Holding a
> reference count because we can't be bothered to free things reliably
> when we actually stop using them.  It does look less error prone than
> what I am doing today, and 2.5KiB for struct net isn't that much memory
> to pin.

What pattern?  Dual refcounts, one for tearing the contents down and another
for keeping the structure allocated (and it address not reused)?  We are
using that kind of stuff for many things.  Sure, we have cases when there
are pointers to object not contributing to refcount, to be removed on
object destruction.  But if you look at those you'll see that normally
it's done for something like "this object can be found in cyclic list/hash
chain/etc.; those references are not affecting refcount and we simply remove
the object from those lists when refcount hits zero".  The thing is, those
references are trivially found starting at the object.  In case of non-counting
references from sysfs superblocks it's nowhere near that.  And in cases of
that kind the use of dual refcounts is normal.

BTW, speaking of refcounts - I have a pending patch fixing a pid_namespace
leak in proc_set_super(); will be in the next pull request.  anon_set_super()
can fail...

> Will pinning an extra 2.5KiB be a problem when we get to the point where
> unprivileged mounts are safe?  I expect there are easier ways to pin more
> memory so I doubt this is worth worrying about.

*snort*
chdir deep enough into sysfs tree and you've got it.

> It isn't clear what is taking or putting what kind of refcount from the
> names.  If we don't correct the bad naming your patch will be worse for
> maintenance than what we already have.

Agreed.  Suggestions of better names are welcome.  In particular, I considered
s/count/active/ and calling new refcount "count".

> We need to rename kobj_ns_current so it is clear we get a ref count.

Agreed.  Suggestions?

> > +	for (type = KOBJ_NS_TYPE_NONE; type < KOBJ_NS_TYPES; type++)
> > +		kobj_ns_put(type, info->ns[type]);
> 
> This loop and the kfree probably deserve a small function of their own.

OK.

> I really don't like removing const here.  It made it very clear that
> what we are messing with is a token and not something that we ever will
> deference.

But we will - when we drop the reference, refcount is going to change...

> > +static void *net_current_ns(void)
> >  {
> > -	return current->nsproxy->net_ns;
> > +	struct net *ns = current->nsproxy->net_ns;
> > +#ifdef CONFIG_NET_NS
> > +	if (ns)
> > +		atomic_inc(&ns->passive);
> > +#endif
> This code  doesn't need to be #ifdef'd
> > +	return ns;
> >  }

It does, unless we want to make net_put_ns() non-NULL in !NET_NS case...

> > +void net_put_ns(void *p)
> > +{
> There has got to be a better name.  We already have put and get net
> methods.

Um...  Suggestions?  hold_current_ns/drop_ns?
