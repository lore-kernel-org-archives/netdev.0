From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] net: neighbour table ABI problem
Date: Wed, 21 May 2008 10:40:19 -0700
Message-ID: <20080521104019.22f9c712@extreme>
References: <20080521163815.GA5028@sc.homeunix.net>
	<4834544A.4010706@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephane Chazelas <Stephane_Chazelas@yahoo.fr>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:45744 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756985AbYEUSoQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 May 2008 14:44:16 -0400
In-Reply-To: <4834544A.4010706@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The neighbor table time of last use information is returned in the incorrect
unit. Kernel to user space ABI's need to use USER_HZ (or milliseconds), otherwise
the application has to try and discover the real system HZ value which is problematic.
Linux has standardized on keeping USER_HZ consistent (100hz) even when kernel is
running internally at some other value.

This change is small, but it breaks the ABI for older version of iproute2 utilities.
But these utilities are already broken since they are looking at the psched_hz values
which are completely different. So let's just go ahead and fix both kernel and user
space. Older utilities will just print wrong values.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/core/neighbour.c	2008-05-21 10:23:05.000000000 -0700
+++ b/net/core/neighbour.c	2008-05-21 10:28:09.000000000 -0700
@@ -2057,9 +2057,9 @@ static int neigh_fill_info(struct sk_buf
 		goto nla_put_failure;
 	}
 
-	ci.ndm_used	 = now - neigh->used;
-	ci.ndm_confirmed = now - neigh->confirmed;
-	ci.ndm_updated	 = now - neigh->updated;
+	ci.ndm_used	 = jiffies_to_clock_t(now - neigh->used);
+	ci.ndm_confirmed = jiffies_to_clock_t(now - neigh->confirmed);
+	ci.ndm_updated	 = jiffies_to_clock_t(now - neigh->updated);
 	ci.ndm_refcnt	 = atomic_read(&neigh->refcnt) - 1;
 	read_unlock_bh(&neigh->lock);
 
