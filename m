From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net] net: vrf: Drop conntrack data after pass through VRF device on Tx
Date: Wed, 14 Dec 2016 14:31:11 -0800
Message-ID: <1481754671-22519-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:36070 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753036AbcLNWcX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 17:32:23 -0500
Received: by mail-pg0-f51.google.com with SMTP id f188so12381033pgc.3
        for <netdev@vger.kernel.org>; Wed, 14 Dec 2016 14:31:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Locally originated traffic in a VRF fails in the presence of a POSTROUTING
rule. For example,

    $ iptables -t nat -A POSTROUTING -s 11.1.1.0/24  -j MASQUERADE
    $ ping -I red -c1 11.1.1.3
    ping: Warning: source address might be selected on device other than red.
    PING 11.1.1.3 (11.1.1.3) from 11.1.1.2 red: 56(84) bytes of data.
    ping: sendmsg: Operation not permitted

Worse, the above causes random corruption resulting in a panic in random
places (I have not seen a consistent backtrace).

Call nf_reset to drop the conntrack info following the pass through the
VRF device.  The nf_reset is needed on Tx but not Rx because of the order
in which NF_HOOK's are hit: on Rx the VRF device is after the real ingress
device and on Tx it is is before the real egress device. Connection
tracking should be tied to the real egress device and not the VRF device.

Fixes: 8f58336d3f78a ("net: Add ethernet header for pass through VRF device")
Fixes: 35402e3136634 ("net: Add IPv6 support to VRF device")
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 015a1321c7dd..7532646c3b7b 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -366,6 +366,8 @@ static int vrf_finish_output6(struct net *net, struct sock *sk,
 	struct in6_addr *nexthop;
 	int ret;
 
+	nf_reset(skb);
+
 	skb->protocol = htons(ETH_P_IPV6);
 	skb->dev = dev;
 
@@ -547,6 +549,8 @@ static int vrf_finish_output(struct net *net, struct sock *sk, struct sk_buff *s
 	u32 nexthop;
 	int ret = -EINVAL;
 
+	nf_reset(skb);
+
 	/* Be paranoid, rather than too clever. */
 	if (unlikely(skb_headroom(skb) < hh_len && dev->header_ops)) {
 		struct sk_buff *skb2;
-- 
2.1.4
