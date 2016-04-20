From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: fix HAVE_EFFICIENT_UNALIGNED_ACCESS typos
Date: Wed, 20 Apr 2016 07:31:31 -0700
Message-ID: <1461162691.10638.260.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160419.195009.1052027353987244150.davem@davemloft.net>
	 <1461142655-5067-1-git-send-email-nicolas.dichtel@6wind.com>
	 <1461142655-5067-2-git-send-email-nicolas.dichtel@6wind.com>
	 <1461144802.10638.249.camel@edumazet-glaptop3.roam.corp.google.com>
	 <57174F8E.6050201@6wind.com>
	 <1461146278.10638.253.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	roopa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f44.google.com ([209.85.213.44]:33818 "EHLO
	mail-vk0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932858AbcDTObg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 10:31:36 -0400
Received: by mail-vk0-f44.google.com with SMTP id e185so60999981vkb.1
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2016 07:31:36 -0700 (PDT)
In-Reply-To: <1461146278.10638.253.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

HAVE_EFFICIENT_UNALIGNED_ACCESS needs CONFIG_ prefix.

Also add a comment in nla_align_64bit() explaining we have
to add a padding if current skb->data is aligned, as it
certainly can be confusing.

Fixes: 35c5845957c7 ("net: Add helpers for 64-bit aligning netlink attributes.")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/netlink.h |   19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index e644b3489acf..cf95df1fa14b 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -1238,18 +1238,21 @@ static inline int nla_validate_nested(const struct nlattr *start, int maxtype,
  * Conditionally emit a padding netlink attribute in order to make
  * the next attribute we emit have a 64-bit aligned nla_data() area.
  * This will only be done in architectures which do not have
- * HAVE_EFFICIENT_UNALIGNED_ACCESS defined.
+ * CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS defined.
  *
  * Returns zero on success or a negative error code.
  */
 static inline int nla_align_64bit(struct sk_buff *skb, int padattr)
 {
-#ifndef HAVE_EFFICIENT_UNALIGNED_ACCESS
-	if (IS_ALIGNED((unsigned long)skb->data, 8)) {
-		struct nlattr *attr = nla_reserve(skb, padattr, 0);
-		if (!attr)
-			return -EMSGSIZE;
-	}
+#ifndef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
+	/* The nlattr header is 4 bytes in size, that's why we test
+	 * if the skb->data _is_ aligned.  This NOP attribute, plus
+	 * nlattr header for next attribute, will make nla_data()
+	 * 8-byte aligned.
+	 */
+	if (IS_ALIGNED((unsigned long)skb->data, 8) &&
+	    !nla_reserve(skb, padattr, 0))
+		return -EMSGSIZE;
 #endif
 	return 0;
 }
@@ -1261,7 +1264,7 @@ static inline int nla_align_64bit(struct sk_buff *skb, int padattr)
 static inline int nla_total_size_64bit(int payload)
 {
 	return NLA_ALIGN(nla_attr_size(payload))
-#ifndef HAVE_EFFICIENT_UNALIGNED_ACCESS
+#ifndef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
 		+ NLA_ALIGN(nla_attr_size(0))
 #endif
 		;
