From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net-next] icmp: avoid allocating large struct on stack
Date: Fri, 31 May 2013 22:22:32 -0700
Message-ID: <1370064152.24311.19.camel@edumazet-glaptop>
References: <1370057053-20519-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:50081 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750995Ab3FAFWe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jun 2013 01:22:34 -0400
Received: by mail-pb0-f46.google.com with SMTP id rq2so3258920pbb.19
        for <netdev@vger.kernel.org>; Fri, 31 May 2013 22:22:34 -0700 (PDT)
In-Reply-To: <1370057053-20519-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-06-01 at 11:24 +0800, Cong Wang wrote:
> From: Cong Wang <amwang@redhat.com>
> 
> struct icmp_bxm is a large struct, reduce stack usage
> by allocating it on heap.
> 

Strange, I posted a patch like that some days ago.

> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> 
> ---
>  net/ipv4/icmp.c |   37 +++++++++++++++++++++----------------
>  1 files changed, 21 insertions(+), 16 deletions(-)
> 
> diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
> index 5d0d379..8157684 100644
> --- a/net/ipv4/icmp.c
> +++ b/net/ipv4/icmp.c
> @@ -482,7 +482,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
>  {
>  	struct iphdr *iph;
>  	int room;
> -	struct icmp_bxm icmp_param;
> +	struct icmp_bxm *icmp_param;
>  	struct rtable *rt = skb_rtable(skb_in);
>  	struct ipcm_cookie ipc;
>  	struct flowi4 fl4;
> @@ -558,6 +558,10 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
>  		}
>  	}
>  
> +	icmp_param = kzalloc(sizeof(*icmp_param), GFP_ATOMIC);
> +	if (!icmp_param)
> +		return;
> +
>  	sk = icmp_xmit_lock(net);
>  	if (sk == NULL)
>  		return;

Please.

Read carefully this code and tell me if you do not leak memory.

For the record my patch was saving more stack space :

 net/ipv4/icmp.c |   72
+++++++++++++++++++++++++++++---------------------------
 1 file changed, 38 insertions(+), 34 deletions(-)

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 76e10b4..e33f3b0 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -208,7 +208,7 @@ static struct sock *icmp_sk(struct net *net)
 	return net->ipv4.icmp_sk[smp_processor_id()];
 }
 
-static inline struct sock *icmp_xmit_lock(struct net *net)
+static struct sock *icmp_xmit_lock(struct net *net)
 {
 	struct sock *sk;
 
@@ -226,7 +226,7 @@ static inline struct sock *icmp_xmit_lock(struct net *net)
 	return sk;
 }
 
-static inline void icmp_xmit_unlock(struct sock *sk)
+static void icmp_xmit_unlock(struct sock *sk)
 {
 	spin_unlock_bh(&sk->sk_lock.slock);
 }
@@ -235,8 +235,8 @@ static inline void icmp_xmit_unlock(struct sock *sk)
  *	Send an ICMP frame.
  */
 
-static inline bool icmpv4_xrlim_allow(struct net *net, struct rtable *rt,
-				      struct flowi4 *fl4, int type, int code)
+static bool icmpv4_xrlim_allow(struct net *net, struct rtable *rt,
+			       struct flowi4 *fl4, int type, int code)
 {
 	struct dst_entry *dst = &rt->dst;
 	bool rc = true;
@@ -375,19 +375,22 @@ out_unlock:
 	icmp_xmit_unlock(sk);
 }
 
-static struct rtable *icmp_route_lookup(struct net *net,
-					struct flowi4 *fl4,
-					struct sk_buff *skb_in,
-					const struct iphdr *iph,
-					__be32 saddr, u8 tos,
-					int type, int code,
-					struct icmp_bxm *param)
+struct icmp_send_data {
+	struct icmp_bxm icmp_param;
+	struct ipcm_cookie ipc;
+	struct flowi4 fl4;
+};
+
+static noinline_for_stack struct rtable *
+icmp_route_lookup(struct net *net, struct flowi4 *fl4,
+		  struct sk_buff *skb_in, const struct iphdr *iph,
+		  __be32 saddr, u8 tos, int type, int code,
+		  struct icmp_bxm *param)
 {
 	struct rtable *rt, *rt2;
 	struct flowi4 fl4_dec;
 	int err;
 
-	memset(fl4, 0, sizeof(*fl4));
 	fl4->daddr = (param->replyopts.opt.opt.srr ?
 		      param->replyopts.opt.opt.faddr : iph->saddr);
 	fl4->saddr = saddr;
@@ -482,14 +485,12 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 {
 	struct iphdr *iph;
 	int room;
-	struct icmp_bxm icmp_param;
 	struct rtable *rt = skb_rtable(skb_in);
-	struct ipcm_cookie ipc;
-	struct flowi4 fl4;
 	__be32 saddr;
 	u8  tos;
 	struct net *net;
 	struct sock *sk;
+	struct icmp_send_data *data = NULL;
 
 	if (!rt)
 		goto out;
@@ -585,7 +586,11 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 					   IPTOS_PREC_INTERNETCONTROL) :
 					  iph->tos;
 
-	if (ip_options_echo(&icmp_param.replyopts.opt.opt, skb_in))
+	data = kzalloc(sizeof(*data), GFP_ATOMIC);
+	if (!data)
+		goto out_unlock;
+
+	if (ip_options_echo(&data->icmp_param.replyopts.opt.opt, skb_in))
 		goto out_unlock;
 
 
@@ -593,23 +598,21 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 	 *	Prepare data for ICMP header.
 	 */
 
-	icmp_param.data.icmph.type	 = type;
-	icmp_param.data.icmph.code	 = code;
-	icmp_param.data.icmph.un.gateway = info;
-	icmp_param.data.icmph.checksum	 = 0;
-	icmp_param.skb	  = skb_in;
-	icmp_param.offset = skb_network_offset(skb_in);
+	data->icmp_param.data.icmph.type	 = type;
+	data->icmp_param.data.icmph.code	 = code;
+	data->icmp_param.data.icmph.un.gateway = info;
+	data->icmp_param.skb	  = skb_in;
+	data->icmp_param.offset = skb_network_offset(skb_in);
 	inet_sk(sk)->tos = tos;
-	ipc.addr = iph->saddr;
-	ipc.opt = &icmp_param.replyopts.opt;
-	ipc.tx_flags = 0;
+	data->ipc.addr = iph->saddr;
+	data->ipc.opt = &data->icmp_param.replyopts.opt;
 
-	rt = icmp_route_lookup(net, &fl4, skb_in, iph, saddr, tos,
-			       type, code, &icmp_param);
+	rt = icmp_route_lookup(net, &data->fl4, skb_in, iph, saddr, tos,
+			       type, code, &data->icmp_param);
 	if (IS_ERR(rt))
 		goto out_unlock;
 
-	if (!icmpv4_xrlim_allow(net, rt, &fl4, type, code))
+	if (!icmpv4_xrlim_allow(net, rt, &data->fl4, type, code))
 		goto ende;
 
 	/* RFC says return as much as we can without exceeding 576 bytes. */
@@ -617,19 +620,20 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 	room = dst_mtu(&rt->dst);
 	if (room > 576)
 		room = 576;
-	room -= sizeof(struct iphdr) + icmp_param.replyopts.opt.opt.optlen;
+	room -= sizeof(struct iphdr) + data->icmp_param.replyopts.opt.opt.optlen;
 	room -= sizeof(struct icmphdr);
 
-	icmp_param.data_len = skb_in->len - icmp_param.offset;
-	if (icmp_param.data_len > room)
-		icmp_param.data_len = room;
-	icmp_param.head_len = sizeof(struct icmphdr);
+	data->icmp_param.data_len = skb_in->len - data->icmp_param.offset;
+	if (data->icmp_param.data_len > room)
+		data->icmp_param.data_len = room;
+	data->icmp_param.head_len = sizeof(struct icmphdr);
 
-	icmp_push_reply(&icmp_param, &fl4, &ipc, &rt);
+	icmp_push_reply(&data->icmp_param, &data->fl4, &data->ipc, &rt);
 ende:
 	ip_rt_put(rt);
 out_unlock:
 	icmp_xmit_unlock(sk);
+	kfree(data);
 out:;
 }
 EXPORT_SYMBOL(icmp_send);
