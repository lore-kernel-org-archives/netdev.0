From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [git pull] VFS patches, the first series
Date: Fri, 22 Aug 2008 22:22:09 -0700
Message-ID: <m18wuoz4ou.fsf@frodo.ebiederm.org>
References: <20080727012212.GW28946@ZenIV.linux.org.uk>
	<m1d4k2zui4.fsf@frodo.ebiederm.org>
	<m1od3mthma.fsf@frodo.ebiederm.org>
	<m1iqttnc7a.fsf@frodo.ebiederm.org>
	<20080823033328.GH28946@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Denis V. Lunev" <den@openvz.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753130AbYHWFYS@vger.kernel.org>
In-Reply-To: <20080823033328.GH28946@ZenIV.linux.org.uk> (Al Viro's message of
	"Sat, 23 Aug 2008 04:33:28 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Al Viro <viro@ZenIV.linux.org.uk> writes:

> On Thu, Aug 21, 2008 at 05:08:25PM -0700, Eric W. Biederman wrote:
>
>> I'm not certain what to do about it.  The semantics of the how the
>> sysctl tables are access have changed significantly.  Now the first 
>> sysctl table to describe a directory must remain until there are no
>> other tables that have entries in that directory and a sysctl table
>> must have a pure path of directories for any portion of the address
>> space it shares with an earlier sysctl table.  This is noticeably
>> different from the union mount semantics we have had previously for
>> the sysctl tables.
>
> Note that the old semantics had a lovely inherent problem (leaving aside
> the utterly insane amount of walking and re-walking the trees, as you've
> found out the hard way - don't tell me you hadn't cursed it when writing
> the previous version of proc_sysctl.c): there's redundancy between the
> trees.  At the very least, just what are we supposed to get when the
> stems do not match each other - either in permissions or in ctl_name?

That case is simple.  We never allowed overlapping leaves, and all of
the directories had essentially the same permissions.  Beyond that
I added checks in sysctl_check to make certain we are never out of
sync. 

As for the walking and rewalking I was never fond of it but it was
simple and worked.

So far I am not a fan of the new semantics.

>> If it doesn't look to bad to maintain the new semantics it looks like
>> the right thing to do is to add some additional checks so we get more
>> precise warnings (who knows what out of tree sysctl code will do) and
>> to find someplace I can insert a net/ipv4/neigh sysctl directory into
>> (ipv4_net_table looks like it will work) to keep the network namespace
>> code working safely.
>> 
>> Al btw nice trick using compare to keep the dentries separate allowing
>> us to cache everything in /proc.  I feel silly for missing that one.
>> Want to get together in the next couple of weeks and build a tree that
>> updates the sysctls infrastructure to suck less?
>
> Fine by me...  BTW, fixing that particular crap is not hard - you need
> to have the entry in question show up before either interface, that's all.
> I missed that part of ordering mess, to be honest.  I'll look into that,
> hopefully will post the fix later tonight.

Thanks for looking.

The ordering problem is self inflicted as you introduced an ordering
constraint where none existed previously, and it seems unnecessary.

I'm currently tearing my hair out trying to think of a reasonable
way to audit the current sysctl usage to see if there is anything
else that was missed.

> FWIW, I'd very much prefer ->d_compare() trick to the horrors you guys
> are doing around sysfs; it might or might not be feasible depending on
> what visibility rules you end up with there, but if it's feasible at all
> I'd rather go for it and avoid the entire 'separate backing store' mess.
> IIRC, I had described that scheme to you quite a few months ago in sysfs
> context; got no response back then...

Weird.  I must have missed seeing it, as I don't have any recollection of
it.

There are two pieces of the problem.  
- How do we get a dentry tree that the vfs won't gag on.  Without
  knowing how to successfully implement the dcompare trick it required
  2 dentry trees.

- Monitoring.  It is desirable to be able to mount the filesystem such that
  someone outside the namespace can get a view of what the folks inside the
  namespace see.  Roughly like is done with /proc/net today.

Neither of those two cases requires multiple dentry trees and the
tagged sysfs dirents can easily support an operation like is_seen.

I don't think the dcompare trick is general enough to support discriminating
on something besides the current process.  Which leads to problems with
monitoring.

Eric
