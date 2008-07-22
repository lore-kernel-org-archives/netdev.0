From: David Miller <davem@davemloft.net>
Subject: Re: Recent tcp_syn_options() buglet
Date: Mon, 21 Jul 2008 18:45:54 -0700 (PDT)
Message-ID: <20080721.184554.141243573.davem@davemloft.net>
References: <20080722014042.GA16846@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: agl@imperialviolet.org, netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34746
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750698AbYGVBpz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 21:45:55 -0400
In-Reply-To: <20080722014042.GA16846@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Tue, 22 Jul 2008 05:40:42 +0400

> 	  CHECK   net/ipv4/tcp_output.c
> 	net/ipv4/tcp_output.c:475:7: warning: dubious: !x & y
> 
> 
> And sparse is damn right!
> 
> 	if (unlikely(!OPTION_TS & opts->options))
> 		    ^^^
> 		size += TCPOLEN_SACKPERM_ALIGNED;
> 
> OPTION_TS is (1 << 1), so condition will never trigger.

Thanks, I'll fix it like so:

tcp: Fix bitmask test in tcp_syn_options()

As reported by Alexey Dobriyan:

	  CHECK   net/ipv4/tcp_output.c
	net/ipv4/tcp_output.c:475:7: warning: dubious: !x & y

And sparse is damn right!

	if (unlikely(!OPTION_TS & opts->options))
		    ^^^
		size += TCPOLEN_SACKPERM_ALIGNED;

OPTION_TS is (1 << 1), so condition will never trigger.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/tcp_output.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 1fa683c..a00532d 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -472,7 +472,7 @@ static unsigned tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 	}
 	if (likely(sysctl_tcp_sack)) {
 		opts->options |= OPTION_SACK_ADVERTISE;
-		if (unlikely(!OPTION_TS & opts->options))
+		if (unlikely(!(OPTION_TS & opts->options)))
 			size += TCPOLEN_SACKPERM_ALIGNED;
 	}
 
-- 
1.5.6.4.433.g09651

