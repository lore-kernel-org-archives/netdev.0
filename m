From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: [patch net-next 1/2] [PATCH] net: ip, raw_diag -- Fix socket leaking for destroy request
Date: Wed, 02 Nov 2016 15:36:31 +0300
Message-ID: <20161102125454.694582296@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Andrey Vagin <avagin@openvz.org>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Cyrill Gorcunov <gorcunov@openvz.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f51.google.com ([209.85.215.51]:33576 "EHLO
        mail-lf0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753507AbcKBM4I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 08:56:08 -0400
Received: by mail-lf0-f51.google.com with SMTP id c13so11676189lfg.0
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 05:56:07 -0700 (PDT)
Content-Disposition: inline; filename=inet-diag-raw-add-sock_put
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In raw_diag_destroy the helper raw_sock_get returns
with sock_hold call, so we have to put it then.

CC: David S. Miller <davem@davemloft.net>
CC: Eric Dumazet <eric.dumazet@gmail.com>
CC: David Ahern <dsa@cumulusnetworks.com>
CC: Andrey Vagin <avagin@openvz.org>
CC: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
---
 net/ipv4/raw_diag.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

Index: linux-ml.git/net/ipv4/raw_diag.c
===================================================================
--- linux-ml.git.orig/net/ipv4/raw_diag.c
+++ linux-ml.git/net/ipv4/raw_diag.c
@@ -205,11 +205,14 @@ static int raw_diag_destroy(struct sk_bu
 {
 	struct net *net = sock_net(in_skb->sk);
 	struct sock *sk;
+	int err;
 
 	sk = raw_sock_get(net, r);
 	if (IS_ERR(sk))
 		return PTR_ERR(sk);
-	return sock_diag_destroy(sk, ECONNABORTED);
+	err = sock_diag_destroy(sk, ECONNABORTED);
+	sock_put(sk);
+	return err;
 }
 #endif
 
