From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [v2 RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Fri, 17 Sep 2010 15:33:07 +0530
Message-ID: <20100917100307.21276.79185.sendpatchset@krkumar2.in.ibm.com>
Cc: kvm@vger.kernel.org, arnd@arndb.de, netdev@vger.kernel.org,
	avi@redhat.com, anthony@codemonkey.ws,
	Krishna Kumar <krkumar2@in.ibm.com>
To: rusty@rustcorp.com.au, davem@davemloft.net, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([122.248.162.7]:58350 "EHLO
	e28smtp07.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751284Ab0IQKDO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 06:03:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patches implement transmit MQ in virtio-net.  Also
included is the user qemu changes. MQ is disabled by default
unless qemu specifies it.

1. This feature was first implemented with a single vhost.
   Testing showed 3-8% performance gain for upto 8 netperf
   sessions (and sometimes 16), but BW dropped with more
   sessions.  However, adding more vhosts improved BW
   significantly all the way to 128 sessions. Multiple
   vhost is implemented in-kernel by passing an argument
   to SET_OWNER (retaining backward compatibility). The
   vhost patch adds 173 source lines (incl comments).
2. BW -> CPU/SD equation: Average TCP performance increased
   23% compared to almost 70% for earlier patch (with
   unrestricted #vhosts).  SD improved -4.2% while it had
   increased 55% for the earlier patch.  Increasing #vhosts
   has it's pros and cons, but this patch lays emphasis on
   reducing CPU utilization.  Another option could be a
   tunable to select number of vhosts threads.
3. Interoperability: Many combinations, but not all, of qemu,
   host, guest tested together.  Tested with multiple i/f's
   on guest, with both mq=on/off, vhost=on/off, etc.

                  Changes from rev1:
                  ------------------
1. Move queue_index from virtio_pci_vq_info to virtqueue,
   and resulting changes to existing code and to the patch.
2. virtio-net probe uses virtio_config_val.
3. Remove constants: VIRTIO_MAX_TXQS, MAX_VQS, all arrays
   allocated on stack, etc.
4. Restrict number of vhost threads to 2 - I get much better
   cpu/sd results (without any tuning) with low number of vhost
   threads.  Higher vhosts gives better average BW performance
   (from average of 45%), but SD increases significantly (90%).
5. Working of vhost threads changes, eg for numtxqs=4:
       vhost-0: handles RX
       vhost-1: handles TX[0]
       vhost-0: handles TX[1]
       vhost-1: handles TX[2]
       vhost-0: handles TX[3]

                  Enabling MQ on virtio:
                  -----------------------
When following options are passed to qemu:
        - smp > 1
        - vhost=on
        - mq=on (new option, default:off)
then #txqueues = #cpus.  The #txqueues can be changed by using
an optional 'numtxqs' option.  e.g. for a smp=4 guest:
        vhost=on                   ->   #txqueues = 1
        vhost=on,mq=on             ->   #txqueues = 4
        vhost=on,mq=on,numtxqs=8   ->   #txqueues = 8
        vhost=on,mq=on,numtxqs=2   ->   #txqueues = 2


                   Performance (guest -> local host):
                   -----------------------------------
System configuration:
        Host:  8 Intel Xeon, 8 GB memory
        Guest: 4 cpus, 2 GB memory, numtxqs=4
All testing without any system tuning, and default netperf
Results split across two tables to show SD and CPU usage:
________________________________________________________________________
                    TCP: BW vs CPU/Remote CPU utilization:
#    BW1    BW2 (%)        CPU1    CPU2 (%)     RCPU1  RCPU2 (%)
________________________________________________________________________
1    69971  65376 (-6.56)  134   170  (26.86)   322    376   (16.77)
2    20911  24839 (18.78)  107   139  (29.90)   217    264   (21.65)
4    21431  28912 (34.90)  213   318  (49.29)   444    541   (21.84)
8    21857  34592 (58.26)  444   859  (93.46)   901    1247  (38.40)
16   22368  33083 (47.90)  899   1523 (69.41)   1813   2410  (32.92)
24   22556  32578 (44.43)  1347  2249 (66.96)   2712   3606  (32.96)
32   22727  30923 (36.06)  1806  2506 (38.75)   3622   3952  (9.11)
40   23054  29334 (27.24)  2319  2872 (23.84)   4544   4551  (.15)
48   23006  28800 (25.18)  2827  2990 (5.76)    5465   4718  (-13.66)
64   23411  27661 (18.15)  3708  3306 (-10.84)  7231   5218  (-27.83)
80   23175  27141 (17.11)  4796  4509 (-5.98)   9152   7182  (-21.52)
96   23337  26759 (14.66)  5603  4543 (-18.91)  10890  7162  (-34.23)
128  22726  28339 (24.69)  7559  6395 (-15.39)  14600  10169 (-30.34)
________________________________________________________________________
Summary:    BW: 22.8%    CPU: 1.9%    RCPU: -17.0%
________________________________________________________________________
                    TCP: BW vs SD/Remote SD:
#    BW1    BW2 (%)        SD1      SD2  (%)        RSD1    RSD2   (%)
________________________________________________________________________
1    69971  65376 (-6.56)  4       6     (50.00)    21      26     (23.80)
2    20911  24839 (18.78)  6       7     (16.66)    27      28     (3.70)
4    21431  28912 (34.90)  26      31    (19.23)    108     111    (2.77)
8    21857  34592 (58.26)  106     135   (27.35)    432     393    (-9.02)
16   22368  33083 (47.90)  431     577   (33.87)    1742    1828   (4.93)
24   22556  32578 (44.43)  972     1393  (43.31)    3915    4479   (14.40)
32   22727  30923 (36.06)  1723    2165  (25.65)    6908    6842   (-.95)
40   23054  29334 (27.24)  2774    2761  (-.46)     10874   8764   (-19.40)
48   23006  28800 (25.18)  4126    3847  (-6.76)    15953   12172  (-23.70)
64   23411  27661 (18.15)  7216    6035  (-16.36)   28146   19078  (-32.21)
80   23175  27141 (17.11)  11729   12454 (6.18)     44765   39750  (-11.20)
96   23337  26759 (14.66)  16745   15905 (-5.01)    65099   50261  (-22.79)
128  22726  28339 (24.69)  30571   27893 (-8.76)    118089  89994  (-23.79)
________________________________________________________________________
Summary:    BW: 22.8%    SD: -4.21%    RSD: -21.06%
________________________________________________________________________
                       UDP: BW vs SD/CPU
#      BW1      BW2 (%)      CPU1      CPU2 (%)      SD1    SD2    (%)
_____________________________________________________________________________
1      36521    37415 (2.44)   61     61    (0)      2      2      (0)
4      28585    46903 (64.08)  397    546   (37.53)  72     68     (-5.55)
8      26649    44694 (67.71)  851    1243  (46.06)  334    339    (1.49)
16     25905    43385 (67.47)  1740   2631  (51.20)  1409   1572   (11.56)
32     24980    40448 (61.92)  3502   5360  (53.05)  5881   6401   (8.84)
48     27439    39451 (43.77)  5410   8324  (53.86)  12475  14855  (19.07)
64     25682    39915 (55.42)  7165   10825 (51.08)  23404  25982  (11.01)
96     26205    40190 (53.36)  10855  16283 (50.00)  52124  75014  (43.91)
128    25741    40252 (56.37)  14448  22186 (53.55)  133922 96843  (-27.68)
____________________________________________________________________________
Summary:       BW: 50.4      CPU: 51.8      SD: -27.68
_____________________________________________________________________________
N#: Number of netperf sessions, 60 sec runs
BW1,SD1,RSD1: Bandwidth (sum across 2 runs in mbps), SD and Remote
              SD for original code
BW2,SD2,RSD2: Bandwidth (sum across 2 runs in mbps), SD and Remote
              SD for new code.
CPU1,CPU2,RCPU1,RCPU2: Similar to SD.

For 1 TCP netperf, I ran 7 iterations and summed it. Explanation
for degradation for 1 stream case:
    1. Without any tuning, BW falls -6.5%.
    2. When vhosts on server were bound to CPU0, BW was as good
       as with original code.
    3. When new code was started with numtxqs=1 (or mq=off, which
       is the default), there was no degradation.


                       Next steps:
                       -----------
1. MQ RX patch is also complete - plan to submit once TX is OK (as
   well as after identifying bandwidth degradations for some test
   cases).
2. Cache-align data structures: I didn't see any BW/SD improvement
   after making the sq's (and similarly for vhost) cache-aligned
   statically:
        struct virtnet_info {
                ...
                struct send_queue sq[16] ____cacheline_aligned_in_smp;
                ...
        };
3. Migration is not tested.

Review/feedback appreciated.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
