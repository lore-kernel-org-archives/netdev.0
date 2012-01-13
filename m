From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Race condition in ipv6 code
Date: Thu, 12 Jan 2012 17:17:32 -0800
Message-ID: <m1ty40tn83.fsf@fess.ebiederm.org>
References: <CA+HUmGhJ-YvFMRnKzb8RqH6COZ=erp1SajVcb1rq1vi2k9OBGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.ne>
To: Francesco Ruggeri <fruggeri@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:47523 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756312Ab2AMBPM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2012 20:15:12 -0500
In-Reply-To: <CA+HUmGhJ-YvFMRnKzb8RqH6COZ=erp1SajVcb1rq1vi2k9OBGw@mail.gmail.com>
	(Francesco Ruggeri's message of "Wed, 11 Jan 2012 18:13:55 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rancesco Ruggeri <fruggeri@aristanetworks.com> writes:

> We have hit a race condition in ipv6 code when setting
> /proc/sys/net/ipv6/conf/*/forwarding. This happens when the syscall
> has to be restarted.
>
> I wonder if anyone else has run into the same issue.
>
> The current sequence in addrconf_sysctl_forward() and
> addrconf_fixup_forwarding()=C2=A0 is as follows:
> - change the parameter in idev->cnf.forwarding (using proc_dointvec()=
)
> - try to get the rtnl lock
> - if cannot get the lock then restore the original value in
> idev->cnf.forwarding and restart the syscall.
>
> While this is going on, the ipv6 code may access idev->cnf.forwarding
> and get an incorrect value.
> In our case we were in addrconf_ifdown (holding the rtnl lock)=C2=A0 =
and
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

Interesting.  So ultimately the problem is not the syscall restart
although that exacerbates it, the problem is that we expect=20
idev->cnf.forwarding to be protected by the rtnl_lock and it is not.

At first read through your patch looks good.  I am a bit worried that
we have some versions of the value: aka
net->ipv6.devconf_dflt->forwarding not protected by the rtnl_lock
and other version of the value protected by the rtnl_lock.

That just seems confusing.

We can't hold the rtnl_lock around proc_dointvec because that can sleep
indefinitely in copy_from_user.  So it looks like your change to create
a temporary ctl_table and call proc_dointvec seems very reasonable,
and necessary however we do this.

I don't know if there are other places that need the rtnl_lock that
but your patch below looks like it makes things better for all of
the right reasons.  So on that score.

Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>

Unless someone wants to volunteer to sort out the impedance mismatch
between these tunables and the sysctl infrastructure.  I suggest
you resend this patch to David with [PATCH] in the subject line.

I would also suggest a little clearer description why
idev->cnf.forwarding and idev->cnf.disable_ipv6 need rntl_lock
protection.

But overall this looks like a pretty obvious bug fix, to the
problem that we need the rtnl_lock to protect idev->cnf.forwarding,
and we currently allow updates to idev->cnf.forwarding without
holding the rtnl_lock.=20

Eric


> Francesco Ruggeri
>
>
> --- a/net/ipv6/addrconf.c    2011-03-14 18:20:32.000000000 -0700
> +++ b/net/ipv6/addrconf.c    2012-01-10 12:56:01.458880292 -0800
> @@ -507,29 +507,31 @@ static void addrconf_forward_change(stru
>      rcu_read_unlock();
>  }
>
> -static int addrconf_fixup_forwarding(struct ctl_table *table, int *p=
, int old)
> +static int addrconf_fixup_forwarding(struct ctl_table *table, int *p=
, int newf)
>  {
>      struct net *net;
> +    int old;
>
>      net =3D (struct net *)table->extra2;
> -    if (p =3D=3D &net->ipv6.devconf_dflt->forwarding)
> +    if (p =3D=3D &net->ipv6.devconf_dflt->forwarding) {
> +        *p =3D newf;
>          return 0;
> +    }
>
> -    if (!rtnl_trylock()) {
> -        /* Restore the original values before restarting */
> -        *p =3D old;
> +    if (!rtnl_trylock())
>          return restart_syscall();
> -    }
> +
> +    old =3D *p;
> +    *p =3D newf;
>
>      if (p =3D=3D &net->ipv6.devconf_all->forwarding) {
> -        __s32 newf =3D net->ipv6.devconf_all->forwarding;
>          net->ipv6.devconf_dflt->forwarding =3D newf;
>          addrconf_forward_change(net, newf);
> -    } else if ((!*p) ^ (!old))
> +    } else if ((!newf) ^ (!old))
>          dev_forward_change((struct inet6_dev *)table->extra1);
>      rtnl_unlock();
>
> -    if (*p)
> +    if (newf)
>          rt6_purge_dflt_routers(net);
>      return 1;
>  }
> @@ -4165,9 +4167,17 @@ int addrconf_sysctl_forward(ctl_table *c
>      int *valp =3D ctl->data;
>      int val =3D *valp;
>      loff_t pos =3D *ppos;
> +    ctl_table lctl;
>      int ret;
>
> -    ret =3D proc_dointvec(ctl, write, buffer, lenp, ppos);
> +    /*
> +     * ctl->data points to idev->cnf.forwarding, we should
> +     * not modify it until we get the rtnl lock.
> +     */
> +    lctl =3D *ctl;
> +    lctl.data =3D &val;
> +
> +    ret =3D proc_dointvec(&lctl, write, buffer, lenp, ppos);
>
>      if (write)
>          ret =3D addrconf_fixup_forwarding(ctl, valp, val);
> @@ -4205,26 +4215,28 @@ static void addrconf_disable_change(stru
>      rcu_read_unlock();
>  }
>
> -static int addrconf_disable_ipv6(struct ctl_table *table, int *p, in=
t old)
> +static int addrconf_disable_ipv6(struct ctl_table *table, int *p, in=
t newf)
>  {
>      struct net *net;
> +    int old;
>
>      net =3D (struct net *)table->extra2;
>
> -    if (p =3D=3D &net->ipv6.devconf_dflt->disable_ipv6)
> +    if (p =3D=3D &net->ipv6.devconf_dflt->disable_ipv6) {
> +        *p =3D newf;
>          return 0;
> +    }
>
> -    if (!rtnl_trylock()) {
> -        /* Restore the original values before restarting */
> -        *p =3D old;
> +    if (!rtnl_trylock())
>          return restart_syscall();
> -    }
> +
> +    old =3D *p;
> +    *p =3D newf;
>
>      if (p =3D=3D &net->ipv6.devconf_all->disable_ipv6) {
> -        __s32 newf =3D net->ipv6.devconf_all->disable_ipv6;
>          net->ipv6.devconf_dflt->disable_ipv6 =3D newf;
>          addrconf_disable_change(net, newf);
> -    } else if ((!*p) ^ (!old))
> +    } else if ((!newf) ^ (!old))
>          dev_disable_change((struct inet6_dev *)table->extra1);
>
>      rtnl_unlock();
> @@ -4238,9 +4250,17 @@ int addrconf_sysctl_disable(ctl_table *c
>      int *valp =3D ctl->data;
>      int val =3D *valp;
>      loff_t pos =3D *ppos;
> +    ctl_table lctl;
>      int ret;
>
> -    ret =3D proc_dointvec(ctl, write, buffer, lenp, ppos);
> +    /*
> +     * ctl->data points to idev->cnf.disable_ipv6, we should
> +     * not modify it until we get the rtnl lock.
> +     */
> +    lctl =3D *ctl;
> +    lctl.data =3D &val;
> +
> +    ret =3D proc_dointvec(&lctl, write, buffer, lenp, ppos);
>
>      if (write)
>          ret =3D addrconf_disable_ipv6(ctl, valp, val);
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
