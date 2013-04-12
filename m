From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/4] netfilter: nf_ct_sip: don't drop packets with offsets pointing outside the packet
Date: Fri, 12 Apr 2013 12:13:16 +0200
Message-ID: <1365761599-6990-2-git-send-email-pablo@netfilter.org>
References: <1365761599-6990-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1365761599-6990-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Some Cisco phones create huge messages that are spread over multiple packets.
After calculating the offset of the SIP body, it is validated to be within
the packet and the packet is dropped otherwise. This breaks operation of
these phones. Since connection tracking is supposed to be passive, just let
those packets pass unmodified and untracked.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_sip.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index 0e7d423..e0c4373 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -1593,10 +1593,8 @@ static int sip_help_tcp(struct sk_buff *skb, unsigned int protoff,
 		end += strlen("\r\n\r\n") + clen;
 
 		msglen = origlen = end - dptr;
-		if (msglen > datalen) {
-			nf_ct_helper_log(skb, ct, "incomplete/bad SIP message");
-			return NF_DROP;
-		}
+		if (msglen > datalen)
+			return NF_ACCEPT;
 
 		ret = process_sip_msg(skb, ct, protoff, dataoff,
 				      &dptr, &msglen);
-- 
1.7.10.4

