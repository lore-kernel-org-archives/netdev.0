From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: md5: dont write skb head in
 tcp_md5_hash_header()
Date: Fri, 21 Oct 2011 14:01:35 +0200
Message-ID: <1319198495.2338.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:63509 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754456Ab1JUMBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2011 08:01:38 -0400
Received: by wwn22 with SMTP id 22so775717wwn.1
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2011 05:01:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp_md5_hash_header() writes into skb header a temporary zero value,
this might confuse other users of this area.

Since tcphdr is small (20 bytes), copy it in a temporary variable and
make the change in the copy.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/tcp.h |    2 +-
 net/ipv4/tcp.c    |   14 ++++++++------
 2 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 3edef0b..910cc29 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1209,7 +1209,7 @@ extern void tcp_free_md5sig_pool(void);
 extern struct tcp_md5sig_pool	*tcp_get_md5sig_pool(void);
 extern void tcp_put_md5sig_pool(void);
 
-extern int tcp_md5_hash_header(struct tcp_md5sig_pool *, struct tcphdr *);
+extern int tcp_md5_hash_header(struct tcp_md5sig_pool *, const struct tcphdr *);
 extern int tcp_md5_hash_skb_data(struct tcp_md5sig_pool *, const struct sk_buff *,
 				 unsigned header_len);
 extern int tcp_md5_hash_key(struct tcp_md5sig_pool *hp,
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 704adad..eefc61e 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2994,17 +2994,19 @@ void tcp_put_md5sig_pool(void)
 EXPORT_SYMBOL(tcp_put_md5sig_pool);
 
 int tcp_md5_hash_header(struct tcp_md5sig_pool *hp,
-			struct tcphdr *th)
+			const struct tcphdr *th)
 {
 	struct scatterlist sg;
+	struct tcphdr hdr;
 	int err;
 
-	__sum16 old_checksum = th->check;
-	th->check = 0;
+	/* We are not allowed to change tcphdr, make a local copy */
+	memcpy(&hdr, th, sizeof(hdr));
+	hdr.check = 0;
+
 	/* options aren't included in the hash */
-	sg_init_one(&sg, th, sizeof(struct tcphdr));
-	err = crypto_hash_update(&hp->md5_desc, &sg, sizeof(struct tcphdr));
-	th->check = old_checksum;
+	sg_init_one(&sg, &hdr, sizeof(hdr));
+	err = crypto_hash_update(&hp->md5_desc, &sg, sizeof(hdr));
 	return err;
 }
 EXPORT_SYMBOL(tcp_md5_hash_header);
