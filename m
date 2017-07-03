From: Eduardo Valentin <eduval@amazon.com>
Subject: [PATCH 1/1] bridge: mdb: report complete_info ptr as not a kmemleak
Date: Mon, 3 Jul 2017 10:06:34 -0700
Message-ID: <1499101594-22421-1-git-send-email-eduval@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <bridge@lists.linux-foundation.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>,
        Eduardo Valentin <eduval@amazon.com>,
        "stable # v4 . 9+" <stable@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We currently get the following kmemleak report:
unreferenced object 0xffff8800039d9820 (size 32):
  comm "softirq", pid 0, jiffies 4295212383 (age 792.416s)
  hex dump (first 32 bytes):
    00 0c e0 03 00 88 ff ff ff 02 00 00 00 00 00 00  ................
    00 00 00 01 ff 11 00 02 86 dd 00 00 ff ff ff ff  ................
  backtrace:
    [<ffffffff8152b4aa>] kmemleak_alloc+0x4a/0xa0
    [<ffffffff811d8ec8>] kmem_cache_alloc_trace+0xb8/0x1c0
    [<ffffffffa0389683>] __br_mdb_notify+0x2a3/0x300 [bridge]
    [<ffffffffa038a0ce>] br_mdb_notify+0x6e/0x70 [bridge]
    [<ffffffffa0386479>] br_multicast_add_group+0x109/0x150 [bridge]
    [<ffffffffa0386518>] br_ip6_multicast_add_group+0x58/0x60 [bridge]
    [<ffffffffa0387fb5>] br_multicast_rcv+0x1d5/0xdb0 [bridge]
    [<ffffffffa037d7cf>] br_handle_frame_finish+0xcf/0x510 [bridge]
    [<ffffffffa03a236b>] br_nf_hook_thresh.part.27+0xb/0x10 [br_netfilter]
    [<ffffffffa03a3738>] br_nf_hook_thresh+0x48/0xb0 [br_netfilter]
    [<ffffffffa03a3fb9>] br_nf_pre_routing_finish_ipv6+0x109/0x1d0 [br_netfilter]
    [<ffffffffa03a4400>] br_nf_pre_routing_ipv6+0xd0/0x14c [br_netfilter]
    [<ffffffffa03a3c27>] br_nf_pre_routing+0x197/0x3d0 [br_netfilter]
    [<ffffffff814a2952>] nf_iterate+0x52/0x60
    [<ffffffff814a29bc>] nf_hook_slow+0x5c/0xb0
    [<ffffffffa037ddf4>] br_handle_frame+0x1a4/0x2c0 [bridge]

This patch flags the complete_info ptr object as not a leak as it will
get freed when .complete_priv() is called, for the br mdb case, it
will be freed at br_mdb_complete().

Cc: stable <stable@vger.kernel.org> # v4.9+
Reviewed-by: Vallish Vaidyeshwara <vallish@amazon.com>
Signed-off-by: Eduardo Valentin <eduval@amazon.com>
---
 net/bridge/br_mdb.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index b084548..1c81546 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -5,6 +5,7 @@
 #include <linux/rculist.h>
 #include <linux/skbuff.h>
 #include <linux/if_ether.h>
+#include <linux/kmemleak.h>
 #include <net/ip.h>
 #include <net/netlink.h>
 #include <net/switchdev.h>
@@ -319,6 +320,8 @@ static void __br_mdb_notify(struct net_device *dev, struct net_bridge_port *p,
 	if (port_dev && type == RTM_NEWMDB) {
 		complete_info = kmalloc(sizeof(*complete_info), GFP_ATOMIC);
 		if (complete_info) {
+			/* This pointer is freed in br_mdb_complete() */
+			kmemleak_not_leak(complete_info);
 			complete_info->port = p;
 			__mdb_entry_to_br_ip(entry, &complete_info->ip);
 			mdb.obj.complete_priv = complete_info;
-- 
2.7.4
