From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] ip_tunnel: the lack of vti_link_ops' dellink() cause
 kernel panic
Date: Mon, 24 Nov 2014 15:18:38 +0100
Message-ID: <54733E3E.7070702@6wind.com>
References: <1416726251-13088-1-git-send-email-lucien.xin@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cong Wang <cwang@twopensource.com>
To: Xin Long <lucien.xin@gmail.com>,
	network dev <netdev@vger.kernel.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:53097 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753741AbaKXOSl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 09:18:41 -0500
Received: by mail-wg0-f43.google.com with SMTP id l18so12459928wgh.2
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2014 06:18:40 -0800 (PST)
In-Reply-To: <1416726251-13088-1-git-send-email-lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 23/11/2014 08:04, Xin Long a =C3=A9crit :
> Now the vti_link_ops do not point the .dellink, for fb tunnel device
> (ip_vti0), the net_device will be removed as the default .dellink is
> unregister_netdevice_queue,but the tunnel still in the tunnel list,
> then if we add a new vti tunnel, in ip_tunnel_find():
>
>          hlist_for_each_entry_rcu(t, head, hash_node) {
>                  if (local =3D=3D t->parms.iph.saddr &&
>                      remote =3D=3D t->parms.iph.daddr &&
>                      link =3D=3D t->parms.link &&
> =3D=3D>                 type =3D=3D t->dev->type &&
>                      ip_tunnel_key_match(&t->parms, flags, key))
>                          break;
>          }
>
> the panic will happen, cause dev of ip_tunnel *t is null:
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
> modprobe ip_vti
> ip link del ip_vti0 type vti
> ip link add ip_vti0 type vti
> rmmod ip_vti
>
> do that one or more times, kernel will panic.
>
> fix it by assigning ip_tunnel_dellink to vti_link_ops' dellink, in
> which we skip the unregister of fb tunnel device. do the same on ip6_=
vti.
>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> Signed-off-by: Cong Wang <cwang@twopensource.com>
> ---
>   net/ipv4/ip_vti.c  |  1 +
>   net/ipv6/ip6_vti.c | 11 +++++++++++
>   2 files changed, 12 insertions(+)
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
Nitpicking: please, use a tab instead of space to align the '=3D', like=
 other
lines.
