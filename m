From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: "TCP: eth0: Driver has suspect GRO implementation, TCP
 performance may be compromised." message with "ethtool -K eth0 gro off"
Date: Mon, 20 Mar 2017 16:27:14 -0300
Message-ID: <20170320192714.GB23552@localhost.localdomain>
References: <1486043964.13103.33.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170203115457.GA5296@localhost.localdomain>
 <1486128246.21871.83.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170203135355.GA3413@localhost.localdomain>
 <1486131366.21871.87.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170203142828.GB3413@localhost.localdomain>
 <1486133253.21871.89.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170206211226.GC3413@localhost.localdomain>
 <20170319121417.GA293@x4>
 <1489951226.16816.5.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Markus Trippelsdorf <markus@trippelsdorf.de>,
        netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49996 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755850AbdCTThz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Mar 2017 15:37:55 -0400
Content-Disposition: inline
In-Reply-To: <1489951226.16816.5.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 19, 2017 at 12:20:26PM -0700, Eric Dumazet wrote:
> On Sun, 2017-03-19 at 13:14 +0100, Markus Trippelsdorf wrote:
> > On 2017.02.06 at 19:12 -0200, Marcelo Ricardo Leitner wrote:
> > > On Fri, Feb 03, 2017 at 06:47:33AM -0800, Eric Dumazet wrote:
> > > > On Fri, 2017-02-03 at 12:28 -0200, Marcelo Ricardo Leitner wrote:
> > > > 
> > > > > Aren't you mixing the endpoints here? MSS is the largest amount of data
> > > > > that the peer can receive in a single segment, and not how much it will
> > > > > send. For the sending part, that depends on what the other peer
> > > > > announced, and we can have 2 different MSS in a single connection, one
> > > > > for each peer.
> > > > > 
> > > > > If a peer later wants to send larger segments, it can, but it must
> > > > > respect the mss advertised by the other peer during handshake.
> > > > > 
> > > > 
> > > > I am not mixing endpoints, you are.
> > > > 
> > > > If you need to be convinced, please grab :
> > > > https://patchwork.ozlabs.org/patch/723028/
> > > > 
> > > > And just watch "ss -temoi ..." 
> > > 
> > > I still don't get it, but I also hit the warning on my laptop, using
> > > iwlwifi. Not sure what I did in order to trigger it, it was by accident.
> > 
> > After many weeks without any warning, I've hit the issue again today:

Nice!

> > 
> >  TCP: eth0: Driver has suspect GRO implementation, TCP performance may be compromised. rcv_mss:1448 advmss:1448 len:1460
> > 
> 
> It is very possible the sender suddenly forgot to use TCP timestamps.

By those 12 bytes, seems so, yes.

> This warning is a hint, and can not assume senders are not dumb.

Agreed. But we can make it consider such cases. What about the following
patch? (untested)

I think we can directly account for the size of the timestamps in there,
as that won't make a difference to congestion control in case it's
wrong, and also validate against MTU if we have it. I didn't subtract
the headers from MTU on purpose, as dealing with ipv4/ipv6 there is
not worth for the same reason.

This should silent this false-positive.

---8<---

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 96b67a8b18c3..96a99446ddce 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -126,7 +126,8 @@ int sysctl_tcp_invalid_ratelimit __read_mostly = HZ/2;
 #define REXMIT_LOST	1 /* retransmit packets marked lost */
 #define REXMIT_NEW	2 /* FRTO-style transmit of unsent/new packets */
 
-static void tcp_gro_dev_warn(struct sock *sk, const struct sk_buff *skb)
+static void tcp_gro_dev_warn(struct sock *sk, const struct sk_buff *skb,
+			     unsigned int len)
 {
 	static bool __once __read_mostly;
 
@@ -137,8 +138,9 @@ static void tcp_gro_dev_warn(struct sock *sk, const struct sk_buff *skb)
 
 		rcu_read_lock();
 		dev = dev_get_by_index_rcu(sock_net(sk), skb->skb_iif);
-		pr_warn("%s: Driver has suspect GRO implementation, TCP performance may be compromised.\n",
-			dev ? dev->name : "Unknown driver");
+		if (!dev || len >= dev->mtu)
+			pr_warn("%s: Driver has suspect GRO implementation, TCP performance may be compromised.\n",
+				dev ? dev->name : "Unknown driver");
 		rcu_read_unlock();
 	}
 }
@@ -161,8 +163,9 @@ static void tcp_measure_rcv_mss(struct sock *sk, const struct sk_buff *skb)
 	if (len >= icsk->icsk_ack.rcv_mss) {
 		icsk->icsk_ack.rcv_mss = min_t(unsigned int, len,
 					       tcp_sk(sk)->advmss);
-		if (unlikely(icsk->icsk_ack.rcv_mss != len))
-			tcp_gro_dev_warn(sk, skb);
+		/* The + 12 accounts for the possible lack of timestamps */
+		if (unlikely(icsk->icsk_ack.rcv_mss + 12 < len))
+			tcp_gro_dev_warn(sk, skb, len);
 	} else {
 		/* Otherwise, we make more careful check taking into account,
 		 * that SACKs block is variable.
