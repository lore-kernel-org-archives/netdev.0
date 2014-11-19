From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH net] pptp: fix stack info leak in pptp_getname()
Date: Wed, 19 Nov 2014 18:05:26 +0100
Message-ID: <1416416726-11886-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, Mathias Krause <minipli@googlemail.com>,
	Dmitry Kozlov <xeb@mail.ru>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:55183 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752950AbaKSRFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 12:05:41 -0500
Received: by mail-wi0-f180.google.com with SMTP id n3so2640974wiv.1
        for <netdev@vger.kernel.org>; Wed, 19 Nov 2014 09:05:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pptp_getname() only partially initializes the stack variable sa,
particularly only fills the pptp part of the sa_addr union. The code
thereby discloses 16 bytes of kernel stack memory via getsockname().

Fix this by memset(0)'ing the union before.

Cc: Dmitry Kozlov <xeb@mail.ru>
Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
Probably material for stable, too -- v2.6.37+.

 drivers/net/ppp/pptp.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
index 1aff970be33e..1dc628ffce2b 100644
--- a/drivers/net/ppp/pptp.c
+++ b/drivers/net/ppp/pptp.c
@@ -506,7 +506,9 @@ static int pptp_getname(struct socket *sock, struct sockaddr *uaddr,
 	int len = sizeof(struct sockaddr_pppox);
 	struct sockaddr_pppox sp;
 
-	sp.sa_family	  = AF_PPPOX;
+	memset(&sp.sa_addr, 0, sizeof(sp.sa_addr));
+
+	sp.sa_family    = AF_PPPOX;
 	sp.sa_protocol  = PX_PROTO_PPTP;
 	sp.sa_addr.pptp = pppox_sk(sock->sk)->proto.pptp.src_addr;
 
-- 
1.7.10.4
