From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCH net] openvswitch: Fix IPv6 exthdr handling with ct helpers.
Date: Mon, 14 Sep 2015 11:14:50 -0700
Message-ID: <1442254490-20385-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org, dan.carpenter@oracle.com
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34425 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750968AbbINSPh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2015 14:15:37 -0400
Received: by padhy16 with SMTP id hy16so150425136pad.1
        for <netdev@vger.kernel.org>; Mon, 14 Sep 2015 11:15:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Static code analysis reveals the following bug:

        net/openvswitch/conntrack.c:281 ovs_ct_helper()
        warn: unsigned 'protoff' is never less than zero.

This signedness bug breaks error handling for IPv6 extension headers when
using conntrack helpers. Fix the error by using a local signed variable.

Fixes:  cae3a2627520: "openvswitch: Allow attaching helpers to ct
action"
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
 net/openvswitch/conntrack.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index e8e524a..002a755 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -275,13 +275,15 @@ static int ovs_ct_helper(struct sk_buff *skb, u16 proto)
 	case NFPROTO_IPV6: {
 		u8 nexthdr = ipv6_hdr(skb)->nexthdr;
 		__be16 frag_off;
+		int ofs;
 
-		protoff = ipv6_skip_exthdr(skb, sizeof(struct ipv6hdr),
-					   &nexthdr, &frag_off);
-		if (protoff < 0 || (frag_off & htons(~0x7)) != 0) {
+		ofs = ipv6_skip_exthdr(skb, sizeof(struct ipv6hdr), &nexthdr,
+				       &frag_off);
+		if (ofs < 0 || (frag_off & htons(~0x7)) != 0) {
 			pr_debug("proto header not found\n");
 			return NF_ACCEPT;
 		}
+		protoff = ofs;
 		break;
 	}
 	default:
-- 
2.1.4
