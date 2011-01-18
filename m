From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: filter: dont block softirqs in sk_run_filter()
Date: Tue, 18 Jan 2011 18:46:52 +0100
Message-ID: <1295372812.3290.35.camel@edumazet-laptop>
References: <1295368755-20931-1-git-send-email-ian.molton@collabora.co.uk>
	 <1295371361.3290.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>,
	ebiederm@xmission.com, xemul@openvz.org, davidel@xmailserver.org,
	Alban Crequy <alban.crequy@collabora.co.uk>,
	Ian Molton <ian.molton@collabora.co.uk>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:40535 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751032Ab1ARRrf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 12:47:35 -0500
In-Reply-To: <1295371361.3290.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Packet filter (BPF) doesnt need to disable softirqs, being fully
re-entrant and lock-less.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/sock.h     |    2 +-
 net/core/filter.c      |    6 +++---
 net/packet/af_packet.c |    6 +++---
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index d884d26..ba6465b 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1189,7 +1189,7 @@ extern void sk_filter_release_rcu(struct rcu_head *rcu);
 static inline void sk_filter_release(struct sk_filter *fp)
 {
 	if (atomic_dec_and_test(&fp->refcnt))
-		call_rcu_bh(&fp->rcu, sk_filter_release_rcu);
+		call_rcu(&fp->rcu, sk_filter_release_rcu);
 }
 
 static inline void sk_filter_uncharge(struct sock *sk, struct sk_filter *fp)
diff --git a/net/core/filter.c b/net/core/filter.c
index afc5837..232b187 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -142,14 +142,14 @@ int sk_filter(struct sock *sk, struct sk_buff *skb)
 	if (err)
 		return err;
 
-	rcu_read_lock_bh();
-	filter = rcu_dereference_bh(sk->sk_filter);
+	rcu_read_lock();
+	filter = rcu_dereference(sk->sk_filter);
 	if (filter) {
 		unsigned int pkt_len = sk_run_filter(skb, filter->insns);
 
 		err = pkt_len ? pskb_trim(skb, pkt_len) : -EPERM;
 	}
-	rcu_read_unlock_bh();
+	rcu_read_unlock();
 
 	return err;
 }
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 91cb1d7..c3fc7b7 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -523,11 +523,11 @@ static inline unsigned int run_filter(const struct sk_buff *skb,
 {
 	struct sk_filter *filter;
 
-	rcu_read_lock_bh();
-	filter = rcu_dereference_bh(sk->sk_filter);
+	rcu_read_lock();
+	filter = rcu_dereference(sk->sk_filter);
 	if (filter != NULL)
 		res = sk_run_filter(skb, filter->insns);
-	rcu_read_unlock_bh();
+	rcu_read_unlock();
 
 	return res;
 }


