From: David Miller <davem@davemloft.net>
Subject: Re: possible kernel oops from user MSS
Date: Wed, 10 Nov 2010 21:36:24 -0800 (PST)
Message-ID: <20101110.213624.104053314.davem@davemloft.net>
References: <20101110.124119.102563803.davem@davemloft.net>
	<4CDB7BD5.6030204@cn.fujitsu.com>
	<20101110.213313.71108940.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: schen@mvista.com, netdev@vger.kernel.org
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58361
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751177Ab0KKFgA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 00:36:00 -0500
In-Reply-To: <20101110.213313.71108940.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 10 Nov 2010 21:33:13 -0800 (PST)

> I'll make the minimum 64 or something like that.

Here is the patch I will use:

--------------------
tcp: Increase TCP_MAXSEG socket option minimum.

As noted by Steve Chen, since commit
f5fff5dc8a7a3f395b0525c02ba92c95d42b7390 ("tcp: advertise MSS
requested by user") we can end up with a situation where
tcp_select_initial_window() does a divide by a zero (or
even negative) mss value.

The problem is that sometimes we effectively subtract
TCPOLEN_TSTAMP_ALIGNED and/or TCPOLEN_MD5SIG_ALIGNED from the mss.

Fix this by increasing the minimum from 8 to 64.

Reported-by: Steve Chen <schen@mvista.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/tcp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 245603c..0814199 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2246,7 +2246,7 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 		/* Values greater than interface MTU won't take effect. However
 		 * at the point when this call is done we typically don't yet
 		 * know which interface is going to be used */
-		if (val < 8 || val > MAX_TCP_WINDOW) {
+		if (val < 64 || val > MAX_TCP_WINDOW) {
 			err = -EINVAL;
 			break;
 		}
-- 
1.7.3.2

