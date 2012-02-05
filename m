From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH] CONFIG_TR/CONFIG_LLC: work around the problem with select
Date: Sun, 5 Feb 2012 06:31:39 +0000
Message-ID: <20120205063139.GB23916@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:34316 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750786Ab2BEGbm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2012 01:31:42 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As it is, with PCI/ISA/MCA/CCW all set to n and PCMCIA set to m
setting TR to y will set LLC to m, with very unpleasant results -
net/802/psnap gets picked into obj-y, resulting in the kernel
that won't link - psnap calls functions from llc.  The cause,
AFAICS, is that kconfig gets rev_dep for LLC containing
|| TR && (deps for TR)
and even though TR is boolean, both LLC and PCMCIA are tristate
and that thing becomes || y && (n || m), i.e. || m.  The reason
for dependency on PCMCIA is that when none of PCI, ISA, MCA, CCW
or PCMCIA is set there'll be no tokenring drivers, so there's no
point building tokenring core.  Proper fix probably belongs in
kconfig (we need strict and, such that y <strict_and> m would be
y, so that rev_deps added for tristate selected by bool would
use that instead of &&; we'd have || TR <strict_and> (deps for TR)
in this case), but it's a rather intrusive change.  There's an
easy workaround in case of TR -> LLC select, namely to have a def_bool y
symbol sitting under if TR and have that symbol selecting LLC.
Kudos to johill for suggesting that one...

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>

diff --git a/drivers/net/tokenring/Kconfig b/drivers/net/tokenring/Kconfig
index c7e0149..45550d4 100644
--- a/drivers/net/tokenring/Kconfig
+++ b/drivers/net/tokenring/Kconfig
@@ -7,7 +7,6 @@ menuconfig TR
 	bool "Token Ring driver support"
 	depends on NETDEVICES && !UML
 	depends on (PCI || ISA || MCA || CCW || PCMCIA)
-	select LLC
 	help
 	  Token Ring is IBM's way of communication on a local network; the
 	  rest of the world uses Ethernet. To participate on a Token Ring
@@ -20,6 +19,10 @@ menuconfig TR
 
 if TR
 
+config WANT_LLC
+	def_bool y
+	select LLC
+
 config PCMCIA_IBMTR
 	tristate "IBM PCMCIA tokenring adapter support"
 	depends on IBMTR!=y && PCMCIA
