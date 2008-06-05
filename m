From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: [PATCH][ATM] he: fix for the dreaded "HBUF_ERR" bug
Date: Thu, 05 Jun 2008 18:11:18 +0200
Message-ID: <48481026.6000707@dti2.net>
Reply-To: jorge@dti2.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: chas williams <chas@cmf.nrl.navy.mil>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alcalazamora.dti2.net ([81.24.162.8]:4152 "EHLO
	alcalazamora.dti2.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751397AbYFEQLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 12:11:31 -0400
Received: from [172.16.16.6] ([81.24.161.20])
	(authenticated user jorge@dti2.net)
	by alcalazamora.dti2.net (alcalazamora.dti2.net [81.24.162.8])
	(MDaemon PRO v9.6.5)
	with ESMTP id md50013608679.msg
	for <netdev@vger.kernel.org>; Thu, 05 Jun 2008 18:11:24 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	If all the buffers in the pool between "head" and "last" are
used (not LOANED), the "for" bucle continues to check past the last
entry, corrupting memory and the buffer pool status what causes the
message "HBUF_ERR" to appear in the kernel log and sometimes the
receive side of the chip stopping due to lack of buffers.
	Usually happens under load but I have seen it more frequently
on cards with lots of VC's opened.
	I've been running for months with this fix on my systems
connected to DSLAM's and hundreds of PVC's and my life have been less
scarier since then.

BTW. It was really hard to find :-(

Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
---
  drivers/atm/he.c |   10 ++++++++++
  1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index ffc4a5a..c329104 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -2062,6 +2062,7 @@ he_service_rbpl(struct he_dev *he_dev, int group)
  {
  	struct he_rbp *newtail;
  	struct he_rbp *rbpl_head;
+	struct he_rbp *rbpl_last = he_dev->rbpl_base + CONFIG_RBPL_SIZE - 1;
  	int moved = 0;

  	rbpl_head = (struct he_rbp *) ((unsigned long)he_dev->rbpl_base |
@@ -2071,6 +2072,10 @@ he_service_rbpl(struct he_dev *he_dev, int group)
  		newtail = (struct he_rbp *) ((unsigned long)he_dev->rbpl_base |
  						RBPL_MASK(he_dev->rbpl_tail+1));

+		/* Never check past the last buffer */
+		if (newtail > rbpl_last)
+			newtail = he_dev->rbpl_base;
+
  		/* table 3.42 -- rbpl_tail should never be set to rbpl_head */
  		if ((newtail == rbpl_head) || (newtail->status & RBP_LOANED))
  			break;
@@ -2090,6 +2095,7 @@ he_service_rbps(struct he_dev *he_dev, int group)
  {
  	struct he_rbp *newtail;
  	struct he_rbp *rbps_head;
+	struct he_rbp *rbps_last = he_dev->rbps_base + CONFIG_RBPS_SIZE - 1;
  	int moved = 0;

  	rbps_head = (struct he_rbp *) ((unsigned long)he_dev->rbps_base |
@@ -2099,6 +2105,10 @@ he_service_rbps(struct he_dev *he_dev, int group)
  		newtail = (struct he_rbp *) ((unsigned long)he_dev->rbps_base |
  						RBPS_MASK(he_dev->rbps_tail+1));

+		/* Never check past the last buffer */
+		if (newtail > rbps_last)
+			newtail = he_dev->rbps_base;
+
  		/* table 3.42 -- rbps_tail should never be set to rbps_head */
  		if ((newtail == rbps_head) || (newtail->status & RBP_LOANED))
  			break;
-- 

