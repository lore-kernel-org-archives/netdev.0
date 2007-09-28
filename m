From: Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>
Subject: [RFC/PATCH 1/3] UDP memory usage accounting (take 2): fix send buffer
 check
Date: Fri, 28 Sep 2007 22:37:54 +0900
Message-ID: <46FD03B2.1000706@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Yumiko SUGITA <yumiko.sugita.yf@hitachi.com>,
	=?ISO-2022-JP?B?IhskQkBEGyhC?=
	 =?ISO-2022-JP?B?GyRCTFobKEJAUmVkSGF0Ig==?= <haoki@redhat.com>,
	=?ISO-2022-JP?B?GyRCNUhGIxsoQiAbJEIxUUxAGyhC?=
	<yoshfuji@linux-ipv6.org>
To: Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.hitachi.co.jp ([133.145.228.5]:34942 "EHLO
	mail4.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755508AbXI1Nh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 09:37:59 -0400
Received: from mlsv14.hitachi.co.jp (unknown [133.144.234.166])
	by mail4.hitachi.co.jp (Postfix) with ESMTP id D5AAC33CD1
	for <netdev@vger.kernel.org>; Fri, 28 Sep 2007 22:37:57 +0900 (JST)
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

+                if (atomic_read(&sk->sk_wmem_alloc) + PAGE_SIZE

+                    > 2 * sk->sk_sndbuf) {

+                    err = -ENOBUFS;

+                    goto error;

+                }

                 if (copy > PAGE_SIZE)

                     copy = PAGE_SIZE;

                 page = alloc_pages(sk->sk_allocation, 0);

