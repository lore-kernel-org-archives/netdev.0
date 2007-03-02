From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] NET : convert network timestamps to ktime_t
Date: Fri, 2 Mar 2007 13:02:10 -0800
Message-ID: <20070302130210.57883edc@freekitty>
References: <45E5570E.7050301@free.fr>
	<200703011230.50596.dada1@cosmosbay.com>
	<45E6F744.8070106@linux-foundation.org>
	<200703021538.41284.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	John find <linux.kernel@free.fr>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:41158 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965621AbXCBVCm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 16:02:42 -0500
In-Reply-To: <200703021538.41284.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2 Mar 2007 15:38:41 +0100
Eric Dumazet <dada1@cosmosbay.com> wrote:

> We currently use a special structure (struct skb_timeval) and plain 'struct 
> timeval' to store packet timestamps in sk_buffs and struct sock.
> 
> This has some drawbacks :
> - Fixed resolution of micro second.
> - Waste of space on 64bit platforms where sizeof(struct timeval)=16
> 
> I suggest using ktime_t that is a nice abstraction of high resolution time 
> services, currently capable of nanosecond resolution.
> 
> As sizeof(ktime_t) is 8 bytes, using ktime_t in 'struct sock' permits a 8 byte 
> shrink of this structure on 64bit architectures. Some other structures also 
> benefit from this size reduction (struct ipq in ipv4/ip_fragment.c, struct 
> frag_queue in ipv6/reassembly.c, ...)
> 
> 

You missed a couple of spots.

--- tcp-2.6.orig/net/sunrpc/svcsock.c	2007-03-02 12:50:45.000000000 -0800
+++ tcp-2.6/net/sunrpc/svcsock.c	2007-03-02 12:58:28.000000000 -0800
@@ -805,16 +805,9 @@
 		/* possibly an icmp error */
 		dprintk("svc: recvfrom returned error %d\n", -err);
 	}
-	if (skb->tstamp.off_sec == 0) {
-		struct timeval tv;
 
-		tv.tv_sec = xtime.tv_sec;
-		tv.tv_usec = xtime.tv_nsec / NSEC_PER_USEC;
-		skb_set_timestamp(skb, &tv);
-		/* Don't enable netstamp, sunrpc doesn't
-		   need that much accuracy */
-	}
-	skb_get_timestamp(skb, &svsk->sk_sk->sk_stamp);
+	svsk->sk_sk->sk_stamp = (skb->tstamp.tv64 != 0) ? skb->tstamp
+		: ktime_get_real();
 	set_bit(SK_DATA, &svsk->sk_flags); /* there may be more data... */
 
 	/*
--- tcp-2.6.orig/kernel/time.c	2007-03-02 12:59:55.000000000 -0800
+++ tcp-2.6/kernel/time.c	2007-03-02 13:00:08.000000000 -0800
@@ -469,6 +469,8 @@
 
 	return tv;
 }
+EXPORT_SYMBOL(ns_to_timeval);
+
 
 /*
  * Convert jiffies to milliseconds and back.



-- 
Stephen Hemminger <shemminger@linux-foundation.org>
