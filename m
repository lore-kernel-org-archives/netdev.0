From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [RFC v2] net: Introduce recvmmsg socket syscall
Date: Fri, 12 Jun 2009 11:19:24 -0300
Message-ID: <20090612141924.GA2568@ghostprotocols.net>
References: <20090611034022.GC22424@ghostprotocols.net> <200906121026.27010.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Chris Van Hoof <vanhoof@redhat.com>,
	Clark Williams <williams@redhat.com>,
	Caitlin Bestler <caitlin.bestler@gmail.com>,
	Paul Moore <paul.moore@hp.com>,
	Steven Whitehouse <steve@chygwyn.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Nivedita Singhvi <niv@us.ibm.com>
To: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:33198 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752964AbZFLOTv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Jun 2009 10:19:51 -0400
Content-Disposition: inline
In-Reply-To: <200906121026.27010.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Fri, Jun 12, 2009 at 10:26:25AM +0300, R=E9mi Denis-Courmont escreve=
u:
> On Thursday 11 June 2009 06:40:22 ext Arnaldo Carvalho de Melo wrote:
> > diff --git a/arch/x86/include/asm/unistd_64.h
> > b/arch/x86/include/asm/unistd_64.h index 900e161..713a32a 100644
> > --- a/arch/x86/include/asm/unistd_64.h
> > +++ b/arch/x86/include/asm/unistd_64.h
> > @@ -661,6 +661,8 @@ __SYSCALL(__NR_pwritev, sys_pwritev)
> >  __SYSCALL(__NR_rt_tgsigqueueinfo, sys_rt_tgsigqueueinfo)
> >  #define __NR_perf_counter_open                 298
> >  __SYSCALL(__NR_perf_counter_open, sys_perf_counter_open)
> > +#define __NR_recvmmsg                          299
> > +__SYSCALL(__NR_recvmmsg, sys_recvmmsg)
>=20
> I guess socketcall is deprecated in favor of full syscalls, then?
> (sorry if this is a stupid question)

In some architectures, like x86_64, yes, but some still need it, the
ones that set __ARCH_WANT_SYS_SOCKETCALL:

[acme@doppio linux-2.6-tip]$ echo $(find . -type f | xargs egrep
"define.+__ARCH_WANT_SYS_SOCKETCALL" | sed -r 's#./arch/(\w+)/.*#\1#g' =
|
sort)
arm cris frv h8300 m32r m68k microblaze mips mn10300 parisc powerpc s39=
0
sh sh sparc x86 x86

So the alpha and ia64, for instance, doesn't want sys_socketcall:

[acme@doppio linux-2.6-tip]$ egrep 'sys_((recv|send)msg|[gs]etsockopt)'
arch/alpha/kernel/systbls.S
	.quad sys_setsockopt			/* 105 */
	.quad sys_recvmsg
	.quad sys_sendmsg
	.quad sys_getsockopt
[acme@doppio linux-2.6-tip]$ egrep sys_socketcall arch/alpha/kernel/sys=
tbls.S
[acme@doppio linux-2.6-tip]$

[acme@doppio linux-2.6-tip]$ egrep 'sys_((recv|send)msg|[gs]etsockopt)'=
 arch/ia64/kernel/entry.S
	data8 sys_setsockopt
	data8 sys_getsockopt
	data8 sys_sendmsg			// 1205
	data8 sys_recvmsg
[acme@doppio linux-2.6-tip]$ egrep sys_socketcall
arch/ia64/kernel/entry.S
[acme@doppio linux-2.6-tip]$=20

But some define __ARCH_WANT_SYS_SOCKETCALL conditionally, like x86_64
and um:

[acme@doppio linux-2.6-tip]$ find arch -type f | xargs egrep 'define.+_=
_NO_STUBS'
arch/x86/kernel/syscall_64.c:#define __NO_STUBS
arch/x86/kernel/asm-offsets_64.c:#define __NO_STUBS 1
arch/um/sys-x86_64/syscall_table.c:#define __NO_STUBS
[acme@doppio linux-2.6-tip]$=20

And others want socketcall if preserving old ABIs, like ARM:

arch/arm/include/asm/unistd.h

#if !defined(CONFIG_AEABI) || defined(CONFIG_OABI_COMPAT)
#define __ARCH_WANT_SYS_TIME
#define __ARCH_WANT_SYS_OLDUMOUNT
#define __ARCH_WANT_SYS_ALARM
#define __ARCH_WANT_SYS_UTIME
#define __ARCH_WANT_SYS_OLD_GETRLIMIT
#define __ARCH_WANT_OLD_READDIR
#define __ARCH_WANT_SYS_SOCKETCALL
#endif

So for the final revision indeed I need to provide a sys_socketcall
interface to sys_recvmmsg.
=20
> > +       if (timeout) {
> > +               /* Doesn't make much sense */
> > +               if (flags & MSG_DONTWAIT)
> > +                       return -EINVAL;
>=20
> An application could possibly hit this degenerated case at the end of=
 a loop=20
> or whatever, and EINVAL makes it look like this is a bug. Why not EAG=
AIN?

EAGAIN for me looks like something that when repeated would possibly
produce a valid result, but in this case it will never be that way.

But lemme look around, perhaps this assumption of mine is invalidated b=
y
some strange standard...  EAGAIN =3D EWOULDBLOCK, and in the current
implementation it wouldn't block at all, because recvmsg would return
right away...

The only semantic we could associate to this would be to make recvmmsg
call, in a non blocking way recvmsg (as specified in the flags) and if
it returns EAGAIN go to sleep waiting for more packets, i.e. a mixed
blocking recvmmsg with a noblocking recvmsg, sounds of creeping
featuritis...

Or perhaps just remove this check and let recvmmsg return imediately,
the app could then use this degenerated case to measure how long it too=
k
for the packets to be received, looks like the most liberal and removes
3 lines of source code and a branch :-\

Keep it simple?

- Arnaldo
