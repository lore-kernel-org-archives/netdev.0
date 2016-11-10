From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net] tcp: take care of truncations done by sk_filter()
Date: Thu, 10 Nov 2016 13:12:35 -0800
Message-ID: <1478812355.8455.39.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1623420310.11961160.1478789246631.JavaMail.zimbra@redhat.com>
         <1478792652.8455.3.camel@edumazet-glaptop3.roam.corp.google.com>
         <1478805992.8455.20.camel@edumazet-glaptop3.roam.corp.google.com>
         <1478807366.8455.21.camel@edumazet-glaptop3.roam.corp.google.com>
         <1478808780.8455.23.camel@edumazet-glaptop3.roam.corp.google.com>
         <1478811016.8455.33.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Marco Grassi <marco.gra@gmail.com>
To: Vladis Dronov <vdronov@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36032 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934256AbcKJVMh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 16:12:37 -0500
Received: by mail-pf0-f193.google.com with SMTP id n85so5366561pfi.3
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 13:12:37 -0800 (PST)
In-Reply-To: <1478811016.8455.33.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

With syzkaller help, Marco Grassi found a bug in TCP stack,
crashing in tcp_collapse()

Root cause is that sk_filter() can truncate the incoming skb,
but TCP stack was not really expecting this to happen.
It probably was expecting a simple DROP or ACCEPT behavior.

We first need to make sure no part of TCP header could be removed.
Then we need to adjust TCP_SKB_CB(skb)->end_seq

Many thanks to syzkaller team and Marco for giving us a reproducer.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Marco Grassi <marco.gra@gmail.com>
Reported-by: Vladis Dronov <vdronov@redhat.com>
---
v2: reload both th/iph in case skb->head changed.

 include/net/tcp.h   |    1 +
 net/ipv4/tcp_ipv4.c |   19 ++++++++++++++++++-
 net/ipv6/tcp_ipv6.c |    6 ++++--
 3 files changed, 23 insertions(+), 3 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 304a8e17bc87..123979fe12bf 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1220,6 +1220,7 @@ static inline void tcp_prequeue_init(struct tcp_sock *tp)
 
 bool tcp_prequeue(struct sock *sk, struct sk_buff *skb);
 bool tcp_add_backlog(struct sock *sk, struct sk_buff *skb);
+int tcp_filter(struct sock *sk, struct sk_buff *skb);
 
 #undef STATE_TRACE
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 61b7be303eec..2259114c7242 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1564,6 +1564,21 @@ bool tcp_add_backlog(struct sock *sk, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(tcp_add_backlog);
 
+int tcp_filter(struct sock *sk, struct sk_buff *skb)
+{
+	struct tcphdr *th = (struct tcphdr *)skb->data;
+	unsigned int eaten = skb->len;
+	int err;
+
+	err = sk_filter_trim_cap(sk, skb, th->doff * 4);
+	if (!err) {
+		eaten -= skb->len;
+		TCP_SKB_CB(skb)->end_seq -= eaten;
+	}
+	return err;
+}
+EXPORT_SYMBOL(tcp_filter);
+
 /*
  *	From tcp_input.c
  */
@@ -1676,8 +1691,10 @@ int tcp_v4_rcv(struct sk_buff *skb)
 
 	nf_reset(skb);
 
-	if (sk_filter(sk, skb))
+	if (tcp_filter(sk, skb))
 		goto discard_and_relse;
+	th = (const struct tcphdr *)skb->data;
+	iph = ip_hdr(skb);
 
 	skb->dev = NULL;
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 6ca23c2e76f7..b9f1fee9a886 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1229,7 +1229,7 @@ static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 	if (skb->protocol == htons(ETH_P_IP))
 		return tcp_v4_do_rcv(sk, skb);
 
-	if (sk_filter(sk, skb))
+	if (tcp_filter(sk, skb))
 		goto discard;
 
 	/*
@@ -1457,8 +1457,10 @@ static int tcp_v6_rcv(struct sk_buff *skb)
 	if (tcp_v6_inbound_md5_hash(sk, skb))
 		goto discard_and_relse;
 
-	if (sk_filter(sk, skb))
+	if (tcp_filter(sk, skb))
 		goto discard_and_relse;
+	th = (const struct tcphdr *)skb->data;
+	hdr = ipv6_hdr(skb);
 
 	skb->dev = NULL;
 
