From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Throughput regression with `tcp: refine TSO autosizing`
Date: Wed, 04 Feb 2015 05:16:50 -0800
Message-ID: <1423055810.907.125.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CA+BoTQkVu23P3EOmY_Q3E1GJnWsyF==Pawz4iPOS_Bq5dvfO5Q@mail.gmail.com>
	 <1422537297.21689.15.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQk2xT-8DqPuiiKG+kHAjLPrj8F9dLTb-rcGhvMq0u_2Qw@mail.gmail.com>
	 <1422628835.21689.95.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQkV+mOZfe_Niz5101sMQeaV6muKCsShptjGQ1AgOHqqoQ@mail.gmail.com>
	 <1422903136.21689.114.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1422926330.21689.138.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQkMikA8wxm1ce2DkKhPB0HiKeAqT7f+sQ=91W40z=X0Rg@mail.gmail.com>
	 <1422973660.907.10.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQmvUuFdfYF=wVMYxrf_nQZB5GCV=LvDZVvfs-3hAE4WKw@mail.gmail.com>
	 <1423051045.907.108.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQ=BDcQ779uKCuX+f40=4npXVF4MTQnpjKimNYAxPsxBoQ@mail.gmail.com>
	 <1423053531.907.115.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQ=qmCZz4CmSOvCOzMLowrDEG12XBffkTcYxjGqVD9604g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	eyalpe@dev.mellanox.co.il
To: Michal Kazior <michal.kazior@tieto.com>,
	Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:55462 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965521AbbBDNQv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 08:16:51 -0500
In-Reply-To: <CA+BoTQ=qmCZz4CmSOvCOzMLowrDEG12XBffkTcYxjGqVD9604g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OK guys

Using a mlx4 testbed I can reproduce the problem by pushing coalescing
settings and disabling SG (thus disabling GSO)

ethtool -K eth0 sg off
Actual changes:
scatter-gather: off
	tx-scatter-gather: off
generic-segmentation-offload: off [requested on]

ethtool -C eth0 tx-usecs 1024 tx-frames 64

Meaning that NIC waits one ms before sending the TX IRQ,
and can accumulate 64 frames before forcing the interrupt.

We probably have a bug in cwnd expansion logic :

lpaa23:~# DUMP_TCP_INFO=1 ./netperf -H 10.246.7.152 -Cc
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 10.246.7.152 () port 0 AF_INET
rto=201000 ato=0 pmtu=1500 rcv_ssthresh=29200 rtt=230 rttvar=30 snd_ssthresh=41 cwnd=59 reordering=3 total_retrans=1 ca_state=0 pacing_rate=5943.1 Mbits
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

 87380  16384  16384    10.00       530.39   0.40     0.32     2.965   2.398  


-> final cwnd=59 which is not enough to avoid the 1ms delay between each
burst. 

So sender sends ~60 packets, then has to wait 1ms (to get NIC TX IRQ)
before sending the following burst.

I am CCing Neal, he probably can help to root cause the problem.

Thanks
