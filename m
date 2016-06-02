From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Possible problem with e6afc8ac ("udp: remove headers from UDP
 packets before queueing")
Date: Thu, 02 Jun 2016 14:52:43 -0700
Message-ID: <1464904363.5939.185.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAHC9VhS0oH8p55_3yOcQGJWx8WmokHW=kSrKOM6tKPM1XoPjGA@mail.gmail.com>
	 <1464808695.5939.167.camel@edumazet-glaptop3.roam.corp.google.com>
	 <0b1fde4f-57ef-8c5e-147f-10c4a51fb2b0@tycho.nsa.gov>
	 <CAHC9VhQAiTRWMN-vNDXgAni2MhsyEYP8f2mZDY63xrx=5SxenQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: samanthakumar@google.com, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	Stephen Smalley <sds@tycho.nsa.gov>,
	samanthakumar <samanthakumar@google.com>
To: Paul Moore <paul@paul-moore.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:36434 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932240AbcFBVwq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2016 17:52:46 -0400
In-Reply-To: <CAHC9VhQAiTRWMN-vNDXgAni2MhsyEYP8f2mZDY63xrx=5SxenQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Paul Moore tracked a regression caused by a recent commit, which
mistakenly assumed that sk_filter() could be avoided if socket
had no current BPF filter.

The intent was to avoid udp_lib_checksum_complete() overhead.

But sk_filter() also checks skb_pfmemalloc() and
security_sock_rcv_skb(), so better call it.

Fixes: e6afc8ace6dd ("udp: remove headers from UDP packets before queueing")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Paul Moore <paul@paul-moore.com>
Tested-by: Paul Moore <paul@paul-moore.com>
Tested-by: Stephen Smalley <sds@tycho.nsa.gov>
Cc: samanthakumar <samanthakumar@google.com>
---
 net/ipv4/udp.c |   10 +++++-----
 net/ipv6/udp.c |   12 ++++++------
 2 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index d56c0559b477..0ff31d97d485 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1618,12 +1618,12 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		}
 	}
 
-	if (rcu_access_pointer(sk->sk_filter)) {
-		if (udp_lib_checksum_complete(skb))
+	if (rcu_access_pointer(sk->sk_filter) &&
+	    udp_lib_checksum_complete(skb))
 			goto csum_error;
-		if (sk_filter(sk, skb))
-			goto drop;
-	}
+
+	if (sk_filter(sk, skb))
+		goto drop;
 
 	udp_csum_pull_header(skb);
 	if (sk_rcvqueues_full(sk, sk->sk_rcvbuf)) {
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 2da1896af934..f421c9f23c5b 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -653,12 +653,12 @@ int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		}
 	}
 
-	if (rcu_access_pointer(sk->sk_filter)) {
-		if (udp_lib_checksum_complete(skb))
-			goto csum_error;
-		if (sk_filter(sk, skb))
-			goto drop;
-	}
+	if (rcu_access_pointer(sk->sk_filter) &&
+	    udp_lib_checksum_complete(skb))
+		goto csum_error;
+
+	if (sk_filter(sk, skb))
+		goto drop;
 
 	udp_csum_pull_header(skb);
 	if (sk_rcvqueues_full(sk, sk->sk_rcvbuf)) {
