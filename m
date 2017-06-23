From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next] tcp: fix out-of-bounds access in ULP sysctl
Date: Thu, 22 Jun 2017 18:57:55 -0700
Message-ID: <20170623015755.23499-1-jakub.kicinski@netronome.com>
Cc: Boris Pismenny <borisp@mellanox.com>,
        Dave Watson <davejwatson@fb.com>, oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:33054 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753785AbdFWB6H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 21:58:07 -0400
Received: by mail-pf0-f171.google.com with SMTP id e7so16889623pfk.0
        for <netdev@vger.kernel.org>; Thu, 22 Jun 2017 18:58:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

KASAN reports out-of-bound access in proc_dostring() coming from
proc_tcp_available_ulp() because in case TCP ULP list is empty
the buffer allocated for the response will not have anything
printed into it.  Set the first byte to zero to avoid strlen()
going out-of-bounds.

Fixes: 734942cc4ea6 ("tcp: ULP infrastructure")
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 net/ipv4/tcp_ulp.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/tcp_ulp.c b/net/ipv4/tcp_ulp.c
index e855ea70819b..2417f55374c5 100644
--- a/net/ipv4/tcp_ulp.c
+++ b/net/ipv4/tcp_ulp.c
@@ -88,6 +88,7 @@ void tcp_get_available_ulp(char *buf, size_t maxlen)
 	struct tcp_ulp_ops *ulp_ops;
 	size_t offs = 0;
 
+	*buf = '\0';
 	rcu_read_lock();
 	list_for_each_entry_rcu(ulp_ops, &tcp_ulp_list, list) {
 		offs += snprintf(buf + offs, maxlen - offs,
-- 
2.11.0
