From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [ofa-general] [PATCH 0/9 Rev3] Implement batching skb API and
	support in IPoIB
Date: Wed, 08 Aug 2007 15:01:14 +0530
Message-ID: <20070808093114.15396.22797.sendpatchset@localhost.localdomain>
Cc: jagana@us.ibm.com, Robert.Olsson@data.slu.se,
	peter.p.waskiewicz.jr@intel.com, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, kumarkr@linux.ibm.com, rdreier@cisco.com,
	mcarlson@broadcom.com, jeff@garzik.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	hadi@cyberus.ca, netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru, sri@us.ibm.com, shemminger@linux-foundation.org,
	davem@davemloft.net, kaber@trash.net
Return-path: <general-bounces@lists.openfabrics.org>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

This set of patches implements the batching API, and adds support for this
API in IPoIB.

List of changes from original submission:
-----------------------------------------
1.  [Patrick] Suggestion to remove tx_queue_len check for enabling batching.
2.  [Patrick] Move queue purging to dev_deactivate to free references on
	device going down.
3.  [Patrick] Remove changelog & unrelated changes from sch_generic.c
4.  [Patrick] Free skb_blist in unregister_netdev (also suggested to put in
	free_netdev, but it is not required as unregister_netdev will not fail
	at this location).
5.  [Stephen/Patrick] Remove /sysfs support.
6.  [Stephen] Add ethtool support.
7.  [Evgeniy] Stop interrupts while changing tx_batch_skb value.
8.  [Michael Tsirkin] Remove misleading comment in ipoib_send().
9.  [KK] Remove NETIF_F_BATCH_SKBS (device supports batching if API present).
10. [KK] Remove xmit_slots from netdev.
11. [KK] [IPoIB]: Use unsigned instead of int for index's, handle race
	between multiple WC's executing on different CPU's by having a new
	lock (or might need to hold lock for entire duration of WC - some
	optimization is possible here), changed multiple skb algo to not use
	xmit_slots, simplify code, minor performance changes wrt slot
	counters, etc.

List of changes implemented, tested and dropped:
------------------------------------------------
1. [Patrick] Suggestion to use skb_blist statically in netdevice. This
	reduces performance (~ 1%) (possibly due to having an extra check for
	dev->hard_start_xmit_batch API).
2. [Patrick] Suggestion to check if hard_start_xmit_batch can be removed:
	This reduces performance as a call to a non inline function is made,
	and an extra check in driver to see if skb is NULL.
3. [Sridhar] Suggestion to always use batching for regular xmit case too:
	While testing, for some reason the tests virtually hangs and
	transfers almost no data for higher number of proceses (like 64 and
	above).

Patches are described as:
		 Mail 0/9: This mail
		 Mail 1/9: HOWTO documentation
		 Mail 2/9: Introduce skb_blist and hard_start_xmit_batch API
		 Mail 3/9: Modify qdisc_run() to support batching
		 Mail 4/9: Add ethtool support to enable/disable batching
		 Mail 5/9: IPoIB header file changes to use batching
		 Mail 6/9: IPoIB CM & Multicast changes
		 Mail 7/9: IPoIB verb changes to use batching
		 Mail 8/9: IPoIB internal post and work completion handler
		 Mail 9/9: Implement the new batching API

RESULTS: The performance improvement for TCP No Delay is in the range of -8%
	to 320% (with -8% being the sole negative), with many individual tests
	giving 50% or more improvement (I think it is to do with the hw slots
	getting full quicker resulting in more batching when the queue gets
	woken). The results for TCP is in the range of -11% to 93%, with most
	of the tests (8/12) giving improvements.

ISSUES: I am getting a huge amount of retransmissions for both TCP and TCP No
	Delay cases for IPoIB (which explains the slight degradation for some
	test cases mentioned above). After a full test run, the regular code
	resulted in 74 retransmissions, while there were 1365716 retrans with
	batching code - or 18500 retransmissions for every 1 in regular code.
	But with this huge amount of retransmissions there is 20.7% overall
	improvement in BW (which implies batching will improve results even
	more if this problem is fixed). I suspect this is some issue in the
	driver/firmware since:
		a. I see similar low retransmissions numbers for E1000 (so
		   no bug in core changes).
		b. Even with batching set to maximum 2 skbs, I get almost the
		   same number of retransmissions (implies receiver is
		   probably not dropping skbs). ifconfig/netstat on receiver
		   gives no clue (drop/errors, etc).
	This issue delayed submitting patches for the last 2 weeks, as I was
	trying to debug this; any help from openIB community is appreciated.

Please review and provide feedback; and consider for inclusion.

Thanks,

- KK

---------------------------------------------------------------
Test Case                 ORG         NEW          % Change
---------------------------------------------------------------
                                 TCP
                                 ---
Size:32 Procs:1           2709        4217           55.66
Size:128 Procs:1          10950       15853          44.77
Size:512 Procs:1          35313       68224          93.19
Size:4096 Procs:1         118144      119935         1.51

Size:32 Procs:8           18976       22432          18.21
Size:128 Procs:8          66351       86072          29.72
Size:512 Procs:8          246546      234373         -4.93
Size:4096 Procs:8         268861      251540         -6.44

Size:32 Procs:16          35009       45861          30.99
Size:128 Procs:16         150979      164961         9.26
Size:512 Procs:16         259443      230730         -11.06
Size:4096 Procs:16        265313      246794         -6.98

                               TCP No Delay
                               ------------
Size:32 Procs:1           1930        1944           .72
Size:128 Procs:1          8573        7831           -8.65
Size:512 Procs:1          28536       29347          2.84
Size:4096 Procs:1         98916       104236         5.37

Size:32 Procs:8           4173        17560          320.80
Size:128 Procs:8          17350       66205          281.58
Size:512 Procs:8          69777       211467         203.06
Size:4096 Procs:8         201096      242578         20.62

Size:32 Procs:16          20570       37778          83.65
Size:128 Procs:16         95005       154464         62.58
Size:512 Procs:16         111677      221570         98.40
Size:4096 Procs:16        204765      240368         17.38
---------------------------------------------------------------
Overall:                  2340962     2826340        20.73%
                        [Summary: 19 Better cases, 5 worse]

Testing environment (on client, server uses 4096 sendq size):
	echo "Using 512 size sendq"
	modprobe ib_ipoib send_queue_size=512 recv_queue_size=512
	echo "4096 524288 4194304" > /proc/sys/net/ipv4/tcp_wmem
	echo "4096 1048576 4194304" > /proc/sys/net/ipv4/tcp_rmem
	echo 4194304 > /proc/sys/net/core/rmem_max
	echo 4194304 > /proc/sys/net/core/wmem_max
	echo 120000 > /proc/sys/net/core/netdev_max_backlog
