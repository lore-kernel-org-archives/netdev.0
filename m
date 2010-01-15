From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: ixgbe: [RFC] [PATCH] Fix return of invalid txq
Date: Thu, 14 Jan 2010 23:58:17 -0800
Message-ID: <F86E8680A7D9D74A99DC6345E35A692950158650@orsmsx503.amr.corp.intel.com>
References: <20100115053117.31513.82775.sendpatchset@krkumar2.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Krishna Kumar <krkumar2@in.ibm.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:58683 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751649Ab0AOH6S convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 02:58:18 -0500
In-Reply-To: <20100115053117.31513.82775.sendpatchset@krkumar2.in.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
>On Behalf Of Krishna Kumar
>Sent: Thursday, January 14, 2010 9:31 PM
>To: davem@davemloft.net
>Cc: netdev@vger.kernel.org; Kirsher, Jeffrey T; Krishna Kumar
>Subject: ixgbe: [RFC] [PATCH] Fix return of invalid txq
>
>A developer had complained of getting lots of warnings:
>
>"eth16 selects TX queue 98, but real number of TX queues is 64"
>
>http://www.mail-archive.com/e1000-
>devel@lists.sourceforge.net/msg02200.html
>
>As there was no follow up on that bug, I am submitting this
>patch assuming that the other return points will not return
>invalid txq's, and also that this fixes the bug (not tested).
>
>Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>

This looks reasonable to me.  I've been trying to find time to add something like igb has, with a tiny Tx lookup table that maps CPUs into a smaller set of Tx queues, but I like this simple approach to fix the current bug.

We'll want to pull this in for a quick set of regression tests, but again I think this will work well.

Thanks Krishna,

-PJ

>---
> drivers/net/ixgbe/ixgbe_main.c |    5 ++++-
> 1 file changed, 4 insertions(+), 1 deletion(-)
>
>diff -ruNp org/drivers/net/ixgbe/ixgbe_main.c
>new/drivers/net/ixgbe/ixgbe_main.c
>--- org/drivers/net/ixgbe/ixgbe_main.c	2010-01-12 11:50:24.000000000
>+0530
>+++ new/drivers/net/ixgbe/ixgbe_main.c	2010-01-12 11:50:44.000000000
>+0530
>@@ -5514,8 +5514,11 @@ static u16 ixgbe_select_queue(struct net
> 	struct ixgbe_adapter *adapter = netdev_priv(dev);
> 	int txq = smp_processor_id();
>
>-	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE)
>+	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) {
>+		while (unlikely(txq >= dev->real_num_tx_queues))
>+			txq -= dev->real_num_tx_queues;
> 		return txq;
>+	}
>
> #ifdef IXGBE_FCOE
> 	if ((adapter->flags & IXGBE_FLAG_FCOE_ENABLED) &&
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
