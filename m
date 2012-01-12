From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Race condition in ipv6 code
Date: Thu, 12 Jan 2012 07:31:51 +0100
Message-ID: <1326349911.2741.1.camel@edumazet-laptop>
References: <CA+HUmGhJ-YvFMRnKzb8RqH6COZ=erp1SajVcb1rq1vi2k9OBGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Francesco Ruggeri <fruggeri@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:42600 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102Ab2ALGbz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2012 01:31:55 -0500
Received: by wibhm14 with SMTP id hm14so952360wib.19
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2012 22:31:54 -0800 (PST)
In-Reply-To: <CA+HUmGhJ-YvFMRnKzb8RqH6COZ=erp1SajVcb1rq1vi2k9OBGw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 11 janvier 2012 =C3=A0 18:13 -0800, Francesco Ruggeri a =C3=
=A9crit :
> We have hit a race condition in ipv6 code when setting
> /proc/sys/net/ipv6/conf/*/forwarding. This happens when the syscall
> has to be restarted.
>=20
> I wonder if anyone else has run into the same issue.
>=20
> The current sequence in addrconf_sysctl_forward() and
> addrconf_fixup_forwarding()  is as follows:
> - change the parameter in idev->cnf.forwarding (using proc_dointvec()=
)
> - try to get the rtnl lock
> - if cannot get the lock then restore the original value in
> idev->cnf.forwarding and restart the syscall.
>=20
> While this is going on, the ipv6 code may access idev->cnf.forwarding
> and get an incorrect value.
> In our case we were in addrconf_ifdown (holding the rtnl lock)  and
> calling __ipv6_ifa_notify(RTM_DELADDR, ifa) on the idev->addr_list
> entries.
> __ipv6_ifa_notify() only invokes addrconf_leave_anycast() if
> idev->cnf.forwarding is set. Because a process trying to set
> forwarding to 0 was stuck in the restart_syscall sequence above
> flipping the flag on and off, we erroneously read the flag as 0, with
> the result that addrconf_leave_anycast() was not invoked, some
> idev->ac_list entries were never released, idev was never freed and
> kept a reference to its net_device, and the net_device was never free=
d
> and caused the "unregister_netdevice: waiting for xxx to become free"
> message forever. In our case this was a vlan interfaces that was bein=
g
> deleted, so we ended up getting stuck in vlan_ioctl_handler() holding
> vlan_ioctl_mutex with further bad consequences.
> The following diffs (for 2.6.38, but the same logic seems to be used
> in 3.2) address the issue by modifying idev->cnf.forwarding only afte=
r
> the rtnl lock is acquired. There is a similar situation for
> disable_ipv6.
> Any comments are appreciated.
>=20
> Francesco Ruggeri

Real question is : why are we using this horrible thing at all

if (!rtnl_trylock())
	return restart_syscall();
