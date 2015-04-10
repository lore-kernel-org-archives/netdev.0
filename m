From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next v2 1/5] fou: avoid calling udp_del_offload() twice
Date: Fri, 10 Apr 2015 12:00:26 -0700
Message-ID: <1428692430-14465-2-git-send-email-xiyou.wangcong@gmail.com>
References: <1428692430-14465-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Tom Herbert <tom@herbertland.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:35625 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754914AbbDJTAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 15:00:42 -0400
Received: by pddn5 with SMTP id n5so31194475pdd.2
        for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 12:00:41 -0700 (PDT)
In-Reply-To: <1428692430-14465-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes the following harmless warning:

./ip/ip fou del port 7777
[  122.907516] udp_del_offload: didn't find offload for port 7777

Cc: Tom Herbert <tom@herbertland.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv4/fou.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index ff069f6..c8db627 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -410,7 +410,8 @@ static void fou_release(struct fou *fou)
 	struct socket *sock = fou->sock;
 	struct sock *sk = sock->sk;
 
-	udp_del_offload(&fou->udp_offloads);
+	if (sk->sk_family == AF_INET)
+		udp_del_offload(&fou->udp_offloads);
 
 	list_del(&fou->list);
 
@@ -528,7 +529,6 @@ static int fou_destroy(struct net *net, struct fou_cfg *cfg)
 	spin_lock(&fou_lock);
 	list_for_each_entry(fou, &fou_list, list) {
 		if (fou->port == port) {
-			udp_del_offload(&fou->udp_offloads);
 			fou_release(fou);
 			err = 0;
 			break;
-- 
1.8.3.1
