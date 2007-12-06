From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH] s2io: fix inconsistent hardware VLAN tagging during driver init
Date: Thu, 6 Dec 2007 14:57:13 -0500
Message-ID: <20071206195713.GA25879@gospo.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ram.vepa@neterion.com, santosh.rastapur@neterion.com,
	sivakumar.subramani@neterion.com, sreenivasa.honnur@neterion.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:41862 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751754AbXLFT52 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Dec 2007 14:57:28 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The s2io driver keeps a local variable around (vlan_strip_flag) to keep
track of the current state of the hardware and whether or not it will
strip VLAN tags on incoming packets.  It seems as though the hardware
default is to strip them, but that variable is not set correctly during
initialization if the default setup is used.  This check ensures
vlan_strip_flag and the hardware setting are in sync.

These variables were introduced by this patch:

commit 926930b202d56c3dfb6aea0a0c6bfba2b87a8c03
Author: Sivakumar Subramani <Sivakumar.Subramani@neterion.com>
Date:   Sat Feb 24 01:59:39 2007 -0500

so this problem hasn't been around forever.

Recent patches from Ramkrishna Vepa <ram.vepa@neterion.com> removed this
variable and would have worked around the problem, but they were not
accepted.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

---

 s2io.c |    5 +++++
 1 files changed, 5 insertions(+)

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 8b9f0ea..08c08de 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -2151,6 +2151,11 @@ static int start_nic(struct s2io_nic *nic)
 		val64 &= ~RX_PA_CFG_STRIP_VLAN_TAG;
 		writeq(val64, &bar0->rx_pa_cfg);
 		vlan_strip_flag = 0;
+	} else {
+		val64 = readq(&bar0->rx_pa_cfg);
+		val64 |= RX_PA_CFG_STRIP_VLAN_TAG;
+		writeq(val64, &bar0->rx_pa_cfg);
+		vlan_strip_flag = 1;
 	}
 
 	/*
