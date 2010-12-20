From: Timo Juhani Lindfors <timo.lindfors@iki.fi>
Subject: [PATCH] ip: reuse ip_summed of first fragment for all subsequent fragments
Date: Mon, 20 Dec 2010 12:38:45 +0200
Message-ID: <1292841525-15572-1-git-send-email-timo.lindfors@iki.fi>
References: <20101217.115837.39184596.davem@davemloft.net>
Cc: Timo Juhani Lindfors <timo.lindfors@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.netsonic.fi ([194.29.192.26]:43544 "EHLO smtp.netsonic.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752491Ab0LTKir (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Dec 2010 05:38:47 -0500
In-Reply-To: <20101217.115837.39184596.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently if an outgoing UDP packet gets fragmented the checksum of
the last fragment is always calculated regardless of SO_NO_CHECK. This
patch reuses the checksum options of the first fragment for all
subsequent fragments to make SO_NO_CHECK work for all fragments.

Tested with Chelsio T320 10GBASE-CX4 NIC (rev 3) PCI Express x8 MSI-X.

Reference: https://bugzilla.kernel.org/show_bug.cgi?id=24832
Signed-off-by: Timo Juhani Lindfors <timo.lindfors@iki.fi>
---
I am not very familiar with networking code so there's a good chance
that I have missed something important. However, with the test program
attached to the bug report I see very real performance improvements
when sending UDP packets larger than MTU with SO_NO_CHECK set:

Perf output before:

46.81%  sendfileudp_tes  [kernel]                   [k] csum_partial

 5.30%  sendfileudp_tes  [kernel]                   [k] _spin_lock
            |
                       |
                       |--99.95%-- sendfile64
                        --0.05%-- [...]

 4.61%  sendfileudp_tes  [kernel]                   [k] ip_append_page

 3.68%  sendfileudp_tes  [kernel]                   [k] ip_fragment

 2.04%  sendfileudp_tes  [kernel]                   [k] _local_bh_enable_ip

 1.84%  sendfileudp_tes  [kernel]                   [k] ip_finish_output2

and after:

6.93%  sendfileudp_tes  [kernel]                   [k] _spin_lock

5.25%  sendfileudp_tes  [kernel]                   [k] ip_append_page

3.21%  sendfileudp_tes  [kernel]                   [k] _spin_lock_bh
           |
           |--99.95%-- sendfile64
            --0.05%-- [...]

3.16%  sendfileudp_tes  [kernel]                   [k] _local_bh_enable_ip

2.97%  sendfileudp_tes  [kernel]                   [k] ip_finish_output2
---
 net/ipv4/ip_output.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 439d2a3..c0743ed 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1167,7 +1167,7 @@ ssize_t	ip_append_page(struct sock *sk, struct page *page,
 			/*
 			 *	Fill in the control structures
 			 */
-			skb->ip_summed = CHECKSUM_NONE;
+			skb->ip_summed = skb_prev->ip_summed;
 			skb->csum = 0;
 			skb_reserve(skb, hh_len);
 
-- 
1.7.2.3

