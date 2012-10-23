From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 2/3] inet-diag: Get more bits for extension flag
Date: Tue, 23 Oct 2012 20:26:04 +0400
Message-ID: <5086C51C.7040403@parallels.com>
References: <5086C36B.6060508@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:12496 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757023Ab2JWQ0I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2012 12:26:08 -0400
In-Reply-To: <5086C36B.6060508@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The inet-diag dumping request carries 8-bit ext value which denotes what
additional info we want to see. Unfortunately there's only one bit left
on it and occupying one with the "I want shutdown" is unwanted.

However, there are 8 more bits in the request and this "pad" field is
currently unused. I propose to make the 8th bit of the existing ext flag
mean "this unused space contains more ext bits".

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
---
 include/uapi/linux/inet_diag.h |    3 ++-
 net/ipv4/inet_diag.c           |    3 +++
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/include/uapi/linux/inet_diag.h b/include/uapi/linux/inet_diag.h
index 8c469af..c5e14f6 100644
--- a/include/uapi/linux/inet_diag.h
+++ b/include/uapi/linux/inet_diag.h
@@ -38,7 +38,7 @@ struct inet_diag_req_v2 {
 	__u8	sdiag_family;
 	__u8	sdiag_protocol;
 	__u8	idiag_ext;
-	__u8	pad;
+	__u8	idiag_ext2;
 	__u32	idiag_states;
 	struct inet_diag_sockid id;
 };
@@ -109,6 +109,7 @@ enum {
 	INET_DIAG_TOS,
 	INET_DIAG_TCLASS,
 	INET_DIAG_SKMEMINFO,
+	__INET_DIAG_EXT2,
 };
 
 #define INET_DIAG_MAX INET_DIAG_SKMEMINFO
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 535584c..52db768 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -81,6 +81,9 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 	const struct inet_diag_handler *handler;
 	int ext = req->idiag_ext;
 
+	if (ext & (1 << (__INET_DIAG_EXT2 - 1)))
+		ext |= req->idiag_ext2 << __INET_DIAG_EXT2;
+
 	handler = inet_diag_table[req->sdiag_protocol];
 	BUG_ON(handler == NULL);
 
-- 
1.7.6.5
