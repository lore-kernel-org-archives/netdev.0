From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 2.6.26-rc4] fix double call of kfree_skb in
	net/llc/llc_sap.c
Date: Wed, 28 May 2008 17:16:33 -0300
Message-ID: <20080528201633.GK30251@ghostprotocols.net>
References: <84ee89da0805270009xe92f7e1l959fa9161c976db2@mail.gmail.com> <483BB8EF.4090904@cn.fujitsu.com> <84ee89da0805270047v1c76b4f3k5768fe853f2cea1d@mail.gmail.com> <483BC1B0.2090600@cn.fujitsu.com> <84ee89da0805270235t7ae75356la2ffbb5244de2f74@mail.gmail.com> <84ee89da0805280359mcbc43f0q33f29960af20fba1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wei Yongjun <yjwei@cn.fujitsu.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Dmitry Petukhov <dmgenp@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52038 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752669AbYE1UQo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 May 2008 16:16:44 -0400
Content-Disposition: inline
In-Reply-To: <84ee89da0805280359mcbc43f0q33f29960af20fba1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Wed, May 28, 2008 at 04:59:45PM +0600, Dmitry Petukhov escreveu:
> 2008/5/27 Dmitry Petukhov <dmgenp@gmail.com>:
> > 2008/5/27 Wei Yongjun <yjwei@cn.fujitsu.com>:
> >
> >> Normally,
> >>
> >> skb_get()         (**return )
> >> kfree_skb()
> >>
> >> will do nothing. If you return with no kfree_skb(), it will let that skb can
> >> not be free.
> >>
> >> skb_get()
> >> kfree_skb()
> >> kfree_skb()
> >>
> >> do the real free.
> >
> > Yeah, you're right. Looks like we mislocated the root of our problem
> > (llc socket hangs on receive). Will debug further .
> > Thanks for explanation.
> >
> 
> Looks like we found the real root of our problem.
> file net/llc/llc_sap.c:
> 
> skb_set_owner_r is called before llc_sap_rcv in two places (lines 363, 384)
> skb_set_owner_r do this:
> atomic_add(skb->truesize, &sk->sk_rmem_alloc);
> 
> and in llc_sap_state_process, on line 223 sock_queue_rcv_skb is
> called, which also calls set_owner_r,
> which in turn adds skb->truesize to sk->sk_rmem_alloc once more.
> This double-addition results in sk_mem_alloc growth to exceed sk_rcvbuf.
> We can observe this in  /proc/net/llc/socket, rx_queue field.
> after this value exceeds sk_rcvbuf, sock_queue_rcv_skb always return
> -ENOMEM, and
> socket stops receiving.
> 
> //note: please CC me on reply, i'm not subscribed to the list.

Good catch, that code needs some revisiting after all these years...
Anyway, can you please try this patch and report results? Compile tested
only:

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


