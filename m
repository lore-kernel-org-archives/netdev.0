From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] possible bug in inet->opt handling
Date: Fri, 15 Apr 2011 17:39:54 +0200
Message-ID: <1302881994.3613.34.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64099 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754497Ab1DOPj6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 11:39:58 -0400
Received: by wya21 with SMTP id 21so2349987wya.19
        for <netdev@vger.kernel.org>; Fri, 15 Apr 2011 08:39:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 903ab86d19 (udp: Add lockless transmit path), we added a
fastpath to avoid taking socket lock if we dont use corking.

Prior work were commit 1c32c5ad6fac8c (inet: Add ip_make_skb and
ip_finish_skb) and commit 1470ddf7f8cecf776921e5 (inet: Remove explicit
write references to sk/inet in ip_append_data)

Problem is ip_make_skb() calls ip_setup_cork() and
ip_setup_cork() possibly makes a copy of ipc->opt (struct ip_options),
without any protection against another thread manipulating inet->opt.

Another thread can change inet->opt pointer and free old one... kaboom.

This was discovered by code analysis (I am trying to remove the zeroing
of cork variable in ip_make_skb(), since its a bit expensive and
probably useless)

Note : race was there before Herbert patches.

My plan is to add RCU protection on inet->opt, unless someone has better
idea ?



