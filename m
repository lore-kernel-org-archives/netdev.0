From: kernel coder <kernelcoder2@gmail.com>
Subject: Re: tunnel creation: using fb_tnl_dev inside struct ip6_tnl_net
Date: Thu, 10 Jun 2010 10:12:59 -0700
Message-ID: <AANLkTinVcGweufTn2TvgcpPqf9-ToqFjmn6kZYAMH2T8@mail.gmail.com>
References: <AANLkTimymJK6qY7rUxkyQzrlKXCgxm5uYLaxqC2IOyM_@mail.gmail.com>
	<AANLkTil_o71Qz2y9UJGw4uKVNQAOlYBVQLRjYtghyrni@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:34212 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753117Ab0FJRNB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jun 2010 13:13:01 -0400
Received: by wwb18 with SMTP id 18so90412wwb.19
        for <netdev@vger.kernel.org>; Thu, 10 Jun 2010 10:12:59 -0700 (PDT)
In-Reply-To: <AANLkTil_o71Qz2y9UJGw4uKVNQAOlYBVQLRjYtghyrni@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I need to port some code from linux kernel 2.6.18 to kernel 2.6.29.
One of the file where changes are involved is <net/ipv6/ip6_tunnel.c>,
where a new structure struct ip6_tnl_net was added into kernel2.6.29
that didn't exist in 2.6.18 as follows:

struct ip6_tnl_net {
=A0 =A0 =A0 =A0/* the IPv6 tunnel fallback device */
=A0 =A0 =A0 =A0struct net_device *fb_tnl_dev;
=A0 =A0 =A0 =A0/* lists for storing tunnels in use */
=A0 =A0 =A0 =A0struct ip6_tnl *tnls_r_l[HASH_SIZE];
=A0 =A0 =A0 =A0struct ip6_tnl *tnls_wc[1];
=A0 =A0 =A0 =A0struct ip6_tnl **tnls[2];

};

All those fields in struct ip6_tnl_net were in global namespace in
2.6.18, but wrapped in this struct for some reason (what benefit does
this gain?)

2.6.18 code in function ip6_tunnel_init() works fine as follows. After
being ported to kernel 2.6.29 as shown below, after kernel/module
build, install, reboot hangs. I inserted some printk message as shown,
only 111111 to 44444 were displayed, which indicates that
"register_netdev(ip6n->fb_tnl_dev)" failed.

Any inputs? Thanks.

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3DKernel 2.6.=
18 code, works fine=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D
static int __init ip6_tunnel_init(void)
{
=A0 =A0 =A0 =A0int =A0err;
=A0 =A0struct =A0ip6_tnl *tun0;

=A0 =A0 =A0 =A0if (xfrm6_tunnel_register(&ip6ip6_handler)) {
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printk(KERN_ERR "ip6ip6 init: can't regi=
ster tunnel\n");
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EAGAIN;
=A0 =A0 =A0 =A0}
=A0 =A0 =A0 =A0ip6ip6_fb_tnl_dev =3D alloc_netdev(sizeof(struct ip6_tnl=
), "ip6tnl0",
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 ip6ip6_tnl_dev_setup);

=A0 =A0 =A0 =A0if (!ip6ip6_fb_tnl_dev) {
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D -ENOMEM;
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto fail;
=A0 =A0 =A0 =A0}
=A0 =A0 =A0 =A0ip6ip6_fb_tnl_dev->init =3D ip6ip6_fb_tnl_dev_init;

=A0 =A0 =A0 =A0if ((err =3D register_netdev(ip6ip6_fb_tnl_dev))) {
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0free_netdev(ip6ip6_fb_tnl_dev);
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto fail;
=A0 =A0 =A0 =A0}
=A0 =A0tun0 =3D ip6ip6_fb_tnl_dev->priv;
=A0 =A0tun0->parms.flags |=3D (IP6_TNL_F_CAP_XMIT | IP6_TNL_F_CAP_RCV);
=A0 =A0 =A0 =A0return 0;
fail:
=A0 =A0 =A0 =A0xfrm6_tunnel_deregister(&ip6ip6_handler);
=A0 =A0 =A0 =A0return err;

}

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3Dmodified Kernel 2.6.=
29 code, buggy=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
static int __init ip6_tunnel_init(void)
{
=A0 =A0 =A0 =A0int err;
=A0 =A0 =A0 =A0struct ip6_tnl_net *ip6n; /*added due to kernel struct c=
hange*/
=A0 =A0 =A0 =A0struct ip6_tnl *tun0; =A0 /*added 06082010*/

=A0 =A0 =A0 =A0if (xfrm6_tunnel_register(&ip4ip6_handler, AF_INET)) {
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printk(KERN_ERR "ip6_tunnel init: can't =
register ip4ip6\n");
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D -EAGAIN;
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
=A0 =A0 =A0 =A0}

=A0 =A0 =A0 =A0if (xfrm6_tunnel_register(&ip6ip6_handler, AF_INET6)) {
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printk(KERN_ERR "ip6_tunnel init: can't =
register ip6ip6\n");
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D -EAGAIN;
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto unreg_ip4ip6;
=A0 =A0 =A0 =A0}

=A0 =A0 =A0 =A0err =3D register_pernet_gen_device(&ip6_tnl_net_id, &ip6=
_tnl_net_ops);
=A0 =A0 =A0 =A0if (err < 0)
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto err_pernet;
=A0 =A0 =A0 =A0printk(KERN_ERR "=3D=3D=3D=3D=3D=3D=3D=3D=3D111111111111=
1111111=3D=3D=3D=3D=3D=3D=3D=3D\n");

=A0 =A0 =A0 =A0//alloc_netdev() and init the device, added
=A0 =A0 =A0 =A0err =3D -ENOMEM;
=A0 =A0 =A0 =A0ip6n =3D kzalloc(sizeof(struct ip6_tnl_net), GFP_KERNEL)=
;
=A0 =A0 =A0 =A0if (ip6n =3D=3D NULL)
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;

=A0 =A0 =A0 =A0ip6n->fb_tnl_dev =3D alloc_netdev(sizeof(struct ip6_tnl)=
, "ip6tnl0",
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 ip6_tnl_dev_setup);
=A0 =A0 =A0 =A0printk(KERN_ERR "=3D=3D=3D=3D=3D=3D=3D222222222222222222=
=3D=3D=3D=3D=3D=3D=3D=3D=3D\n");
=A0 =A0 =A0 =A0if (!ip6n->fb_tnl_dev) {
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D -ENOMEM;
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
=A0 =A0 =A0 =A0}
printk(KERN_ERR "=3D=3D=3D=3D=3D=3D=3D=3D=3D3333333333333333333=3D=3D=3D=
=3D=3D=3D=3D=3D\n");

=A0 =A0 =A0 =A0ip6n->fb_tnl_dev->init =3D ip6_fb_tnl_dev_init2;
=A0 =A0 =A0 =A0//ip6_fb_tnl_dev_init(ip6n->fb_tnl_dev);
printk(KERN_ERR "=3D=3D=3D=3D=3D=3D=3D=3D=3D4444444444444444444=3D=3D=3D=
=3D=3D=3D=3D=3D\n");

=A0 =A0 =A0 =A0err =3D register_netdev(ip6n->fb_tnl_dev);
=A0 =A0 =A0 =A0if (err<0) {
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0free_netdev(ip6n->fb_tnl_dev);
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto err_pernet;
=A0 =A0 =A0 =A0}
printk(KERN_ERR "=3D=3D=3D=3D=3D=3D=3D=3D=3D555555555555555555=3D=3D=3D=
=3D=3D=3D=3D=3D\n");

// =A0 =A0 =A0tun0 =3D ip6ip6_fb_tnl_dev->priv; =A0 =A0 =A0 =A0 =A0 =A0=
 =A0/*added per patch*/
=A0 =A0 =A0 =A0tun0 =3D netdev_priv(ip6n->fb_tnl_dev); =A0 =A0 =A0 =A0/=
*modified =A0*/
printk(KERN_ERR "=3D=3D=3D=3D=3D=3D=3D=3D=3D666666666666666666=3D=3D=3D=
=3D=3D=3D=3D=3D\n");
=A0 =A0 =A0 =A0tun0->parms.flags |=3D (IP6_TNL_F_CAP_XMIT | IP6_TNL_F_C=
AP_RCV);
printk(KERN_ERR "=3D=3D=3D=3D=3D=3D=3D=3D=3D777777777777777777=3D=3D=3D=
=3D=3D=3D=3D=3D\n");
=A0 =A0 =A0 =A0return 0;

err_pernet:
=A0 =A0 =A0 =A0xfrm6_tunnel_deregister(&ip6ip6_handler, AF_INET6);
printk(KERN_ERR "=3D=3D=3D=3D=3D=3D=3D=3Derr pernet=3D=3D=3D=3D=3D=3D=3D=
=3D=3D\n");
unreg_ip4ip6:
=A0 =A0 =A0 =A0xfrm6_tunnel_deregister(&ip4ip6_handler, AF_INET);
printk(KERN_ERR "=3D=3D=3D=3D=3D=3D=3D=3Derr unreg_ip4ip6=3D=3D=3D=3D=3D=
=3D=3D=3D=3D\n");
out:
printk(KERN_ERR "=3D=3D=3D=3D=3D=3D=3D=3Derr out=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D\n");
=A0 =A0 =A0 =A0return err;
}
