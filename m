From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH] [net]ip_tunnel: the lack of vti_link_ops' dellink() cause kernel panic
Date: Tue, 25 Nov 2014 13:55:19 +0800
Message-ID: <1416894919-3267-1-git-send-email-lucien.xin@gmail.com>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Xin Long <lucien.xin@gmail.com>,
	Cong Wang <cwang@twopensource.com>
To: network dev <netdev@vger.kernel.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:45294 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751763AbaKYFzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 00:55:36 -0500
Received: by mail-pd0-f169.google.com with SMTP id fp1so11195253pdb.14
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2014 21:55:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now the vti_link_ops do not point the .dellink, for fb tunnel device
(ip_vti0), the net_device will be removed as the default .dellink is
unregister_netdevice_queue,but the tunnel still in the tunnel list,
then if we add a new vti tunnel, in ip_tunnel_find():

        hlist_for_each_entry_rcu(t, head, hash_node) {
                if (local == t->parms.iph.saddr &&
                    remote == t->parms.iph.daddr &&
                    link == t->parms.link &&
==>                 type == t->dev->type &&
                    ip_tunnel_key_match(&t->parms, flags, key))
                        break;
        }

the panic will happen, cause dev of ip_tunnel *t is null:
[ 3835.072977] IP: [<ffffffffa04103fd>] ip_tunnel_find+0x9d/0xc0 [ip_tunnel]
[ 3835.073008] PGD b2c21067 PUD b7277067 PMD 0
[ 3835.073008] Oops: 0000 [#1] SMP
.....
[ 3835.073008] Stack:
[ 3835.073008]  ffff8800b72d77f0 ffffffffa0411924 ffff8800bb956000 ffff8800b72d78e0
[ 3835.073008]  ffff8800b72d78a0 0000000000000000 ffffffffa040d100 ffff8800b72d7858
[ 3835.073008]  ffffffffa040b2e3 0000000000000000 0000000000000000 0000000000000000
[ 3835.073008] Call Trace:
[ 3835.073008]  [<ffffffffa0411924>] ip_tunnel_newlink+0x64/0x160 [ip_tunnel]
[ 3835.073008]  [<ffffffffa040b2e3>] vti_newlink+0x43/0x70 [ip_vti]
[ 3835.073008]  [<ffffffff8150d4da>] rtnl_newlink+0x4fa/0x5f0
[ 3835.073008]  [<ffffffff812f68bb>] ? nla_strlcpy+0x5b/0x70
[ 3835.073008]  [<ffffffff81508fb0>] ? rtnl_link_ops_get+0x40/0x60
[ 3835.073008]  [<ffffffff8150d11f>] ? rtnl_newlink+0x13f/0x5f0
[ 3835.073008]  [<ffffffff81509cf4>] rtnetlink_rcv_msg+0xa4/0x270
[ 3835.073008]  [<ffffffff8126adf5>] ? sock_has_perm+0x75/0x90
[ 3835.073008]  [<ffffffff81509c50>] ? rtnetlink_rcv+0x30/0x30
[ 3835.073008]  [<ffffffff81529e39>] netlink_rcv_skb+0xa9/0xc0
[ 3835.073008]  [<ffffffff81509c48>] rtnetlink_rcv+0x28/0x30
....

modprobe ip_vti
ip link del ip_vti0 type vti
ip link add ip_vti0 type vti
rmmod ip_vti

do that one or more times, kernel will panic.

fix it by assigning ip_tunnel_dellink to vti_link_ops' dellink, in
which we skip the unregister of fb tunnel device. do the same on ip6_vti.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
Signed-off-by: Cong Wang <cwang@twopensource.com>
---
 net/ipv4/ip_vti.c  |  1 +
 net/ipv6/ip6_vti.c | 11 +++++++++++
 2 files changed, 12 insertions(+)

diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 3e86101..5f29e49 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -528,6 +528,7 @@ static struct rtnl_link_ops vti_link_ops __read_mostly = {
 	.validate	= vti_tunnel_validate,
 	.newlink	= vti_newlink,
 	.changelink	= vti_changelink,
+	.dellink	= ip_tunnel_dellink,
 	.get_size	= vti_get_size,
 	.fill_info	= vti_fill_info,
 };
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index 31089d1..bcda14d 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -905,6 +905,15 @@ static int vti6_newlink(struct net *src_net, struct net_device *dev,
 	return vti6_tnl_create2(dev);
 }
 
+static void vti6_dellink(struct net_device *dev, struct list_head *head)
+{
+	struct net *net = dev_net(dev);
+	struct vti6_net *ip6n = net_generic(net, vti6_net_id);
+
+	if (dev != ip6n->fb_tnl_dev)
+		unregister_netdevice_queue(dev, head);
+}
+
 static int vti6_changelink(struct net_device *dev, struct nlattr *tb[],
 			   struct nlattr *data[])
 {
@@ -980,6 +989,7 @@ static struct rtnl_link_ops vti6_link_ops __read_mostly = {
 	.setup		= vti6_dev_setup,
 	.validate	= vti6_validate,
 	.newlink	= vti6_newlink,
+	.dellink	= vti6_dellink,
 	.changelink	= vti6_changelink,
 	.get_size	= vti6_get_size,
 	.fill_info	= vti6_fill_info,
@@ -1020,6 +1030,7 @@ static int __net_init vti6_init_net(struct net *net)
 	if (!ip6n->fb_tnl_dev)
 		goto err_alloc_dev;
 	dev_net_set(ip6n->fb_tnl_dev, net);
+	ip6n->fb_tnl_dev->rtnl_link_ops = &vti6_link_ops;
 
 	err = vti6_fb_tnl_dev_init(ip6n->fb_tnl_dev);
 	if (err < 0)
-- 
1.8.3.1
