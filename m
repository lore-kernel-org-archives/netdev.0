From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH] [net]ip_tunnel: the lack of vti_link_ops' dellink() cause kernel panic
Date: Tue, 18 Nov 2014 18:37:39 +0800
Message-ID: <1416307059-32732-1-git-send-email-lucien.xin@gmail.com>
Cc: Xin Long <lucien.xin@gmail.com>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:33581 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753861AbaKRKh5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 05:37:57 -0500
Received: by mail-pd0-f179.google.com with SMTP id g10so22983498pdj.24
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 02:37:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now the vti_link_ops do not point the .dellink, rtnl_newlink will invoke
the default function, unregister_netdevice_queue, which will cause the
dev to unregister later. so when we delete a vti device, the net_device
will be removed, but the tunnel still in the tunnel list. then, we add
a new vti, in ip_tunnel_find():

        hlist_for_each_entry_rcu(t, head, hash_node) {
                if (local == t->parms.iph.saddr &&
                    remote == t->parms.iph.daddr &&
                    link == t->parms.link &&
                    type == t->dev->type &&
                    ip_tunnel_key_match(&t->parms, flags, key))
                        break;
        }

the dev of ip_tunnel *t may be null because of unregister_netdevice_queue
motioned above. so the panic will happen:

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

the reproduction can be like this:

modprobe ip_vti
ip link del ip_vti0 type vti
ip link add ip_vti0 type vti
rmmod ip_vti

do that one or more time, kernel will panic.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/ipv4/ip_vti.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 3e86101..1a7e979 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -528,6 +528,7 @@ static struct rtnl_link_ops vti_link_ops __read_mostly = {
 	.validate	= vti_tunnel_validate,
 	.newlink	= vti_newlink,
 	.changelink	= vti_changelink,
+	.dellink        = ip_tunnel_dellink,
 	.get_size	= vti_get_size,
 	.fill_info	= vti_fill_info,
 };
-- 
1.8.3.1
