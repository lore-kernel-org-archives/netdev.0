From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: network stream fairness
Date: Mon, 09 Nov 2015 08:07:51 -0800
Message-ID: <1447085271.17135.44.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5640BEAC.10404@axis.com>
	 <1447084258.17135.39.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5640C15E.805@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "edumazet@google.com" <edumazet@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Niklas Cassel <niklas.cassel@axis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36097 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751822AbbKIQHx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2015 11:07:53 -0500
Received: by pacdm15 with SMTP id dm15so178984524pac.3
        for <netdev@vger.kernel.org>; Mon, 09 Nov 2015 08:07:52 -0800 (PST)
In-Reply-To: <5640C15E.805@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-11-09 at 16:53 +0100, Niklas Cassel wrote:
> On 11/09/2015 04:50 PM, Eric Dumazet wrote:
> > On Mon, 2015-11-09 at 16:41 +0100, Niklas Cassel wrote:
> >> I have a ethernet driver for a 100 Mbps NIC.
> >> The NIC has dedicated hardware for offloading.
> >> The driver has implemented TSO, GSO and BQL.
> >> Since the CPU on the SoC is rather weak, I'd rather
> >> not increase the CPU load by turning off offloading.
> >>
> >> Since commit
> >> 605ad7f184b6 ("tcp: refine TSO autosizing")
> >>
> >> the bandwidth is no longer fair between streams.
> >> see output at the end of the mail, where I'm testing with 2 streams.
> >>
> >>
> >> If I revert 605ad7f184b6 on 4.3, I get a stable 45 Mbps per stream.
> >>
> >> I can also use vanilla 4.3 and do:
> >> echo 3000 > /sys/class/net/eth0/queues/tx-0/byte_queue_limits/limit_max
> >> to also get a stable 45 Mbps per stream.
> >>
> >> My question is, am I supposed to set the BQL limit explicitly?
> >> It is possible that I have missed something in my driver,
> >> but my understanding is that the TCP stack sets and adjusts
> >> the BQL limit automatically.
> >>
> >>
> >> Perhaps the following info might help:
> >>
> >> After running iperf3 on vanilla 4.3:
> >> /sys/class/net/eth0/queues/tx-0/byte_queue_limits/
> >> limit 89908
> >> limit_max 1879048192
> >>
> >> After running iperf3 on vanilla 4.3 + BQL explicitly set:
> >> /sys/class/net/eth0/queues/tx-0/byte_queue_limits/
> >> limit 3000
> >> limit_max 3000
> >>
> >> After running iperf3 on 4.3 + 605ad7f184b6 reverted:
> >> /sys/class/net/eth0/queues/tx-0/byte_queue_limits/
> >> limit 8886
> >> limit_max 1879048192
> >>
> > 
> > There is absolutely nothing ensuring fairness among multiple TCP flows.
> > 
> > One TCP flow can very easily grab whole bandwidth for itself, there are
> > numerous descriptions of this phenomena in various TCP studies. 
> > 
> > This is why we have packet schedulers ;)
> 
> Oh.. How stupid of me, I forgot to mention.. all of the measurements were
> done with fq_codel.

Your numbers suggest a cwnd growth then, which might show a CC bug.

Please run the following when your iper3 runs on regular 4.3 kernel

for i in `seq 1 10`
do
ss -temoi dst 192.168.0.141
sleep 1
done
