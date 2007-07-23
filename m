From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 00/12 -Rev2] Implement batching skb API
Date: Mon, 23 Jul 2007 15:23:27 +0530
Message-ID: <OFEEE36890.E2C7EE2B-ON65257321.00333027-65257321.0036555D@in.ibm.com>
References: <20070722090457.7787.4601.sendpatchset@K50wks273871wss.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, gaagaan@gmail.com,
	general@lists.openfabrics.org, hadi@cyberus.ca,
	herbert@gondor.apana.org.au, jagana@us.ibm.com, jeff@garzik.org,
	johnpol@2ka.mipt.ru, kaber@trash.net, kumarkr@linux.ibm.com,
	mcarlson@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com, rdreier@cisco.com,
	rick.jones2@hp.com, Robert.Olsson@data.slu.se, sri@us.ibm.com,
	tgraf@suug.ch, xma@us.ibm.com
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:38930 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751333AbXGWJxL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2007 05:53:11 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l6NAGNS1093082
	for <netdev@vger.kernel.org>; Mon, 23 Jul 2007 20:16:23 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.250.237])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6N9uYDK149936
	for <netdev@vger.kernel.org>; Mon, 23 Jul 2007 19:56:34 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6N9qx2n001450
	for <netdev@vger.kernel.org>; Mon, 23 Jul 2007 19:53:01 +1000
In-Reply-To: <20070722090457.7787.4601.sendpatchset@K50wks273871wss.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I have started a 10 run test for various buffer sizes and processes, and
> will post the results on Monday.

The 10 iteration run results for Rev2 are (average) :

----------------------------------------------------------------------------------
Test Case               Org         New            %Change
----------------------------------------------------------------------------------

                          TCP 1 Process
Size:32               2703            3063            13.31
Size:128             12948          12217           -5.64
Size:512             48108          55384           15.12
Size:4096           129089        132586          2.70
Average:            192848         203250          5.39

                          TCP 4 Processes
Size:32              10389          10768            3.64
Size:128            39694           42265           6.47
Size:512            159563         156373         -1.99
Size:4096           268094         256008        -4.50
Average:            477740         465414         -2.58


                          TCP No Delay 1 Process
Size:32               2606           2950            13.20
Size:128             8115           11864           46.19
Size:512             39113          42608           8.93
Size:4096           103966        105333          1.31
Average:            153800         162755          5.82


                  TCP No Delay 4 Processes
Size:32               4213            8727            107.14
Size:128             17579           35143           99.91
Size:512             70803           123936         75.04
Size:4096           203541          225259         10.67
Average:             296136         393065          32.73

--------------------------------------------------------------------------
Average:            1120524        1224484         9.28%

There are three cases that degrade a little (upto -5.6%), but there are 13
cases
that improve, and many of those are in the 13% to over 100% (7 cases).

Thanks,

- KK

Krishna Kumar2/India/IBM@IBMIN wrote on 07/22/2007 02:34:57 PM:

> This set of patches implements the batching API, and makes the following
> changes resulting from the review of the first set:
>
> Changes :
> ---------
> 1.  Changed skb_blist from pointer to static as it saves only 12 bytes
>     (i386), but bloats the code.
> 2.  Removed requirement for driver to set "features & NETIF_F_BATCH_SKBS"
>     in register_netdev to enable batching as it is redundant. Changed
this
>     flag to NETIF_F_BATCH_ON and it is set by register_netdev, and other
>     user changable calls can modify this bit to enable/disable batching.
> 3.  Added ethtool support to enable/disable batching (not tested).
> 4.  Added rtnetlink support to enable/disable batching (not tested).
> 5.  Removed MIN_QUEUE_LEN_BATCH for batching as high performance drivers
>     should not have a small queue anyway (adding bloat).
> 6.  skbs are purged from dev_deactivate instead of from unregister_netdev
>     to drop all references to the device.
> 7.  Removed changelog in source code in sch_generic.c, and unrelated
renames
>     from sch_generic.c (lockless, comments).
> 8.  Removed xmit_slots entirely, as it was adding bloat (code and header)
>     and not adding value (it is calculated and set twice in internal send
>     routine and handle work completion, and referenced once in batch
xmit;
>     and can instead be calculated once in xmit).
>
> Issues :
> --------
> 1. Remove /sysfs support completely ?
> 2. Whether rtnetlink support is required as GSO has only ethtool ?
>
> Patches are described as:
>    Mail 0/12  : This mail.
>    Mail 1/12  : HOWTO documentation.
>    Mail 2/12  : Changes to netdevice.h
>    Mail 3/12  : dev.c changes.
>    Mail 4/12  : Ethtool changes.
>    Mail 5/12  : sysfs changes.
>    Mail 6/12  : rtnetlink changes.
>    Mail 7/12  : Change in qdisc_run & qdisc_restart API, modify callers
>            to use this API.
>    Mail 8/12  : IPoIB include file changes.
>    Mail 9/12  : IPoIB verbs changes
>    Mail 10/12 : IPoIB multicast, CM changes
>    Mail 11/12 : IPoIB xmit API addition
>    Mail 12/12 : IPoIB xmit internals changes (ipoib_ib.c)
>
> I have started a 10 run test for various buffer sizes and processes, and
> will post the results on Monday.
>
> Please review and provide feedback/ideas; and consider for inclusion.
>
> Thanks,
>
> - KK

