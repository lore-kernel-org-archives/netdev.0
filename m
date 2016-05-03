From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 1/3] gre: remove superfluous pskb_may_pull
Date: Tue,  3 May 2016 17:10:06 +0200
Message-ID: <16f60994d62766aca2de269f1bfca44eb0b184ec.1462286214.git.jbenc@redhat.com>
References: <cover.1462286214.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>, pravin shelar <pshelar@ovn.org>,
	Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49709 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755635AbcECPKi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2016 11:10:38 -0400
In-Reply-To: <cover.1462286214.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The call to gre_parse_header is either followed by iptunnel_pull_header, or
in the case of ICMP error path, the actual header is not accessed at all.

In the first case, iptunnel_pull_header will call pskb_may_pull anyway and
it's pointless to do it twice. The only difference is what call will fail
with what error code but the net effect is still the same in all call sites.

In the second case, pskb_may_pull is pointless, as skb->data is at the outer
IP header and not at the GRE header.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 net/ipv4/gre_demux.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/net/ipv4/gre_demux.c b/net/ipv4/gre_demux.c
index a41e73ab1369..d78e2eefc0f7 100644
--- a/net/ipv4/gre_demux.c
+++ b/net/ipv4/gre_demux.c
@@ -114,11 +114,8 @@ int gre_parse_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
 	 */
 	if (greh->flags == 0 && tpi->proto == htons(ETH_P_WCCP)) {
 		tpi->proto = htons(ETH_P_IP);
-		if ((*(u8 *)options & 0xF0) != 0x40) {
+		if ((*(u8 *)options & 0xF0) != 0x40)
 			hdr_len += 4;
-			if (!pskb_may_pull(skb, hdr_len))
-				return -EINVAL;
-		}
 	}
 	return hdr_len;
 }
-- 
1.8.3.1
