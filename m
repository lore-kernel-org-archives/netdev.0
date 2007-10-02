From: Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>
Subject: [RFC/PATCH 1/3] UDP memory usage accounting (take 3): fix send buffer
 check
Date: Tue, 02 Oct 2007 22:11:30 +0900
Message-ID: <47024382.80907@hitachi.com>
References: <4702430C.2080002@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	?? ?? <yoshfuji@linux-ipv6.org>,
	Yumiko SUGITA <yumiko.sugita.yf@hitachi.com>,
	"??@RedHat" <haoki@redhat.com>
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail9.hitachi.co.jp ([133.145.228.44]:57934 "EHLO
	mail9.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752772AbXJBNLg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 09:11:36 -0400
Received: from mlsv13.hitachi.co.jp (unknown [133.144.234.166])
	by mail9.hitachi.co.jp (Postfix) with ESMTP id 7573F37C94
	for <netdev@vger.kernel.org>; Tue,  2 Oct 2007 22:11:35 +0900 (JST)
In-Reply-To: <4702430C.2080002@hitachi.com>
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
