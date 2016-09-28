From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [PATCH RFC 0/4] xfs: Transmit flow steering
Date: Wed, 28 Sep 2016 08:13:59 -0700
Message-ID: <7c278b6b-085c-e77c-ed77-0150e1718e7f@hpe.com>
References: <1472601634-531498-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel-team@fb.com, "Balliet, Drew" <andrew_balliet@hpe.com>,
        Juerg Haefliger <juerg.haefliger@hpe.com>
To: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3427.houston.hpe.com ([15.241.140.73]:51148 "EHLO
        g4t3427.houston.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751742AbcI1POB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 11:14:01 -0400
In-Reply-To: <1472601634-531498-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Here is a quick look at performance tests for the result of trying the
prototype fix for the packet reordering problem with VMs sending over
an XPS-configured NIC.  In particular, the Emulex/Avago/Broadcom
Skyhawk.  The fix was applied to a 4.4 kernel.

Before: 3884 Mbit/s
After: 8897 Mbit/s

That was from a VM on a node with a Skyhawk and 2 E5-2640 processors
to baremetal E5-2640 with a BE3.  Physical MTU was 1500, the VM's
vNIC's MTU was 1400.  Systems were HPE ProLiants in OS Control Mode
for power management, with the "performance" frequency governor
loaded. An OpenStack Mitaka setup with Distributed Virtual Router.

We had some other NIC types in the setup as well.  XPS was also
enabled on the ConnectX3-Pro.  It was not enabled on the 82599ES (a
function of the kernel being used, which had it disabled from the
first reports of XPS negatively affecting VM traffic at the beginning
of the year)

Average Mbit/s From NIC type To Bare Metal BE3:
NIC Type,
  CPU on VM Host            Before        After
------------------------------------------------
ConnectX-3 Pro,E5-2670v3    9224         9271
BE3, E5-2640                9016	 9022
82599, E5-2640              9192	 9003
BCM57840, E5-2640           9213	 9153
Skyhawk, E5-2640            3884	 8897

For completeness:
Average Mbit/s To NIC type from Bare Metal BE3:
NIC Type,
  CPU on VM Host            Before        After
------------------------------------------------
ConnectX-3 Pro,E5-2670v3    9322         9144
BE3, E5-2640		    9074	 9017
82599, E5-2640              8670	 8564
BCM57840, E5-2640           2468 *	 7979
Skyhawk, E5-2640            8897	 9269

* This is the Busted bnx2x NIC FW GRO implementation issue.  It was
   not visible in the "After" because the system was setup to disable
   the NIC FW GRO by the time it booted on the fix kernel.

Average Transactions/s Between NIC type and Bare Metal BE3:
NIC Type,
  CPU on VM Host            Before        After
------------------------------------------------
ConnectX-3 Pro,E5-2670v3   12421         12612
BE3, E5-2640		    8178	  8484
82599, E5-2640              8499	  8549
BCM57840, E5-2640           8544	  8560
Skyhawk, E5-2640            8537	  8701

happy benchmarking,

Drew Balliet
Jeurg Haefliger
rick jones

The semi-cooked results with additional statistics:

554M  - BE3
544+M - ConnectX-3 Pro
560M - 82599ES
630M - BCM57840
650M - Skyhawk

(substitute is simply replacing a system name with the model of NIC and CPU)
Bulk To (South) and From (North) VM, Before:
$ ../substitute.sh 
vxlan_554m_control_performance_gvnr_dvr_northsouth_stream.log | 
~/netperf2_trunk/doc/examples/parse_single_stream.py -r -5 -f 1 -f 3 -f 
4 -f 7 -f 8
Field1,Field3,Field4,Field7,Field8,Min,P10,Median,Average,P90,P99,Max,Count
North,560M,E5-2640,554FLB,E5-2640,8148.090,9048.830,9235.400,9192.868,9315.980,9338.845,9339.500,113
North,630M,E5-2640,554FLB,E5-2640,8909.980,9113.238,9234.750,9213.140,9299.442,9336.206,9337.830,47
North,544+M,E5-2670v3,554FLB,E5-2640,9013.740,9182.546,9229.620,9224.025,9264.036,9299.206,9301.970,99
North,650M,E5-2640,554FLB,E5-2640,3187.680,3393.724,3796.160,3884.765,4405.096,4941.391,4956.300,129
North,554M,E5-2640,554FLB,E5-2640,8700.930,8855.768,9026.030,9016.061,9158.846,9213.687,9226.150,135
South,554FLB,E5-2640,560M,E5-2640,7754.350,8193.114,8718.540,8670.612,9026.436,9262.355,9285.010,113
South,554FLB,E5-2640,630M,E5-2640,1897.660,2068.290,2514.430,2468.323,2787.162,2942.934,2957.250,53
South,554FLB,E5-2640,544+M,E5-2670v3,9298.260,9314.432,9323.220,9322.207,9328.324,9330.704,9331.080,100
South,554FLB,E5-2640,650M,E5-2640,8407.050,8907.136,9304.390,9206.776,9321.320,9325.347,9326.410,103
South,554FLB,E5-2640,554M,E5-2640,7844.900,8632.530,9199.385,9074.535,9308.070,9319.224,9322.360,132
0 too-short lines ignored.

Bulk To (South) and From (North) VM, After:

$ ../substitute.sh 
vxlan_554m_control_performance_gvnr_xpsfix_dvr_northsouth_stream.log | 
~/netperf2_trunk/doc/examples/parse_single_stream.py -r -5 -f 1 -f 3 -f 
4 -f 7 -f 8
Field1,Field3,Field4,Field7,Field8,Min,P10,Median,Average,P90,P99,Max,Count
North,560M,E5-2640,554FLB,E5-2640,7576.790,8213.890,9182.870,9003.190,9295.975,9315.878,9318.160,36
North,630M,E5-2640,554FLB,E5-2640,8811.800,8924.000,9206.660,9153.076,9306.287,9315.152,9315.790,12
North,544+M,E5-2670v3,554FLB,E5-2640,9135.990,9228.520,9277.465,9271.875,9324.545,9339.604,9339.780,46
North,650M,E5-2640,554FLB,E5-2640,8133.420,8483.340,8995.040,8897.779,9129.056,9165.230,9165.860,43
North,554M,E5-2640,554FLB,E5-2640,8438.390,8879.150,9048.590,9022.813,9181.540,9248.650,9297.660,101
South,554FLB,E5-2640,630M,E5-2640,7347.120,7592.565,7951.325,7979.951,8365.400,8575.837,8579.890,16
South,554FLB,E5-2640,560M,E5-2640,7719.510,8044.496,8602.750,8564.741,9172.824,9248.686,9259.070,45
South,554FLB,E5-2640,544+M,E5-2670v3,8838.660,8907.402,9112.335,9114.040,9326.510,9329.062,9329.990,52
South,554FLB,E5-2640,650M,E5-2640,8699.660,9204.378,9307.940,9269.755,9321.060,9328.007,9331.370,58
South,554FLB,E5-2640,554M,E5-2640,7893.310,8483.182,9111.070,9017.273,9314.984,9322.822,9326.750,103

Request/Response Before:
$ ../substitute.sh 
vxlan_554m_control_performance_gvnr_dvr_northsouth_rr.log | 
~/netperf2_trunk/doc/examples/parse_single_stream.py -r -5 -f 1 -f 3 -f 
4 -f 7 -f 8
Field1,Field3,Field4,Field7,Field8,Min,P10,Median,Average,P90,P99,Max,Count
RR,554FLB,E5-2640,560M,E5-2640,6971.540,8356.420,8515.275,8499.397,8717.740,9023.489,9114.990,186
RR,554FLB,E5-2640,630M,E5-2640,7538.530,8461.090,8532.970,8544.005,8665.414,8895.486,9003.330,119
RR,554FLB,E5-2640,544+M,E5-2670v3,8825.970,12279.268,12504.175,12421.076,12646.219,12742.536,12831.490,238
RR,554FLB,E5-2640,650M,E5-2640,7152.220,8425.368,8535.370,8537.314,8757.256,9046.692,9128.290,219

Request/Response After:

$ ../substitute.sh 
vxlan_554m_control_performance_gvnr_xpsfix_dvr_northsouth_rr.log | 
~/netperf2_trunk/doc/examples/parse_single_stream.py -r -5 -f 1 -f 3 -f 
4 -f 7 -f 8
Field1,Field3,Field4,Field7,Field8,Min,P10,Median,Average,P90,P99,Max,Count
RR,554FLB,E5-2640,560M,E5-2640,7385.910,8411.654,8568.280,8549.659,8724.006,8874.092,8971.860,85
RR,554FLB,E5-2640,630M,E5-2640,8265.030,8472.924,8543.215,8560.117,8657.339,8900.349,8902.260,34
RR,554FLB,E5-2640,544+M,E5-2670v3,12365.830,12446.182,12597.575,12612.538,12790.654,12939.399,12968.120,78
RR,554FLB,E5-2640,650M,E5-2640,8391.870,8516.924,8672.000,8701.399,8977.302,9100.178,9130.380,89
RR,554FLB,E5-2640,554M,E5-2640,6859.680,8390.240,8481.835,8484.884,8649.290,8850.360,8976.960,226
