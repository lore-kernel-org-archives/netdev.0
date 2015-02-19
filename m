From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: TX offloads for NVGRE (OVS GRE with inner protocol being TEB)
Date: Thu, 19 Feb 2015 16:05:17 +0200
Message-ID: <54E5ED9D.8080206@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>,
	Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0055.outbound.protection.outlook.com ([157.56.112.55]:52960
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753445AbbBSOGc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Feb 2015 09:06:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

It seems that the OVS GRE code lacks handling of offloads (e.g to come 
into play with NICs that support NVGRE).

I assume we need to place a call to iptunnel_handle_offloads before 
invoking iptunnel_xmit, agree? so ~the quick patch below should do the 
work? I wasn't sure how to set the value of the 2nd param for 
iptunnel_handle_offloads().


Or.

diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index f17ac96..524825f 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -187,6 +187,10 @@ static int gre_tnl_send(struct vport *vport, struct 
sk_buff *skb)
                 htons(IP_DF) : 0;

         skb->ignore_df = 1;
+
+       skb = iptunnel_handle_offloads(skb, false, SKB_GSO_GRE);
+       if (IS_ERR(skb))
+               goto err_free_rt;

         return iptunnel_xmit(skb->sk, rt, skb, fl.saddr,
                              tun_key->ipv4_dst, IPPROTO_GRE,
