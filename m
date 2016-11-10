From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG() can be hit in tcp_collapse()
Date: Thu, 10 Nov 2016 12:13:00 -0800
Message-ID: <1478808780.8455.23.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1623420310.11961160.1478789246631.JavaMail.zimbra@redhat.com>
         <1478792652.8455.3.camel@edumazet-glaptop3.roam.corp.google.com>
         <1478805992.8455.20.camel@edumazet-glaptop3.roam.corp.google.com>
         <1478807366.8455.21.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@vger.kernel.org,
        Marco Grassi <marco.gra@gmail.com>
To: Vladis Dronov <vdronov@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:32962 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933923AbcKJUND (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 15:13:03 -0500
In-Reply-To: <1478807366.8455.21.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-11-10 at 11:49 -0800, Eric Dumazet wrote:
> On Thu, 2016-11-10 at 11:26 -0800, Eric Dumazet wrote:
> 
> > The issue is that sk_filter() truncates an incoming packet to a smaller
> > value.
> > 
> > Bad things happen because TCP_SKB_CB(skb)->end_seq is not updated.
> > 
> > I guess other issues would also happen if the truncation also removes
> > part of tcp header.
> > 
> > sk_filter_trim_cap(sk, skb, tcp_hlen) would be needed,
> > or sk_filter_trim_cap(sk, skb, skb->len) to only ACCEPT/DROP packets,
> > but no truncations.
> 
> Something like :

Another sk_filter() is used in tcp v6.
So the correct patch would be :

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 61b7be303eec..0b8f575eefaa 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1676,7 +1676,7 @@ int tcp_v4_rcv(struct sk_buff *skb)
 
 	nf_reset(skb);
 
-	if (sk_filter(sk, skb))
+	if (sk_filter_trim_cap(sk, skb, skb->len))
 		goto discard_and_relse;
 
 	skb->dev = NULL;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 6ca23c2e76f7..96525649a397 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1229,7 +1229,7 @@ static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 	if (skb->protocol == htons(ETH_P_IP))
 		return tcp_v4_do_rcv(sk, skb);
 
-	if (sk_filter(sk, skb))
+	if (sk_filter_trim_cap(sk, skb, skb->len))
 		goto discard;
 
 	/*
@@ -1457,7 +1457,7 @@ static int tcp_v6_rcv(struct sk_buff *skb)
 	if (tcp_v6_inbound_md5_hash(sk, skb))
 		goto discard_and_relse;
 
-	if (sk_filter(sk, skb))
+	if (sk_filter_trim_cap(sk, skb, skb->len))
 		goto discard_and_relse;
 
 	skb->dev = NULL;
