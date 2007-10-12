From: Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>
Subject: [PATCH 1/4] UDP memory accounting and limitation(take 5): fix send
 buffer check
Date: Fri, 12 Oct 2007 21:01:53 +0900
Message-ID: <470F6231.5020408@hitachi.com>
References: <470F61D4.6040808@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Hideo AOKI <hideo.aoki.tk@hitachi.com>,
	Yumiko SUGITA <yumiko.sugita.yf@hitachi.com>,
	=?windows-1252?Q?=22=3F=3F=40RedHat=22?= <haoki@redhat.com>,
	Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	=?windows-1252?Q?=3F=3F_=3F=3F?= <yoshfuji@linux-ipv6.org>
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.hitachi.co.jp ([133.145.228.5]:34513 "EHLO
	mail4.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753729AbXJLMCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 08:02:00 -0400
Received: from mlsv9.hitachi.co.jp (unknown [133.144.234.166])
	by mail4.hitachi.co.jp (Postfix) with ESMTP id 8CC2233CC5
	for <netdev@vger.kernel.org>; Fri, 12 Oct 2007 21:01:59 +0900 (JST)
In-Reply-To: <470F61D4.6040808@hitachi.com>
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

