From: Francesco Ruggeri <fruggeri@aristanetworks.com>
Subject: Re: Race condition in ipv6 code
Date: Fri, 13 Jan 2012 14:02:46 -0800
Message-ID: <CA+HUmGhzOe6AR8uJw52KfBY_EEzvB3A-S-L5iPq3QYX=2bC3BA@mail.gmail.com>
References: <CA+HUmGhJ-YvFMRnKzb8RqH6COZ=erp1SajVcb1rq1vi2k9OBGw@mail.gmail.com>
	<m1ty40tn83.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.ne>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:36612 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755782Ab2AMWCt convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jan 2012 17:02:49 -0500
Received: by obcva7 with SMTP id va7so2779984obc.19
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2012 14:02:48 -0800 (PST)
In-Reply-To: <m1ty40tn83.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks.
I will submit a patch in a few days, then you guys can decide if you
want to go for a more comprehensive approach.

=46rancesco

On Thu, Jan 12, 2012 at 5:17 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> Francesco Ruggeri <fruggeri@aristanetworks.com> writes:
>
>> We have hit a race condition in ipv6 code when setting
>> /proc/sys/net/ipv6/conf/*/forwarding. This happens when the syscall
>> has to be restarted.
>>
>> I wonder if anyone else has run into the same issue.
>>
>> The current sequence in addrconf_sysctl_forward() and
>> addrconf_fixup_forwarding()=A0 is as follows:
>> - change the parameter in idev->cnf.forwarding (using proc_dointvec(=
))
>> - try to get the rtnl lock
>> - if cannot get the lock then restore the original value in
>> idev->cnf.forwarding and restart the syscall.
>>
>> While this is going on, the ipv6 code may access idev->cnf.forwardin=
g
>> and get an incorrect value.
>> In our case we were in addrconf_ifdown (holding the rtnl lock)=A0 an=
d
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
>
> Interesting. =A0So ultimately the problem is not the syscall restart
> although that exacerbates it, the problem is that we expect
> idev->cnf.forwarding to be protected by the rtnl_lock and it is not.
>
> At first read through your patch looks good. =A0I am a bit worried th=
at
> we have some versions of the value: aka
> net->ipv6.devconf_dflt->forwarding not protected by the rtnl_lock
> and other version of the value protected by the rtnl_lock.
>
> That just seems confusing.
>
> We can't hold the rtnl_lock around proc_dointvec because that can sle=
ep
> indefinitely in copy_from_user. =A0So it looks like your change to cr=
eate
> a temporary ctl_table and call proc_dointvec seems very reasonable,
> and necessary however we do this.
>
> I don't know if there are other places that need the rtnl_lock that
> but your patch below looks like it makes things better for all of
> the right reasons. =A0So on that score.
>
> Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>
>
> Unless someone wants to volunteer to sort out the impedance mismatch
> between these tunables and the sysctl infrastructure. =A0I suggest
> you resend this patch to David with [PATCH] in the subject line.
>
> I would also suggest a little clearer description why
> idev->cnf.forwarding and idev->cnf.disable_ipv6 need rntl_lock
> protection.
>
> But overall this looks like a pretty obvious bug fix, to the
> problem that we need the rtnl_lock to protect idev->cnf.forwarding,
> and we currently allow updates to idev->cnf.forwarding without
> holding the rtnl_lock.
>
> Eric
>
>
>> Francesco Ruggeri
>>
>>
>> --- a/net/ipv6/addrconf.c =A0 =A02011-03-14 18:20:32.000000000 -0700
>> +++ b/net/ipv6/addrconf.c =A0 =A02012-01-10 12:56:01.458880292 -0800
>> @@ -507,29 +507,31 @@ static void addrconf_forward_change(stru
>> =A0 =A0 =A0rcu_read_unlock();
>> =A0}
>>
>> -static int addrconf_fixup_forwarding(struct ctl_table *table, int *=
p, int old)
>> +static int addrconf_fixup_forwarding(struct ctl_table *table, int *=
p, int newf)
>> =A0{
>> =A0 =A0 =A0struct net *net;
>> + =A0 =A0int old;
>>
>> =A0 =A0 =A0net =3D (struct net *)table->extra2;
>> - =A0 =A0if (p =3D=3D &net->ipv6.devconf_dflt->forwarding)
>> + =A0 =A0if (p =3D=3D &net->ipv6.devconf_dflt->forwarding) {
>> + =A0 =A0 =A0 =A0*p =3D newf;
>> =A0 =A0 =A0 =A0 =A0return 0;
>> + =A0 =A0}
>>
>> - =A0 =A0if (!rtnl_trylock()) {
>> - =A0 =A0 =A0 =A0/* Restore the original values before restarting */
>> - =A0 =A0 =A0 =A0*p =3D old;
>> + =A0 =A0if (!rtnl_trylock())
>> =A0 =A0 =A0 =A0 =A0return restart_syscall();
>> - =A0 =A0}
>> +
>> + =A0 =A0old =3D *p;
>> + =A0 =A0*p =3D newf;
>>
>> =A0 =A0 =A0if (p =3D=3D &net->ipv6.devconf_all->forwarding) {
>> - =A0 =A0 =A0 =A0__s32 newf =3D net->ipv6.devconf_all->forwarding;
>> =A0 =A0 =A0 =A0 =A0net->ipv6.devconf_dflt->forwarding =3D newf;
>> =A0 =A0 =A0 =A0 =A0addrconf_forward_change(net, newf);
>> - =A0 =A0} else if ((!*p) ^ (!old))
>> + =A0 =A0} else if ((!newf) ^ (!old))
>> =A0 =A0 =A0 =A0 =A0dev_forward_change((struct inet6_dev *)table->ext=
ra1);
>> =A0 =A0 =A0rtnl_unlock();
>>
>> - =A0 =A0if (*p)
>> + =A0 =A0if (newf)
>> =A0 =A0 =A0 =A0 =A0rt6_purge_dflt_routers(net);
>> =A0 =A0 =A0return 1;
>> =A0}
>> @@ -4165,9 +4167,17 @@ int addrconf_sysctl_forward(ctl_table *c
>> =A0 =A0 =A0int *valp =3D ctl->data;
>> =A0 =A0 =A0int val =3D *valp;
>> =A0 =A0 =A0loff_t pos =3D *ppos;
>> + =A0 =A0ctl_table lctl;
>> =A0 =A0 =A0int ret;
>>
>> - =A0 =A0ret =3D proc_dointvec(ctl, write, buffer, lenp, ppos);
>> + =A0 =A0/*
>> + =A0 =A0 * ctl->data points to idev->cnf.forwarding, we should
>> + =A0 =A0 * not modify it until we get the rtnl lock.
>> + =A0 =A0 */
>> + =A0 =A0lctl =3D *ctl;
>> + =A0 =A0lctl.data =3D &val;
>> +
>> + =A0 =A0ret =3D proc_dointvec(&lctl, write, buffer, lenp, ppos);
>>
>> =A0 =A0 =A0if (write)
>> =A0 =A0 =A0 =A0 =A0ret =3D addrconf_fixup_forwarding(ctl, valp, val)=
;
>> @@ -4205,26 +4215,28 @@ static void addrconf_disable_change(stru
>> =A0 =A0 =A0rcu_read_unlock();
>> =A0}
>>
>> -static int addrconf_disable_ipv6(struct ctl_table *table, int *p, i=
nt old)
>> +static int addrconf_disable_ipv6(struct ctl_table *table, int *p, i=
nt newf)
>> =A0{
>> =A0 =A0 =A0struct net *net;
>> + =A0 =A0int old;
>>
>> =A0 =A0 =A0net =3D (struct net *)table->extra2;
>>
>> - =A0 =A0if (p =3D=3D &net->ipv6.devconf_dflt->disable_ipv6)
>> + =A0 =A0if (p =3D=3D &net->ipv6.devconf_dflt->disable_ipv6) {
>> + =A0 =A0 =A0 =A0*p =3D newf;
>> =A0 =A0 =A0 =A0 =A0return 0;
>> + =A0 =A0}
>>
>> - =A0 =A0if (!rtnl_trylock()) {
>> - =A0 =A0 =A0 =A0/* Restore the original values before restarting */
>> - =A0 =A0 =A0 =A0*p =3D old;
>> + =A0 =A0if (!rtnl_trylock())
>> =A0 =A0 =A0 =A0 =A0return restart_syscall();
>> - =A0 =A0}
>> +
>> + =A0 =A0old =3D *p;
>> + =A0 =A0*p =3D newf;
>>
>> =A0 =A0 =A0if (p =3D=3D &net->ipv6.devconf_all->disable_ipv6) {
>> - =A0 =A0 =A0 =A0__s32 newf =3D net->ipv6.devconf_all->disable_ipv6;
>> =A0 =A0 =A0 =A0 =A0net->ipv6.devconf_dflt->disable_ipv6 =3D newf;
>> =A0 =A0 =A0 =A0 =A0addrconf_disable_change(net, newf);
>> - =A0 =A0} else if ((!*p) ^ (!old))
>> + =A0 =A0} else if ((!newf) ^ (!old))
>> =A0 =A0 =A0 =A0 =A0dev_disable_change((struct inet6_dev *)table->ext=
ra1);
>>
>> =A0 =A0 =A0rtnl_unlock();
>> @@ -4238,9 +4250,17 @@ int addrconf_sysctl_disable(ctl_table *c
>> =A0 =A0 =A0int *valp =3D ctl->data;
>> =A0 =A0 =A0int val =3D *valp;
>> =A0 =A0 =A0loff_t pos =3D *ppos;
>> + =A0 =A0ctl_table lctl;
>> =A0 =A0 =A0int ret;
>>
>> - =A0 =A0ret =3D proc_dointvec(ctl, write, buffer, lenp, ppos);
>> + =A0 =A0/*
>> + =A0 =A0 * ctl->data points to idev->cnf.disable_ipv6, we should
>> + =A0 =A0 * not modify it until we get the rtnl lock.
>> + =A0 =A0 */
>> + =A0 =A0lctl =3D *ctl;
>> + =A0 =A0lctl.data =3D &val;
>> +
>> + =A0 =A0ret =3D proc_dointvec(&lctl, write, buffer, lenp, ppos);
>>
>> =A0 =A0 =A0if (write)
>> =A0 =A0 =A0 =A0 =A0ret =3D addrconf_disable_ipv6(ctl, valp, val);
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
