From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: e100 problems in .23rc8 ?
Date: Thu, 11 Oct 2007 09:10:34 -0700
Message-ID: <470E4AFA.60507@intel.com>
References: <46FAA083.9020604@intel.com> <E1IanKN-0003ju-00@gondolin.me.apana.org.au> <20071011003638.GA27174@redhat.com> <20071011012520.GA13160@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org,
	esandeen@redhat.com, dmack@juniper.net
To: Herbert Xu <herbert.xu@redhat.com>, Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:63409 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754302AbXJKQKx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Oct 2007 12:10:53 -0400
In-Reply-To: <20071011012520.GA13160@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Wed, Oct 10, 2007 at 08:36:38PM -0400, Dave Jones wrote:
>> The e1000 changes you reference above, is this the changeset you mean?
>>
>> commit 416b5d10afdc797c21c457ade3714e8f2f75edd9
>> Author: Auke Kok <auke-jan.h.kok@intel.com>
>> Date:   Fri Jun 1 10:22:39 2007 -0700
>>
>>     e1000: disable polling before registering netdevice
> 
> Yep.

this patch actually called napi_disable() in the probe routine which was wrong,
but e100 does not do that. Nonetheless e100 doesn't call netif_carrier_off() and
netif_stop_queue(), so to make e100 the same as e1000 we should probably do this,
see below.

Dave, can you see if this resolves the issue for you? If so then we might want to
push this to -stable.

Auke


---
e100: disable netdevice explicitly to avoid rx irq oops

Several reported OOPS messages suggest that e100 has a race that was fixed in
e1000 before where incoming interrupts trigger an OOPS immediately after probe()
finishes.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 280313b..ded5f68 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -2682,6 +2682,10 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 	if (err)
 		DPRINTK(PROBE, ERR, "Error clearing wake event\n");

+	/* tell the stack to leave us alone until e100_open() is called */
+	netif_carrier_off(netdev);
+	netif_stop_queue(netdev);
+
 	strcpy(netdev->name, "eth%d");
 	if((err = register_netdev(netdev))) {
 		DPRINTK(PROBE, ERR, "Cannot register net device, aborting.\n");
