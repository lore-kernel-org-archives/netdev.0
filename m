From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] unexport softnet_data
Date: Fri, 26 Oct 2007 04:19:06 -0700 (PDT)
Message-ID: <20071026.041906.223457165.davem@davemloft.net>
References: <20071024162425.GI30533@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	christopher.leech@intel.com, shannon.nelson@intel.com,
	dan.j.williams@intel.com
To: bunk@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33242
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751347AbXJZLTG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2007 07:19:06 -0400
In-Reply-To: <20071024162425.GI30533@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@kernel.org>
Date: Wed, 24 Oct 2007 18:24:25 +0200

> The EXPORT_PER_CPU_SYMBOL(softnet_data) is no longer used.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

I wanted to apply this, but in validing the patch I noticed
what appears to be an omission in TCP ipv6.

It seems that NET_DMA support there is only half-cooked and
the following patch is needed (and thus there is a modular
use of softnet_data again).

Looking at Christopher Leech's original TCP I/O AT commit:

1a2449a87bb7606113b1aa1a9d3c3e78ef189a1c

this appears to just be an oversight.

If one of the current I/O AT folks can look this over and
confirm I'd appreciate it.

Thanks!

[TCP]: Add missing I/O AT code to ipv6 side.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 32dc329..06fa4ba 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1732,6 +1732,8 @@ process:
 	if (!sock_owned_by_user(sk)) {
 #ifdef CONFIG_NET_DMA
 		struct tcp_sock *tp = tcp_sk(sk);
+		if (!tp->ucopy.dma_chan && tp->ucopy.pinned_list)
+			tp->ucopy.dma_chan = get_softnet_dma();
 		if (tp->ucopy.dma_chan)
 			ret = tcp_v6_do_rcv(sk, skb);
 		else
