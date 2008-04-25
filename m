From: Mandeep Singh Baines <msb@google.com>
Subject: [PATCH] [ETHTOOL]: EEPROM dump no longer works for tg3 and natsemi
Date: Thu, 24 Apr 2008 19:20:30 -0700
Message-ID: <20080425022030.GA593@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: thockin@google.com, jeff@garzik.org, joe@perches.com,
	nil@google.com, matthew@wil.cx
To: netdev@vger.kernel.org, leitao@linux.vnet.ibm.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:42598 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753254AbYDYCUv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 22:20:51 -0400
Received: from zps38.corp.google.com (zps38.corp.google.com [172.25.146.38])
	by smtp-out.google.com with ESMTP id m3P2Kj0j017940
	for <netdev@vger.kernel.org>; Fri, 25 Apr 2008 03:20:45 +0100
Received: from an-out-0708.google.com (andd11.prod.google.com [10.100.30.11])
	by zps38.corp.google.com with ESMTP id m3P2KiuJ024700
	for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 19:20:44 -0700
Received: by an-out-0708.google.com with SMTP id d11so877405and.53
        for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 19:20:44 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the ethtool user-space application, tg3 and natsemi over-ride the default
implementation of dump_eeprom(). In both tg3_dump_eeprom() and
natsemi_dump_eeprom(), there is a magic number check which is not present in
the default implementation.

Commit b131dd5d snipped the code which copied the ethtool_eeprom structure
back to user-space. tg3 and natsemi are over-writing the magic number field
and then checking it in user-space. With the ethtool_eeprom copy removed, the
check is failing.

The fix is simple. Add the ethtool_eeprom copy back.

Signed-off-by: Mandeep Singh Baines <msb@google.com>
---
 net/core/ethtool.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index a29b43d..0133b5e 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -323,6 +323,11 @@ static int ethtool_get_eeprom(struct net_device *dev, void __user *useraddr)
 		bytes_remaining -= eeprom.len;
 	}
 
+	eeprom.len = userbuf - (useraddr + sizeof(eeprom));
+	eeprom.offset -= eeprom.len;
+	if (copy_to_user(useraddr, &eeprom, sizeof(eeprom)))
+		ret = -EFAULT;
+
 	kfree(data);
 	return ret;
 }
-- 
1.5.2.5

