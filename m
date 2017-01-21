From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: dsa: Keep a reference count on ethernet_dev
Date: Sat, 21 Jan 2017 09:40:54 -0800
Message-ID: <20170121174055.27560-1-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

of_find_net_device_by_node() just returns a reference to a net_device but does
not increment its reference count, which means that the master network device
can just vanish under our feet.

Fixes: 83c0afaec7b7 ("net: dsa: Add new binding implementation")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa2.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index da3862124545..4adb9b11c22c 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -440,6 +440,8 @@ static void dsa_dst_unapply(struct dsa_switch_tree *dst)
 
 	pr_info("DSA: tree %d unapplied\n", dst->tree);
 	dst->applied = false;
+
+	dev_put(dst->master_netdev);
 }
 
 static int dsa_cpu_parse(struct device_node *port, u32 index,
@@ -458,6 +460,8 @@ static int dsa_cpu_parse(struct device_node *port, u32 index,
 	if (!ethernet_dev)
 		return -EPROBE_DEFER;
 
+	dev_hold(ethernet_dev);
+
 	if (!ds->master_netdev)
 		ds->master_netdev = ethernet_dev;
 
@@ -473,6 +477,7 @@ static int dsa_cpu_parse(struct device_node *port, u32 index,
 	dst->tag_ops = dsa_resolve_tag_protocol(tag_protocol);
 	if (IS_ERR(dst->tag_ops)) {
 		dev_warn(ds->dev, "No tagger for this switch\n");
+		dev_put(ethernet_dev);
 		return PTR_ERR(dst->tag_ops);
 	}
 
-- 
2.9.3
