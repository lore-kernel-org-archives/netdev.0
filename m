From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net, ipvs: fix build on !CONFIG_INET
Date: Sun, 12 Oct 2008 12:46:32 -0700 (PDT)
Message-ID: <20081012.124632.135563543.davem@davemloft.net>
References: <20081012105329.GA29306@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	juliusv@google.com, horms@verge.net.au
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44410
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755220AbYJLTq4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Oct 2008 15:46:56 -0400
In-Reply-To: <20081012105329.GA29306@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Sun, 12 Oct 2008 12:53:29 +0200

> quick fixlet below - please double-check.

See my posting yesterday to Linus, it's already in my net-2.6
tree and I already asked Linus to pull it in.

If you had submitted the build failure directly instead of privately
via Linus you would have been CC:'d and therefore be able to see all
of this. :-)

--------------------
Subject: Re: [GIT]: Networking for 2.6.28
From: David Miller <davem@davemloft.net>
To: torvalds@linux-foundation.org
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org
Date: Sat, 11 Oct 2008 12:19:30 -0700 (PDT)
X-Mailer: Mew version 6.1 on Emacs 22.1 / Mule 5.0 (SAKAKI)

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

--------------------
Subject: [GIT]: Networking
From: David Miller <davem@davemloft.net>
To: torvalds@linux-foundation.org
CC: akpm@linux-foundation.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org
Date: Sat, 11 Oct 2008 15:11:53 -0700 (PDT)
X-Mailer: Mew version 6.1 on Emacs 22.1 / Mule 5.0 (SAKAKI)


This includes:

1) The bad IP_VS dependency randconfig build failure.

2) GRE tunnel rtnl_link initialization (bad memset size),
   from Herbert Xu.

3) External PHY detection fix in smc911x from Guennadi Liakhovetski.

4) E1000 VLAN feature flags should include TSO and CSUM offloads,
   from Patrick McHardy and ACK'd by Intel folks.

Please pull, thanks a lot!

The following changes since commit bf6f51e3a46f6a602853d3cbacd05864bc6e2a37:
  Linus Torvalds (1):
        Merge phase #3 (IOMMU) of git://git.kernel.org/.../tip/linux-2.6-tip

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

David S. Miller (1):
      ipvs: Add proper dependencies on IP_VS, and fix description header line.

Guennadi Liakhovetski (1):
      smc911x: Fix external PHY detection

Herbert Xu (1):
      gre: Initialise rtnl_link tunnel parameters properly

Patrick McHardy (1):
      e1000: allow VLAN devices to use TSO and CSUM offload

 drivers/net/e1000/e1000_main.c |    5 +++++
 drivers/net/smc911x.c          |    3 +++
 net/ipv4/ip_gre.c              |    2 +-
 net/netfilter/ipvs/Kconfig     |    4 ++--
 4 files changed, 11 insertions(+), 3 deletions(-)
