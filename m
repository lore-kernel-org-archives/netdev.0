From: Unai Uribarri <unai.uribarri@optenet.com>
Subject: Re: [RFC] af_packet: allow disabling timestamps
Date: Thu, 27 Sep 2007 16:34:30 +0200
Message-ID: <1190903670.6487.170.camel@localhost.localdomain>
References: <1186669314.24669.56.camel@localhost.localdomain>
	 <20070809143322.GA5345@2ka.mipt.ru>
	 <1186683234.24669.65.camel@localhost.localdomain>
	 <20070809181823.GA32449@2ka.mipt.ru>
	 <1186685450.24669.81.camel@localhost.localdomain>
	 <20070913124253.60da52f2@oldman>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipsec.mad.optenet.com ([213.27.232.70]:43820 "EHLO
	smtp.optenet.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757686AbXI0Oee (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 10:34:34 -0400
In-Reply-To: <20070913124253.60da52f2@oldman>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This small modification to Stephen's patch timestamps the skb when
needed, so the timestamp can be reused by other af_packet sockets.

Signed-off-by: Unai Uribarri <unai.uribarri@optenet.com>

--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -259,7 +259,8 @@ static void sock_disable_timestamp(struct sock *sk)
 {
 	if (sock_flag(sk, SOCK_TIMESTAMP)) {
 		sock_reset_flag(sk, SOCK_TIMESTAMP);
-		net_disable_timestamp();
+		if (sk->sk_family != PF_PACKET)
+			net_disable_timestamp();
 	}
 }
 
@@ -1655,7 +1656,8 @@ void sock_enable_timestamp(struct sock *sk)
 {
 	if (!sock_flag(sk, SOCK_TIMESTAMP)) {
 		sock_set_flag(sk, SOCK_TIMESTAMP);
-		net_enable_timestamp();
+		if (sk->sk_family != PF_PACKET)
+			net_enable_timestamp();
 	}
 }
 EXPORT_SYMBOL(sock_enable_timestamp);
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -570,7 +570,6 @@ static int tpacket_rcv(struct sk_buff *skb, struct
net_device *dev, struct packe
 	unsigned long status = TP_STATUS_LOSING|TP_STATUS_USER;
 	unsigned short macoff, netoff;
 	struct sk_buff *copy_skb = NULL;
-	struct timeval tv;
 
 	if (dev->nd_net != &init_net)
 		goto drop;
@@ -648,12 +647,18 @@ static int tpacket_rcv(struct sk_buff *skb, struct
net_device *dev, struct packe
 	h->tp_snaplen = snaplen;
 	h->tp_mac = macoff;
 	h->tp_net = netoff;
-	if (skb->tstamp.tv64)
+
+	if (sock_flag(sk, SOCK_TIMESTAMP)) {
+		struct timeval tv;
+		if (skb->tstamp.tv64 == 0)
+			__net_timestamp(skb);
 		tv = ktime_to_timeval(skb->tstamp);
-	else
-		do_gettimeofday(&tv);
-	h->tp_sec = tv.tv_sec;
-	h->tp_usec = tv.tv_usec;
+		h->tp_sec = tv.tv_sec;
+		h->tp_usec = tv.tv_usec;
+	} else {
+		h->tp_sec = 0;
+		h->tp_usec = 0;
+	}
 
 	sll = (struct sockaddr_ll*)((u8*)h + TPACKET_ALIGN(sizeof(*h)));
 	sll->sll_halen = dev_parse_header(skb, sll->sll_addr);
@@ -1004,6 +1009,7 @@ static int packet_create(struct net *net, struct
socket *sock, int protocol)
 		sock->ops = &packet_ops_spkt;
 
 	sock_init_data(sock, sk);
+	sock_set_flag(sk, SOCK_TIMESTAMP);
 
 	po = pkt_sk(sk);
 	sk->sk_family = PF_PACKET;



On jue, 2007-09-13 at 12:42 +0200, Stephen Hemminger wrote:
> Currently, af_packet does not allow disabling timestamps. This patch changes
> that but doesn't force global timestamps on.
> 
> This shows up in bugzilla as:
> 	http://bugzilla.kernel.org/show_bug.cgi?id=4809
> 
> Patch against net-2.6.24 tree.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> --- a/net/core/sock.c	2007-09-12 15:08:43.000000000 +0200
> +++ b/net/core/sock.c	2007-09-13 12:10:19.000000000 +0200
> @@ -259,7 +259,8 @@ static void sock_disable_timestamp(struc
>  {
>  	if (sock_flag(sk, SOCK_TIMESTAMP)) {
>  		sock_reset_flag(sk, SOCK_TIMESTAMP);
> -		net_disable_timestamp();
> +		if (sk->sk_family != PF_PACKET)
> +			net_disable_timestamp();
>  	}
>  }
>  
> @@ -1645,7 +1646,8 @@ void sock_enable_timestamp(struct sock *
>  {
>  	if (!sock_flag(sk, SOCK_TIMESTAMP)) {
>  		sock_set_flag(sk, SOCK_TIMESTAMP);
> -		net_enable_timestamp();
> +		if (sk->sk_family != PF_PACKET)
> +			net_enable_timestamp();
>  	}
>  }
>  EXPORT_SYMBOL(sock_enable_timestamp);
> --- a/net/packet/af_packet.c	2007-09-12 17:07:00.000000000 +0200
> +++ b/net/packet/af_packet.c	2007-09-13 12:09:10.000000000 +0200
> @@ -572,7 +572,6 @@ static int tpacket_rcv(struct sk_buff *s
>  	unsigned long status = TP_STATUS_LOSING|TP_STATUS_USER;
>  	unsigned short macoff, netoff;
>  	struct sk_buff *copy_skb = NULL;
> -	struct timeval tv;
>  
>  	if (dev->nd_net != &init_net)
>  		goto drop;
> @@ -650,12 +649,19 @@ static int tpacket_rcv(struct sk_buff *s
>  	h->tp_snaplen = snaplen;
>  	h->tp_mac = macoff;
>  	h->tp_net = netoff;
> -	if (skb->tstamp.tv64)
> -		tv = ktime_to_timeval(skb->tstamp);
> -	else
> -		do_gettimeofday(&tv);
> -	h->tp_sec = tv.tv_sec;
> -	h->tp_usec = tv.tv_usec;
> +
> +	if (sock_flag(sk, SOCK_TIMESTAMP)) {
> +		struct timeval tv;
> +		if (skb->tstamp.tv64)
> +			tv = ktime_to_timeval(skb->tstamp);
> +		else
> +			do_gettimeofday(&tv);
> +		h->tp_sec = tv.tv_sec;
> +		h->tp_usec = tv.tv_usec;
> +	} else {
> +		h->tp_sec = 0;
> +		h->tp_usec = 0;
> +	}
>  
>  	sll = (struct sockaddr_ll*)((u8*)h + TPACKET_ALIGN(sizeof(*h)));
>  	sll->sll_halen = 0;
> @@ -1014,6 +1020,7 @@ static int packet_create(struct net *net
>  		sock->ops = &packet_ops_spkt;
>  
>  	sock_init_data(sock, sk);
> +	sock_set_flag(sk, SOCK_TIMESTAMP);
>  
>  	po = pkt_sk(sk);
>  	sk->sk_family = PF_PACKET;
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 




