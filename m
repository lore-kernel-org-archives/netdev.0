From: Simon Xiao <sixiao@microsoft.com>
Subject: RE: linux-next network throughput performance regression
Date: Mon, 9 Nov 2015 20:23:03 +0000
Message-ID: <CY1PR03MB13761B2731BF4FA3748D73B7C4150@CY1PR03MB1376.namprd03.prod.outlook.com>
References: <CY1PR03MB13760C9F1AABC4EBC455B85CC4280@CY1PR03MB1376.namprd03.prod.outlook.com>
 <563D1180.60206@cumulusnetworks.com>
 <CY1PR03MB13763CB0C0A9C822660E248AC4280@CY1PR03MB1376.namprd03.prod.outlook.com>
 <563D1BE0.2070107@cumulusnetworks.com>
 <1446924959.17135.23.camel@edumazet-glaptop2.roam.corp.google.com>
 <1446925821.17135.24.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 Haiyang Zhang <haiyangz@microsoft.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>, David Ahern
 <dsa@cumulusnetworks.com>, "ohering@suse.com" <ohering@suse.com>, Tom Herbert
 <tom@herbertland.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1446925821.17135.24.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Thanks Eric to provide the data. I am looping Tom (as I am looking into his recent patches) and Olaf (from Suse).

So, if I understand it correctly, you are running netperf with single TCP connection, and you got ~26Gbps initially and got ~30Gbps after turning the tx-usecs and tx-frames.

Do you have a baseline on your environment for the best/max/or peak throughput?
Again, in my environment (SLES bare metal), if use SLES12 default kernel as a baseline, we can see significant performance drop (10% ~ 50%) on latest linux-next kernel. 
Absolutely I will try the same test on net-next soon and update the results to here later.

Thanks,
Simon


> -----Original Message-----
> From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
> Sent: Saturday, November 7, 2015 11:50 AM
> To: David Ahern <dsa@cumulusnetworks.com>
> Cc: Simon Xiao <sixiao@microsoft.com>; devel@linuxdriverproject.org;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org; David Miller
> <davem@davemloft.net>; KY Srinivasan <kys@microsoft.com>; Haiyang
> Zhang <haiyangz@microsoft.com>
> Subject: Re: linux-next network throughput performance regression
> 
> On Sat, 2015-11-07 at 11:35 -0800, Eric Dumazet wrote:
> > On Fri, 2015-11-06 at 14:30 -0700, David Ahern wrote:
> > > On 11/6/15 2:18 PM, Simon Xiao wrote:
> > > > The .config file used to build linux-next kernel is attached to this mail.
> > >
> > > Thanks.
> > >
> > > Failed to notice this on the first response; my brain filled in. Why
> > > linux-next tree? Can you try net-next which is more relevant for
> > > this mailing list, post the top commit id and config file used?
> >
> > Throughput on a single TCP flow for a 40G NIC can be tricky to tune.
> >
> > Make sure IRQ are properly setup/balanced, as I know that IRQ names
> > were changed recently and your scripts might have not noticed...
> >
> > Also "ethtool -c eth0" might show very different interrupt coalescing
> > params ?
> >
> > I too have a Mellanox 40Gb in my lab and saw no difference in
> > performance with recent kernels.
> >
> > Of course, a simple "perf record -a -g sleep 4 ; perf report" might
> > point to some obvious issue. Like unexpected segmentation in case of
> > forwarding...
> >
> >
> 
> I did a test with current net tree on both sender and receiver
> 
> lpaa23:~# ./netperf -H 10.246.7.152
> MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
> 10.246.7.152 () port 0 AF_INET
> Recv   Send    Send
> Socket Socket  Message  Elapsed
> Size   Size    Size     Time     Throughput
> bytes  bytes   bytes    secs.    10^6bits/sec
> 
>  87380  16384  16384    10.00    26864.98
> lpaa23:~# ethtool -c eth1
> Coalesce parameters for eth1:
> Adaptive RX: on  TX: off
> stats-block-usecs: 0
> sample-interval: 0
> pkt-rate-low: 400000
> pkt-rate-high: 450000
> 
> rx-usecs: 16
> rx-frames: 44
> rx-usecs-irq: 0
> rx-frames-irq: 0
> 
> tx-usecs: 16
> tx-frames: 16
> tx-usecs-irq: 0
> tx-frames-irq: 256
> 
> rx-usecs-low: 0
> rx-frame-low: 0
> tx-usecs-low: 0
> tx-frame-low: 0
> 
> rx-usecs-high: 128
> rx-frame-high: 0
> tx-usecs-high: 0
> tx-frame-high: 0
> 
> lpaa23:~# ethtool -C eth1 tx-usecs 4 tx-frames 4


> lpaa23:~# ./netperf -H
> 10.246.7.152 MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0
> AF_INET to
> 10.246.7.152 () port 0 AF_INET
> Recv   Send    Send
> Socket Socket  Message  Elapsed
> Size   Size    Size     Time     Throughput
> bytes  bytes   bytes    secs.    10^6bits/sec
> 
>  87380  16384  16384    10.00    30206.27
> 
