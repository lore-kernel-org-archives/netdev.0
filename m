From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 11/15] ax25: Stop depending on arp_find
Date: Mon, 02 Mar 2015 00:09:42 -0600
Message-ID: <87h9u46ic9.fsf_-_@x220.int.ebiederm.org>
References: <87pp8xx6ik.fsf@x220.int.ebiederm.org>
	<20150227.162131.431559184124647735.davem@davemloft.net>
	<87mw3yg8da.fsf@x220.int.ebiederm.org>
	<20150301.230306.2023670900391030920.davem@davemloft.net>
	<871tl8dlxn.fsf@x220.int.ebiederm.org>
	<87lhjg9byo.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>,
	linux-hams@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <87lhjg9byo.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Sun, 01 Mar 2015 23:59:11 -0600")
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Have ax25_neigh_output perform ordinary arp resolution before calling
ax25_neigh_xmit.

Call dev_hard_header in ax25_neigh_output with a destination address so
it will not fail, and the destination mac address will not need to be
set in ax25_neigh_xmit.

Remove arp_find from ax25_neigh_xmit (the ordinary arp resolution added
to ax25_neigh_output removes the need for calling arp_find).

Document how close ax25_neigh_output is to neigh_resolve_output.

Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: linux-hams@vger.kernel.org
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/ax25/ax25_ip.c | 40 ++++++++++++++++++++++++++++------------
 1 file changed, 28 insertions(+), 12 deletions(-)

diff --git a/net/ax25/ax25_ip.c b/net/ax25/ax25_ip.c
index 08803e820f1d..e030c64ebfb7 100644
--- a/net/ax25/ax25_ip.c
+++ b/net/ax25/ax25_ip.c
@@ -115,9 +115,6 @@ static int ax25_neigh_xmit(struct sk_buff *skb)
 	dst = (ax25_address *)(bp + 1);
 	src = (ax25_address *)(bp + 8);
 
-	if (arp_find(bp + 1, skb))
-		return 1;
-
 	route = ax25_get_route(dst, NULL);
 	if (route) {
 		digipeat = route->digipeat;
@@ -218,16 +215,35 @@ put:
 
 static int ax25_neigh_output(struct neighbour *neigh, struct sk_buff *skb)
 {
-	struct net_device *dev = skb->dev;
-
-	__skb_pull(skb, skb_network_offset(skb));
-
-	if (dev_hard_header(skb, dev, ntohs(skb->protocol), NULL, NULL,
-			    skb->len) < 0 &&
-	    ax25_neigh_xmit(skb));
-		return 0;
+	/* Except for calling ax25_neigh_xmit instead of
+	 * dev_queue_xmit this is neigh_resolve_output.
+	 */
+	int rc = 0;
+
+	if (!neigh_event_send(neigh, skb)) {
+		int err;
+		struct net_device *dev = neigh->dev;
+		unsigned int seq;
+
+		do {
+			__skb_pull(skb, skb_network_offset(skb));
+			seq = read_seqbegin(&neigh->ha_lock);
+			err = dev_hard_header(skb, dev, ntohs(skb->protocol),
+					      neigh->ha, NULL, skb->len);
+		} while (read_seqretry(&neigh->ha_lock, seq));
+
+		if (err >= 0) {
+			ax25_neigh_xmit(skb);
+		} else
+			goto out_kfree_skb;
+	}
+out:
+	return rc;
 
-	return dev_queue_xmit(skb);
+out_kfree_skb:
+	rc = -EINVAL;
+	kfree_skb(skb);
+	goto out;
 }
 
 int ax25_neigh_construct(struct neighbour *neigh)
-- 
2.2.1

