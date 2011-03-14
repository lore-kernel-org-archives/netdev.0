From: Phil Oester <kernel@linuxace.com>
Subject: [PATCH 3/3] bonding: Improve syslog message at device creation time
Date: Mon, 14 Mar 2011 09:22:06 -0700
Message-ID: <1300119726-17529-4-git-send-email-kernel@linuxace.com>
References: <1300119726-17529-1-git-send-email-kernel@linuxace.com>
Cc: fubar@us.ibm.com, andy@greyhouse.net,
	Phil Oester <kernel@linuxace.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:42286 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754001Ab1CNQWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 12:22:41 -0400
Received: by mail-qw0-f46.google.com with SMTP id 3so1404142qwk.19
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 09:22:40 -0700 (PDT)
In-Reply-To: <1300119726-17529-1-git-send-email-kernel@linuxace.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the bonding module is loaded, it creates bond0 by default.
Then, when attempting to create bond0, the following messages
are printed to syslog:

    kernel: bonding: bond0 is being created...
    kernel: bonding: Bond creation failed.

Which seems to indicate a problem, when in reality there is no
problem.  Since the actual error code is passed down from bond_create,
make use of it to print a bit less ominous message:

    kernel: bonding: bond0 is being created...
    kernel: bond0 already exists.

Signed-off-by: Phil Oester <kernel@linuxace.com>
---
 drivers/net/bonding/bond_sysfs.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 72bb0f6..e718144 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -118,7 +118,10 @@ static ssize_t bonding_store_bonds(struct class *cls,
 		pr_info("%s is being created...\n", ifname);
 		rv = bond_create(net, ifname);
 		if (rv) {
-			pr_info("Bond creation failed.\n");
+			if (rv == -EEXIST)
+				pr_info("%s already exists.\n", ifname);
+			else
+				pr_info("%s creation failed.\n", ifname);
 			res = rv;
 		}
 	} else if (command[0] == '-') {
-- 
1.7.4

