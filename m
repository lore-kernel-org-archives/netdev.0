From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 0/10 Rev4] Implement skb batching and support in IPoIB
Date: Wed, 22 Aug 2007 13:58:39 +0530
Message-ID: <20070822082839.11964.63503.sendpatchset@localhost.localdomain>
Cc: jagana@us.ibm.com, Robert.Olsson@data.slu.se, rick.jones2@hp.com,
	xma@us.ibm.com, gaagaan@gmail.com, netdev@vger.kernel.org,
	rdreier@cisco.com, peter.p.waskiewicz.jr@intel.com,
	mcarlson@broadcom.com, jeff@garzik.org, mchan@broadcom.com,
	general@lists.openfabrics.org, kumarkr@linux.ibm.com,
	tgraf@suug.ch, Krishna Kumar <krkumar2@in.ibm.com>, sri@us.ibm.com
To: johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au, hadi@cyberus.ca,
	kaber@trash.net, shemminger@linux-foundation.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:59217 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750828AbXHVI1P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 04:27:15 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7M8RAVW007244
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 04:27:10 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7M8RAwX529604
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 04:27:10 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7M8R7ku024273
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 04:27:10 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This set of patches implements the batching xmit capability (changed from
API), and adds support for batching in IPoIB. Also included is a sample patch
for E1000 (ported - thanks to Jamal's E1000 changes from earlier kernel). I
will use this patch for testing E1000 TSO vs batching after the weekend.

List of changes from previous revision:
----------------------------------------
1. [Dave/Patrick] Remove new xmit API altogether (and add a capabilities
	flag in dev->features). Modify documentation to remove API, etc.
2. [Evgeniy] Remove bogus checks for <0, and use spin_lock_bh.
3. [Jamal] Ported Jamal's E1000 driver changes for using batching xmit.
5. [KK] Fix out-of-order sending of skbs bug resulting in re-transmissions
	by a fix in IPoIB [see XXX].
6. [KK] Do not force device to use batching as default, instead let user
	enable batching if required. This is useful in case users are not
	aware that batching is taking place.
4. [KK] IPoIB: Remove multiple xmit handlers and convert to use one.
7. [KK] IPoIB: Removed overkill - poll handler can be called on one CPU, so
	there is no need to take a new lock against parallel WC's.

Extras that I can do later:
---------------------------
1. [Patrick] Use skb_blist statically in netdevice. This could also be used
	to integrate GSO and batching.
2. [Evgeniy] Useful to splice lists dev_add_skb_to_blist (and this can be
	done for regular xmit's of GSO skbs too for #1 above).

Patches are described as:
		 Mail 0/10:  This mail
		 Mail 1/10:  HOWTO documentation
		 Mail 2/10:  Introduce skb_blist, NETIF_F_BATCH_SKBS, use
		 	     single API for batching/no-batching, etc.
		 Mail 3/10:  Modify qdisc_run() to support batching
		 Mail 4/10:  Add ethtool support to enable/disable batching
		 Mail 5/10:  IPoIB: Header file changes to use batching
		 Mail 6/10:  IPoIB: CM & Multicast changes
		 Mail 7/10:  IPoIB: Verbs changes to use batching
		 Mail 8/10:  IPoIB: Internal post and work completion handler
		 Mail 9/10:  IPoIB: Implement the new batching capability
		 Mail 10/10: E1000: Implement the new batching capability

Issues:
--------
I am getting a huge amount of retransmissions for both TCP and TCP No Delay
cases for IPoIB (which explains the slight degradation for some test cases
mentioned in previous mail). After a full test run, there were 18500
retransmissions for every 1 in regular code. But there is 20.7% overall
improvement in BW even with this huge amount of retransmissions (which implies
batching could improve results even more if this problem is fixed). Results of
experiments are:
	a. With batching set to maximum 2 skbs, I get almost the same number
	   of retransmissions (implies receiver probably is not dropping skbs).
	   ifconfig/netstat on receiver gives no clue (drop/errors, etc).
	b. Making the IPoIB xmit create single work requests for each skb on
	   blist reduces retrans to same as in regular code.
	c. Similar retransmission increase is not seen for E1000.

Please review and provide feedback; and consider for inclusion.

Thanks,

- KK

[XXX] Dave had suggested to use batching only in the net_tx_action case.
When I implemented that in earlier revisions, there were lots of TCP
retransmissions (about 18,000 to every 1 in regular code). I found the reason
for part of that problem as: skbs get queue'd up in dev->qdisc (when tx lock
was not got or queue blocked); when net_tx_action is called later, it passes
the batch list as argument to qdisc_run and this results in skbs being moved
to the batch list; then batching xmit also fails due to tx lock failure; the
next many regular xmit of a single skb will go through the fast path (pass
NULL batch list to qdisc_run) and send those skbs out to the device while
previous skbs are cooling their heels in the batch list.

The first fix was to not pass NULL/batch-list to qdisc_run() but to always
check whether skbs are present in batch list when trying to xmit. This reduced
retransmissions by a third (from 18,000 to around 12,000), but led to another
problem while testing - iperf transmit almost zero data for higher # of
parallel flows like 64 or more (and when I run iperf for a 2 min run, it
takes about 5-6 mins, and reports that it ran 0 secs and the amount of data
transfered is a few MB's). I don't know why this happens with this being the
only change (any ideas is very appreciated).

The second fix that resolved this was to revert back to Dave's suggestion to
use batching only in net_tx_action case, and modify the driver to see if skbs
are present in batch list and to send them out first before sending the
current skb. I still see huge retransmission for IPoIB (but not for E1000),
though it has reduced to 12,000 from the earlier 18,000 number.
