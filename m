From: Francesco Ruggeri <fruggeri@aristanetworks.com>
Subject: Re: Race condition in ipv6 code
Date: Thu, 12 Jan 2012 12:48:11 -0800
Message-ID: <CA+HUmGhURzDX9Sa98S65sVGNu5FsvmHsRz15OvqzKQuGXre04g@mail.gmail.com>
References: <CA+HUmGhJ-YvFMRnKzb8RqH6COZ=erp1SajVcb1rq1vi2k9OBGw@mail.gmail.com>
	<1326349911.2741.1.camel@edumazet-laptop>
	<20120111.224429.1750818553057090631.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:38893 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755378Ab2ALUsL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2012 15:48:11 -0500
Received: by iabz25 with SMTP id z25so3228468iab.19
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2012 12:48:11 -0800 (PST)
In-Reply-To: <20120111.224429.1750818553057090631.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am not familiar with the process, how can one submit a patch for
inclusion in future releases?

On a related note, and independently of the race condition, the return
value of proc_dointvec() in addrconf_sysctl_forward() should be
checked or incorrect situations like the following could occur:

1) User successfully sets all/forwarding to 1.
2) User successfully sets eth1/forwarding to 0.
3) User tries to set all/forwarding to 0, but proc_dointvec() fails,
so addrconf_fixup_forwarding() is invoked with both old and new value
as 1. addrconf_forward_change() then executes with a new value of 1,
and it sets the value to 1 for all idevs where the value is 0.
So the result of proc_dointvec() failing when writing 0 to
all/forwarding is that the value of eth1/forwarding is changed back to
1.

Thanks,
=46rancesco Ruggeri


On Wed, Jan 11, 2012 at 10:44 PM, David Miller <davem@davemloft.net> wr=
ote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 12 Jan 2012 07:31:51 +0100
>
>> Real question is : why are we using this horrible thing at all
>>
>> if (!rtnl_trylock())
>> =A0 =A0 =A0 return restart_syscall();
>
> Because:
>
> --------------------
> commit 88af182e389097997c5e2a0b42285b3522796759
> Author: Eric W. Biederman <ebiederm@xmission.com>
> Date: =A0 Fri Feb 19 13:22:59 2010 +0000
>
> =A0 =A0net: Fix sysctl restarts...
>
> =A0 =A0Yuck. =A0It turns out that when we restart sysctls we were res=
tarting
> =A0 =A0with the values already changed. =A0Which unfortunately meant =
that
> =A0 =A0the second time through we thought there was no change and ski=
pped
> =A0 =A0all kinds of work, despite the fact that there was indeed a ch=
ange.
>
> =A0 =A0I have fixed this the simplest way possible by restoring the c=
hanged
> =A0 =A0values when we restart the sysctl write.
>
> =A0 =A0One of my coworkers spotted this bug when after disabling forw=
arding
> =A0 =A0on an interface pings were still forwarded.
>
> =A0 =A0Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> =A0 =A0Signed-off-by: David S. Miller <davem@davemloft.net>
>
> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
> index 040c4f0..26dec2b 100644
> --- a/net/ipv4/devinet.c
> +++ b/net/ipv4/devinet.c
> @@ -1317,14 +1317,19 @@ static int devinet_sysctl_forward(ctl_table *=
ctl, int write,
> =A0{
> =A0 =A0 =A0 =A0int *valp =3D ctl->data;
> =A0 =A0 =A0 =A0int val =3D *valp;
> + =A0 =A0 =A0 loff_t pos =3D *ppos;
> =A0 =A0 =A0 =A0int ret =3D proc_dointvec(ctl, write, buffer, lenp, pp=
os);
>
> =A0 =A0 =A0 =A0if (write && *valp !=3D val) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct net *net =3D ctl->extra2;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (valp !=3D &IPV4_DEVCONF_DFLT(net, =
=46ORWARDING)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!rtnl_trylock())
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!rtnl_trylock()) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Rest=
ore the original values before restarting */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *valp =3D=
 val;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *ppos =3D=
 pos;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return=
 restart_syscall();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (valp =3D=3D &IPV4_=
DEVCONF_ALL(net, FORWARDING)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0inet_f=
orward_change(net);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else if (*valp) {
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index de7a194..143791d 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -502,8 +502,11 @@ static int addrconf_fixup_forwarding(struct ctl_=
table *table, int *p, int old)
> =A0 =A0 =A0 =A0if (p =3D=3D &net->ipv6.devconf_dflt->forwarding)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
>
> - =A0 =A0 =A0 if (!rtnl_trylock())
> + =A0 =A0 =A0 if (!rtnl_trylock()) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Restore the original values before r=
estarting */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 *p =3D old;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return restart_syscall();
> + =A0 =A0 =A0 }
>
> =A0 =A0 =A0 =A0if (p =3D=3D &net->ipv6.devconf_all->forwarding) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__s32 newf =3D net->ipv6.devconf_all->=
forwarding;
> @@ -4028,12 +4031,15 @@ int addrconf_sysctl_forward(ctl_table *ctl, i=
nt write,
> =A0{
> =A0 =A0 =A0 =A0int *valp =3D ctl->data;
> =A0 =A0 =A0 =A0int val =3D *valp;
> + =A0 =A0 =A0 loff_t pos =3D *ppos;
> =A0 =A0 =A0 =A0int ret;
>
> =A0 =A0 =A0 =A0ret =3D proc_dointvec(ctl, write, buffer, lenp, ppos);
>
> =A0 =A0 =A0 =A0if (write)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D addrconf_fixup_forwarding(ctl,=
 valp, val);
> + =A0 =A0 =A0 if (ret)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 *ppos =3D pos;
> =A0 =A0 =A0 =A0return ret;
> =A0}
>
> @@ -4075,8 +4081,11 @@ static int addrconf_disable_ipv6(struct ctl_ta=
ble *table, int *p, int old)
> =A0 =A0 =A0 =A0if (p =3D=3D &net->ipv6.devconf_dflt->disable_ipv6)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
>
> - =A0 =A0 =A0 if (!rtnl_trylock())
> + =A0 =A0 =A0 if (!rtnl_trylock()) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Restore the original values before r=
estarting */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 *p =3D old;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return restart_syscall();
> + =A0 =A0 =A0 }
>
> =A0 =A0 =A0 =A0if (p =3D=3D &net->ipv6.devconf_all->disable_ipv6) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__s32 newf =3D net->ipv6.devconf_all->=
disable_ipv6;
> @@ -4095,12 +4104,15 @@ int addrconf_sysctl_disable(ctl_table *ctl, i=
nt write,
> =A0{
> =A0 =A0 =A0 =A0int *valp =3D ctl->data;
> =A0 =A0 =A0 =A0int val =3D *valp;
> + =A0 =A0 =A0 loff_t pos =3D *ppos;
> =A0 =A0 =A0 =A0int ret;
>
> =A0 =A0 =A0 =A0ret =3D proc_dointvec(ctl, write, buffer, lenp, ppos);
>
> =A0 =A0 =A0 =A0if (write)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D addrconf_disable_ipv6(ctl, val=
p, val);
> + =A0 =A0 =A0 if (ret)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 *ppos =3D pos;
> =A0 =A0 =A0 =A0return ret;
> =A0}
>
