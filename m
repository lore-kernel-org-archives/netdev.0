From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH][ATM] he: fix for the dreaded "HBUF_ERR" bug
Date: Fri, 06 Jun 2008 12:29:01 -0400
Message-ID: <200806061629.m56GT1Lu009284@cmf.nrl.navy.mil>
References: <48481026.6000707@dti2.net>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@vger.kernel.org
To: jorge@dti2.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:59909 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751882AbYFFQ30 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2008 12:29:26 -0400
In-reply-to: <48481026.6000707@dti2.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

this patch doesnt make sense to me, but i wrote that code awhile
ago.  the counter for the queue interation is:

	newtail = (struct he_rbp *) ((unsigned long)he_dev->rbpl_base |
					RBPL_MASK(he_dev->rbpl_tail+1));

the incremented (new) tail pointer is masked by the queue size - 1, so
newtail should never be larger than rbpl_base + CONFIG_RBPL_SIZE*8.

In message <48481026.6000707@dti2.net>,"Jorge Boncompte [DTI2]" writes:
>	If all the buffers in the pool between "head" and "last" are
>used (not LOANED), the "for" bucle continues to check past the last
>entry, corrupting memory and the buffer pool status what causes the
>message "HBUF_ERR" to appear in the kernel log and sometimes the
>receive side of the chip stopping due to lack of buffers.
>	Usually happens under load but I have seen it more frequently
>on cards with lots of VC's opened.
>	I've been running for months with this fix on my systems
>connected to DSLAM's and hundreds of PVC's and my life have been less
>scarier since then.
>
>BTW. It was really hard to find :-(
>
>Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
>---
>  drivers/atm/he.c |   10 ++++++++++
>  1 files changed, 10 insertions(+), 0 deletions(-)
>
>diff --git a/drivers/atm/he.c b/drivers/atm/he.c
>index ffc4a5a..c329104 100644
>--- a/drivers/atm/he.c
>+++ b/drivers/atm/he.c
>@@ -2062,6 +2062,7 @@ he_service_rbpl(struct he_dev *he_dev, int group)
>  {
>  	struct he_rbp *newtail;
>  	struct he_rbp *rbpl_head;
>+	struct he_rbp *rbpl_last = he_dev->rbpl_base + CONFIG_RBPL_SIZE - 1;
>  	int moved = 0;
>
>  	rbpl_head = (struct he_rbp *) ((unsigned long)he_dev->rbpl_base |
>@@ -2071,6 +2072,10 @@ he_service_rbpl(struct he_dev *he_dev, int group)
>  		newtail = (struct he_rbp *) ((unsigned long)he_dev->rbpl_base |
>  						RBPL_MASK(he_dev->rbpl_tail+1))
>;
>
>+		/* Never check past the last buffer */
>+		if (newtail > rbpl_last)
>+			newtail = he_dev->rbpl_base;
>+
>  		/* table 3.42 -- rbpl_tail should never be set to rbpl_head */
>  		if ((newtail == rbpl_head) || (newtail->status & RBP_LOANED))
>  			break;
>@@ -2090,6 +2095,7 @@ he_service_rbps(struct he_dev *he_dev, int group)
>  {
>  	struct he_rbp *newtail;
>  	struct he_rbp *rbps_head;
>+	struct he_rbp *rbps_last = he_dev->rbps_base + CONFIG_RBPS_SIZE - 1;
>  	int moved = 0;
>
>  	rbps_head = (struct he_rbp *) ((unsigned long)he_dev->rbps_base |
>@@ -2099,6 +2105,10 @@ he_service_rbps(struct he_dev *he_dev, int group)
>  		newtail = (struct he_rbp *) ((unsigned long)he_dev->rbps_base |
>  						RBPS_MASK(he_dev->rbps_tail+1))
>;
>
>+		/* Never check past the last buffer */
>+		if (newtail > rbps_last)
>+			newtail = he_dev->rbps_base;
>+
>  		/* table 3.42 -- rbps_tail should never be set to rbps_head */
>  		if ((newtail == rbps_head) || (newtail->status & RBP_LOANED))
>  			break;
>-- 
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
