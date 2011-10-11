From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/4] ipv4: Fix pmtu propagating
Date: Tue, 11 Oct 2011 13:09:22 +0200
Message-ID: <20111011110922.GD1830@secunet.com>
References: <20111011110842.GC1830@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:43620 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753338Ab1JKLJZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Oct 2011 07:09:25 -0400
Content-Disposition: inline
In-Reply-To: <20111011110842.GC1830@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 2c8cec5c (ipv4: Cache learned PMTU information in inetpeer)
we cache the learned pmtu informations in inetpeer and propagate these
informations with the dst_ops->check() functions. However, these functions
might not be called for udp and raw packets. As a consequence, we don't
use the learned pmtu informations in these cases. With this patch we
call dst_check() from ip_setup_cork() to propagate the pmtu informations.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/ip_output.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 8c65633..f682437 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1063,6 +1063,11 @@ static int ip_setup_cork(struct sock *sk, struct inet_cork *cork,
 	rt = *rtp;
 	if (unlikely(!rt))
 		return -EFAULT;
+
+	rt = (struct rtable *)dst_check(&rt->dst, 0);
+	if (!rt)
+		return -EHOSTUNREACH;
+
 	/*
 	 * We steal reference to this route, caller should not release it
 	 */
-- 
1.7.0.4
