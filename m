From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 3+/4] bridge: fix locking of set path cost
Date: Tue, 27 Feb 2007 09:52:51 -0800
Message-ID: <20070227095251.0c20eebd@freekitty>
References: <20070221224107.741532037@linux-foundation.org>
	<20070221224255.790379091@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@linux-foundation.org,
	Srinivas Aji <Aji_Srinivas@emc.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:42677 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751346AbXB0Rw6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Feb 2007 12:52:58 -0500
In-Reply-To: <20070221224255.790379091@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This change goes with earlier change to get rid of 
work queue for path cost. Now stp_set_path_cost does its own
locking. This is to allow it to call br_path_cost() which calls
ethtool interfaces (might sleep).


Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
 net/bridge/br_ioctl.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

--- bridge.orig/net/bridge/br_ioctl.c	2007-02-27 09:46:15.000000000 -0800
+++ bridge/net/bridge/br_ioctl.c	2007-02-27 09:43:24.000000000 -0800
@@ -291,12 +291,11 @@
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
 
-		spin_lock_bh(&br->lock);
 		if ((p = br_get_port(br, args[1])) == NULL)
 			ret = -EINVAL;
 		else
 			br_stp_set_path_cost(p, args[2]);
-		spin_unlock_bh(&br->lock);
+
 		return ret;
 	}
 
