From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2] netfilter: nf_sockopt_find() / nf_register_sockopt()
 should not return EINTR
Date: Thu, 24 Jul 2014 22:41:35 +0200
Message-ID: <1406234495.3363.79.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1406155995.3363.19.camel@edumazet-glaptop2.roam.corp.google.com>
	 <3ff5bf70-5db3-4dc4-9f02-abb07843ab81@email.android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:59078 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934176AbaGXUln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2014 16:41:43 -0400
In-Reply-To: <3ff5bf70-5db3-4dc4-9f02-abb07843ab81@email.android.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

getsockopt() or setsockopt() sometimes returns -EINTR instead of
-ENOPROTOOPT, causing headaches to application developers.

This is because unsupported commands might go through nf_sockopt_find()
and this function returns -EINTR if a signal is pending.

Just use non interruptible mutex functions, as there is no reason
we should sleep for a long time here.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
v2: at Patrick suggestion simply use mutex_lock()

 net/netfilter/nf_sockopt.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/nf_sockopt.c b/net/netfilter/nf_sockopt.c
index f042ae521557..3e59a465407b 100644
--- a/net/netfilter/nf_sockopt.c
+++ b/net/netfilter/nf_sockopt.c
@@ -26,8 +26,7 @@ int nf_register_sockopt(struct nf_sockopt_ops *reg)
 	struct nf_sockopt_ops *ops;
 	int ret = 0;
 
-	if (mutex_lock_interruptible(&nf_sockopt_mutex) != 0)
-		return -EINTR;
+	mutex_lock(&nf_sockopt_mutex);
 
 	list_for_each_entry(ops, &nf_sockopts, list) {
 		if (ops->pf == reg->pf
@@ -65,8 +64,7 @@ static struct nf_sockopt_ops *nf_sockopt_find(struct sock *sk, u_int8_t pf,
 {
 	struct nf_sockopt_ops *ops;
 
-	if (mutex_lock_interruptible(&nf_sockopt_mutex) != 0)
-		return ERR_PTR(-EINTR);
+	mutex_lock(&nf_sockopt_mutex);
 
 	list_for_each_entry(ops, &nf_sockopts, list) {
 		if (ops->pf == pf) {
