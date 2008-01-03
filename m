From: Mark McLoughlin <markmc@redhat.com>
Subject: [PATCH] [INET] Fix netdev renaming and inet address labels
Date: Thu,  3 Jan 2008 15:57:03 +0000
Message-ID: <1199375823-28729-1-git-send-email-markmc@redhat.com>
Cc: Mark McLoughlin <markmc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail03.svc.cra.dublin.eircom.net ([159.134.118.19]:23190 "HELO
	mail03.svc.cra.dublin.eircom.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752042AbYACQDs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2008 11:03:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When re-naming an interface, the previous secondary address
labels get lost e.g.

  $> brctl addbr foo
  $> ip addr add 192.168.0.1 dev foo
  $> ip addr add 192.168.0.2 dev foo label foo:00
  $> ip addr show dev foo | grep inet
    inet 192.168.0.1/32 scope global foo
    inet 192.168.0.2/32 scope global foo:00
  $> ip link set foo name bar
  $> ip addr show dev bar | grep inet
    inet 192.168.0.1/32 scope global bar
    inet 192.168.0.2/32 scope global bar:2

Turns out to be a simple thinko in inetdev_changename() - clearly we
want to look at the address label, rather than the device name, for
a suffix to retain.

Signed-off-by: Mark McLoughlin <markmc@redhat.com>
---
 net/ipv4/devinet.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 3168c3d..b42f746 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1027,7 +1027,7 @@ static void inetdev_changename(struct net_device *dev, struct in_device *in_dev)
 		memcpy(ifa->ifa_label, dev->name, IFNAMSIZ);
 		if (named++ == 0)
 			continue;
-		dot = strchr(ifa->ifa_label, ':');
+		dot = strchr(old, ':');
 		if (dot == NULL) {
 			sprintf(old, ":%d", named);
 			dot = old;
-- 
1.5.3.6

