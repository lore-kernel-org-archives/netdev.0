From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH] Fix recommended permissions for /dev/net/tun
Date: Tue, 20 Jun 2006 17:18:46 +0100
Message-ID: <1150820326.17609.88.camel@hades.cambridge.redhat.com>
References: <1150817723.17609.81.camel@hades.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:7568 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1751388AbWFTQSh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 12:18:37 -0400
Received: from nat-pool-stn.redhat.com ([62.200.124.98] helo=hades.cambridge.redhat.com)
	by pentafluge.infradead.org with esmtpsa (Exim 4.62 #1 (Red Hat Linux))
	id 1Fsiw0-0004Ed-63
	for netdev@vger.kernel.org; Tue, 20 Jun 2006 17:18:36 +0100
To: netdev@vger.kernel.org
In-Reply-To: <1150817723.17609.81.camel@hades.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-06-20 at 16:35 +0100, David Woodhouse wrote:
> There's no reason to restrict unprivileged users from opening
> the /dev/net/tun device node -- to do anything exciting requires
> CAP_NET_ADMIN or a persistent device which is owned by the user in
> question anyway. 

Hm, I lie. Let us alter reality to match my previous perception of it...

[PATCH] Require CAP_SYS_ADMIN to create tuntap devices.

The tuntap driver allows an admin to create persistent devices and
assign ownership of them to individual users. Unfortunately, relaxing
the permissions on the /dev/net/tun device node _also_ allows those
users to create arbitrary new devices of their own. This patch corrects
that, and adjusts the recommended permissions for the device node
accordingly.

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

