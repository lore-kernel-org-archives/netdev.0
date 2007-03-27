From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] NET : inet_ehash_secret should be __read_mostly and set
 only once
Date: Tue, 27 Mar 2007 12:13:43 +0200
Message-ID: <20070327121343.395a57e5.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:47379 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753623AbXC0KNp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 06:13:45 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David

Please find this patch against net-2.6.22

Thank you

[PATCH] NET : inet_ehash_secret should be __read_mostly and set only once

There is a very tiny probability that build_ehash_secret() is called at the same time by different CPUS.

Also, using __read_mostly is a must for inet_ehash_secret

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index b7b7278..597646b 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -218,13 +218,23 @@ out:
 	return err;
 }
 
-u32 inet_ehash_secret;
+u32 inet_ehash_secret __read_mostly;
 EXPORT_SYMBOL(inet_ehash_secret);
 
+/*
+ * inet_ehash_secret must be set exactly once
+ * Instead of using a dedicated spinlock, we (ab)use inetsw_lock
+ */
 void build_ehash_secret(void)
 {
-	while (!inet_ehash_secret)
-		get_random_bytes(&inet_ehash_secret, 4);
+	u32 rnd;
+	do {
+		get_random_bytes(&rnd, sizeof(rnd));
+	} while (rnd == 0);
+	spin_lock_bh(&inetsw_lock);
+	if (!inet_ehash_secret)
+		inet_ehash_secret = rnd;
+	spin_unlock_bh(&inetsw_lock);
 }
 EXPORT_SYMBOL(build_ehash_secret);
 
@@ -684,7 +694,8 @@ int inet_sendmsg(struct kiocb *iocb, str
 }
 
 
-static ssize_t inet_sendpage(struct socket *sock, struct page *page, int offset, size_t size, int flags)
+static ssize_t inet_sendpage(struct socket *sock, struct page *page, int offset,
+	size_t size, int flags)
 {
 	struct sock *sk = sock->sk;
 
