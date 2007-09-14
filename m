From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 0/10 REV5] Implement skb batching and support in IPoIB/E1000
Date: Fri, 14 Sep 2007 14:30:58 +0530
Message-ID: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
Cc: jagana@us.ibm.com, Robert.Olsson@data.slu.se, rick.jones2@hp.com,
	xma@us.ibm.com, gaagaan@gmail.com, netdev@vger.kernel.org,
	rdreier@cisco.com, peter.p.waskiewicz.jr@intel.com,
	mcarlson@broadcom.com, jeff@garzik.org, mchan@broadcom.com,
	general@lists.openfabrics.org, kumarkr@linux.ibm.com,
	tgraf@suug.ch, randy.dunlap@oracle.com,
	Krishna Kumar <krkumar2@in.ibm.com>, sri@us.ibm.com
To: johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au, hadi@cyberus.ca,
	kaber@trash.net, shemminger@linux-foundation.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:33036 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751223AbXINI67 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 04:58:59 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8E90P0f007680
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 05:00:25 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8E8wwms684510
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 04:58:58 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8E8wt9P005731
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 04:58:58 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This set of patches implements the batching xmit capability, and adds support
for batching in IPoIB and E1000 (E1000 driver changes is ported, thanks to
changes taken from Jamal's code from an old kernel).

List of changes from previous revision:
----------------------------------------
1. [Dave] Enable batching as default (change in register_netdev).
2. [Randy] Update documentation (however ethtool cmd to get/set batching is
	not implemented, hence I am guessing the usage).
3. [KK] When changing tx_batch_skb, qdisc xmits need to be blocked since
	qdisc_restart() drops queue_lock before calling driver xmit, and
	driver could find blist change under it.
4. [KK] sched: requeue could wrongly requeue skb already put in the batching
	list (in case a single skb was sent to the device but not sent as the
	device was full, resulting in the skb getting added to blist). This
	also results in slight optimization of batching behavior where for
	getting skbs #2 onwards don't require to check for gso_skb as that
	is the first skb that is processed.
4. [KK] Change documentation to explain this behavior.
5. [KK] sched: Fix panic when GSO is enabled in driver.
6. [KK] IPoIB: Small optimization in ipoib_ib_handle_tx_wc
7. [KK] netdevice: Needed to change NETIF_F_GSO_SHIFT/NETIF_F_GSO_MASK as
	BATCH_SKBS is now defined as 65536 (earlier it was using 8192 which
	was taken up by NETIF_F_NETNS_LOCAL).


Will submit in the next 1-2 days:
---------------------------------
1. [Auke] Enable batching in e1000e.


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
The retransmission problem reported earlier seems to happen when mthca is
used as the underlying device, but when I tested ehca the retransmissions
dropped to normal levels (around 2 times the regular code). The performance
improvement is around 55% for TCP.

Please review and provide feedback; and consider for inclusion.

Thanks,

- KK

----------------------------------------------------
			TCP
			----
Size:32 Procs:1		2728	3544	29.91
Size:128 Procs:1	11803	13679	15.89
Size:512 Procs:1	43279	49665	14.75
Size:4096 Procs:1	147952	101246	-31.56
Size:16384 Procs:1	149852	141897	-5.30

Size:32 Procs:4		10562	11349	7.45
Size:128 Procs:4	41010	40832	-.43
Size:512 Procs:4	75374	130943	73.72
Size:4096 Procs:4	167996	368218	119.18
Size:16384 Procs:4	123176	379524	208.11

Size:32 Procs:8		21125	21990	4.09
Size:128 Procs:8	77419	78605	1.53
Size:512 Procs:8	234678	265047	12.94
Size:4096 Procs:8	218063	367604	68.57
Size:16384 Procs:8	184283	370972	101.30

Average:	1509300 -> 2345115 = 55.38%
----------------------------------------------------
