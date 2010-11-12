From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: [PATCH 5/10] Fix leaking of kernel heap addresses in net/
Date: Thu, 11 Nov 2010 20:07:09 -0500
Message-ID: <1289524029.5167.69.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	Hideaki YOSHI
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:60753 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755068Ab0KLBIf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 20:08:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

diff --git a/net/key/af_key.c b/net/key/af_key.c
index d87c22d..977481a 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -3643,14 +3643,25 @@ static int pfkey_seq_show(struct seq_file *f, void *v)
 	if (v == SEQ_START_TOKEN)
 		seq_printf(f ,"sk       RefCnt Rmem   Wmem   User   Inode\n");
 	else
-		seq_printf(f ,"%p %-6d %-6u %-6u %-6u %-6lu\n",
-			       s,
-			       atomic_read(&s->sk_refcnt),
-			       sk_rmem_alloc_get(s),
-			       sk_wmem_alloc_get(s),
-			       sock_i_uid(s),
-			       sock_i_ino(s)
-			       );
+		/* Only expose kernel addresses to privileged readers */
+		if (capable(CAP_NET_ADMIN))
+			seq_printf(f, "%p %-6d %-6u %-6u %-6u %-6lu\n",
+				s,
+				atomic_read(&s->sk_refcnt),
+				sk_rmem_alloc_get(s),
+				sk_wmem_alloc_get(s),
+				sock_i_uid(s),
+				sock_i_ino(s)
+				);
+		else
+			seq_printf(f, "%d %-6d %-6u %-6u %-6u %-6lu\n",
+				0,
+				atomic_read(&s->sk_refcnt),
+				sk_rmem_alloc_get(s),
+				sk_wmem_alloc_get(s),
+				sock_i_uid(s),
+				sock_i_ino(s)
+				);
 	return 0;
 }
 



