From: David Miller <davem@davemloft.net>
Subject: Re: Broken commit: [NETFILTER]: ipt_REJECT: remove largely
 duplicate route_reverse function
Date: Tue, 28 Nov 2006 20:25:35 -0800 (PST)
Message-ID: <20061128.202535.112619392.davem@davemloft.net>
References: <456CAE0D.2080209@trash.net>
	<m3slg3ktvw.fsf@defiant.localdomain>
	<456CF049.7040407@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:61126
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1758782AbWK2EZk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Nov 2006 23:25:40 -0500
To: kaber@trash.net
In-Reply-To: <456CF049.7040407@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 29 Nov 2006 03:28:25 +0100

> [NETFILTER]: ipt_REJECT: fix memory corruption
> 
> On devices with hard_header_len > LL_MAX_HEADER ip_route_me_harder()
> reallocates the skb, leading to memory corruption when using the stale
> tcph pointer to update the checksum.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks Patrick.

And based upon your discovery wrt. MAX_HEADER I'm also
applying the following.

commit 93e3a20d6c67a09b867431e7d5b3e7bc97154fab
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Tue Nov 28 20:24:10 2006 -0800

    [NET]: Fix MAX_HEADER setting.
    
    MAX_HEADER is either set to LL_MAX_HEADER or LL_MAX_HEADER + 48, and
    this is controlled by a set of CONFIG_* ifdef tests.
    
    It is trying to use LL_MAX_HEADER + 48 when any of the tunnels are
    enabled which set hard_header_len like this:
    
    dev->hard_header_len = LL_MAX_HEADER + sizeof(struct xxx);
    
    The correct set of tunnel drivers which do this are:
    
    ipip
    ip_gre
    ip6_tunnel
    sit
    
    so make the ifdef test match.
    
    Noticed by Patrick McHardy.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9264139..95e86ac 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -94,7 +94,9 @@ #endif
 #endif
 
 #if !defined(CONFIG_NET_IPIP) && \
-    !defined(CONFIG_IPV6) && !defined(CONFIG_IPV6_MODULE)
+    !defined(CONFIG_NET_IPGRE) && \
+    !defined(CONFIG_IPV6_SIT) && \
+    !defined(CONFIG_IPV6_TUNNEL)
 #define MAX_HEADER LL_MAX_HEADER
 #else
 #define MAX_HEADER (LL_MAX_HEADER + 48)
