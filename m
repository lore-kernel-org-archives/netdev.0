From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC v2 09/10] landlock: Handle cgroups (performance)
Date: Tue, 30 Aug 2016 18:36:06 -0700
Message-ID: <20160831013605.GB75654@ast-mbp.thefacebook.com>
References: <20160827204307.GA43714@ast-mbp.thefacebook.com>
 <57C202BF.7000207@digikod.net>
 <CALCETrXgQ+njtupXiKcOXG8ZRzD=n2LhT45NiJr1Ehob7bHskQ@mail.gmail.com>
 <57C2B21E.9040705@digikod.net>
 <CALCETrXU64+UApeKL_NogpBYk5kN7zA7UwkypZt8SYfvkuQrbA@mail.gmail.com>
 <57C5EAA3.5090901@digikod.net>
 <CALCETrWAYyx_5Axyeqiz6tQa0kqTeNTuHRrERcM2G8ROhaphVw@mail.gmail.com>
 <57C5ED9B.3040303@digikod.net>
 <20160830205552.GB71063@ast-mbp.thefacebook.com>
 <CALCETrX6hPFZwdnypkPA0p9VjdcK=ZFYpR8zXpzOYS6f=fx3_g@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LSM List <linux-security-module@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@kernel.org>,
	Linux API <linux-api@vger.kernel.org>,
	Sargun Dhillon <sargun@sargun.me>, Tejun Heo <tj@kernel.org>,
	Kees Cook <keescook@chromium.org>,
	"David S . Miller" <davem@davemloft.net>,
	"open list:CONTROL GROUP (CGROUP)" <cgroups@vger.kernel.org>,
	=?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>,
	Daniel Mack <daniel@zonque.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <kernel-hardening-return-4519-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
Content-Disposition: inline
In-Reply-To: <CALCETrX6hPFZwdnypkPA0p9VjdcK=ZFYpR8zXpzOYS6f=fx3_g@mail.gmail.com>
List-Id: netdev.vger.kernel.org

On Tue, Aug 30, 2016 at 02:45:14PM -0700, Andy Lutomirski wrote:
> 
> One might argue that landlock shouldn't be tied to seccomp (in theory,
> attached progs could be given access to syscall_get_xyz()), but I

proposed lsm is way more powerful than syscall_get_xyz.
no need to dumb it down.

> think that the seccomp attachment mechanism is the right way to
> install unprivileged filters.  It handles the no_new_privs stuff, it
> allows TSYNC, it's totally independent of systemwide policy, etc.
> 
> Trying to use cgroups or similar for this is going to be much nastier.
> Some tighter sandboxes (Sandstorm, etc) aren't even going to dream of
> putting cgroupfs in their containers, so requiring cgroups or similar
> would be a mess for that type of application.

I don't see why it is a 'mess'. cgroups are already used by majority
of the systems, so I don't see why requiring a cgroup is such a big deal.
But let's say we don't do them. How implementation is going to look like
for task based hierarchy? Note that we need an array of bpf_prog pointers.
One for each lsm hook. Where this array is going to be stored?
We cannot put in task_struct, since it's too large. Cannot put it
into 'struct seccomp' directly either, unless it will become a pointer.
Is that the proposal?
So now we will be wasting extra 1kbyte of memory per task. Not great.
We'd want to optimize it by sharing this such struct seccomp with prog array
across threads of the same task? Or dynimically allocating it when
landlock is in use? May sound nice, but how to account for that kernel
memory? I guess also solvable by charging memlock.
With cgroup based approach we don't need to worry about all that.
