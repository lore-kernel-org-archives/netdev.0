From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [Bug #11500] /proc/net bug related to selinux
Date: Wed, 17 Sep 2008 14:56:17 -0700
Message-ID: <m1abe6308u.fsf@frodo.ebiederm.org>
References: <j3zWxt-CgYL.A.WTF.bbsyIB@albercik>
	<SpS7rta8n4.A.i9G.ZcsyIB@albercik>
	<alpine.LRH.1.10.0809130812460.12313@tundra.namei.org>
	<20080912152443.c4e59f42.akpm@linux-foundation.org>
	<alpine.LRH.1.10.0809131012310.13073@tundra.namei.org>
	<20080913123722.e238ae2a.akpm@linux-foundation.org>
	<1221483926.30816.18.camel@moss-spartans.epoch.ncsc.mil>
	<20080917125053.1f9ecf37.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Smalley <sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>, jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org,
	rjw-KKrjLPT3xs0@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080917125053.1f9ecf37.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> (Andrew
	Morton's message of "Wed, 17 Sep 2008 12:50:53 -0700")
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> writes:

> On Mon, 15 Sep 2008 09:05:26 -0400
> Stephen Smalley <sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org> wrote:

>> On Sat, 2008-09-13 at 12:37 -0700, Andrew Morton wrote:
>> However, the most likely explanation is simply that when /proc/net was
>> changed from being a directory to being a symlink to /proc/self/net,
>> that introduced an additional permission check on accesses
>> of /proc/net/<whatever>, namely the read check on the symlink itself.
>> And since that check wasn't happening on /proc/net accesses with older
>> kernels, older policies didn't allow it.

>> As to why others haven't reported it, I expect that they have updated
>> their policies to newer ones that allow the necessary access.  The fact
>> that legacy distros wouldn't have such updated policies isn't surprising
>> - they don't push updates to those distros for new kernels.  FC5 and FC6
>> are both EOL'd, right?
>> 
>> In any event, we didn't change anything in SELinux - the change was
>> elsewhere (in the proc/net implementation).  Don't blame the messenger
>> please.
>> 
>
> Vanilla FC5 broke and vanilla FC6 broke.  Did vanilla FC7, 8 or 9 break?
>
> http://smolt.fedoraproject.org/static/stats/stats.html shows 11,000-odd
> people running FC5 and FC6.  It would be incautious to assume that all
> those people have updated their selinux rules.
>
> And _requiring_ people to update their selinux rules to fix a
> kernel-caused regression is a pretty big deal for some people, I
> expect.

> Then again, given that this regression has been out there since 2.6.25,
> I guess not too many people are hurting from it.  But we suck.

Looking at this discussion closely from what I see selinux is designed
to work on the principle of least privilege.  If you make a user space
visible but compatible change, selinux will keep the system until
you update selinux.  Is selinux exposing too much to user space?
    
selinux was taken into consideration when the change was made.
The patch was even updated with feedback from Stephen Smiley.

> commit e9720acd728a46cb40daa52c99a979f7c4ff195c
> Author: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> Date:   Fri Mar 7 11:08:40 2008 -0800
> 
>     [NET]: Make /proc/net a symlink on /proc/self/net (v3)
>     
>     Current /proc/net is done with so called "shadows", but current
>     implementation is broken and has little chances to get fixed.
>     
>     The problem is that dentries subtree of /proc/net directory has
>     fancy revalidation rules to make processes living in different
>     net namespaces see different entries in /proc/net subtree, but
>     currently, tasks see in the /proc/net subdir the contents of any
>     other namespace, depending on who opened the file first.
>     
>     The proposed fix is to turn /proc/net into a symlink, which points
>     to /proc/self/net, which in turn shows what previously was in
>     /proc/net - the network-related info, from the net namespace the
>     appropriate task lives in.
>     
>     # ls -l /proc/net
>     lrwxrwxrwx  1 root root 8 Mar  5 15:17 /proc/net -> self/net
>     
>     In other words - this behaves like /proc/mounts, but unlike
>     "mounts", "net" is not a file, but a directory.
>     
>     Changes from v2:
>     * Fixed discrepancy of /proc/net nlink count and selinux labeling
>       screwup pointed out by Stephen.
>     
>       To get the correct nlink count the ->getattr callback for /proc/net
>       is overridden to read one from the net->proc_net entry.
>     
>       To make selinux still work the net->proc_net entry is initialized
>       properly, i.e. with the "net" name and the proc_net parent.
>     
>     Selinux fixes are
>     Acked-by:  Stephen Smalley <sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
>     
>     Changes from v1:
>     * Fixed a task_struct leak in get_proc_task_net, pointed out by Paul.
>     
>     Signed-off-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
>     Acked-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>     Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
