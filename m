From: John Linn <John.Linn@xilinx.com>
Subject: RE: [PATCH] [V2] Add non-Virtex5 support for LL TEMAC driver
Date: Mon, 15 Mar 2010 11:23:10 -0600
Message-ID: <3ce2ca43-5eed-4995-af67-29cff5a764fe@SG2EHSMHS005.ehs.local>
References: <bda26c8d-00b2-411d-b4b7-ad6954b9049e@SG2EHSMHS005.ehs.local> <977C41F842E66D4CB2E41332313B615009A27BCA@XSJ-EXCHVS1.xlnx.xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <michal.simek@petalogix.com>, "John Tyner" <jtyner@cs.ucr.edu>,
	<john.williams@petalogix.com>
To: "Stephen Neuendorffer" <stephenn@xilinx.com>,
	<netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>,
	<grant.likely@secretlab.ca>, <jwboyer@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sg2ehsobe001.messaging.microsoft.com ([207.46.51.75]:39658 "EHLO
	SG2EHSOBE001.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S965538Ab0CORXU convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Mar 2010 13:23:20 -0400
Content-Class: urn:content-classes:message
In-Reply-To: <977C41F842E66D4CB2E41332313B615009A27BCA@XSJ-EXCHVS1.xlnx.xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> -----Original Message-----
> From: Stephen Neuendorffer
> Sent: Monday, March 15, 2010 11:03 AM
> To: John Linn; netdev@vger.kernel.org; linuxppc-dev@ozlabs.org;
grant.likely@secretlab.ca;
> jwboyer@linux.vnet.ibm.com
> Cc: michal.simek@petalogix.com; John Tyner;
john.williams@petalogix.com
> Subject: RE: [PATCH] [V2] Add non-Virtex5 support for LL TEMAC driver
> 
> 
> 
> > -----Original Message-----
> > From:
linuxppc-dev-bounces+stephen=neuendorffer.name@lists.ozlabs.org
[mailto:linuxppc-dev-
> > bounces+stephen=neuendorffer.name@lists.ozlabs.org] On Behalf Of
John Linn
> > Sent: Friday, March 12, 2010 5:06 PM
> > To: netdev@vger.kernel.org; linuxppc-dev@ozlabs.org;
grant.likely@secretlab.ca;
> > jwboyer@linux.vnet.ibm.com
> > Cc: michal.simek@petalogix.com; John Tyner; John Linn;
john.williams@petalogix.com
> > Subject: [PATCH] [V2] Add non-Virtex5 support for LL TEMAC driver
> >
> > This patch adds support for using the LL TEMAC Ethernet driver on
> > non-Virtex 5 platforms by adding support for accessing the Soft DMA
> > registers as if they were memory mapped instead of solely through
the
> > DCR's (available on the Virtex 5).
> >
> > The patch also updates the driver so that it runs on the MicroBlaze.
> > The changes were tested on the PowerPC 440, PowerPC 405, and the
> > MicroBlaze platforms.
> >
> > Signed-off-by: John Tyner <jtyner@cs.ucr.edu>
> > Signed-off-by: John Linn <john.linn@xilinx.com>
> > ---
> >
> > V2 - Incorporated comments from Grant and added more logic to allow
the driver
> > to work on MicroBlaze.
> >
> >  drivers/net/Kconfig         |    1 -
> >  drivers/net/ll_temac.h      |   17 +++++-
> >  drivers/net/ll_temac_main.c |  124
++++++++++++++++++++++++++++++++++---------
> >  3 files changed, 113 insertions(+), 29 deletions(-)
> >
> > diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> > index 9b6efe1..5402105 100644
> > --- a/drivers/net/Kconfig
> > +++ b/drivers/net/Kconfig
> > @@ -2443,7 +2443,6 @@ config MV643XX_ETH
> >  config XILINX_LL_TEMAC
> >  	tristate "Xilinx LL TEMAC (LocalLink Tri-mode Ethernet MAC)
driver"
> >  	select PHYLIB
> > -	depends on PPC_DCR_NATIVE
> >  	help
> >  	  This driver supports the Xilinx 10/100/1000 LocalLink TEMAC
> >  	  core used in Xilinx Spartan and Virtex FPGAs
> > diff --git a/drivers/net/ll_temac.h b/drivers/net/ll_temac.h
> > index 1af66a1..915aa34 100644
> > --- a/drivers/net/ll_temac.h
> > +++ b/drivers/net/ll_temac.h
> > @@ -5,8 +5,11 @@
> >  #include <linux/netdevice.h>
> >  #include <linux/of.h>
> >  #include <linux/spinlock.h>
> > +
> > +#ifdef CONFIG_PPC_DCR
> >  #include <asm/dcr.h>
> >  #include <asm/dcr-regs.h>
> > +#endif
> >
> >  /* packet size info */
> >  #define XTE_HDR_SIZE			14      /* size of
Ethernet header */
> > @@ -290,8 +293,12 @@ This option defaults to enabled (set) */
> >
> >  #define TX_CONTROL_CALC_CSUM_MASK   1
> >
> > +/* Align the IP data in the packet on word boundaries as MicroBlaze
> > + * needs it.
> > + */
> > +
> >  #define XTE_ALIGN       32
> > -#define BUFFER_ALIGN(adr) ((XTE_ALIGN - ((u32) adr)) % XTE_ALIGN)
> > +#define BUFFER_ALIGN(adr) ((34 - ((u32) adr)) % XTE_ALIGN)
> 
> Is '34' really XTE_ALIGN + 2?  (I really have no idea.... it just
looks like a suspicious change.)
> 
> Steve

Valid point that it is XTE_ALIGN + 2. As the comment says, it aligns the
IP data in the packet.

-- John

This email and any attachments are intended for the sole use of the named recipient(s) and contain(s) confidential information that may be proprietary, privileged or copyrighted under applicable law. If you are not the intended recipient, do not read, copy, or forward this email message or any attachments. Delete this email message and any attachments immediately.


