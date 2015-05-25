From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: TCP window auto-tuning sub-optimal in GRE tunnel
Date: Mon, 25 May 2015 18:22:00 -0400
Message-ID: <1432592520.32671.110.camel@jasiiieee.pacifera.com>
References: <1432568524.32671.29.camel@jasiiieee.pacifera.com>
	 <1432573139.4060.167.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1432579766.32671.66.camel@jasiiieee.pacifera.com>
	 <1432580733.4060.178.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1432581685.32671.80.camel@jasiiieee.pacifera.com>
	 <1432586494.4060.183.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1432589642.32671.108.camel@jasiiieee.pacifera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.197]:62063 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750894AbbEYWWD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 May 2015 18:22:03 -0400
In-Reply-To: <1432589642.32671.108.camel@jasiiieee.pacifera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-05-25 at 17:34 -0400, John A. Sullivan III wrote:
> On Mon, 2015-05-25 at 13:41 -0700, Eric Dumazet wrote:
> > On Mon, 2015-05-25 at 15:21 -0400, John A. Sullivan III wrote:
> > 
> > > 
> > > Thanks, Eric. I really appreciate the help. This is a problem holding up
> > > a very high profile, major project and, for the life of me, I can't
> > > figure out why my TCP window size is reduced inside the GRE tunnel.
> > > 
> > > Here is the netem setup although we are using this merely to reproduce
> > > what we are seeing in production.  We see the same results bare metal to
> > > bare metal across the Internet.
> > > 
> > > qdisc prio 10: root refcnt 17 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
> > >  Sent 32578077286 bytes 56349187 pkt (dropped 15361, overlimits 0 requeues 61323)
> > >  backlog 0b 1p requeues 61323
> > > qdisc netem 101: parent 10:1 limit 1000 delay 40.0ms
> > >  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> > >  backlog 0b 0p requeues 0
> > > qdisc netem 102: parent 10:2 limit 1000 delay 40.0ms
> > >  Sent 32434562015 bytes 54180984 pkt (dropped 15361, overlimits 0 requeues 0)
> > >  backlog 0b 1p requeues 0
> > > qdisc netem 103: parent 10:3 limit 1000 delay 40.0ms
> > >  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> > >  backlog 0b 0p requeues 0
> > > 
> > > 
> > > root@router-001:~# tc -s qdisc show dev eth2
> > > qdisc prio 2: root refcnt 17 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
> > >  Sent 296515482689 bytes 217794609 pkt (dropped 11719, overlimits 0 requeues 5307)
> > >  backlog 0b 2p requeues 5307
> > > qdisc netem 21: parent 2:1 limit 1000 delay 40.0ms
> > >  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> > >  backlog 0b 0p requeues 0
> > > qdisc netem 22: parent 2:2 limit 1000 delay 40.0ms
> > >  Sent 289364020190 bytes 212892539 pkt (dropped 11719, overlimits 0 requeues 0)
> > >  backlog 0b 2p requeues 0
> > > qdisc netem 23: parent 2:3 limit 1000 delay 40.0ms
> > >  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> > >  backlog 0b 0p requeues 0
> > > 
> > > I'm not sure how helpful these stats are as we did set this router up
> > > for packet loss at one point.  We did suspect netem at some point and
> > > did things like change the limit but that had no effect.
> > 
> > 
> > 80 ms at 1Gbps -> you need to hold about 6666 packets in your netem
> > qdisc, not 1000.
> > 
> > tc qdisc ... netem ... limit 8000 ...
> > 
> > (I see you added 40ms both ways, so you need 3333 packets in forward,
> > and 1666 packets for the ACK packets)
> > 
> > I tried a netem 80ms here and got following with default settings (no
> > change in send/receive windows)
> > 
> > 
> > lpaa23:~# DUMP_TCP_INFO=1 ./netperf -H 10.7.8.152 -Cc -t OMNI -l 20
> > OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 10.7.8.152 () port 0 AF_INET
> > tcpi_rto 281000 tcpi_ato 0 tcpi_pmtu 1476 tcpi_rcv_ssthresh 28720
> > tcpi_rtt 80431 tcpi_rttvar 304 tcpi_snd_ssthresh 2147483647 tpci_snd_cwnd 2215
> > tcpi_reordering 3 tcpi_total_retrans 0
> > Local       Remote      Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
> > Send Socket Recv Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
> > Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
> > Final       Final                                             %     Method %      Method                          
> > 4194304     6291456     16384  20.17   149.54     10^6bits/s  0.40  S      0.78   S      10.467  20.554  usec/KB  
> > 
> > 
> > Now with 16MB I got :
> > 
> > 
> Hmm . . . I did:
> tc qdisc replace dev eth0 parent 10:1 handle 101: netem delay 40ms limit 8000
> tc qdisc replace dev eth0 parent 10:2 handle 102: netem delay 40ms limit 8000
> tc qdisc replace dev eth0 parent 10:3 handle 103: netem delay 40ms limit 8000
> tc qdisc replace dev eth2 parent 2:1 handle 21: netem delay 40ms limit 8000
> tc qdisc replace dev eth2 parent 2:2 handle 22: netem delay 40ms limit 8000
> tc qdisc replace dev eth2 parent 2:3 handle 23: netem delay 40ms limit 8000
> 
> The gateway to gateway performance was still abysmal:
> root@gwhq-1:~# nuttcp -T 60 -i 10 192.168.126.1
>    19.8750 MB /  10.00 sec =   16.6722 Mbps     0 retrans
>    23.2500 MB /  10.00 sec =   19.5035 Mbps     0 retrans
>    23.3125 MB /  10.00 sec =   19.5559 Mbps     0 retrans
>    23.3750 MB /  10.00 sec =   19.6084 Mbps     0 retrans
>    23.2500 MB /  10.00 sec =   19.5035 Mbps     0 retrans
>    23.3125 MB /  10.00 sec =   19.5560 Mbps     0 retrans
> 
>   136.4375 MB /  60.13 sec =   19.0353 Mbps 0 %TX 0 %RX 0 retrans 80.25 msRTT
> 
> But the end to end was near wire speed!:
> rita@vserver-002:~$ nuttcp -T 60 -i 10 192.168.8.20
>   518.9375 MB /  10.00 sec =  435.3154 Mbps     0 retrans
>   979.6875 MB /  10.00 sec =  821.8186 Mbps     0 retrans
>   979.2500 MB /  10.00 sec =  821.4541 Mbps     0 retrans
>   979.7500 MB /  10.00 sec =  821.8782 Mbps     0 retrans
>   979.7500 MB /  10.00 sec =  821.8735 Mbps     0 retrans
>   979.8750 MB /  10.00 sec =  821.9784 Mbps     0 retrans
> 
>  5419.8750 MB /  60.11 sec =  756.3881 Mbps 7 %TX 10 %RX 0 retrans 80.58 msRTT
> 
> I'm still downloading the trace to see what the window size is but this
> begs the interesting question of what would reproduce this in a
> non-netem environment? I'm guessing the netem limit being too small
> would simply drop packets so we would be seeing the symptoms of upper
> layer retransmissions.
> 
> Hmm . . . but an even more interesting question - why did this only
> affect GRE traffic? If the netem buffer was being overrun, shouldn't
> this have affected both results, tunneled and untunneled? Thanks - John

More interesting data.  I finally received the packet trace and the
window still only goes to about 8.4MB which now makes more sense
compared to the throughput.  At 8.4MB at an 80ms RTT, I would expect
about 840 Mbps.

So we still have two unresolved questions:
1) Why did the netem buffer inadequacy only affect GRE traffic?
2) Why do we still not negotiate the 16MB buffer that we get when we are
not using GRE?

Thanks - John
