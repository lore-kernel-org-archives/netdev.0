From: Mike Galbraith <efault@gmx.de>
Subject: [regression]  benchmark throughput loss from a622cf6..f7160c7 pull
Date: Mon, 10 Nov 2008 11:35:50 +0100
Message-ID: <1226313350.10058.16.camel@marge.simson.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Miklos Szeredi <mszeredi@suse.cz>,
	Rusty Russell <rusty@rustcorp.com.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755145AbYKJKgU@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Greetings,

While retesting that recent scheduler fixes/improvements had survived
integration into mainline, I found that we've regressed a bit since..
yesterday.  In testing, it seems that CFS has finally passed what the
old O(1) scheduler could deliver in scalability and throughput, but we
already lost a bit.

Reverting 984f2f3 cd83e42 2d3854a and 6209344 recovered the loss.

2.6.22.19-smp virgin
volanomark         130504 129530 129438 messages/sec    avg 129824.00   1.000
tbench 40          1151.58 1131.62 1151.66 MB/sec       avg 1144.95     1.000
tbench 160         1113.80 1108.12 1103.16 MB/sec       avg 1108.36     1.000
netperf TCP_RR     421568.71 418142.64 417817.28 rr/sec avg 419176.21   1.000
pipe-test          3.37 usecs/loop                                      1.000

2.6.25.19-smp virgin
volanomark         128967 125653 125913 messages/sec    avg 126844.33    .977
tbench 40          1036.35 1031.72 1027.86 MB/sec       avg 1031.97      .901
tbench 160         578.310 571.059 569.219 MB/sec       avg 572.86       .516
netperf TCP_RR     414134.81 415001.04 413729.41 rr/sec avg 414288.42    .988
pipe-test          3.19 usecs/loop                                       .946

WIP! incomplete clock back-port, salt to taste.  (cya O(1), enjoy retirement)
2.6.25.19-smp + last_buddy + WIP_25..28-rc3_sched_clock + native_read_tsc()
volanomark         146280 136047 137204 messages/sec    avg 139843.66   1.077
tbench 40          1232.60 1225.91 1222.56 MB/sec       avg 1227.02     1.071
tbench 160         1226.35 1219.37 1223.69 MB/sec       avg 1223.13     1.103
netperf TCP_RR     424816.34 425735.14 423583.85 rr/sec avg 424711.77   1.013
pipe-test          3.13 usecs/loop                                       .928

2.6.26.7-smp + last_buddy + v2.6.26..v2.6.28-rc3_sched_clock + native_read_tsc()
volanomark         149085 137944 139815 messages/sec    avg 142281.33   1.095
tbench 40          1171.22 1169.65 1170.87 MB/sec       avg 1170.58     1.022
tbench 160         1163.11 1173.36 1170.61 MB/sec       avg 1169.02     1.054
netperf TCP_RR     410945.22 412223.92 408210.13 rr/sec avg 410459.75    .979
pipe-test          3.41 usecs/loop                                      1.004

v2.6.28-rc3-249-ga622cf6-smp
volanomark         137792 132961 133672 messages/sec    avg 134808.33   1.038 
volanomark         144302 132915 133440 messages/sec    avg 136885.66   1.054
volanomark         143559 130598 133110 messages/sec    avg 135755.66   1.045  avg 135816.55  1.000
tbench 40          1154.37 1157.23 1154.37 MB/sec       avg 1155.32     1.009      1155.32    1.000
tbench 160         1157.25 1153.35 1154.37 MB/sec       avg 1154.99     1.042      1154.99    1.000
netperf TCP_RR     385895.13 385675.89 386651.03 rr/sec avg 386074.01    .921      386074.01  1.000
pipe-test          3.41 usecs/loop                                      1.004

v2.6.28-rc4-smp
volanomark         138733 129958 130647 messages/sec    avg 133112.66   1.025
volanomark         141951 133862 131652 messages/sec    avg 135821.66   1.046
volanomark         136182 134131 132926 messages/sec    avg 134413.00   1.035  avg 134449.10   .989
tbench 40          1140.48 1137.64 1140.91 MB/sec       avg 1139.67      .995      1139.67     .986
tbench 160         1128.23 1131.14 1131.19 MB/sec       avg 1130.18     1.019      1130.18     .978
netperf TCP_RR     371695.82 374002.70 371824.78 rr/sec avg 372507.76    .888      372507.76   .964
pipe-test          3.41 usecs/loop                                      1.004

v2.6.28-rc4-smp + revert 984f2f3 cd83e42 2d3854a
volanomark         143305 132649 133175 messages/sec    avg 136376.33   1.050
volanomark         139049 131403 132571 messages/sec    avg 134341.00   1.025
volanomark         141499 131572 131461 messages/sec    avg 134844.00   1.034  avg 135187.11  1.005
tbench 40          1154.79 1153.41 1152.18 MB/sec       avg 1153.46     1.007      1153.46     .998
tbench 160         1148.72 1143.80 1143.96 MB/sec       avg 1145.49     1.033      1145.49     .991
netperf TCP_RR     379334.51 379871.08 376917.76 rr/sec avg 378707.78    .903      378707.78   .980
pipe-test          3.36 usecs/loop (hm)                                  .997

v2.6.28-rc4-smp + revert 984f2f3 cd83e42 2d3854a + 6209344
volanomark         143875 133182 133451 messages/sec    avg 136836.00   1.054
volanomark         142314 134700 133783 messages/sec    avg 136932.33   1.054
volanomark         141798 132922 132406 messages/sec    avg 135708.66   1.045  avg 136492.33  1.004
tbench 40          1160.33 1157.89 1156.12 MB/sec       avg 1158.11     1.011      1158.11    1.002
tbench 160         1150.42 1150.49 1151.83 MB/sec       avg 1150.91     1.038      1150.91     .996
netperf TCP_RR     385468.32 386160.09 385377.01 rr/sec avg 385668.47    .920      385668.47   .998
pipe-test          3.37 usecs/loop                                      1.000
