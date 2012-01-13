From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Race condition in ipv6 code
Date: Thu, 12 Jan 2012 17:57:58 -0800
Message-ID: <20120112175758.773c8e85@nehalam.linuxnetplumber.net>
References: <CA+HUmGhJ-YvFMRnKzb8RqH6COZ=erp1SajVcb1rq1vi2k9OBGw@mail.gmail.com>
	<m1ty40tn83.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francesco Ruggeri <fruggeri@aristanetworks.com>,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.ne>
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41926 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756799Ab2AMB6B convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2012 20:58:01 -0500
In-Reply-To: <m1ty40tn83.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Jan 2012 17:17:32 -0800
ebiederm@xmission.com (Eric W. Biederman) wrote:

> Francesco Ruggeri <fruggeri@aristanetworks.com> writes:
>=20
> > We have hit a race condition in ipv6 code when setting
> > /proc/sys/net/ipv6/conf/*/forwarding. This happens when the syscall
> > has to be restarted.
> >
> > I wonder if anyone else has run into the same issue.
> >
> > The current sequence in addrconf_sysctl_forward() and
> > addrconf_fixup_forwarding()=A0 is as follows:
> > - change the parameter in idev->cnf.forwarding (using proc_dointvec=
())
> > - try to get the rtnl lock
> > - if cannot get the lock then restore the original value in
> > idev->cnf.forwarding and restart the syscall.
> >
> > While this is going on, the ipv6 code may access idev->cnf.forwardi=
ng
> > and get an incorrect value.
> > In our case we were in addrconf_ifdown (holding the rtnl lock)=A0 a=
nd
> > calling __ipv6_ifa_notify(RTM_DELADDR, ifa) on the idev->addr_list
> > entries.
> > __ipv6_ifa_notify() only invokes addrconf_leave_anycast() if
> > idev->cnf.forwarding is set. Because a process trying to set
> > forwarding to 0 was stuck in the restart_syscall sequence above
> > flipping the flag on and off, we erroneously read the flag as 0, wi=
th
> > the result that addrconf_leave_anycast() was not invoked, some
> > idev->ac_list entries were never released, idev was never freed and
> > kept a reference to its net_device, and the net_device was never fr=
eed
> > and caused the "unregister_netdevice: waiting for xxx to become fre=
e"
> > message forever. In our case this was a vlan interfaces that was be=
ing
> > deleted, so we ended up getting stuck in vlan_ioctl_handler() holdi=
ng
> > vlan_ioctl_mutex with further bad consequences.
> > The following diffs (for 2.6.38, but the same logic seems to be use=
d
> > in 3.2) address the issue by modifying idev->cnf.forwarding only af=
ter
> > the rtnl lock is acquired. There is a similar situation for
> > disable_ipv6.
> > Any comments are appreciated.
>=20
> Interesting.  So ultimately the problem is not the syscall restart
> although that exacerbates it, the problem is that we expect=20
> idev->cnf.forwarding to be protected by the rtnl_lock and it is not.
>=20
> At first read through your patch looks good.  I am a bit worried that
> we have some versions of the value: aka
> net->ipv6.devconf_dflt->forwarding not protected by the rtnl_lock
> and other version of the value protected by the rtnl_lock.
>=20
> That just seems confusing.
>=20
> We can't hold the rtnl_lock around proc_dointvec because that can sle=
ep
> indefinitely in copy_from_user.  So it looks like your change to crea=
te
> a temporary ctl_table and call proc_dointvec seems very reasonable,
> and necessary however we do this.
>=20
> I don't know if there are other places that need the rtnl_lock that
> but your patch below looks like it makes things better for all of
> the right reasons.  So on that score.
>=20
> Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>
>=20
> Unless someone wants to volunteer to sort out the impedance mismatch
> between these tunables and the sysctl infrastructure.  I suggest
> you resend this patch to David with [PATCH] in the subject line.
>=20
> I would also suggest a little clearer description why
> idev->cnf.forwarding and idev->cnf.disable_ipv6 need rntl_lock
> protection.
>=20
> But overall this looks like a pretty obvious bug fix, to the
> problem that we need the rtnl_lock to protect idev->cnf.forwarding,
> and we currently allow updates to idev->cnf.forwarding without
> holding the rtnl_lock.=20
>=20
> Eric
>=20

Looks like a better function (proc_doint_rtnl?) needs to be built
that has the locking in the right place. I.e:
  get value from user
  get lock (with restart)
  do changes
  unlock
