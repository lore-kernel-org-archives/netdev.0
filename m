From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 1/3] net: Add cache alignment in sock_common for socket lookup fields
Date: Tue, 26 May 2015 09:34:07 -0700
Message-ID: <1432658049-3400132-2-git-send-email-tom@herbertland.com>
References: <1432658049-3400132-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:38718 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752084AbbEZQe0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 12:34:26 -0400
Received: from pps.filterd (m0004348 [127.0.0.1])
	by m0004348.ppops.net (8.14.5/8.14.5) with SMTP id t4QGXfnd023954
	for <netdev@vger.kernel.org>; Tue, 26 May 2015 09:34:24 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0004348.ppops.net with ESMTP id 1umun7g3ef-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 26 May 2015 09:34:24 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 10fcbc0403c511e5bb350002c95209d8-cbbf73a0 for <netdev@vger.kernel.org>;	Tue,
 26 May 2015 09:34:23 -0700
In-Reply-To: <1432658049-3400132-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use ____cacheline_aligned_in_smp to keep the fields used on socket
lookup in their own cachelines. These are read only fields and will
be often accessed on accross CPUs (would be very common with
SO_REUSEPORT for instance).

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/sock.h | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 26c1c31..bcf6114 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -211,7 +211,13 @@ struct sock_common {
 		struct hlist_node	skc_node;
 		struct hlist_nulls_node skc_nulls_node;
 	};
-	int			skc_tx_queue_mapping;
+
+	/* Cachelines above this point are read mostly and are used in socket
+	 * lookup.
+	 */
+	int			skc_tx_queue_mapping
+				____cacheline_aligned_in_smp;
+
 	atomic_t		skc_refcnt;
 	/* private: */
 	int                     skc_dontcopy_end[0];
-- 
1.8.1
