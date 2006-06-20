From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH] Require CAP_NET_ADMIN to create tuntap devices.
Date: Tue, 20 Jun 2006 20:36:50 +0100
Message-ID: <1150832210.3176.487.camel@pmac.infradead.org>
References: <1150817723.17609.81.camel@hades.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([205.233.218.70]:22209 "EHLO
	canuck.infradead.org") by vger.kernel.org with ESMTP
	id S1750814AbWFTTgz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 15:36:55 -0400
Received: from pmac.infradead.org ([81.187.2.168])
	by canuck.infradead.org with esmtpsa (Exim 4.62 #1 (Red Hat Linux))
	id 1Fsm1s-0001I7-NZ
	for netdev@vger.kernel.org; Tue, 20 Jun 2006 15:36:54 -0400
To: netdev@vger.kernel.org
In-Reply-To: <1150817723.17609.81.camel@hades.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The tuntap driver allows an admin to create persistent devices and
assign ownership of them to individual users. Unfortunately, relaxing
the permissions on the /dev/net/tun device node so that they can
actually use those devices will _also_ allow those users to create
arbitrary new devices of their own. This patch corrects that, and
adjusts the recommended permissions for the device node accordingly.

Signed-Off-By: David Woodhouse <dwmw2@infradead.org>

diff --git a/Documentation/networking/tuntap.txt b/Documentation/networking/tuntap.txt
index 76750fb..839cbb7 100644
--- a/Documentation/networking/tuntap.txt
+++ b/Documentation/networking/tuntap.txt
@@ -39,10 +39,13 @@ Copyright (C) 1999-2000 Maxim Krasnyansk
      mknod /dev/net/tun c 10 200
   
   Set permissions:
-     e.g. chmod 0700 /dev/net/tun
-     if you want the device only accessible by root. Giving regular users the
-     right to assign network devices is NOT a good idea. Users could assign
-     bogus network interfaces to trick firewalls or administrators.
+     e.g. chmod 0666 /dev/net/tun
+     There's no harm in allowing the device to be accessible by non-root users,
+     since CAP_NET_ADMIN is required for creating network devices or for 
+     connecting to network devices which aren't owned by the user in question.
+     If you want to create persistent devices and give ownership of them to 
+     unprivileged users, then you need the /dev/net/tun device to be usable by
+     those users.
 
   Driver module autoloading
 
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index a1ed2d9..6c62d5c 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -490,6 +490,9 @@ static int tun_set_iff(struct file *file
 
 		err = -EINVAL;
 
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+
 		/* Set dev type */
 		if (ifr->ifr_flags & IFF_TUN) {
 			/* TUN device */


-- 
dwmw2

