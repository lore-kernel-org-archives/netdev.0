From: Tim Gardner <tim.gardner@canonical.com>
Subject: [PATCH net-next v2] net: neighbour: Remove CONFIG_ARPD
Date: Thu, 29 Aug 2013 06:38:47 -0600
Message-ID: <1377779927-28500-1-git-send-email-tim.gardner@canonical.com>
References: <8761upbd6h.fsf@xmission.com>
Cc: Tim Gardner <tim.gardner@canonical.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	Joe Perches <joe@perches.com>,
	Veaceslav Falico <vfalico@redhat.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8761upbd6h.fsf@xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This config option is superfluous in that it only guards a call
to neigh_app_ns(). Enabling CONFIG_ARPD by default has no
change in behavior. There will now be call to __neigh_notify()
for each ARP resolution, which has no impact unless there is a
user space daemon waiting to receive the notification, i.e.,
the case for which CONFIG_ARPD was designed anyways.

Suggested-by: Eric W. Biederman <ebiederm@xmission.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Gao feng <gaofeng@cn.fujitsu.com>
Cc: Joe Perches <joe@perches.com>
Cc: Veaceslav Falico <vfalico@redhat.com>
Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
---

Eric's suggestion to simply remove the config option makes sense
to me. If acceptable then I'll submit a patch series that also removes
CONFIG_ARPD from the various arch defconfigs.

 net/core/neighbour.c |    2 --
 net/ipv4/Kconfig     |   16 ----------------
 net/ipv4/arp.c       |    2 --
 net/ipv6/ndisc.c     |    2 --
 4 files changed, 22 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 60533db..6072610 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2759,13 +2759,11 @@ errout:
 		rtnl_set_sk_err(net, RTNLGRP_NEIGH, err);
 }
 
-#ifdef CONFIG_ARPD
 void neigh_app_ns(struct neighbour *n)
 {
 	__neigh_notify(n, RTM_GETNEIGH, NLM_F_REQUEST);
 }
 EXPORT_SYMBOL(neigh_app_ns);
-#endif /* CONFIG_ARPD */
 
 #ifdef CONFIG_SYSCTL
 static int zero;
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 37cf1a6..05c57f0 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -259,22 +259,6 @@ config IP_PIMSM_V2
 	  gated-5). This routing protocol is not used widely, so say N unless
 	  you want to play with it.
 
-config ARPD
-	bool "IP: ARP daemon support"
-	---help---
-	  The kernel maintains an internal cache which maps IP addresses to
-	  hardware addresses on the local network, so that Ethernet
-	  frames are sent to the proper address on the physical networking
-	  layer. Normally, kernel uses the ARP protocol to resolve these
-	  mappings.
-
-	  Saying Y here adds support to have an user space daemon to do this
-	  resolution instead. This is useful for implementing an alternate
-	  address resolution protocol (e.g. NHRP on mGRE tunnels) and also for
-	  testing purposes.
-
-	  If unsure, say N.
-
 config SYN_COOKIES
 	bool "IP: TCP syncookie support"
 	---help---
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 4429b01..7808093 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -368,9 +368,7 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 	} else {
 		probes -= neigh->parms->app_probes;
 		if (probes < 0) {
-#ifdef CONFIG_ARPD
 			neigh_app_ns(neigh);
-#endif
 			return;
 		}
 	}
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 04d31c2..d5693ad 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -663,9 +663,7 @@ static void ndisc_solicit(struct neighbour *neigh, struct sk_buff *skb)
 		}
 		ndisc_send_ns(dev, neigh, target, target, saddr);
 	} else if ((probes -= neigh->parms->app_probes) < 0) {
-#ifdef CONFIG_ARPD
 		neigh_app_ns(neigh);
-#endif
 	} else {
 		addrconf_addr_solict_mult(target, &mcaddr);
 		ndisc_send_ns(dev, NULL, target, &mcaddr, saddr);
-- 
1.7.9.5
