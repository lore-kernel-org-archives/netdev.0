From: Andrew Lutomirski <amluto@gmail.com>
Subject: [PATCH 1/1] Tell linkwatch about new interfaces
Date: Wed, 1 Apr 2009 11:40:06 -0400
Message-ID: <cb0375e10904010840n1543a890w9039465d0f80ffcc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f169.google.com ([209.85.218.169]:46853 "EHLO
	mail-bw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751730AbZDAPkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 11:40:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lutomirski <amluto@gmail.com>

When a network driver registers a new interface, linkwatch will not notice,
and hence not set the rfc2863 operstate, until netif_carrier_on gets called.
If the new interface has no carrier when it is connected, then a status of
"unknown" is reported to userspace, which confuses various tools
(NetworkManager, for example).

This fires a linkwatch event for all new interfaces, so that operstate
gets set reasonably quickly.

Signed-off-by: Andrew Lutomirski <amluto@gmail.com>

---

This looks like the root cause of the bug I reported here:

http://lkml.org/lkml/2009/3/24/499

Without knowing all the locking and ordering constraints imposed on network
drivers, this seemed like the safest way to fix the bug.  Alternative
approaches would be to call rfc2863_policy directly or to initialize the
relevent fields to sane values (for the carrier off state) in alloc_netdev.

This applies to 2.6.29.  I can rediff it for any other tree, but I didn't see
any changes that would conflict.

diff --git a/net/core/dev.c b/net/core/dev.c
index e438f54..45911fd 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4445,6 +4445,9 @@ int register_netdevice(struct net_device *dev)
 		dev->reg_state = NETREG_UNREGISTERED;
 	}

+	/* Update link state. */
+	linkwatch_fire_event(dev);
+
 out:
 	return ret;
