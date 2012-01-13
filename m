From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Race condition in ipv6 code
Date: Thu, 12 Jan 2012 16:11:50 -0800
Message-ID: <m1pqeov4u1.fsf@fess.ebiederm.org>
References: <CA+HUmGhJ-YvFMRnKzb8RqH6COZ=erp1SajVcb1rq1vi2k9OBGw@mail.gmail.com>
	<1326349911.2741.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francesco Ruggeri <fruggeri@aristanetworks.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:58764 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756128Ab2AMAJa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2012 19:09:30 -0500
In-Reply-To: <1326349911.2741.1.camel@edumazet-laptop> (Eric Dumazet's message
	of "Thu, 12 Jan 2012 07:31:51 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> Le mercredi 11 janvier 2012 =C3=A0 18:13 -0800, Francesco Ruggeri a =C3=
=A9crit :
>> We have hit a race condition in ipv6 code when setting
>> /proc/sys/net/ipv6/conf/*/forwarding. This happens when the syscall
>> has to be restarted.
>>=20
>> I wonder if anyone else has run into the same issue.
>>=20
>> The current sequence in addrconf_sysctl_forward() and
>> addrconf_fixup_forwarding()  is as follows:
>> - change the parameter in idev->cnf.forwarding (using proc_dointvec(=
))
>> - try to get the rtnl lock
>> - if cannot get the lock then restore the original value in
>> idev->cnf.forwarding and restart the syscall.
>>=20
>> While this is going on, the ipv6 code may access idev->cnf.forwardin=
g
>> and get an incorrect value.
>> In our case we were in addrconf_ifdown (holding the rtnl lock)  and
>> calling __ipv6_ifa_notify(RTM_DELADDR, ifa) on the idev->addr_list
>> entries.
>> __ipv6_ifa_notify() only invokes addrconf_leave_anycast() if
>> idev->cnf.forwarding is set. Because a process trying to set
>> forwarding to 0 was stuck in the restart_syscall sequence above
>> flipping the flag on and off, we erroneously read the flag as 0, wit=
h
>> the result that addrconf_leave_anycast() was not invoked, some
>> idev->ac_list entries were never released, idev was never freed and
>> kept a reference to its net_device, and the net_device was never fre=
ed
>> and caused the "unregister_netdevice: waiting for xxx to become free=
"
>> message forever. In our case this was a vlan interfaces that was bei=
ng
>> deleted, so we ended up getting stuck in vlan_ioctl_handler() holdin=
g
>> vlan_ioctl_mutex with further bad consequences.
>> The following diffs (for 2.6.38, but the same logic seems to be used
>> in 3.2) address the issue by modifying idev->cnf.forwarding only aft=
er
>> the rtnl lock is acquired. There is a similar situation for
>> disable_ipv6.
>> Any comments are appreciated.
>>=20
>> Francesco Ruggeri
>
> Real question is : why are we using this horrible thing at all
>
> if (!rtnl_trylock())
> 	return restart_syscall();

Because the rtnl_lock is broad and we have ABBA deadlocks if we don't i=
n
particular we hold the rtnl_lock over sysctl registration and removal.
sysctl removal blocks until all of the callers into the sysctl methods
namely addrconf_sysctl_forward in this case finish executing.

CPU 0                                         CPU 1

rtnl_lock()                                   use_count++
unregister_netdevice()                           addrconf_ctl_foward
  unregister_sysctl_table()                        rtnl_lock()
     wait for use_count of addrconf_ctl_forward
       to =3D=3D 0
    =20

I smacked lockdep around so it would warn about the sysfs ones.
The proc and sysctl ones I never did manage to get lockdep warnings
but a ABBA deadlock is most definitely possible.

Any solutions better than simply restarting the system call are welcome=
=2E

Perhaps for these heavy weigh methods we should create a work struct
and go schedule work to perform the change instead of trying to do the
work synchronously in the sysctl handler.

Eric
