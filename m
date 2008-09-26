From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: key: Free dumping state on socket close
Date: Fri, 26 Sep 2008 09:08:40 +0300
Message-ID: <48DC7C68.1060507@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:37261 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750917AbYIZGIl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2008 02:08:41 -0400
Received: by ey-out-2122.google.com with SMTP id 6so264753eyi.37
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2008 23:08:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a xfrm_{state,policy}_walk leak if pfkey socket is closed while
dumping is on-going.

Signed-off-by: Timo Teras <timo.teras@iki.fi>
---
Checked netlink code and the dumper clean up is done in there in
netlink_sock_destruct.

I'll update the "put dumpers on dump list" patch by making the
state release a function since there's the skb to free too.

 net/key/af_key.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index d628df9..97007de 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -89,6 +89,14 @@ static int pfkey_do_dump(struct pfkey_sock *pfk)
 
 static void pfkey_sock_destruct(struct sock *sk)
 {
+	struct pfkey_sock *pfk = pfkey_sk(sk);
+
+	if (pfk->dump.dump) {
+		pfk->dump.done(pfk);
+		pfk->dump.dump = NULL;
+		pfk->dump.done = NULL;
+	}
+
 	skb_queue_purge(&sk->sk_receive_queue);
 
 	if (!sock_flag(sk, SOCK_DEAD)) {
-- 
1.5.4.3
