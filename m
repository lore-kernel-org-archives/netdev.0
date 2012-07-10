From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH v2] fail dentry revalidation after namespace change
Date: Mon, 09 Jul 2012 18:51:37 -0700
Message-ID: <87629wxu1i.fsf@xmission.com>
References: <1341565747-15374-1-git-send-email-glommer@parallels.com>
	<20120709161336.0ec23592.akpm@linux-foundation.org>
	<87txxgxxs7.fsf@xmission.com>
	<20120709174705.0e2078c8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Glauber Costa <glommer@parallels.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Greg Thelen <gthelen@google.com>,
	Serge Hallyn <serge.hallyn@canonical.com>,
	Tejun Heo <tj@kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120709174705.0e2078c8.akpm@linux-foundation.org> (Andrew
	Morton's message of "Mon, 9 Jul 2012 17:47:05 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@linux-foundation.org> writes:

> On Mon, 09 Jul 2012 17:30:48 -0700 ebiederm@xmission.com (Eric W. Biederman) wrote:
>
>> Andrew Morton <akpm@linux-foundation.org> writes:
>> 
>> >>  {
>> >>  	struct sysfs_dirent *sd;
>> >>  	int is_dir;
>> >> +	int type;
>> >>  
>> >>  	if (nd->flags & LOOKUP_RCU)
>> >>  		return -ECHILD;
>> >> @@ -326,6 +327,13 @@ static int sysfs_dentry_revalidate(struct dentry *dentry, struct nameidata *nd)
>> >>  	if (strcmp(dentry->d_name.name, sd->s_name) != 0)
>> >>  		goto out_bad;
>> >>  
>> >> +	/* The sysfs dirent has been moved to a different namespace */
>> >> +	type = KOBJ_NS_TYPE_NONE;
>> >> +	if (sd->s_parent)
>> >> +		type = sysfs_ns_type(sd->s_parent);
>> >> +	if (type && (sysfs_info(dentry->d_sb)->ns[type] != sd->s_ns))
>> >
>> > eww, the code is assuming that KOBJ_NS_TYPE_NONE has a value of zero. 
>> > Don't do that; it smells bad.
>> 
>> Gag.  An incomplete change in idiom.
>> 
>> KOBJ_NS_TYPE_NONE is explicitly defined as 0 so that it can be used
>> this way, and every where else in fs/sysfs/dir.c uses this idiom.
>
> One man's idiom is another man's idiocy.

And code that uses inconsistent idioms is even harder to read.

A half assed cleanup is worse than no cleanup.

> Seriously.  What sort of idea is that?  Create an enumerated type and
> then just ignore it?

It isn't ignored.  It just has a well defined NULL value. That is hardly
controversial.

>> Pray tell in what parallel universe is that monstrosity above more
>> readable than the line it replaces?
>
> Don't be silly, it is not a "monstrosity".  The code it is modifying
> contains an unneeded test-and-branch.  It's a test and branch which the
> compiler might be able to avoid.  If we can demonstrate that the
> compiler does indeed optimise it, or if we can find a less monstrous
> way of implementing it then fine.  Otherwise, efficiency wins.

Efficiency wins?  In a rarely used function?  Which kernel are you
working on?

Readable maintainable code wins.  Unreadable code causes regressions.

Your addition while it may not be monstrous is most definitely less
readable.

Eric
