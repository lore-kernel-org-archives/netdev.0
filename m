From: Timo Juhani Lindfors <timo.lindfors@iki.fi>
Subject: Re: [PATCH] ip: reuse ip_summed of first fragment for all subsequent fragments
Date: Tue, 11 Jan 2011 15:49:19 +0200
Message-ID: <84mxn7czz4.fsf@sauna.l.org>
References: <20101217.115837.39184596.davem@davemloft.net>
	<1292841525-15572-1-git-send-email-timo.lindfors@iki.fi>
	<20101228.134905.183040321.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.academica.fi ([217.64.177.130]:44407 "EHLO ns2.academica.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932143Ab1AKOKG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jan 2011 09:10:06 -0500
In-Reply-To: <20101228.134905.183040321.davem@davemloft.net> (David Miller's message of "Tue\, 28 Dec 2010 13\:49\:05 -0800 \(PST\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:
> > -			skb->ip_summed = CHECKSUM_NONE;
> > +			skb->ip_summed = skb_prev->ip_summed;
> You can't just assign skb_prev->ip_summed here, if it's CHECKSUM_PARTIAL
> then things will go completely wrong.  This is especially true since
> we're about to zero out skb->csum.

Thanks, I clearly didn't understand the semantics of ip_summed. For
received packets CHECKSUM_PARTIAL apparently means that the checksum
is calculated by hardware and CHECKSUM_NONE that it is calculated by
software or it is not calculated at all. I guess the ip_summed of a
new fragment is set to CHECKSUM_NONE because hardware can not handle
checksums of fragments?

Anyways, socket option SO_NO_CHECK sets sk->sk_no_check. Could this be
checked before calculating checksums of each fragment? Currently
udp_push_pending_frames checks this but checksums have already been
calculated at that point (and the only job left is to sum the
checksums together). Here's a patch that works for me (=according to
perf time is no longer spent calculating checksums) but probably
should be reviewed carefully:

>From 67fe193db5a2e1a2efaa0fa8e1c1c2554e108b78 Mon Sep 17 00:00:00 2001
From: Timo Juhani Lindfors <timo.lindfors@iki.fi>
Date: Tue, 11 Jan 2011 14:36:23 +0200
Subject: [PATCH] ip: make sure disabling checksums really works

---
 net/ipv4/ip_output.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 439d2a3..9bc163a 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -80,6 +80,7 @@
 #include <linux/mroute.h>
 #include <linux/netlink.h>
 #include <linux/tcp.h>
+#include <net/udp.h>

 int sysctl_ip_default_ttl __read_mostly = IPDEFTTL;

@@ -1208,7 +1209,7 @@ ssize_t   ip_append_page(struct sock *sk, struct page *page,
                        goto error;
                }

-               if (skb->ip_summed == CHECKSUM_NONE) {
+               if (skb->ip_summed == CHECKSUM_NONE && sk->sk_no_check != UDP_CSUM_NOXMIT) {
                        __wsum csum;
                        csum = csum_page(page, offset, len);
                        skb->csum = csum_block_add(skb->csum, csum, skb->len);
--
1.7.2.3

