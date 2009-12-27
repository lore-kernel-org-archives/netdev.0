From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: RFC: disablenetwork facility. (v4)
Date: Sun, 27 Dec 2009 20:49:17 +0900
Message-ID: <200912272049.FIB35755.OMFFOOJQtVLFSH@I-love.SAKURA.ne.jp>
References: <20091227010441.GA12077@heat>
	<200912271736.GDB17180.OFJHOOQStMFLVF@I-love.SAKURA.ne.jp>
	<20091227083857.GC11737@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: michael@laptop.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	andi@firstfloor.org, david@lang.hm, socketcan@hartkopp.net,
	alan@lxorguk.ukuu.org.uk, herbert@gondor.apana.org.au,
	Valdis.Kletnieks@vt.edu, bdonlan@gmail.com, zbr@ioremap.net,
	cscott@cscott.net, jmorris@namei.org, ebiederm@xmission.com,
	bernie@codewiz.org, mrs@mythic-beasts.com, randy.dunlap@oracle.com,
	xiyou.wangcong@gmail.com, sam@synack.fr, casey@schaufler-ca.com,
	serue@us.ibm.com
To: pavel@ucw.cz, viro@ZenIV.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from wine.ocn.ne.jp ([122.1.235.145]:57945 "EHLO smtp.wine.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751441AbZL0LtV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Dec 2009 06:49:21 -0500
In-Reply-To: <20091227083857.GC11737@elf.ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Machek wrote:
> Syscalls are very wrong granularity for security system. But easy to
> implement, see seccomp.

Quoting from http://en.wikipedia.org/wiki/Seccomp
> It allows a process to make a one-way transition into a "secure" state where
> it cannot make any system calls except exit(), read() and write() to
> already-open file descriptors. 

I think seccomp() is too much restricted to apply for general applications.
Most applications will need some other syscalls in addition to exit(), read()
and write(). Most applications cannot use seccomp().

What I want to do is similar to seccomp(), but allows userland process to
forbid some syscalls like execve(), mount(), chroot(), link(), unlink(),
socket(), bind(), listen() etc. selectively.

Al Viro wrote:
>> Application writers know better what syscalls the application will call than
>> application users.
> 
> Aren't you forgetting about libc?  Seriously, any interface along the
> lines of "pass a set of syscall numbers to kernel" is DOA:

We can determine what syscalls we need from application's code and libc's code,
can't we?
Otherwise, I think disablenetwork can't be used. If we simply forbid use of
sendmsg() because application's code doesn't use UDP sockets, DNS requests (UDP
port 53) by libc's code cannot be handled and applications will stop working.
We must know what syscalls we need to allow when we forbid some syscalls.

> 	* syscall numbers are architecture-dependent
> 	* there are socketcall-style multiplexors (sys_ipc, anyone?)
> 	* libc is free to substitute one for another
> 	* libc is free to do so in arch-specific manner
> 	* libc is free to do so in kernel-revision-specific manner
> 	* libc is free to do so in libc-revision-specific manner
> (... and does all of the above)
> 	* new syscalls get added
> 	* e.g. on sparc64 32bit task can issue 64bit syscalls

I don't mean to tell the kernel by "syscall numbers".
To be able to handle socketcall-style multiplexors, we will need a hook inside
each syscall functions.
