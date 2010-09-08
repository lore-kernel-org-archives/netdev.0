From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Wed, 08 Sep 2010 12:58:59 +0530
Message-ID: <20100908072859.23769.97363.sendpatchset@krkumar2.in.ibm.com>
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org, anthony@codemonkey.ws,
	Krishna Kumar <krkumar2@in.ibm.com>, mst@redhat.com
To: rusty@rustcorp.com.au, davem@davemloft.net
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Following patches implement Transmit mq in virtio-net.  Also
included is the user qemu changes.

1. This feature was first implemented with a single vhost.
   Testing showed 3-8% performance gain for upto 8 netperf
   sessions (and sometimes 16), but BW dropped with more
   sessions.  However, implementing per-txq vhost improved
   BW significantly all the way to 128 sessions.
2. For this mq TX patch, 1 daemon is created for RX and 'n'
   daemons for the 'n' TXQ's, for a total of (n+1) daemons.
   The (subsequent) RX mq patch changes that to a total of
   'n' daemons, where RX and TX vq's share 1 daemon.
3. Service Demand increases for TCP, but significantly
   improves for UDP.
4. Interoperability: Many combinations, but not all, of
   qemu, host, guest tested together.


                  Enabling mq on virtio:
                  -----------------------

When following options are passed to qemu:
        - smp > 1
        - vhost=on
        - mq=on (new option, default:off)
then #txqueues = #cpus.  The #txqueues can be changed by using
an optional 'numtxqs' option. e.g.  for a smp=4 guest:
        vhost=on,mq=on             ->   #txqueues = 4
        vhost=on,mq=on,numtxqs=8   ->   #txqueues = 8
        vhost=on,mq=on,numtxqs=2   ->   #txqueues = 2


                   Performance (guest -> local host):
                   -----------------------------------

System configuration:
        Host:  8 Intel Xeon, 8 GB memory
        Guest: 4 cpus, 2 GB memory
All testing without any tuning, and TCP netperf with 64K I/O
_______________________________________________________________________________
                           TCP (#numtxqs=2)
N#      BW1     BW2    (%)      SD1     SD2    (%)      RSD1    RSD2    (%)
_______________________________________________________________________________
4       26387   40716 (54.30)   20      28   (40.00)    86i     85     (-1.16)
8       24356   41843 (71.79)   88      129  (46.59)    372     362    (-2.68)
16      23587   40546 (71.89)   375     564  (50.40)    1558    1519   (-2.50)
32      22927   39490 (72.24)   1617    2171 (34.26)    6694    5722   (-14.52)
48      23067   39238 (70.10)   3931    5170 (31.51)    15823   13552  (-14.35)
64      22927   38750 (69.01)   7142    9914 (38.81)    28972   26173  (-9.66)
96      22568   38520 (70.68)   16258   27844 (71.26)   65944   73031  (10.74)
_______________________________________________________________________________
                       UDP (#numtxqs=8)
N#      BW1     BW2   (%)      SD1     SD2   (%)
__________________________________________________________
4       29836   56761 (90.24)   67      63    (-5.97)
8       27666   63767 (130.48)  326     265   (-18.71)
16      25452   60665 (138.35)  1396    1269  (-9.09)
32      26172   63491 (142.59)  5617    4202  (-25.19)
48      26146   64629 (147.18)  12813   9316  (-27.29)
64      25575   65448 (155.90)  23063   16346 (-29.12)
128     26454   63772 (141.06)  91054   85051 (-6.59)
__________________________________________________________
N#: Number of netperf sessions, 90 sec runs
BW1,SD1,RSD1: Bandwidth (sum across 2 runs in mbps), SD and Remote
              SD for original code
BW2,SD2,RSD2: Bandwidth (sum across 2 runs in mbps), SD and Remote
              SD for new code. e.g. BW2=40716 means average BW2 was
              20358 mbps.


                       Next steps:
                       -----------

1. mq RX patch is also complete - plan to submit once TX is OK.
2. Cache-align data structures: I didn't see any BW/SD improvement
   after making the sq's (and similarly for vhost) cache-aligned
   statically:
        struct virtnet_info {
                ...
                struct send_queue sq[16] ____cacheline_aligned_in_smp;
                ...
        };

Guest interrupts for a 4 TXQ device after a 5 min test:
# egrep "virtio0|CPU" /proc/interrupts 
      CPU0     CPU1     CPU2    CPU3       
40:   0        0        0       0        PCI-MSI-edge  virtio0-config
41:   126955   126912   126505  126940   PCI-MSI-edge  virtio0-input
42:   108583   107787   107853  107716   PCI-MSI-edge  virtio0-output.0
43:   300278   297653   299378  300554   PCI-MSI-edge  virtio0-output.1
44:   372607   374884   371092  372011   PCI-MSI-edge  virtio0-output.2
45:   162042   162261   163623  162923   PCI-MSI-edge  virtio0-output.3

Review/feedback appreciated.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
