From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net/llc: avoid BUG_ON() in skb_orphan()
Date: Sun, 12 Feb 2017 14:03:52 -0800
Message-ID: <1486937032.8227.14.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAAeHK+yzH_M4uzetrMQPMgYBNDXYAp0V11DcMtUgNWVvPg4x=g@mail.gmail.com>
         <CANn89iKww-oSWGWx-PZ_gXYmeFr8NSwJS55vNB=jyaBghTmtvA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrey Konovalov <andreyknvl@google.com>, acme@redhat.com,
        netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34083 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751327AbdBLWDy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2017 17:03:54 -0500
Received: by mail-pg0-f67.google.com with SMTP id v184so7918173pgv.1
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 14:03:53 -0800 (PST)
In-Reply-To: <CANn89iKww-oSWGWx-PZ_gXYmeFr8NSwJS55vNB=jyaBghTmtvA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

It seems nobody used LLC since linux-3.12.

Fortunately fuzzers like syzkaller still know how to run this code,
otherwise it would be no fun.

Setting skb->sk without skb->destructor leads to all kinds of
bugs, we now prefer to be very strict about it.

Ideally here we would use skb_set_owner() but this helper does not exist yet,
only CAN seems to have a private helper for that.

Fixes: 376c7311bdb6 ("net: add a temporary sanity check in skb_orphan()")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Andrey Konovalov <andreyknvl@google.com>
---
 net/llc/llc_conn.c |    3 +++
 net/llc/llc_sap.c  |    3 +++
 2 files changed, 6 insertions(+)

diff --git a/net/llc/llc_conn.c b/net/llc/llc_conn.c
index 3e821daf9dd4a2fbf00550591e92b153efd4a73a..8bc5a1bd2d453542df31506f543feb64b64cdd96 100644
--- a/net/llc/llc_conn.c
+++ b/net/llc/llc_conn.c
@@ -821,7 +821,10 @@ void llc_conn_handler(struct llc_sap *sap, struct sk_buff *skb)
 		 * another trick required to cope with how the PROCOM state
 		 * machine works. -acme
 		 */
+		skb_orphan(skb);
+		sock_hold(sk);
 		skb->sk = sk;
+		skb->destructor = sock_efree;
 	}
 	if (!sock_owned_by_user(sk))
 		llc_conn_rcv(sk, skb);
diff --git a/net/llc/llc_sap.c b/net/llc/llc_sap.c
index d0e1e804ebd73dcebcf2f930b921233a49b0f454..5404d0d195cc581613e356b75bd70321e617673e 100644
--- a/net/llc/llc_sap.c
+++ b/net/llc/llc_sap.c
@@ -290,7 +290,10 @@ static void llc_sap_rcv(struct llc_sap *sap, struct sk_buff *skb,
 
 	ev->type   = LLC_SAP_EV_TYPE_PDU;
 	ev->reason = 0;
+	skb_orphan(skb);
+	sock_hold(sk);
 	skb->sk = sk;
+	skb->destructor = sock_efree;
 	llc_sap_state_process(sap, skb);
 }
 
