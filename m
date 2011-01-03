From: Ferenc Wagner <wferi@niif.hu>
Subject: spurious netconsole: network logging stopped messages
Date: Mon, 03 Jan 2011 17:57:35 +0100
Message-ID: <87bp3yq60w.fsf@tac.ki.iif.hu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tac.ki.iif.hu ([193.6.222.43]:33988 "EHLO tac.ki.iif.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755524Ab1ACR1a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jan 2011 12:27:30 -0500
Received: from wferi by tac.ki.iif.hu with local (Exim 4.72)
	(envelope-from <wferi@niif.hu>)
	id 1PZnix-00084d-65
	for netdev@vger.kernel.org; Mon, 03 Jan 2011 17:57:35 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-=-=

Hi,

In a running system, I can load the netconsole module, and gather the
messages on the other side all right. Now if I modprobe dummy and rmmod
dummy, the following message gets logged (via netconsole as well):

netconsole: network logging stopped, interface dummy0 unregistered

although I never asked netconsole to log through dummy0. The problem is
fairly obvious in netconsole_netdev_event() and could probably be fixed
with something like the first attached patch.  I didn't even compile
tested it, though, because the second attached patch made me realise
that I don't quite understand the bridge logic here.  Why should
netconsole stop logging through a bridge device if that loses a slave?
Or do I misunderstand the meaning of NETDEV_BONDING_DESLAVE?

Please Cc me, I'm not subscribed.
-- 
Thanks,
Feri.


--=-=-=
Content-Type: text/x-diff
Content-Disposition: inline;
 filename=0001-netconsole-don-t-announce-stopping-if-nothing-happen.patch

>From b324e4425f47fcde54757c134a7fdd98f3dc9521 Mon Sep 17 00:00:00 2001
Message-Id: <b324e4425f47fcde54757c134a7fdd98f3dc9521.1294073227.git.wferi@niif.hu>
From: Ferenc Wagner <wferi@niif.hu>
Date: Mon, 3 Jan 2011 17:34:55 +0100
Subject: [PATCH 1/2] netconsole: don't announce stopping if nothing happened


Signed-off-by: Ferenc Wagner <wferi@niif.hu>
---
 drivers/net/netconsole.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index 94255f0..b2ad998 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -664,6 +664,7 @@ static int netconsole_netdev_event(struct notifier_block *this,
 	unsigned long flags;
 	struct netconsole_target *nt;
 	struct net_device *dev = ptr;
+	bool stopped = false;
 
 	if (!(event == NETDEV_CHANGENAME || event == NETDEV_UNREGISTER ||
 	      event == NETDEV_BONDING_DESLAVE || event == NETDEV_GOING_DOWN))
@@ -690,13 +691,14 @@ static int netconsole_netdev_event(struct notifier_block *this,
 			case NETDEV_GOING_DOWN:
 			case NETDEV_BONDING_DESLAVE:
 				nt->enabled = 0;
+				stopped = true;
 				break;
 			}
 		}
 		netconsole_target_put(nt);
 	}
 	spin_unlock_irqrestore(&target_list_lock, flags);
-	if (event == NETDEV_UNREGISTER || event == NETDEV_BONDING_DESLAVE)
+	if (stopped && (event == NETDEV_UNREGISTER || event == NETDEV_BONDING_DESLAVE))
 		printk(KERN_INFO "netconsole: network logging stopped, "
 			"interface %s %s\n",  dev->name,
 			event == NETDEV_UNREGISTER ? "unregistered" : "released slaves");
-- 
1.6.5


--=-=-=
Content-Type: text/x-diff
Content-Disposition: inline;
 filename=0002-netconsole-clarify-stopping-message.patch

>From 211feede3c64419e6997e62a60f4c3c70f237ef8 Mon Sep 17 00:00:00 2001
Message-Id: <211feede3c64419e6997e62a60f4c3c70f237ef8.1294073227.git.wferi@niif.hu>
In-Reply-To: <b324e4425f47fcde54757c134a7fdd98f3dc9521.1294073227.git.wferi@niif.hu>
References: <b324e4425f47fcde54757c134a7fdd98f3dc9521.1294073227.git.wferi@niif.hu>
From: Ferenc Wagner <wferi@niif.hu>
Date: Mon, 3 Jan 2011 17:44:25 +0100
Subject: [PATCH 2/2] netconsole: clarify stopping message


Signed-off-by: Ferenc Wagner <wferi@niif.hu>
---
 drivers/net/netconsole.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index b2ad998..dfb67eb 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -699,8 +699,8 @@ static int netconsole_netdev_event(struct notifier_block *this,
 	}
 	spin_unlock_irqrestore(&target_list_lock, flags);
 	if (stopped && (event == NETDEV_UNREGISTER || event == NETDEV_BONDING_DESLAVE))
-		printk(KERN_INFO "netconsole: network logging stopped, "
-			"interface %s %s\n",  dev->name,
+		printk(KERN_INFO "netconsole: network logging stopped on "
+			"interface %s as it %s\n",  dev->name,
 			event == NETDEV_UNREGISTER ? "unregistered" : "released slaves");
 
 done:
-- 
1.6.5


--=-=-=--
