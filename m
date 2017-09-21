From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: prevent dst uses after free
Date: Thu, 21 Sep 2017 09:15:46 -0700
Message-ID: <1506010546.29839.148.camel@edumazet-glaptop3.roam.corp.google.com>
References: <4745525f-18e4-7f69-fe21-8e507e407b33@itcare.pl>
         <3c227be7-a954-a406-1987-24e908cf214c@itcare.pl>
         <CAM_iQpUOOCcES4d_ueK2wizn2oyDZPEzLfWQFu3oOq=BuRzdiw@mail.gmail.com>
         <1505932231.29839.106.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpVF3Gf3G=543o8g+5N2dtEL4DcUPN3a6=L8V_G0CXZ65w@mail.gmail.com>
         <07f0c800-7ee7-1ebe-9f5f-eaad52a7b42d@itcare.pl>
         <548a893c-8a8f-3b07-00f7-d75de1d777ad@itcare.pl>
         <7d8731ee-6c91-bbfd-6313-c95f52d7b49a@itcare.pl>
         <26e8b899-d8b1-caa4-436b-e23ffe384b0f@itcare.pl>
         <6c36fa00-13e6-8cd7-ff5c-df7739220736@itcare.pl>
         <CAEA6p_DpSr84cYu3pXqoHV=V=daSsbiOcnzsF+Kt0r4Wv_jmdg@mail.gmail.com>
         <CAEA6p_AiLvZxsyu+iOCrPzW-H28N=HBnWycy8w6gdZHFk2Q1dQ@mail.gmail.com>
         <1505956639.29839.108.camel@edumazet-glaptop3.roam.corp.google.com>
         <a016d5bc-1cbb-44d7-9ebf-e7e5428e6f98@itcare.pl>
         <1505991826.29839.124.camel@edumazet-glaptop3.roam.corp.google.com>
         <8d2b4263-bd81-9cff-81ac-2df686cf29aa@itcare.pl>
         <80e8948e-669b-4139-add6-637c6dd3405f@itcare.pl>
         <1506005799.29839.130.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Wei Wang <weiwan@google.com>, Cong Wang <xiyou.wangcong@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: =?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:37370 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751531AbdIUQPt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 12:15:49 -0400
Received: by mail-pf0-f195.google.com with SMTP id e69so2664077pfg.4
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 09:15:49 -0700 (PDT)
In-Reply-To: <1506005799.29839.130.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

In linux-4.13, Wei worked hard to convert dst to a traditional
refcounted model, removing GC.

We now want to make sure a dst refcount can not transition from 0 back
to 1.

The problem here is that input path attached a not refcounted dst to an
skb. Then later, because packet is forwarded and hits skb_dst_force()
before exiting RCU section, we might try to take a refcount on one dst
that is about to be freed, if another cpu saw 1 -> 0 transition in
dst_release() and queued the dst for freeing after one RCU grace period.

Lets unify skb_dst_force() and skb_dst_force_safe(), since we should
always perform the complete check against dst refcount, and not assume
it is not zero.

Bugzilla : https://bugzilla.kernel.org/show_bug.cgi?id=197005

[  989.919496]  skb_dst_force+0x32/0x34
[  989.919498]  __dev_queue_xmit+0x1ad/0x482
[  989.919501]  ? eth_header+0x28/0xc6
[  989.919502]  dev_queue_xmit+0xb/0xd
[  989.919504]  neigh_connected_output+0x9b/0xb4
[  989.919507]  ip_finish_output2+0x234/0x294
[  989.919509]  ? ipt_do_table+0x369/0x388
[  989.919510]  ip_finish_output+0x12c/0x13f
[  989.919512]  ip_output+0x53/0x87
[  989.919513]  ip_forward_finish+0x53/0x5a
[  989.919515]  ip_forward+0x2cb/0x3e6
[  989.919516]  ? pskb_trim_rcsum.part.9+0x4b/0x4b
[  989.919518]  ip_rcv_finish+0x2e2/0x321
[  989.919519]  ip_rcv+0x26f/0x2eb
[  989.919522]  ? vlan_do_receive+0x4f/0x289
[  989.919523]  __netif_receive_skb_core+0x467/0x50b
[  989.919526]  ? tcp_gro_receive+0x239/0x239
[  989.919529]  ? inet_gro_receive+0x226/0x238
[  989.919530]  __netif_receive_skb+0x4d/0x5f
[  989.919532]  netif_receive_skb_internal+0x5c/0xaf
[  989.919533]  napi_gro_receive+0x45/0x81
[  989.919536]  ixgbe_poll+0xc8a/0xf09
[  989.919539]  ? kmem_cache_free_bulk+0x1b6/0x1f7
[  989.919540]  net_rx_action+0xf4/0x266
[  989.919543]  __do_softirq+0xa8/0x19d
[  989.919545]  irq_exit+0x5d/0x6b
[  989.919546]  do_IRQ+0x9c/0xb5
[  989.919548]  common_interrupt+0x93/0x93
[  989.919548]  </IRQ>


Similarly dst_clone() can use dst_hold() helper to have additional
debugging, as a follow up to commit 44ebe79149ff ("net: add debug
atomic_inc_not_zero() in dst_hold()")

In net-next we will convert dst atomic_t to refcount_t for peace of
mind.

Fixes: a4c2fd7f7891 ("net: remove DST_NOCACHE flag")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Wei Wang <weiwan@google.com>
Reported-by: Paweł Staszewski <pstaszewski@itcare.pl>
Bisected-by: Paweł Staszewski <pstaszewski@itcare.pl>
---
 include/net/dst.h   |   22 ++++------------------
 include/net/route.h |    2 +-
 include/net/sock.h  |    2 +-
 3 files changed, 6 insertions(+), 20 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 93568bd0a3520bb7402f04d90cf04ac99c81cfbe..06a6765da074449e6f1fe42ee05e711e898ad372 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -271,7 +271,7 @@ static inline void dst_use_noref(struct dst_entry *dst, unsigned long time)
 static inline struct dst_entry *dst_clone(struct dst_entry *dst)
 {
 	if (dst)
-		atomic_inc(&dst->__refcnt);
+		dst_hold(dst);
 	return dst;
 }
 
@@ -311,21 +311,6 @@ static inline void skb_dst_copy(struct sk_buff *nskb, const struct sk_buff *oskb
 	__skb_dst_copy(nskb, oskb->_skb_refdst);
 }
 
-/**
- * skb_dst_force - makes sure skb dst is refcounted
- * @skb: buffer
- *
- * If dst is not yet refcounted, let's do it
- */
-static inline void skb_dst_force(struct sk_buff *skb)
-{
-	if (skb_dst_is_noref(skb)) {
-		WARN_ON(!rcu_read_lock_held());
-		skb->_skb_refdst &= ~SKB_DST_NOREF;
-		dst_clone(skb_dst(skb));
-	}
-}
-
 /**
  * dst_hold_safe - Take a reference on a dst if possible
  * @dst: pointer to dst entry
@@ -339,16 +324,17 @@ static inline bool dst_hold_safe(struct dst_entry *dst)
 }
 
 /**
- * skb_dst_force_safe - makes sure skb dst is refcounted
+ * skb_dst_force - makes sure skb dst is refcounted
  * @skb: buffer
  *
  * If dst is not yet refcounted and not destroyed, grab a ref on it.
  */
-static inline void skb_dst_force_safe(struct sk_buff *skb)
+static inline void skb_dst_force(struct sk_buff *skb)
 {
 	if (skb_dst_is_noref(skb)) {
 		struct dst_entry *dst = skb_dst(skb);
 
+		WARN_ON(!rcu_read_lock_held());
 		if (!dst_hold_safe(dst))
 			dst = NULL;
 
diff --git a/include/net/route.h b/include/net/route.h
index 1b09a9368c68d46f0c5ee8ce3cefe566000c1ec1..57dfc6850d378e4b96f13b140eef554d66c24cdf 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -190,7 +190,7 @@ static inline int ip_route_input(struct sk_buff *skb, __be32 dst, __be32 src,
 	rcu_read_lock();
 	err = ip_route_input_noref(skb, dst, src, tos, devin);
 	if (!err) {
-		skb_dst_force_safe(skb);
+		skb_dst_force(skb);
 		if (!skb_dst(skb))
 			err = -EINVAL;
 	}
diff --git a/include/net/sock.h b/include/net/sock.h
index 03a362568357acc7278a318423dd3873103f90ca..a6b9a8d1a6df3f72df8f1aac0f577257fa6452d0 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -856,7 +856,7 @@ void sk_stream_write_space(struct sock *sk);
 static inline void __sk_add_backlog(struct sock *sk, struct sk_buff *skb)
 {
 	/* dont let skb dst not refcounted, we are going to leave rcu lock */
-	skb_dst_force_safe(skb);
+	skb_dst_force(skb);
 
 	if (!sk->sk_backlog.tail)
 		sk->sk_backlog.head = skb;
