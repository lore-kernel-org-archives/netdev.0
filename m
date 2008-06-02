From: Krzysztof Oledzki <olel@ans.pl>
Subject: [PATCH]  Fix routing tables with id > 255 for legacy software
Date: Tue, 03 Jun 2008 00:09:47 +0200
Message-ID: <48446fab.fEFxpuNLP1rSMKv2%olel@ans.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: kaber@trash.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:41999 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752395AbYFBWJ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2008 18:09:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 4cb8c341fc444afc638cf9ce4efb7e4248e88b5e Mon Sep 17 00:00:00 2001
From: Krzysztof Piotr Oledzki <ole@ans.pl>
Date: Tue, 3 Jun 2008 00:03:41 +0200
Subject: [NET] Fix routing tables with id > 255 for legacy software

Most legacy software do not like tables > 255 as rtm_table is u8
so tb_id is sent &0xff and it is possible to mismatch for example
table 510 with table 254 (main).

This patch introduces RT_TABLE_COMPAT=253 so the code uses it if
tb_id > 255. It makes such old applications happy, new
ones are still able to use RTA_TABLE to get a proper table id.

Signed-off-by: Krzysztof Piotr Oledzki <ole@ans.pl>
---
 include/linux/rtnetlink.h |    1 +
 net/ipv4/fib_semantics.c  |    5 ++++-
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 44c81c7..8bcdea8 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -246,6 +246,7 @@ enum rt_class_t
 {
 	RT_TABLE_UNSPEC=0,
 /* User defined values */
+	RT_TABLE_COMPAT=252,
 	RT_TABLE_DEFAULT=253,
 	RT_TABLE_MAIN=254,
 	RT_TABLE_LOCAL=255,
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 3b83c34..0d4d728 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -960,7 +960,10 @@ int fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
 	rtm->rtm_dst_len = dst_len;
 	rtm->rtm_src_len = 0;
 	rtm->rtm_tos = tos;
-	rtm->rtm_table = tb_id;
+	if (tb_id < 256)
+		rtm->rtm_table = tb_id;
+	else
+		rtm->rtm_table = RT_TABLE_COMPAT;
 	NLA_PUT_U32(skb, RTA_TABLE, tb_id);
 	rtm->rtm_type = type;
 	rtm->rtm_flags = fi->fib_flags;
-- 
1.5.5.3

