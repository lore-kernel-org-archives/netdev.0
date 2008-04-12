From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [TOMOYO #7 30/30] Hooks for SAKURA and TOMOYO.
Date: Sat, 12 Apr 2008 20:33:20 +0900
Message-ID: <200804122033.CJC09379.VFOHMSJFFOLtOQ@I-love.SAKURA.ne.jp>
References: <200804071140.59247.paul.moore@hp.com>
	<47FC8052.9070409@nttdata.co.jp>
	<20080409131151.GK11962@parisc-linux.org>
	<200804112312.HGE69734.LFOOHQOSFFMJtV@I-love.SAKURA.ne.jp>
	<20080411143013.GB11962@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paul.moore@hp.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, takedakn@nttdata.co.jp,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: matthew@wil.cx
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20080411143013.GB11962@parisc-linux.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

----- part 1 -----

Matthew Wilcox wrote:
> In my role as a sysadmin, I would consider it a flaw if someone could
> edit a file I'd marked uneditable -- simply by creating a hard-link to it.

That depends on the *language* you used for marking.

I feel it is a flaw if the policy says "you can read a file reached by
resolving /tmp/ro_file" and "you can read/write a file reached by resolving
/tmp/rw_file" but the access control mechanism says "you cannot write a file
reached by resolving /tmp/rw_file because this file is a hard link of
/tmp/ro_file".
Both statements "you can read a file reached by resolving /tmp/ro_file" and
"you can read/write a file reached by resolving /tmp/rw_file" have to be
adhered by the access control mechanism. If not, I dismiss such access control
mechanism.

I feel it is a flaw if the policy says "you can read a file with ro_file_t" and
"you can read/write a file with rw_file_t" but the access control mechanism
says "you cannot write a file with rw_file_t".

Those who use policy based access control must understand what the policy says.
Pathname language does not refer to the entity of a file.
It refers to one of routes to reach to a file.
Don't expect pathname language to refer to the entity of a file.
If you use pathnames as the language to describe rules in policy,
you must understand what the pathname language refers to and accept it.
If you cannot accept it, don't use pathname language in policy.
Use label (or inode number) as the language to describe rules in policy
(like SELinux).

> In short, if a file is named as protected, I think the admin clearly
> means to protect that file -- no matter what name is used to address it.

If "named" in your statement used pathname, the admin didn't clearly mean to
protect that file.
If "named" in your statement used inode number (or label), the admin clearly
meant to protect that file.

----- part 2 -----

> If the same file exists in two places, you have to resolve the question
> of which rule overrides the other.

Your suggestion to use pathname in policy file but judge based on inode number
is incompatible.

What users see and approve as the policy is pathnames, and they expect
the policy to be adhered. But if the policy cannot be adhered by some reason
(e.g. hard link problems), access control mechanism must ask users for
explicit approval *before* the policy is loaded.
It is no good to override the rules without asking users for explicit approval.
If the rules are implicitly overridden and the system became malfunction,
users will dismiss such access control mechanism.

If you suggest to use inode number in policy file (and users see and approve
as the policy) and judge based on inode number, it is correct, and that is
LIDS (Linux Intrusion Detecting System).

> Let's take an example.  We have the two rules "nobody can edit
> /etc/passwd" and "root can edit /tmp/passwd".  A daemon running as root
> is compromised.  Instead of being able to simply write to /etc/passwd,
> the attacker has to "ln /etc/passwd /tmp" first.  There's no additional
> security here, just obfuscation.

It seems to me that you are assuming that pathname based access control uses
black listing. Pathname based access control uses while listing.
So, unless permission to do "ln /etc/passwd /tmp" is explicitly defined in
the policy, the attacker cannot do "ln /etc/passwd /tmp".

The character of pathname based policy is that pathname doesn't reflect
the past state. But please be patient and continue reading before you complain
"Pathname based access control is completely helpless for security".
Pathname based access control has a role in security.

----- part 3 -----

I don't want to start label-vs-pathname battle again.
But I must explain that security is not so simple that can be covered by
only label (or inode number) based access control.

Correctness of userland application code plays some part of security,
correctness of user's operation plays some part of security,
correctness of kernel code plays some part of security,
correctness of file's label plays some part of security,
correctness of file's pathname plays some part of security,
and more...

What SELinux people are talking about is "correctness of file's label is
important".
But I want to talk about "correctness of file's pathname is also important".

Do you think pathname has nothing to do with system's security?
The answer is no. Names have meaning. Names are very important.

The system's availability depends on whether essential files are in place.

You can write policy that allows mounting procfs on /sys/ and sysfs on /proc/ .
But if you actually do such mounts, the system will no longer work as expected.
/proc/ is expected that procfs is mounted and /sys/ is expected that sysfs
is mounted.

Let's consider that buggy program1 needs to create /etc/config1 and
rename /etc/config1 to /etc/config1.old .
You can write policy that allows creating and renaming files in /etc/ .
But if the granularity is "allow creating and renaming files in /etc/ ",
it can lead to unexpected behavior.
If program1 created /etc/config1 and renamed /etc/config1 to /etc/config1.old ,
that's no problem.
If program1 created /etc/config1 and renamed /etc/config1 to /etc/nologin ,
that's problematic. You know, /etc/nologin is a marker that indicates
non-root users are not permitted to login to the system.
You should have written policy that only allows "create /etc/config1" and
"rename /etc/config1 to /etc/config1.old" rather than
"create files in /etc/ directory" and "rename files in /etc/ directory"
to make sure that program1 won't intervene other user's login.

No problem because labels are not changed?
OK. Let's consider that malicious admin1 is permitted to create /forcefsck
and run /sbin/reboot to do maintenance task.
You can write policy that allows creating files in / .
If malicious admin1 creates /forcefsck and runs /sbin/reboot ,
that's no problem.
If malicious admin1 creates /.autorelabel and runs /sbin/reboot ,
that's problematic. You know, files that are not in place will lose their
labels since relabeling operation takes place upon bootup.
You should have written policy that only allows "create /forcefsck" rather than
"create files in / directory" to make sure that admin1 won't tamper labels.

What if /etc/passwd is renamed to /etc/my_passwd?
Label (or inode number) is not changed. But users can no longer login.
Still no problems?

What if /bin/cat and /usr/bin/md5sum are exchanged?
Label (or inode number) is not changed. But many scripts stops working.
Still no problems?

What if /etc/ is bind mounted to /bin/ ?
Label (or inode number) is not changed. But programs won't work.
Still no problems?

No way...

It is a label's (or inode's) advantage that the result of access request is not
affected by rename/link/bind-mount operations.
But that is different from "I can rename/link/bind-mount files freely because
rename/link/bind-mount won't affect the result of access request".
The system behaves differently if essential files are not in place.
To keep the system available, don't allow rename/link/bind-mount operations
freely from the beginning, even if the labels (or inode numbers) are preserved.

----- part 4 -----

Operations that changes pathnames (i.e. rename/link/bind-mount ) are
unnecessary for almost all files in a system. Only a few files such as
/etc/passwd.$$ are subjected to rename/link/bind-mount operations.

When defining pathname based policy, firstly, separate files that are subjected
to rename/link/bind-mount operations and files that are not.
Secondly, write policy that allows rename/link/bind-mount operations with
the granularity of /foo/bar rather than /foo/ to minimize the uncertain part
in the pathname.

> So when considering your problem, I worked from the point of view of the
> attacker "Oh, I can't modify /etc/passwd?  In that case, I'll create
> a new name to the same file", and then figured out a defense to it.

Don't expect that /etc/passwd is allowed to freely rename/link/bind-mount from
the beginning. It is not allowed by default, and is allowed only if it is
needed for the system to work properly.

You might think that "Why do you spend resources in restricting names that
can exist within a mount tree? You can save a lot of resources if you don't
use pathnames for restricting access.", and the below is my answer.

"Applications depend on pathnames, not on inode's number or labels.
 Thinking little of pathnames leads to serious result."

SELinux (label based access control) tries to keep correctness of
file's attributes by restricting operation that changes attributes.
TOMOYO Linux (pathname based access control) tries to keep correctness of
file's pathnames by restricting operation that changes names.
SELinux and TOMOYO Linux are both security tools.
But they play different part in security.
