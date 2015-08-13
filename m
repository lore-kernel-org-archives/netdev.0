From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 09/11] net: Use VRF index for oif in ip_send_unicast_reply
Date: Thu, 13 Aug 2015 14:59:08 -0600
Message-ID: <1439499551-90231-10-git-send-email-dsa@cumulusnetworks.com>
References: <1439499551-90231-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, ddutt@cumulusnetworks.com,
	hannes@stressinduktion.org, nicolas.dichtel@6wind.com,
	stephen@networkplumber.org, hadi@mojatatu.com,
	ebiederm@xmission.com, davem@davemloft.net, svaidya@brocade.com,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:36272 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932173AbbHMVAJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 17:00:09 -0400
Received: by igxp17 with SMTP id p17so29454030igx.1
        for <netdev@vger.kernel.org>; Thu, 13 Aug 2015 14:00:09 -0700 (PDT)
In-Reply-To: <1439499551-90231-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If output device is not specified use VRF device if input device is
enslaved. This is needed to ensure tcp acks and resets go out VRF device.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/ip_output.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 6bf89a6312bc..0138fada0951 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1542,6 +1542,7 @@ void ip_send_unicast_reply(struct sock *sk, struct sk_buff *skb,
 	struct net *net = sock_net(sk);
 	struct sk_buff *nskb;
 	int err;
+	int oif;
 
 	if (__ip_options_echo(&replyopts.opt.opt, skb, sopt))
 		return;
@@ -1559,7 +1560,11 @@ void ip_send_unicast_reply(struct sock *sk, struct sk_buff *skb,
 			daddr = replyopts.opt.opt.faddr;
 	}
 
-	flowi4_init_output(&fl4, arg->bound_dev_if,
+	oif = arg->bound_dev_if;
+	if (!oif && netif_index_is_vrf(net, skb->skb_iif))
+		oif = skb->skb_iif;
+
+	flowi4_init_output(&fl4, oif,
 			   IP4_REPLY_MARK(net, skb->mark),
 			   RT_TOS(arg->tos),
 			   RT_SCOPE_UNIVERSE, ip_hdr(skb)->protocol,
-- 
2.3.2 (Apple Git-55)
