From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: Fix struct sock bitfield annotation
Date: Thu, 08 Oct 2009 17:16:13 +0200
Message-ID: <4ACE023D.9030208@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Vegard Nossum <vegard.nossum@gmail.com>,
	Ingo Molnar <mingo@elte.hu>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54593 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932695AbZJHPRD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2009 11:17:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit a98b65a3 (net: annotate struct sock bitfield), we lost 8 bytes
in struct sock on 64bits arches because of kmemcheck_bitfield_end(flags) misplacement.


struct good {
	int		begin_flags[0];
	unsigned char	a : 8;
	unsigned char	b;
	unsigned short	c;
	int		end_flags[0];
	int		sk_rcvbuf;
	void           *ptr;
};
struct bad {
	int		begin_flags[0];
	unsigned char	a : 8;
	int		end_flags[0];
	unsigned char	b;
	unsigned short	c;
	int		sk_rcvbuf;
	void           *ptr;
};
sizeof(struct good) = 16, sizeof(struct bad) = 24

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/sock.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 1621935..ecfb831 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -229,9 +229,9 @@ struct sock {
 	unsigned char		sk_shutdown : 2,
 				sk_no_check : 2,
 				sk_userlocks : 4;
-	kmemcheck_bitfield_end(flags);
 	unsigned char		sk_protocol;
 	unsigned short		sk_type;
+	kmemcheck_bitfield_end(flags);
 	int			sk_rcvbuf;
 	socket_lock_t		sk_lock;
 	/*
