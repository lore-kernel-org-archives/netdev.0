From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [PATCH][2.6.26] ehea: set mac address fix
Date: Mon, 9 Jun 2008 15:17:37 +0100
Message-ID: <200806091617.38396.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>, hering2@de.ibm.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:49585 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752626AbYFIORz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2008 10:17:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

eHEA has to call firmware functions in order to change the mac address
of a logical port. This patch checks if the logical port is up
when calling the register / deregister mac address calls. If the port
is down these firmware calls would fail and are therefore not executed.

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>

---

diff -Nurp -X dontdiff linux-2.6.26-rc4/drivers/net/ehea/ehea_main.c patched_kernel/drivers/net/ehea/ehea_main.c
--- linux-2.6.26-rc4/drivers/net/ehea/ehea_main.c	2008-05-26 20:08:11.000000000 +0200
+++ patched_kernel/drivers/net/ehea/ehea_main.c	2008-06-09 15:42:17.000000000 +0200
@@ -1766,16 +1766,20 @@ static int ehea_set_mac_addr(struct net_
 	mutex_lock(&ehea_bcmc_regs.lock);
 
 	/* Deregister old MAC in pHYP */
-	ret = ehea_broadcast_reg_helper(port, H_DEREG_BCMC);
-	if (ret)
-		goto out_upregs;
+	if (port->state == EHEA_PORT_UP) {
+		ret = ehea_broadcast_reg_helper(port, H_DEREG_BCMC);
+		if (ret)
+			goto out_upregs;
+	}
 
 	port->mac_addr = cb0->port_mac_addr << 16;
 
 	/* Register new MAC in pHYP */
-	ret = ehea_broadcast_reg_helper(port, H_REG_BCMC);
-	if (ret)
-		goto out_upregs;
+	if (port->state == EHEA_PORT_UP) {
+		ret = ehea_broadcast_reg_helper(port, H_REG_BCMC);
+		if (ret)
+			goto out_upregs;
+	}
 
 	ret = 0;
 
