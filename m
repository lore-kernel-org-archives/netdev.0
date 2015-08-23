From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] vrf: Add ethernet header for pass through VRF device
Date: Sun, 23 Aug 2015 12:41:00 -0600
Message-ID: <1440355260-16528-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:34191 "EHLO
	mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752389AbbHWSlf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2015 14:41:35 -0400
Received: by iodb91 with SMTP id b91so127110350iod.1
        for <netdev@vger.kernel.org>; Sun, 23 Aug 2015 11:41:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The change to use a custom dst broke tcpdump captures on the VRF device:

$ tcpdump -n -i vrf10
...
05:32:29.009362 IP 10.2.1.254 > 10.2.1.2: ICMP echo request, id 21989, seq 1, length 64
05:32:29.009855 00:00:40:01:8d:36 > 45:00:00:54:d6:6f, ethertype Unknown (0x0a02), length 84:
	0x0000:  0102 0a02 01fe 0000 9181 55e5 0001 bd11  ..........U.....
	0x0010:  da55 0000 0000 bb5d 0700 0000 0000 1011  .U.....]........
	0x0020:  1213 1415 1617 1819 1a1b 1c1d 1e1f 2021  ...............!
	0x0030:  2223 2425 2627 2829 2a2b 2c2d 2e2f 3031  "#$%&'()*+,-./01
	0x0040:  3233 3435 3637                           234567

Local packets going through the VRF device are missing an ethernet header.
Fix by adding one and then stripping it off before pushing back to the IP
stack. With this patch you get the expected dumps:

...
05:36:15.713944 IP 10.2.1.254 > 10.2.1.2: ICMP echo request, id 23795, seq 1, length 64
05:36:15.714160 IP 10.2.1.2 > 10.2.1.254: ICMP echo reply, id 23795, seq 1, length 64
...

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index dbeffe789185..e5c792e4c224 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -219,6 +219,9 @@ static netdev_tx_t vrf_process_v4_outbound(struct sk_buff *skb,
 
 static netdev_tx_t is_ip_tx_frame(struct sk_buff *skb, struct net_device *dev)
 {
+	/* strip the ethernet header added for pass through VRF device */
+	__skb_pull(skb, skb_network_offset(skb));
+
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
 		return vrf_process_v4_outbound(skb, dev);
@@ -250,6 +253,17 @@ static netdev_tx_t vrf_xmit(struct sk_buff *skb, struct net_device *dev)
 
 static netdev_tx_t vrf_finish(struct sock *sk, struct sk_buff *skb)
 {
+	int err;
+
+	__skb_pull(skb, skb_network_offset(skb));
+	err = dev_hard_header(skb, skb->dev, ntohs(skb->protocol),
+			      NULL, NULL, skb->len);
+
+	if (err < 0) {
+		vrf_tx_error(skb->dev, skb);
+		return -EINVAL;
+	}
+
 	return dev_queue_xmit(skb);
 }
 
-- 
2.3.2 (Apple Git-55)
