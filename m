From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] [net]ip_tunnel: the lack of vti_link_ops' dellink() cause
 kernel panic
Date: Tue, 18 Nov 2014 18:23:31 +0100
Message-ID: <546B8093.4080507@6wind.com>
References: <1416307059-32732-1-git-send-email-lucien.xin@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steffen Klassert <steffen.klassert@secunet.com>
To: Xin Long <lucien.xin@gmail.com>,
	network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:35722 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932092AbaKRRXe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 12:23:34 -0500
Received: by mail-wi0-f170.google.com with SMTP id bs8so7000655wib.5
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 09:23:33 -0800 (PST)
In-Reply-To: <1416307059-32732-1-git-send-email-lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 18/11/2014 11:37, Xin Long a =C3=A9crit :
> Now the vti_link_ops do not point the .dellink, rtnl_newlink will inv=
oke
> the default function, unregister_netdevice_queue, which will cause th=
e
> dev to unregister later. so when we delete a vti device, the net_devi=
ce
> will be removed, but the tunnel still in the tunnel list. then, we ad=
d
> a new vti, in ip_tunnel_find():
>
>          hlist_for_each_entry_rcu(t, head, hash_node) {
>                  if (local =3D=3D t->parms.iph.saddr &&
>                      remote =3D=3D t->parms.iph.daddr &&
>                      link =3D=3D t->parms.link &&
>                      type =3D=3D t->dev->type &&
>                      ip_tunnel_key_match(&t->parms, flags, key))
>                          break;
>          }
>
> the dev of ip_tunnel *t may be null because of unregister_netdevice_q=
ueue
> motioned above. so the panic will happen:
>
> [ 3835.072977] IP: [<ffffffffa04103fd>] ip_tunnel_find+0x9d/0xc0 [ip_=
tunnel]
> [ 3835.073008] PGD b2c21067 PUD b7277067 PMD 0
> [ 3835.073008] Oops: 0000 [#1] SMP
> .....
> [ 3835.073008] Stack:
> [ 3835.073008]  ffff8800b72d77f0 ffffffffa0411924 ffff8800bb956000 ff=
ff8800b72d78e0
> [ 3835.073008]  ffff8800b72d78a0 0000000000000000 ffffffffa040d100 ff=
ff8800b72d7858
> [ 3835.073008]  ffffffffa040b2e3 0000000000000000 0000000000000000 00=
00000000000000
> [ 3835.073008] Call Trace:
> [ 3835.073008]  [<ffffffffa0411924>] ip_tunnel_newlink+0x64/0x160 [ip=
_tunnel]
> [ 3835.073008]  [<ffffffffa040b2e3>] vti_newlink+0x43/0x70 [ip_vti]
> [ 3835.073008]  [<ffffffff8150d4da>] rtnl_newlink+0x4fa/0x5f0
> [ 3835.073008]  [<ffffffff812f68bb>] ? nla_strlcpy+0x5b/0x70
> [ 3835.073008]  [<ffffffff81508fb0>] ? rtnl_link_ops_get+0x40/0x60
> [ 3835.073008]  [<ffffffff8150d11f>] ? rtnl_newlink+0x13f/0x5f0
> [ 3835.073008]  [<ffffffff81509cf4>] rtnetlink_rcv_msg+0xa4/0x270
> [ 3835.073008]  [<ffffffff8126adf5>] ? sock_has_perm+0x75/0x90
> [ 3835.073008]  [<ffffffff81509c50>] ? rtnetlink_rcv+0x30/0x30
> [ 3835.073008]  [<ffffffff81529e39>] netlink_rcv_skb+0xa9/0xc0
> [ 3835.073008]  [<ffffffff81509c48>] rtnetlink_rcv+0x28/0x30
> ....
>
> the reproduction can be like this:
>
> modprobe ip_vti
> ip link del ip_vti0 type vti
> ip link add ip_vti0 type vti
> rmmod ip_vti
>
> do that one or more time, kernel will panic.
>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
A quick look at the ipv6 side seems to show that there is the same prob=
lem. Can
you provide the IPv6 patch too?

Note also that the maintainer of this module is Steffen Klassert, pleas=
e don't
forget to CC him.

> ---
>   net/ipv4/ip_vti.c | 1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
> index 3e86101..1a7e979 100644
> --- a/net/ipv4/ip_vti.c
> +++ b/net/ipv4/ip_vti.c
> @@ -528,6 +528,7 @@ static struct rtnl_link_ops vti_link_ops __read_m=
ostly =3D {
>   	.validate	=3D vti_tunnel_validate,
>   	.newlink	=3D vti_newlink,
>   	.changelink	=3D vti_changelink,
> +	.dellink        =3D ip_tunnel_dellink,
Nitpicking: other lines into this struct uses tabs to align the '=3D', =
but
the one you add uses spaces.


Thank you,
Nicolas
