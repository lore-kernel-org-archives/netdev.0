From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 1/3] gro: Pull headers into skb head for 1st skb in gro list
Date: Thu, 2 Jul 2015 14:04:12 -0700
Message-ID: <1435871054-635096-2-git-send-email-tom@herbertland.com>
References: <1435871054-635096-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:57815 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753455AbbGBVEw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2015 17:04:52 -0400
Received: from pps.filterd (m0004348 [127.0.0.1])
	by m0004348.ppops.net (8.14.5/8.14.5) with SMTP id t62L4SSY006952
	for <netdev@vger.kernel.org>; Thu, 2 Jul 2015 14:04:51 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0004348.ppops.net with ESMTP id 1vd9tb0bgv-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 02 Jul 2015 14:04:51 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 fa9f7b6220fd11e58bf40002c99331b0-9e8da2b0 for <netdev@vger.kernel.org>;	Thu,
 02 Jul 2015 14:04:50 -0700
In-Reply-To: <1435871054-635096-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When setting up the first skb in a gro list we ensure that all the
headers up to skb_gro_offset have been pulled into head. In subsequent
uses of this skb (e.g. determining same_flow) it is assumed that the
headers can be accessed in the skb head.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/core/dev.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index 6778a99..05e0e37 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4228,6 +4228,10 @@ static enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff
 	} else {
 		napi->gro_count++;
 	}
+
+	/* Ensure all headers are pulled into head for 1st skb */
+	skb_gro_header_slow(skb, skb_gro_offset(skb), 0);
+
 	NAPI_GRO_CB(skb)->count = 1;
 	NAPI_GRO_CB(skb)->age = jiffies;
 	NAPI_GRO_CB(skb)->last = skb;
-- 
1.8.1
