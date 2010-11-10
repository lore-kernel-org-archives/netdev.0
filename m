From: David Miller <davem@davemloft.net>
Subject: Re: possible kernel oops from user MSS
Date: Wed, 10 Nov 2010 12:41:19 -0800 (PST)
Message-ID: <20101110.124119.102563803.davem@davemloft.net>
References: <AANLkTimMDMb74-3E9vhFxZ5Dgeuk3HMzPZVjwCj+yFEJ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: schen@mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41121
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753603Ab0KJUkz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 15:40:55 -0500
In-Reply-To: <AANLkTimMDMb74-3E9vhFxZ5Dgeuk3HMzPZVjwCj+yFEJ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Chen <schen@mvista.com>
Date: Wed, 10 Nov 2010 07:24:51 -0600

> With commit f5fff5dc8a7a3f395b0525c02ba92c95d42b7390, a user program
> can pass in TCP_MAXSEG of 12 (or TCPOLEN_TSTAMP_ALIGNED), and cause
> kernel oops with division by 0
>  in tcp_select_initial_window.  One way to prevent it is to change the
> minimum value for TCP_MAXSEG in do_tcp_setsockopt from 8 to some value
> over 12.  Two questions.
> 
> 1.  Is this the right solution?
> 2.  If it is, what is a good minimum value?

Thanks Steve, I'll fix this like so:

--------------------
tcp: Increase TCP_MAXSEG socket option minimum.

As noted by Steve Chen, since commit
f5fff5dc8a7a3f395b0525c02ba92c95d42b7390 ("tcp: advertise MSS
requested by user") we can end up with a situation where
tcp_select_initial_window() does a divide by a zero (or
even negative) mss value.

The problem is that sometimes we subtract TCPOLEN_TSTAMP_ALIGNED
from the mss.

Fix this by increasing the minimum from 8 to 8 plus the value
of TCPOLEN_TSTATMP_ALIGNED.

Reported-by: Steve Chen <schen@mvista.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/tcp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 245603c..6b0eb4d 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2246,7 +2246,7 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 		/* Values greater than interface MTU won't take effect. However
 		 * at the point when this call is done we typically don't yet
 		 * know which interface is going to be used */
-		if (val < 8 || val > MAX_TCP_WINDOW) {
+		if (val < TCPOLEN_TSTAMP_ALIGNED + 8 || val > MAX_TCP_WINDOW) {
 			err = -EINVAL;
 			break;
 		}
-- 
1.7.3.2

