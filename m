From: David Miller <davem@davemloft.net>
Subject: Re: ipv6: Fix tcp_v6_send_response checksum
Date: Wed, 21 Apr 2010 01:58:23 -0700 (PDT)
Message-ID: <20100421.015823.266647388.davem@davemloft.net>
References: <20100421070737.GA30517@gondor.apana.org.au>
	<20100421.004922.193694715.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cratiu@ixiacom.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47842
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752014Ab0DUI6S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 04:58:18 -0400
In-Reply-To: <20100421.004922.193694715.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 21 Apr 2010 00:49:22 -0700 (PDT)

> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Wed, 21 Apr 2010 15:07:37 +0800
> 
>> ipv6: Fix tcp_v6_send_response checksum
> 
> I put this into net-2.6 and modified the commit message since, as we
> found, this incorrect transport header reset was added there to fix
> IPSEC.

Ok, even with this pulled into net-next-2.6 the ipv6 tcp response
checksums are still bad.  The following fix is necessary as
well:

--------------------
tcp: Fix ipv6 checksumming on response packets for real.

Commit 6651ffc8e8bdd5fb4b7d1867c6cfebb4f309512c
("ipv6: Fix tcp_v6_send_response transport header setting.")
fixed one half of why ipv6 tcp response checksums were
invalid, but it's not the whole story.

If we're going to use CHECKSUM_PARTIAL for these things (which we are
since commit 2e8e18ef52e7dd1af0a3bd1f7d990a1d0b249586 "tcp: Set
CHECKSUM_UNNECESSARY in tcp_init_nondata_skb"), we can't be setting
buff->csum as we always have been here in tcp_v6_send_response.  We
need to leave it at zero.

Kill that line and checksums are good again.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/tcp_ipv6.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 78480f4..5d2e430 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1050,8 +1050,6 @@ static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
 	}
 #endif
 
-	buff->csum = csum_partial(t1, tot_len, 0);
-
 	memset(&fl, 0, sizeof(fl));
 	ipv6_addr_copy(&fl.fl6_dst, &ipv6_hdr(skb)->saddr);
 	ipv6_addr_copy(&fl.fl6_src, &ipv6_hdr(skb)->daddr);
-- 
1.7.0.4

