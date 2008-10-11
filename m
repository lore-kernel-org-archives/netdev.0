From: David Miller <davem@davemloft.net>
Subject: Re: [GIT]: Networking for 2.6.28
Date: Sat, 11 Oct 2008 12:19:30 -0700 (PDT)
Message-ID: <20081011.121930.193700319.davem@davemloft.net>
References: <20081010.144921.115563930.davem@davemloft.net>
	<alpine.LFD.2.00.0810110941330.3402@nehalem.linux-foundation.org>
	<alpine.LFD.2.00.0810111057020.3402@nehalem.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42021
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755144AbYJKTTy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 15:19:54 -0400
In-Reply-To: <alpine.LFD.2.00.0810111057020.3402@nehalem.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 11 Oct 2008 10:57:29 -0700 (PDT)

> 
> 
> On Sat, 11 Oct 2008, Linus Torvalds wrote:
> > 
> > On Fri, 10 Oct 2008, David Miller wrote:
> > > 
> > > Here are the queued up networking changes for the 2.6.28 merge window.
> > 
> > This generates _tons_ of new warnings for me:
> 
> And apparently errors for others:
> 
>  net/netfilter/ipvs/ip_vs_xmit.c: In function 'ip_vs_tunnel_xmit':
>  net/netfilter/ipvs/ip_vs_xmit.c:616: error: implicit declaration of function 'ip_select_ident'
> 
> some other config-dependent breakage.

So the proper include (of net/ip.h) is there in ip_vs_xmit.c, but this
failure can also happen if CONFIG_INET is not enabled.

Are you doing that kind of test build?

This patch should fix that case, let me know if it works:


ipvs: Add proper dependencies on IP_VS, and fix description header line.

Linus noted a build failure case:

net/netfilter/ipvs/ip_vs_xmit.c: In function 'ip_vs_tunnel_xmit':
net/netfilter/ipvs/ip_vs_xmit.c:616: error: implicit declaration of function 'ip_select_ident'

The proper include file (net/ip.h) is being included in ip_vs_xmit.c to get
that declaration.  So the only possible case where this can happen is if
CONFIG_INET is not enabled.

This seems to be purely a missing dependency in the ipvs/Kconfig file IP_VS
entry.

Also, while we're here, remove the out of date "EXPERIMENTAL" string in the
IP_VS config help header line.  IP_VS no longer depends upon CONFIG_EXPERIMENTAL

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/netfilter/ipvs/Kconfig |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
index de6004d..05048e4 100644
--- a/net/netfilter/ipvs/Kconfig
+++ b/net/netfilter/ipvs/Kconfig
@@ -2,8 +2,8 @@
 # IP Virtual Server configuration
 #
 menuconfig IP_VS
-	tristate "IP virtual server support (EXPERIMENTAL)"
-	depends on NETFILTER
+	tristate "IP virtual server support"
+	depends on NET && INET && NETFILTER
 	---help---
 	  IP Virtual Server support will let you build a high-performance
 	  virtual server based on cluster of two or more real servers. This
-- 
1.5.6.5

