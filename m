From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] fail dentry revalidation after namespace change
Date: Mon, 9 Jul 2012 19:15:05 -0700
Message-ID: <20120709191505.bcce7947.akpm@linux-foundation.org>
References: <1341565747-15374-1-git-send-email-glommer@parallels.com>
	<20120709161336.0ec23592.akpm@linux-foundation.org>
	<87txxgxxs7.fsf@xmission.com>
	<20120709174705.0e2078c8.akpm@linux-foundation.org>
	<87629wxu1i.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Glauber Costa <glommer@parallels.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Greg Thelen <gthelen@google.com>,
	Serge Hallyn <serge.hallyn@canonical.com>,
	Tejun Heo <tj@kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87629wxu1i.fsf@xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 09 Jul 2012 18:51:37 -0700 ebiederm@xmission.com (Eric W. Biederman) wrote:

> Andrew Morton <akpm@linux-foundation.org> writes:
> 
> > On Mon, 09 Jul 2012 17:30:48 -0700 ebiederm@xmission.com (Eric W. Biederman) wrote:
> >
> >> Andrew Morton <akpm@linux-foundation.org> writes:
> >> 
> >> >>  {
> >> >>  	struct sysfs_dirent *sd;
> >> >>  	int is_dir;
> >> >> +	int type;
> >> >>  
> >> >>  	if (nd->flags & LOOKUP_RCU)
> >> >>  		return -ECHILD;
> >> >> @@ -326,6 +327,13 @@ static int sysfs_dentry_revalidate(struct dentry *dentry, struct nameidata *nd)
> >> >>  	if (strcmp(dentry->d_name.name, sd->s_name) != 0)
> >> >>  		goto out_bad;
> >> >>  
> >> >> +	/* The sysfs dirent has been moved to a different namespace */
> >> >> +	type = KOBJ_NS_TYPE_NONE;
> >> >> +	if (sd->s_parent)
> >> >> +		type = sysfs_ns_type(sd->s_parent);
> >> >> +	if (type && (sysfs_info(dentry->d_sb)->ns[type] != sd->s_ns))
> >> >
> >> > eww, the code is assuming that KOBJ_NS_TYPE_NONE has a value of zero. 
> >> > Don't do that; it smells bad.
> >> 
> >> Gag.  An incomplete change in idiom.
> >> 
> >> KOBJ_NS_TYPE_NONE is explicitly defined as 0 so that it can be used
> >> this way, and every where else in fs/sysfs/dir.c uses this idiom.
> >
> > One man's idiom is another man's idiocy.
> 
> And code that uses inconsistent idioms is even harder to read.

Not true.  That patch is more readable when it is changed to use
correct types.  If only because readers don't need to go in and check
that KOBJ_NS_TYPE_NONE has value zero.

> > Seriously.  What sort of idea is that?  Create an enumerated type and
> > then just ignore it?
> 
> It isn't ignored.  It just has a well defined NULL value. That is hardly
> controversial.

If it's uncontroversial, why are we talking about it?  Why did I, an
experienced C and kernel developer, think that it looked stupid and
possibly buggy?

I'm uncomfortable with propagating this idiotic and unnecessary trick
any further.  It's better to fix it.

> >> Pray tell in what parallel universe is that monstrosity above more
> >> readable than the line it replaces?
> >
> > Don't be silly, it is not a "monstrosity".  The code it is modifying
> > contains an unneeded test-and-branch.  It's a test and branch which the
> > compiler might be able to avoid.  If we can demonstrate that the
> > compiler does indeed optimise it, or if we can find a less monstrous
> > way of implementing it then fine.  Otherwise, efficiency wins.
> 
> Efficiency wins?  In a rarely used function?  Which kernel are you
> working on?

One in which we frequently optimise uncommon code paths.

> Readable maintainable code wins.  Unreadable code causes regressions.

Dude, the whole reason for having enums and enumerated types is for
readability and maintainability.  If we didn't care about that, we'd
use literal constants everywhere.  And here you are arguing against
that readability and maintainability.

If you want to say "yes, the sysfs code is bad but I can't be bothered
fixing it all" then grumble, but OK.  But for heavens sake, don't go
and *defend* what that code is doing.
