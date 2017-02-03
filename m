From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: "TCP: eth0: Driver has suspect GRO implementation, TCP
 performance may be compromised." message with "ethtool -K eth0 gro off"
Date: Fri, 3 Feb 2017 09:54:57 -0200
Message-ID: <20170203115457.GA5296@localhost.localdomain>
References: <20170202115240.GH17590@x4>
 <1486038733.13103.21.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170202123427.GA7212@x4>
 <1486042270.13103.26.camel@edumazet-glaptop3.roam.corp.google.com>
 <1486043964.13103.33.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Markus Trippelsdorf <markus@trippelsdorf.de>,
        netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52388 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751762AbdBCLzA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Feb 2017 06:55:00 -0500
Content-Disposition: inline
In-Reply-To: <1486043964.13103.33.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 02, 2017 at 05:59:24AM -0800, Eric Dumazet wrote:
> On Thu, 2017-02-02 at 05:31 -0800, Eric Dumazet wrote:
> 
> > Anyway, I suspect the test is simply buggy ;)
> > 
> > diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> > index 41dcbd568cbe2403f2a9e659669afe462a42e228..5394a39fcce964a7fe7075b1531a8a1e05550a54 100644
> > --- a/net/ipv4/tcp_input.c
> > +++ b/net/ipv4/tcp_input.c
> > @@ -164,7 +164,7 @@ static void tcp_measure_rcv_mss(struct sock *sk, const struct sk_buff *skb)
> >  	if (len >= icsk->icsk_ack.rcv_mss) {
> >  		icsk->icsk_ack.rcv_mss = min_t(unsigned int, len,
> >  					       tcp_sk(sk)->advmss);
> > -		if (unlikely(icsk->icsk_ack.rcv_mss != len))
> > +		if (unlikely(icsk->icsk_ack.rcv_mss != len && skb_is_gso(skb)))
> >  			tcp_gro_dev_warn(sk, skb);
> >  	} else {
> >  		/* Otherwise, we make more careful check taking into account,
> 
> This wont really help.
> 
> Our tcp_sk(sk)->advmss can be lower than the MSS used by the remote
> peer.
> 
> ip ro add .... advmss 512

I don't follow. With a good driver, how can advmss be smaller than the
MSS used by the remote peer? Even with the route entry above, I get
segments just up to advmss, and no warning.

Though yeah, interesting that this driver doesn't even support GRO. FCS
perhaps?

Markus, do you have other interfaces in your system? Which MTU do you
use, and please try the (untested) patch below, to gather more debug
info:

---8<---

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index bfa165cc455a..eddd5b6a28b1 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -128,6 +128,7 @@ int sysctl_tcp_invalid_ratelimit __read_mostly = HZ/2;
 
 static void tcp_gro_dev_warn(struct sock *sk, const struct sk_buff *skb)
 {
+	struct inet_connection_sock *icsk = inet_csk(sk);
 	static bool __once __read_mostly;
 
 	if (!__once) {
@@ -137,8 +138,9 @@ static void tcp_gro_dev_warn(struct sock *sk, const struct sk_buff *skb)
 
 		rcu_read_lock();
 		dev = dev_get_by_index_rcu(sock_net(sk), skb->skb_iif);
-		pr_warn("%s: Driver has suspect GRO implementation, TCP performance may be compromised.\n",
-			dev ? dev->name : "Unknown driver");
+		pr_warn("%s: Driver has suspect GRO implementation, TCP performance may be compromised. rcv_mss:%u advmss:%u len:%u\n",
+			dev ? dev->name : "Unknown driver",
+			icsk->icsk_ack.rcv_mss, tcp_sk(sk)->advmss, skb->len);
 		rcu_read_unlock();
 	}
 }
