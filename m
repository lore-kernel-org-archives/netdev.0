From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [RFC] New driver API to speed up small packets xmits
Date: Thu, 10 May 2007 20:23:51 +0530
Message-ID: <20070510145351.1390.77066.sendpatchset@K50wks273871wss.in.ibm.com>
Cc: krkumar2@in.ibm.com, Krishna Kumar <krkumar2@in.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp05.au.ibm.com ([202.81.18.154]:59236 "EHLO
	ausmtp05.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754285AbXEJOyq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 10:54:46 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp05.au.ibm.com (8.13.8/8.13.8) with ESMTP id l4AEuISx7192760
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 00:56:20 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.250.237])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4AEvf7V150318
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 00:57:42 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4AEsAdL015583
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 00:54:10 +1000
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

While looking at common packet sizes on xmits, I found that most of
the packets are small. On my personal system, the statistics of
packets after using (browsing, mail, ftp'ing two linux kernels from
www.kernel.org) for about 6 hours is :

-----------------------------------------------------------
	Packet Size	#packets (Total:60720)	Percentage
-----------------------------------------------------------
	32 		0 			0
	64 		7716 			12.70
	80 		40193 			66.19
sub-total:		47909			78.90 %

	96 		2007 			3.30
	128 		1917 			3.15
sub-total:		3924			6.46 %

	256 		1822 			3.00
	384 		863 			1.42
	512 		459 			.75
sub-total:		3144			5.18 %

	640 		763 			1.25
	768 		2329 			3.83
	1024 		1700 			2.79
	1500 		461 			.75
sub-total:		5253			8.65 %

	2048 		312 			.51
	4096 		53 			.08
	8192 		84 			.13
	16384 		41 			.06
	32768+ 		0 			0
sub-total:		490			0.81 %
-----------------------------------------------------------

Doing some measurements, I found that for small packets like 128 bytes,
the bandwidth is approximately 60% of the line speed. To possibly speed
up performance of small packet xmits, a method of "linking" skbs was
thought of - where two pointers (skb_flink/blink) is added to the skb.
It is felt (no data yet) that drivers will get better results when more
number of "linked" skbs are sent to it in one shot, rather than sending
each skb independently (where for each skb, extra call to driver is
made and also the driver needs to get/drop lock, etc). The method is to
send as many packets as possible from qdisc (eg multiple packets can
accumulate if the driver is stopped or trylock failed) if the device
supports the new API. Steps for enabling API for a driver is :

	- driver needs to set NETIF_F_LINKED_SKB before netdev_register
	- register_netdev sets a new tx_link_skbs tunable parameter in
	  dev to 1, indicating that the driver supports linked skbs.
	- driver implements the new API - hard_start_xmit_link to
	  handle linked skbs, which is mostly a simple task. Eg,
	  support for e1000 driver can be added, avoiding duplicating
	  existing code as :

	e1000_xmit_frame_link()
	{
	top:
		next_skb = skb->linked
		(original driver code here)
		skb = next_skb;
		if (skb)
			goto top;
		...
	}

	e1000_xmit_frame()
	{
		return e1000_xmit_frame_link(skb, NULL, dev);
	}

	Drivers can take other approaches, eg, get lock at the top and
	handle all the packets in one shot, or get/drop locks for each
	skb; but those are internal to the driver. In any case, driver
	changes to support (optional) this API is minimal.

The main change is in core/sched code. Qdisc links packets if the
device supports it and multiple skbs are present, and calls
dev_hard_start_xmit, which calls one of the two API's depending on
whether the passed skb is linked or not. A sys interface can set or
reset the tx_link_skbs parameter for the device to use the old or the
new driver API.

The reason to implement the same was to speed up IPoIB driver. But
before doing that, a proof of concept for E1000/AMSO drivers was
considered (as most of the code is generic) before implementing for
IPoIB. I do not have test results at this time but I am working on it.

Please let me know if this approach is acceptable, or any suggestions.

Thanks,

- KK
