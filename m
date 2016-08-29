From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH] e1000: add initial XDP support
Date: Mon, 29 Aug 2016 17:55:09 +0200
Message-ID: <20160829175509.7ed19b89@redhat.com>
References: <20160827071145.25345.84712.stgit@john-Precision-Tower-5810>
        <b6cfb3c5-9c68-3ea7-48dd-7fbf666db751@mojatatu.com>
        <20160829103047.3968a4d8@redhat.com>
        <61de1b91-30b4-67ba-4192-834fa30757ea@mojatatu.com>
        <20160829153905.50066865@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>, bblanco@plumgrid.com,
        davem@davemloft.net, alexei.starovoitov@gmail.com,
        john.r.fastabend@intel.com, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, brouer@redhat.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56094 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750984AbcH2PzP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 29 Aug 2016 11:55:15 -0400
In-Reply-To: <20160829153905.50066865@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Jamal,

I'm adding: drop a specific UDP port option to my script... But I does
not match/drop the packets, command below does apply, but it does not
work in practice

$ ./tc_ingress_drop.sh --verbose --dev mlx5p2 --port 9
tc qdisc del dev mlx5p2 ingress
tc qdisc add dev mlx5p2 ingress
tc filter add dev mlx5p2 parent ffff: prio 4 protocol ip u32 match ip protocol 17 0xff match udp dst 9 0xffff flowid 1:1 action drop

(Use-case is obviously to drop pktgen UDP packets.)

I also tried with:

 tc filter add dev mlx5p2 parent ffff: prio 4 protocol ip \
  u32 \
  match udp dst 9 0xffff \
  match ip protocol 17 0xff flowid 1:1 action drop

--Jesper
(top post)

On Mon, 29 Aug 2016 15:39:05 +0200 Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> On Mon, 29 Aug 2016 06:53:53 -0400
> Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> 
> > On 16-08-29 04:30 AM, Jesper Dangaard Brouer wrote:
> >   
> > > Hi Jamal,
> > >
> > > Can you please provide a simple "tc" command that implements "tc drop"?
> > >
> > > Then, I'll add this to the series of tests I'm using for (what I call)
> > > "zoom-in" benchmarking.
> > >    
> > 
> > Thanks Jesper.  
> 
> I've created a script called tc_ingress_drop.sh[1] which uses the
> commands you provided below.  Now people can easily use this script to
> perform the benchmark you were requesting ;-)
> 
> [1] https://github.com/netoptimizer/network-testing/blob/master/bin/tc_ingress_drop.sh
> 
> Example to enable dropping:
> 
>  $ ./tc_ingress_drop.sh --dev mlx5p2 --verbose
>  # (Not root, running with sudo)
>  # Flush existing ingress qdisc on device :mlx5p2
>  tc qdisc del dev mlx5p2 ingress
>  tc qdisc add dev mlx5p2 ingress
>  # Simply drop all ingress packets on device: mlx5p2
>  tc filter add dev mlx5p2 parent ffff: prio 2 protocol ip u32 match u32 0 0 flowid 1:1 action drop
> 
> Example to disable again:
>  ./tc_ingress_drop.sh --dev mlx5p2 --flush
> 
>  
> > Something simple since this is done in ingress; lets say drop icmp
> > packets:
> > 
> > export ETH=eth0
> > export TC=/sbin/tc
> > #delete existing ingress qdisc - flushes all filters/actions
> > sudo $TC qdisc del dev $ETH ingress
> > #re-add ingress
> > sudo $TC qdisc add dev $ETH ingress
> > #
> > #simple rule to drop all icmp
> > sudo $TC filter add dev $ETH parent ffff: prio 4 protocol ip \
> > u32 match ip protocol 1 0xff flowid 1:1 \
> > action drop
> > 
> > # other type of filters if you want to compare instead of above
> > #
> > # a)drop all
> > sudo $TC filter add dev $ETH parent ffff: prio 2 protocol ip \
> > u32 match u32 0 0 flowid 1:1 \
> > action drop
> > #b) drop if src is XXX
> > sudo $TC filter add dev $ETH parent ffff: prio 2 protocol ip \
> > u32 match ip src 192.168.100.1 flowid 1:1 \
> > action drop
> >   



-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
