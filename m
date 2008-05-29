From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCH][LLC]: Fix double accounting of received packets
Date: Thu, 29 May 2008 10:44:41 -0300
Message-ID: <20080529134441.GT30251@ghostprotocols.net>
References: <84ee89da0805280359mcbc43f0q33f29960af20fba1@mail.gmail.com> <20080528201633.GK30251@ghostprotocols.net> <84ee89da0805290151o500f1d5bg542f3ee9dff18be6@mail.gmail.com> <20080529.034510.89175399.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dmgenp@gmail.com, acme@redhat.com, yjwei@cn.fujitsu.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:43738 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756428AbYE2Nov (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2008 09:44:51 -0400
Content-Disposition: inline
In-Reply-To: <20080529.034510.89175399.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David, please apply.

- Arnaldo

commit 3eb2a480af55fe7494c1601b6b7eda499cd67ddd
Author: Arnaldo Carvalho de Melo <acme@redhat.com>
Date:   Thu May 29 10:33:00 2008 -0300

    [LLC]: Fix double accounting of received packets
    
    llc_sap_rcv was being preceded by skb_set_owner_r, then calling
    llc_state_process that calls sock_queue_rcv_skb, that in turn calls
    skb_set_owner_r again making the space allowed to be used by the socket to be
    leaked, making the socket to get stuck.
    
    Fix it by setting skb->sk at llc_sap_rcv and leave the accounting to be done
    only at sock_queue_rcv_skb.
    
    Reported-by: Dmitry Petukhov <dmgenp@gmail.com>
    Tested-by: Dmitry Petukhov <dmgenp@gmail.com>
    Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

diff --git a/net/llc/llc_sap.c b/net/llc/llc_sap.c
index e2ddde7..008de1f 100644
--- a/net/llc/llc_sap.c
+++ b/net/llc/llc_sap.c
@@ -286,12 +286,14 @@ void llc_build_and_send_xid_pkt(struct llc_sap *sap, struct sk_buff *skb,
  *
  *	Sends received pdus to the sap state machine.
  */
-static void llc_sap_rcv(struct llc_sap *sap, struct sk_buff *skb)
+static void llc_sap_rcv(struct llc_sap *sap, struct sk_buff *skb,
+			struct sock *sk)
 {
 	struct llc_sap_state_ev *ev = llc_sap_ev(skb);
 
 	ev->type   = LLC_SAP_EV_TYPE_PDU;
 	ev->reason = 0;
+	skb->sk = sk;
 	llc_sap_state_process(sap, skb);
 }
 
@@ -360,8 +362,7 @@ static void llc_sap_mcast(struct llc_sap *sap,
 			break;
 
 		sock_hold(sk);
-		skb_set_owner_r(skb1, sk);
-		llc_sap_rcv(sap, skb1);
+		llc_sap_rcv(sap, skb1, sk);
 		sock_put(sk);
 	}
 	read_unlock_bh(&sap->sk_list.lock);
@@ -381,8 +382,7 @@ void llc_sap_handler(struct llc_sap *sap, struct sk_buff *skb)
 	} else {
 		struct sock *sk = llc_lookup_dgram(sap, &laddr);
 		if (sk) {
-			skb_set_owner_r(skb, sk);
-			llc_sap_rcv(sap, skb);
+			llc_sap_rcv(sap, skb, sk);
 			sock_put(sk);
 		} else
 			kfree_skb(skb);
