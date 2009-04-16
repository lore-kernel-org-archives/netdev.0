From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 01/03: nf_log regression fix
Date: Thu, 16 Apr 2009 19:16:23 +0200 (MEST)
Message-ID: <20090416171622.11406.71514.sendpatchset@x2.localnet>
References: <20090416171621.11406.78609.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61771 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757019AbZDPRQZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 13:16:25 -0400
In-Reply-To: <20090416171621.11406.78609.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit b6f0a3652ea9d2296fdc98c3b2c96603be611c4d
Author: Eric Dumazet <dada1@cosmosbay.com>
Date:   Wed Apr 15 12:16:19 2009 +0200

    netfilter: nf_log regression fix
    
    commit ca735b3aaa945626ba65a3e51145bfe4ecd9e222
    'netfilter: use a linked list of loggers'
    introduced an array of list_head in "struct nf_logger", but
    forgot to initialize it in nf_log_register(). This resulted
    in oops when calling nf_log_unregister() at module unload time.
    
    Reported-and-tested-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
    Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
    Acked-by: Eric Leblond <eric@inl.fr>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index 8bb998f..beb3731 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -36,10 +36,14 @@ static struct nf_logger *__find_logger(int pf, const char *str_logger)
 int nf_log_register(u_int8_t pf, struct nf_logger *logger)
 {
 	const struct nf_logger *llog;
+	int i;
 
 	if (pf >= ARRAY_SIZE(nf_loggers))
 		return -EINVAL;
 
+	for (i = 0; i < ARRAY_SIZE(logger->list); i++)
+		INIT_LIST_HEAD(&logger->list[i]);
+
 	mutex_lock(&nf_log_mutex);
 
 	if (pf == NFPROTO_UNSPEC) {
