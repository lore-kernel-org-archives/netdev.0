From: Romain Francoise <romain@orebokech.com>
Subject: [PATCH] ipv6: Silence privacy extensions initialization
Date: Mon, 17 Jan 2011 18:59:18 +0100
Message-ID: <87sjwr4djd.fsf@elegiac.orebokech.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola \(ipv6\)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:32786 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751658Ab1AQR7e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Jan 2011 12:59:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a network namespace is created (via CLONE_NEWNET), the loopback
interface is automatically added to the new namespace, triggering a
printk in ipv6_add_dev() if CONFIG_IPV6_PRIVACY is set.

This is problematic for applications which use CLONE_NEWNET as
part of a sandbox, like Chromium's suid sandbox or recent versions of
vsftpd. On a busy machine, it can lead to thousands of useless
"lo: Disabled Privacy Extensions" messages appearing in dmesg.

It's easy enough to check the status of privacy extensions via the
use_tempaddr sysctl, so just removing the printk seems like the most
sensible solution.

Signed-off-by: Romain Francoise <romain@orebokech.com>
---
 net/ipv6/addrconf.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 5b189c9..24a1cf1 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -420,9 +420,6 @@ static struct inet6_dev * ipv6_add_dev(struct net_device *dev)
 	    dev->type == ARPHRD_TUNNEL6 ||
 	    dev->type == ARPHRD_SIT ||
 	    dev->type == ARPHRD_NONE) {
-		printk(KERN_INFO
-		       "%s: Disabled Privacy Extensions\n",
-		       dev->name);
 		ndev->cnf.use_tempaddr = -1;
 	} else {
 		in6_dev_hold(ndev);
-- 
1.7.2.3

