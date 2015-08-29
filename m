From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH v2] openvswitch: retain parsed IPv6 header fields in flow on error skipping extension headers
Date: Sat, 29 Aug 2015 09:02:21 +0900
Message-ID: <1440806541-22729-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Simon Horman <simon.horman@netronome.com>
To: Pravin Shelar <pshelar@nicira.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36643 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752920AbbH2ACb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 20:02:31 -0400
Received: by padhm10 with SMTP id hm10so21560663pad.3
        for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 17:02:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When an error occurs skipping IPv6 extension headers retain the already
parsed IP protocol and IPv6 addresses in the flow. Also assume that the
packet is not a fragment in the absence of information to the contrary;
that is always use the frag_off value set by ipv6_skip_exthdr().

This allows matching on the IP protocol and IPv6 addresses of packets
with malformed extension headers.

Signed-off-by: Simon Horman <simon.horman@netronome.com>

---

v2
* As suggested by Pravin Shelar
  - Use new errno for the case handled by this patch in order
    to retain the old behaviour if the call to check_header()
    in parse_ipv6hdr() returns -EINVAL, which it may.
* Dropped RFC from prefix

* Some consideration should be given to unwanted side effects of this patch
  as it affects the handling of malformed packets.
---
 net/openvswitch/flow.c | 21 +++++++++++++++------
 1 file changed, 15 insertions(+), 6 deletions(-)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 5a3195e538ce..daf914ec58d0 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -272,8 +272,6 @@ static int parse_ipv6hdr(struct sk_buff *skb, struct sw_flow_key *key)
 	key->ipv6.addr.dst = nh->daddr;
 
 	payload_ofs = ipv6_skip_exthdr(skb, payload_ofs, &nexthdr, &frag_off);
-	if (unlikely(payload_ofs < 0))
-		return -EINVAL;
 
 	if (frag_off) {
 		if (frag_off & htons(~0x7))
@@ -284,6 +282,13 @@ static int parse_ipv6hdr(struct sk_buff *skb, struct sw_flow_key *key)
 		key->ip.frag = OVS_FRAG_TYPE_NONE;
 	}
 
+	/* Delayed handling of error in ipv6_skip_exthdr() as it
+	 * always sets frag_off to a valid value which may be
+	 * used to set key->ip.frag above.
+	 */
+	if (unlikely(payload_ofs < 0))
+		return -EPROTO;
+
 	nh_len = payload_ofs - nh_ofs;
 	skb_set_transport_header(skb, nh_ofs + nh_len);
 	key->ip.proto = nexthdr;
@@ -623,12 +628,16 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
 
 		nh_len = parse_ipv6hdr(skb, key);
 		if (unlikely(nh_len < 0)) {
-			memset(&key->ip, 0, sizeof(key->ip));
-			memset(&key->ipv6.addr, 0, sizeof(key->ipv6.addr));
-			if (nh_len == -EINVAL) {
+			switch (nh_len) {
+			case -EINVAL:
+				memset(&key->ip, 0, sizeof(key->ip));
+				memset(&key->ipv6.addr, 0, sizeof(key->ipv6.addr));
+				/* fall-through */
+			case -EPROTO:
 				skb->transport_header = skb->network_header;
 				error = 0;
-			} else {
+				break;
+			default:
 				error = nh_len;
 			}
 			return error;
-- 
2.1.4
