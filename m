From: YueHaibing <yuehaibing@huawei.com>
Subject: Re: net/arp: ARP cache aging failed.
Date: Wed, 14 Dec 2016 18:54:07 +0800
Message-ID: <74d41c47-7091-3c52-096d-5b9af2e0e9cf@huawei.com>
References: <957c2a80-7302-1ce9-726e-1e7512a941f4@huawei.com>
 <alpine.LFD.2.11.1611230928140.1659@ja.home.ssi.bg>
 <1479902729.8455.479.camel@edumazet-glaptop3.roam.corp.google.com>
 <250d3a88-45ad-891f-389a-997f39d7bdad@stressinduktion.org>
 <1479944967.8455.516.camel@edumazet-glaptop3.roam.corp.google.com>
 <alpine.LFD.2.11.1611240931560.1685@ja.home.ssi.bg>
 <c82b7b44-c0ad-9ee7-1114-3eae3b5cf75a@huawei.com>
 <1fdf938e-600c-ce58-ece1-06b816ddba1c@stressinduktion.org>
 <alpine.LFD.2.11.1611250957100.1966@ja.home.ssi.bg>
 <40b84d35-4185-bfbc-7f85-9d6abf984d31@stressinduktion.org>
 <alpine.LFD.2.11.1611252140120.1888@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:4031 "EHLO
        szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753255AbcLNKze (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 05:55:34 -0500
In-Reply-To: <alpine.LFD.2.11.1611252140120.1888@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016/11/26 4:40, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Fri, 25 Nov 2016, Hannes Frederic Sowa wrote:
> 
>> On 25.11.2016 09:18, Julian Anastasov wrote:
>>>
>>> 	Another option would be to add similar bit to
>>> struct sock (sk_dst_pending_confirm), may be ip_finish_output2
>>> can propagate it to dst_neigh_output via new arg and then to
>>> reset it.
>>
>> I don't understand how this can help? Maybe I understood it wrong?
> 
> 	The idea is, the indication from highest level (TCP) to
> be propagated to lowest level (neigh).
> 
>>> Or to change n->confirmed via some new inline sock
>>> function instead of changing dst_neigh_output. At this place 
>>> skb->sk is optional, may be we need (skb->sk && dst ==
>>> skb->sk->sk_dst_cache) check. Also, when sk_dst_cache changes
>>> we should clear this flag.
>>
>> In "(skb->sk && dst == skb->sk->sk_dst_cache)" where does dst come from?
> 
> 	This is in case we do not want to propagate indication
> from TCP to tunnels, see below...
> 
>> I don't see a possibility besides using mac_header or inner_mac_header
>> to look up the incoming MAC address and confirm that one in the neighbor
>> cache so far (we could try to optimize this case for rt_gateway though).
> 
> 	My idea is as follows:
> 
> - TCP instead of calling dst_confirm should call new func
> dst_confirm_sk(sk) where sk->sk_dst_pending_confirm is set,
> not dst->pending_confirm.
> 
> - ip_finish_output2: use skb->sk (TCP) to check for
> sk_dst_pending_confirm and update n->confirmed in some
> new inline func
> 
> 	Correct me if I'm wrong but here is how I see the
> situation:
> 
> - TCP caches output dst in socket, for example, dst1,
> sets it as skb->dst
> 
> - if xfrm tunnels are used then dst1 can point to some tunnel,
> i.e. it is not in all cases the same skb->dst, as seen by 
> ip_finish_output2
> 
> - netfilter can DNAT and assign different skb->dst
> 
> - as result, before now, dst1->pending_confirm is set but
> it is not used properly because ip_finish_output2 uses
> the final skb->dst which can be different or with
> rt_gateway = 0
> 
> - considering that tunnels do not use dst_confirm,
> n->confirmed is not changed every time. There are some
> interesting cases:
> 
> 1. both dst1 and the final skb->dst point to same
> dst with rt_gateway = 0: n->confirmed is updated but
> as wee see it can be for wrong neigh.
> 
> 2. dst1 is different from skb->dst, so n->confirmed is
> not changed. This can happen on DNAT or when using
> tunnel to secure gateway.
> 
> - in ip_finish_output2 we have skb->sk (original TCP sk) and
> sk arg (equal to skb->sk or second option is sock of some UDP
> tunnel, etc). The idea is to use skb->sk->sk_dst_pending_confirm,
> i.e. highest level sk because the sk arg, if different, does not
> have such flag set (tunnels do not call dst_confirm).
> 
> - ip_finish_output2 should call new func dst_neigh_confirm_sk
> (which has nothing related to dst, hm... better name is needed):
> 
>  	if (!IS_ERR(neigh)) {
> -		int res = dst_neigh_output(dst, neigh, skb);
> +		int res;
> +
> +		dst_neigh_confirm_sk(skb->sk, neigh);
> +		res = dst_neigh_output(dst, neigh, skb);
> 
> 	which should do something like this:
> 
> 	if (sk && sk->sk_dst_pending_confirm) {
> 		unsigned long now = jiffies;
> 
> 		sk->sk_dst_pending_confirm = 0;
> 		/* avoid dirtying neighbour */
> 		if (n->confirmed != now)
> 			n->confirmed = now;
> 	}
> 
> 	Additional dst == skb->sk->sk_dst_cache check will
> not propagate the indication on DNAT/tunnel. For me,
> it is better without such check.
> 
> 	So, the idea is to move TCP and other similar
> users to the new dst_confirm_sk() method. If other
> dst_confirm() users are left, they should be checked
> if dsts with rt_gateway = 0 can be wrongly used.
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
> 
> .
> 

Sorry for so late.

Based on your ideas, I make a patch and test it for a while.

It works for me.

>From dc033fe4bac8931590e15774a298f04ccea8ed4c Mon Sep 17 00:00:00 2001
From: YueHabing <yuehaibing@huawei.com>
Date: Wed, 14 Dec 2016 02:43:51 -0500
Subject: [PATCH] arp: do neigh confirm based on sk arg

Signed-off-by: YueHabing <yuehaibing@huawei.com>
---
 include/net/sock.h     | 18 ++++++++++++++++++
 net/ipv4/ip_output.c   |  5 ++++-
 net/ipv4/ping.c        |  2 +-
 net/ipv4/raw.c         |  2 +-
 net/ipv4/tcp_input.c   |  8 ++------
 net/ipv4/tcp_metrics.c |  5 +++--
 net/ipv4/udp.c         |  2 +-
 net/ipv6/raw.c         |  2 +-
 net/ipv6/route.c       |  6 +++---
 net/ipv6/udp.c         |  2 +-
 10 files changed, 35 insertions(+), 17 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 92b2697..ece8dfa 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -434,6 +434,7 @@ struct sock {
 	struct sk_buff		*sk_send_head;
 	__s32			sk_peek_off;
 	int			sk_write_pending;
+	unsigned short          sk_dst_pending_confirm;
 #ifdef CONFIG_SECURITY
 	void			*sk_security;
 #endif
@@ -2263,6 +2264,23 @@ static inline void sk_state_store(struct sock *sk, int newstate)
 	smp_store_release(&sk->sk_state, newstate);
 }

+static inline void dst_confirm_sk(struct sock *sk)
+{
+        sk->sk_dst_pending_confirm = 1;
+}
+
+static inline void dst_neigh_confirm_sk(struct sock *sk, struct neighbour *n)
+{
+        if (sk && sk->sk_dst_pending_confirm) {
+                unsigned long now = jiffies;
+
+                sk->sk_dst_pending_confirm = 0;
+                /* avoid dirtying neighbour */
+                if (n->confirmed != now)
+                        n->confirmed = now;
+        }
+}
+
 void sock_enable_timestamp(struct sock *sk, int flag);
 int sock_get_timestamp(struct sock *, struct timeval __user *);
 int sock_get_timestampns(struct sock *, struct timespec __user *);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 877bdb0..7c9b640 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -221,7 +221,10 @@ static int ip_finish_output2(struct net *net, struct sock *sk, struct sk_buff *s
 	if (unlikely(!neigh))
 		neigh = __neigh_create(&arp_tbl, &nexthop, dev, false);
 	if (!IS_ERR(neigh)) {
-		int res = dst_neigh_output(dst, neigh, skb);
+		int res;
+
+		dst_neigh_confirm_sk(skb->sk, neigh);
+		res = dst_neigh_output(dst, neigh, skb);

 		rcu_read_unlock_bh();
 		return res;
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 96b8e2b..bcff1c6 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -847,7 +847,7 @@ static int ping_v4_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	return err;

 do_confirm:
-	dst_confirm(&rt->dst);
+	dst_confirm_sk(sk);
 	if (!(msg->msg_flags & MSG_PROBE) || len)
 		goto back_from_confirm;
 	err = 0;
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index ecbe5a7..e01424d 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -664,7 +664,7 @@ static int raw_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	return len;

 do_confirm:
-	dst_confirm(&rt->dst);
+	dst_confirm_sk(sk);
 	if (!(msg->msg_flags & MSG_PROBE) || len)
 		goto back_from_confirm;
 	err = 0;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c71d49c..92b2060 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3702,9 +3702,7 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 		tcp_process_tlp_ack(sk, ack, flag);

 	if ((flag & FLAG_FORWARD_PROGRESS) || !(flag & FLAG_NOT_DUP)) {
-		struct dst_entry *dst = __sk_dst_get(sk);
-		if (dst)
-			dst_confirm(dst);
+		dst_confirm_sk(sk);
 	}

 	if (icsk->icsk_pending == ICSK_TIME_RETRANS)
@@ -6049,9 +6047,7 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb)
 		tcp_set_state(sk, TCP_FIN_WAIT2);
 		sk->sk_shutdown |= SEND_SHUTDOWN;

-		dst = __sk_dst_get(sk);
-		if (dst)
-			dst_confirm(dst);
+		dst_confirm_sk(sk);

 		if (!sock_flag(sk, SOCK_DEAD)) {
 			/* Wake up lingering close() */
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index bf1f3b2..375ff08 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -379,7 +379,8 @@ void tcp_update_metrics(struct sock *sk)
 		return;

 	if (dst->flags & DST_HOST)
-		dst_confirm(dst);
+		dst_confirm_sk(sk);
+		

 	rcu_read_lock();
 	if (icsk->icsk_backoff || !tp->srtt_us) {
@@ -496,7 +497,7 @@ void tcp_init_metrics(struct sock *sk)
 	if (!dst)
 		goto reset;

-	dst_confirm(dst);
+	dst_confirm_sk(sk);

 	rcu_read_lock();
 	tm = tcp_get_metrics(sk, dst, true);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 5bab6c3..f7852d3 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1111,7 +1111,7 @@ int udp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	return err;

 do_confirm:
-	dst_confirm(&rt->dst);
+	dst_confirm_sk(sk);
 	if (!(msg->msg_flags&MSG_PROBE) || len)
 		goto back_from_confirm;
 	err = 0;
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 054a1d8..bbb09a4 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -927,7 +927,7 @@ static int rawv6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	txopt_put(opt_to_free);
 	return err < 0 ? err : len;
 do_confirm:
-	dst_confirm(dst);
+	dst_confirm_sk(sk);
 	if (!(msg->msg_flags & MSG_PROBE) || len)
 		goto back_from_confirm;
 	err = 0;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 1b57e11..8df4671 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1356,7 +1356,7 @@ static bool rt6_cache_allowed_for_pmtu(const struct rt6_info *rt)
 		(rt->rt6i_flags & RTF_PCPU || rt->rt6i_node);
 }

-static void __ip6_rt_update_pmtu(struct dst_entry *dst, const struct sock *sk,
+static void __ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
 				 const struct ipv6hdr *iph, u32 mtu)
 {
 	struct rt6_info *rt6 = (struct rt6_info *)dst;
@@ -1367,7 +1367,7 @@ static void __ip6_rt_update_pmtu(struct dst_entry *dst, const struct sock *sk,
 	if (dst_metric_locked(dst, RTAX_MTU))
 		return;

-	dst_confirm(dst);
+	dst_confirm_sk(sk);
 	mtu = max_t(u32, mtu, IPV6_MIN_MTU);
 	if (mtu >= dst_mtu(dst))
 		return;
@@ -2248,7 +2248,7 @@ static void rt6_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_bu
 	 * Look, redirects are sent only in response to data packets,
 	 * so that this nexthop apparently is reachable. --ANK
 	 */
-	dst_confirm(&rt->dst);
+	dst_confirm_sk(sk);

 	neigh = __neigh_lookup(&nd_tbl, &msg->target, skb->dev, 1);
 	if (!neigh)
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index e4a8000..6057101 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1309,7 +1309,7 @@ int udpv6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	return err;

 do_confirm:
-	dst_confirm(dst);
+	dst_confirm_sk(sk);
 	if (!(msg->msg_flags&MSG_PROBE) || len)
 		goto back_from_confirm;
 	err = 0;
-- 
1.8.3.1
