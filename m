From: Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>
Subject: [RFC/PATCH 1/4] UDP memory usage accounting (take 4): fix send buffer
 check
Date: Sat, 06 Oct 2007 00:00:18 +0900
Message-ID: <47065182.7080803@hitachi.com>
References: <47065139.5030402@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Yumiko SUGITA <yumiko.sugita.yf@hitachi.com>,
	"??@RedHat" <haoki@redhat.com>
To: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.hitachi.co.jp ([133.145.228.42]:52251 "EHLO
	mail7.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750796AbXJEPAX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 11:00:23 -0400
Received: from mlsv17.hitachi.co.jp (unknown [133.144.234.166])
	by mail7.hitachi.co.jp (Postfix) with ESMTP id B65A537AE3
	for <netdev@vger.kernel.org>; Sat,  6 Oct 2007 00:00:22 +0900 (JST)
In-Reply-To: <47065139.5030402@hitachi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces sndbuf size check before
memory allcation for send buffer.


signed-off-by: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>
signed-off-by: Hideo Aoki <haoki@redhat.com>

Index: 2.6.23-rc7-udp_limit/net/ipv4/ip_output.c
===================================================================
--- 2.6.23-rc7-udp_limit.orig/net/ipv4/ip_output.c
+++ 2.6.23-rc7-udp_limit/net/ipv4/ip_output.c
@@ -1004,6 +1004,11 @@ alloc_new_skb:
 					frag = &skb_shinfo(skb)->frags[i];
 				}
 			} else if (i < MAX_SKB_FRAGS) {
+				if (atomic_read(&sk->sk_wmem_alloc) + PAGE_SIZE
+				    > 2 * sk->sk_sndbuf) {
+					err = -ENOBUFS;
+					goto error;
+				}
 				if (copy > PAGE_SIZE)
 					copy = PAGE_SIZE;
 				page = alloc_pages(sk->sk_allocation, 0);

