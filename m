From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [WIP][PATCHES] Network xmit batching
Date: Thu, 7 Jun 2007 14:12:45 +0530
Message-ID: <OF4ACB16BB.A5DB2CC2-ON652572F3.002CD2F1-652572F3.002FDC45@in.ibm.com>
References: <1181137761.4068.22.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Gagan Arneja <gaagaan@gmail.com>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:53305 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750825AbXFGIrG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 04:47:06 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l5797nUb145682
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 19:07:49 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l578nvL8049626
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 18:50:08 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l578hs7e018187
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 18:43:58 +1000
In-Reply-To: <1181137761.4068.22.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jamal,

I ran these bits today and the results are included. For comparison, I am
running 2.6.22-rc3 original bits. The systems are both 2.8Ghz, 2 cpu, P4,
2GB RAM, one E1000 82547GI card connected using a crossover cable.
The test runs for 3 mins for each case. I have run only once instead of
taking any averages, so there could be some spurts/drops.

These results are based on the test script that I sent earlier today. I
removed the results for UDP 32 procs 512 and 4096 buffer cases since
the BW was coming >line speed (infact it was showing 1500Mb/s and
4900Mb/s respectively for both the ORG and these bits). I am not sure
how it is coming this high, but netperf4 is the only way to correctly
measure multiple process combined BW. Another thing to do is to disable
pure performance fixes in E1000 (eg changing THRESHOLD to 128 and
some other changes like Erratum workaround or MSI, etc) which are
independent of this functionality. Then a more accurate performance
result is possible when comparing org vs batch code, without mixing in
unrelated performance fixes which skews the results (either positively
or negatively :).

Each iteration consists of running buffer sizes 8, 32, 128, 512, 4096.

---------------------------------------------------------------------------------------------
   Org                  New               Perc
BW    Service           BW     Service          BW     Service
---------------------------------------------------------------------------------------------

                  TCP 1 process
68.50 119.94                  67.70 121.34            -1.16 1.16
234.68      35.02             234.42      35.02       -.11  0
768.91      10.68             850.38      9.65        10.59 -9.64
941.16      2.92              941.15      2.80        0     -4.10
939.78      1.90              939.81      1.87        0     -1.57

                  TCP 32 processes
93.80 185714.97         91.02 190822.43   -2.96 2.75
324.76      53909.46          315.69      54528.68    -2.79 1.14
944.24      13035.72          958.14      12946.88    1.47  -.68
939.95      4508.47                 941.35      4545.90           .14   .83
941.88      3334.41                 941.88      3134.97           0     -5.98

                  TCP 1 process No Delay
18.35 447.47                  17.75 462.79            -3.26 3.42
73.64 111.53                  71.31 115.20            -3.16 3.29
275.33      29.83             272.35      30.16       -1.08 1.10
940.41      3.99              941.12      2.83        .07   -29.07
941.06      3.00              941.12      1.87        0     -37.66

                  TCP 32 processes No Delay
40.59 454802.47         36.80 525062.48   -9.33 15.44
93.34 191264.12         89.41 220342.26   -4.21 15.20
940.99      12663.67          942.11      13143.16    .11   3.78
941.81      4659.62                 942.24      4435.86           .04   -4.80
941.80      3384.20                 941.77      3163.40           0     -6.52

                  UDP 1 process
20.2  407.20                  20.2  406.45            0     -.18
80.1  102.63                  80.6  102.01            .62   -.60
317.5 25.71             319.1 25.58       .50   -.50
885.4 7.24              885.3 5.15        -.01  -28.86
957.1 2.96              957.1 2.72        0     -8.10

                  UDP 32 processes (only 3 buffer sizes)
21.1  850934.50         21.5  823970.70   1.89  -3.16
83.2  211132.86         85.0  209824.30   2.16  -.61
337.6 73860.56          353.7 242295.07   4.76  228.04
---------------------------------------------------------------------------------------------
Avg: 14107.18   2064517.05    14200.02   2309541.53   .65   11.86

Summary : Average BW (whatever meaning that has) improved 0.65%, while
                 Service Demand deteriorated 11.86%

Regards,

- KK

J Hadi Salim <j.hadi123@gmail.com> wrote on 06/06/2007 07:19:21 PM:

> Folks,
>
> While Krishna and I have been attempting this on the side, progress has
> been rather slow - so this is to solicit for more participation so we
> can get this over with faster. Success (myself being conservative when
> it comes to performance) requires testing on a wide variety of hardware.
>
> The results look promising - certainly from a pktgen perspective where
> performance has been known in some cases to go up over 50%.
> Tests by Sridhar on a low number of TCP flows also indicate improved
> performance as well as lowered CPU use.
>
> I have setup the current state of my patches against Linus tree at:
> git://git.kernel.org/pub/scm/linux/kernel/git/hadi/batch-lin26.git
>
> This is also clean against 2.6.22-rc4. So if you want just a diff that
> will work against 2.6.22-rc4 - i can send it to you.
> I also have a tree against Daves net-2.6 at
> git://git.kernel.org/pub/scm/linux/kernel/git/hadi/batch-net26.git
> but iam abandoning that effort until we get this stable due to the
> occasional bug that cropped up(like e1000).
>
> I am attaching a pktgen script. There is one experimental parameter
> called "batch_low" - for starters just leave it at 0 in order to reduce
> experimental variance. If you have solid results you can muck around
> with it.
> KK has a netperf script he has been using - if you know netperf your
> help will really be appreciated in testing it on your hardware.
> KK, can you please post your script?
> Testing with forwarding and bridging will also be appreaciated.
> Above that, suggestions to changes as long as they are based on
> verifiable results or glaringly obvious changes are welcome. My
> preference at the moment is to flesh out the patch as is and then
> improve on it later if it shows it has some value on a wide variety of
> apps. As the subject is indicating this is a WIP and as all eulas
> suggest "subject to change without notice".
> If you help out, when you post your results, can you please say what
> hardware and setup was?
>
> The only real driver that has been changed is e1000 for now. KK is
> working on something infiniband related and i plan (if noone beats me)
> to get tg3 working. It would be nice if someone converted some 10G
> ethernet driver.
>
> cheers,
> jamal
> [attachment "pktgen.batch-1-1" deleted by Krishna Kumar2/India/IBM]

