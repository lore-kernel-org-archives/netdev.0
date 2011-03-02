From: kaber@trash.net
Subject: [PATCH 2/2] netfilter: nf_log: avoid oops in (un)bind with invalid nfproto values
Date: Wed,  2 Mar 2011 12:56:21 +0100
Message-ID: <1299066981-14058-3-git-send-email-kaber@trash.net>
References: <1299066981-14058-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:65383 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757094Ab1CBL4g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 06:56:36 -0500
In-Reply-To: <1299066981-14058-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>

Like many other places, we have to check that the array index is
within allowed limits, or otherwise, a kernel oops and other nastiness
can ensue when we access memory beyond the end of the array.

[ 5954.115381] BUG: unable to handle kernel paging request at 0000004000000000
[ 5954.120014] IP:  __find_logger+0x6f/0xa0
[ 5954.123979]  nf_log_bind_pf+0x2b/0x70
[ 5954.123979]  nfulnl_recv_config+0xc0/0x4a0 [nfnetlink_log]
[ 5954.123979]  nfnetlink_rcv_msg+0x12c/0x1b0 [nfnetlink]
...

The problem goes back to v2.6.30-rc1~1372~1342~31 where nf_log_bind
was decoupled from nf_log_register.

Reported-by: Miguel Di Ciurcio Filho <miguel.filho@gmail.com>,
  via irc.freenode.net/#netfilter
Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nf_log.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index b07393e..9181699 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -85,6 +85,8 @@ EXPORT_SYMBOL(nf_log_unregister);
 
 int nf_log_bind_pf(u_int8_t pf, const struct nf_logger *logger)
 {
+	if (pf >= ARRAY_SIZE(nf_loggers))
+		return -EINVAL;
 	mutex_lock(&nf_log_mutex);
 	if (__find_logger(pf, logger->name) == NULL) {
 		mutex_unlock(&nf_log_mutex);
@@ -98,6 +100,8 @@ EXPORT_SYMBOL(nf_log_bind_pf);
 
 void nf_log_unbind_pf(u_int8_t pf)
 {
+	if (pf >= ARRAY_SIZE(nf_loggers))
+		return;
 	mutex_lock(&nf_log_mutex);
 	rcu_assign_pointer(nf_loggers[pf], NULL);
 	mutex_unlock(&nf_log_mutex);
-- 
1.7.4

