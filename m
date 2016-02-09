From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net PATCH] net: Copy inner L3 and L4 headers as unaligned on GRE
 TEB
Date: Tue, 09 Feb 2016 06:14:43 -0800
Message-ID: <20160209141234.19305.82202.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, davem@davemloft.net
To: netdev@vger.kernel.org, alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:35769 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756413AbcBIOOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 09:14:45 -0500
Received: by mail-pf0-f171.google.com with SMTP id c10so61604717pfc.2
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2016 06:14:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch corrects the unaligned accesses seen on GRE TEB tunnels when
generating hash keys.  Specifically what this patch does is make it so that
we force the use of skb_copy_bits when the GRE inner headers will be
unaligned due to NET_IP_ALIGNED being a non-zero value.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---

I don't have the ability to test it but this should fix flow dissector for
GRE TEB tunnels traffic seen on architectures that require network and
transport headers to be 4 byte aligned.

 net/core/flow_dissector.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 699b2c415cb0..9c181ba7263e 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -402,6 +402,13 @@ ip_proto_again:
 				goto out_bad;
 			proto = eth->h_proto;
 			nhoff += sizeof(*eth);
+
+			/* Cap headers that we access via pointers at the
+			 * end of the Ethernet header as our maximum alignment
+			 * at that point is only 2 bytes.
+			 */
+			if (NET_IP_ALIGN)
+				hlen = nhoff;
 		}
 
 		key_control->flags |= FLOW_DIS_ENCAPSULATION;
