From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 0/2] net: threadable napi poll loop
Date: Tue, 10 May 2016 15:44:06 -0700
Message-ID: <1462920246.23934.107.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1462886866.git.pabeni@redhat.com>
	 <1462890590.23934.68.camel@edumazet-glaptop3.roam.corp.google.com>
	 <90f3db8c-c30c-b204-576a-454939ac93ce@stressinduktion.org>
	 <CANn89i+YKrVOgfFwW-2psfCzq5_YLdmbV06-H-1FCOwXdMBuzQ@mail.gmail.com>
	 <1462915900.23934.99.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1462916121.16365.14.camel@redhat.com>
	 <1462917217.23934.101.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1462917747.23934.102.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Paolo Abeni <pabeni@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Tom Herbert <tom@herbertland.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Rik van Riel <riel@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33770 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751293AbcEJWoJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 18:44:09 -0400
In-Reply-To: <1462917747.23934.102.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-05-10 at 15:02 -0700, Eric Dumazet wrote:
> On Tue, 2016-05-10 at 14:53 -0700, Eric Dumazet wrote:
> > On Tue, 2016-05-10 at 17:35 -0400, Rik van Riel wrote:
> > 
> > > You might need another one of these in invoke_softirq()
> > > 
> > 
> > Excellent.
> > 
> > I gave it a quick try (without your suggestion), and host seems to
> > survive a stress test.
> > 
> > Of course we do have to fix these problems :
> > 
> > [  147.781629] NOHZ: local_softirq_pending 48
> > [  147.785546] NOHZ: local_softirq_pending 48
> > [  147.788344] NOHZ: local_softirq_pending 48
> > [  147.788992] NOHZ: local_softirq_pending 48
> > [  147.790943] NOHZ: local_softirq_pending 48
> > [  147.791232] NOHZ: local_softirq_pending 24a
> > [  147.791258] NOHZ: local_softirq_pending 48
> > [  147.791366] NOHZ: local_softirq_pending 48
> > [  147.792118] NOHZ: local_softirq_pending 48
> > [  147.793428] NOHZ: local_softirq_pending 48
> 
> 
> Well, with your suggestion, these warnings disappear ;)

This is really nice.

Under stress number of context switches is really small.

ksoftirqd and my netserver compete equally to get the cpu cycles (on
CPU0)

lpaa23:~# vmstat 1 10
procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 2  0      0 260668416  37240 2414428    0    0    21     0  329  349  0  3 96  0
 1  0      0 260667904  37240 2414428    0    0     0    12 193126 1050  0  2 98  0
 1  0      0 260667904  37240 2414428    0    0     0     0 194354 1056  0  2 98  0
 1  0      0 260669104  37240 2414492    0    0     0     0 200897 1095  0  2 98  0
 1  0      0 260668592  37240 2414492    0    0     0     0 205731  964  0  2 98  0
 1  0      0 260678832  37240 2414492    0    0     0     0 201689  981  0  2 98  0
 1  0      0 260678832  37240 2414492    0    0     0     0 204899  742  0  2 98  0
 1  0      0 260678320  37240 2414492    0    0     0     0 199148  792  0  3 97  0
 1  0      0 260678832  37240 2414492    0    0     0     0 196398  766  0  2 98  0
 1  0      0 260678832  37240 2414492    0    0     0     0 201930  858  0  2 98  0


And we can see that ksoftirqd/0 runs for longer periods (~500 usec),
instead of stupid 4 usec before the patch. Less overhead.

lpaa23:~# cat /proc/3/sched
ksoftirqd/0 (3, #threads: 1)
-------------------------------------------------------------------
se.exec_start                                :       1552401.399526
se.vruntime                                  :        237599.421560
se.sum_exec_runtime                          :         75432.494199
se.nr_migrations                             :                    0
nr_switches                                  :               144333
nr_voluntary_switches                        :               143828
nr_involuntary_switches                      :                  505
se.load.weight                               :                 1024
se.avg.load_sum                              :                10445
se.avg.util_sum                              :                10445
se.avg.load_avg                              :                    0
se.avg.util_avg                              :                    0
se.avg.last_update_time                      :        1552401399526
policy                                       :                    0
prio                                         :                  120
clock-delta                                  :                   47
lpaa23:~# echo 75432.494199/144333|bc -l
.52262818758703830724

And yes indeed, user space can progress way faster under flood.

lpaa23:~# nstat >/dev/null;sleep 1;nstat | grep Udp
UdpInDatagrams                  186132             0.0
UdpInErrors                     735462             0.0
UdpOutDatagrams                 10                 0.0
UdpRcvbufErrors                 735461             0.0
