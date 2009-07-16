From: Bill Fink <billfink@mindspring.com>
Subject: Re: Achieved 10Gbit/s bidirectional routing
Date: Thu, 16 Jul 2009 11:38:27 -0400
Message-ID: <20090716113827.19fbb379.billfink@mindspring.com>
References: <1247676631.30876.29.camel@localhost.localdomain>
	<20090715232253.91d9f264.billfink@mindspring.com>
	<1247737144.30876.53.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	jesse.brandeburg@intel.com,
	Stephen Hemminger <shemminger@vyatta.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-kukur.atl.sa.earthlink.net ([209.86.89.65]:55756 "EHLO
	elasmtp-kukur.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932448AbZGPPia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 11:38:30 -0400
In-Reply-To: <1247737144.30876.53.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 16 Jul 2009, Jesper Dangaard Brouer wrote:

> On Wed, 2009-07-15 at 23:22 -0400, Bill Fink wrote:
> > On Wed, 15 Jul 2009, Jesper Dangaard Brouer wrote:
> > 
> > > I'm giving a talk at LinuxCon, about 10Gbit/s routing on standard
> > > hardware running Linux.
> > > 
> > >   http://linuxcon.linuxfoundation.org/meetings/1585
> > >   https://events.linuxfoundation.org/lc09o17
> > > 
> > > I'm getting some really good 10Gbit/s bidirectional routing results
> > > with Intels latest 82599 chip. (I got two pre-release engineering
> > > samples directly from Intel, thanks Peter)
> > > 
> > > Using a Core i7-920, and tuning the memory according to the RAMs
> > > X.M.P. settings DDR3-1600MHz, notice this also increases the QPI to
> > > 6.4GT/s.  (Motherboard P6T6 WS revolution)
> > > 
> > > With big 1514 bytes packets, I can basically do 10Gbit/s wirespeed
> > > bidirectional routing.
> > > 
> > > Notice bidirectional routing means that we actually has to move approx
> > > 40Gbit/s through memory and in-and-out of the interfaces.
> > > 
> > > Formatted quick view using 'ifstat -b'
> > > 
> > >   eth31-in   eth31-out   eth32-in  eth32-out
> > >     9.57  +    9.52  +     9.51 +     9.60  = 38.20 Gbit/s
> > >     9.60  +    9.55  +     9.52 +     9.62  = 38.29 Gbit/s
> > >     9.61  +    9.53  +     9.52 +     9.62  = 38.28 Gbit/s
> > >     9.61  +    9.53  +     9.54 +     9.62  = 38.30 Gbit/s
> > > 
> > > [Adding an extra NIC]
> > > 
> > > Another observation is that I'm hitting some kind of bottleneck on the
> > > PCI-express switch.  Adding an extra NIC in a PCIe slot connected to
> > > the same PCIe switch, does not scale beyond 40Gbit/s collective
> > > throughput.
> 
> Correcting my self, according to Bill's info below.
> 
> It does not scale when adding an extra NIC to the same NVIDIA NF200 PCIe
> switch chip (reason explained below by Bill)
> 
>  
> > > But, I happened to have a special motherboard ASUS P6T6 WS revolution,
> > > which has an additional PCIe switch chip NVIDIA's NF200.
> > > 
> > > Connecting two dual port 10GbE NICs via two different PCI-express
> > > switch chips, makes things scale again!  I have achieved a collective
> > > throughput of 66.25 Gbit/s.  This results is also influenced by my
> > > pktgen machines cannot keep up, and I'm getting closer to the memory
> > > bandwidth limits.
> > > 
> > > FYI: I found a really good reference explaining the PCI-express
> > > architecture, written by Intel:
> > > 
> > >  http://download.intel.com/design/intarch/papers/321071.pdf
> > > 
> > > I'm not sure how to explain the PCI-express chip bottleneck I'm
> > > seeing, but my guess is that I'm limited by the number of outstanding
> > > packets/DMA-transfers and the latency for the DMA operations.
> > > 
> > > Does any one have datasheets on the X58 and NVIDIA's NF200 PCI-express
> > > chips, that can tell me the number of outstanding transfers they
> > > support?
> > 
> > We've achieved 70 Gbps aggregate unidirectional TCP performance from
> > one P6T6 based system to another.  We figured out in our case that
> > we were being limited by the interconnect between the Intel X58 and
> > Nvidia N200 chips.  The first 2 PCIe 2.0 slots are directly off the
> > Intel X58 and get the full 40 Gbps throughput from the dual-port
> > Myricom 10-GigE NICs we have installed in them.  But the other
> > 3 PCIe 2.0 slots are on the Nvidia N200 chip, and I discovered
> > through googling that the link between the X58 and N200 chips
> > only operates at PCIe x16 _1.0_ speed, which limits the possible
> > aggregate throughput of the last 3 PCIe 2.0 slots to only 32 Gbps.
> 
> This definitly explains the bottlenecks I have seen! Thanks!
> 
> Yes, it seems to scale when installing the two NICs in the first two
> slots, both connected to the X58.  If overclocking the RAM and CPU a
> bit, I can match my pktgen machines speed which gives a collective
> throughput of 67.95 Gbit/s.
> 
>    eth33          eth34          eth31         eth32
>  in     out     in     out     in    out     in    out 
> 7.54 + 9.58  + 9.56 + 7.56  + 7.33 + 9.53 + 9.50 + 7.35  = 67.95 Gbit/s
> 
> Now I just need a faster generator machine, to find the next bottleneck ;-)
> 
> 
> > This was clearly seen in our nuttcp testing:
> > 
> > [root@i7raid-1 ~]# ./nuttcp-6.2.6 -In2 -xc0/0 -p5001 192.168.1.11 & ./nuttcp-6.2.6 -In3 -xc0/0 -p5002 192.168.2.11 & ./nuttcp-6.2.6 -In4 -xc1/1 -p5003 192.168.3.11 & ./nuttcp-6.2.6 -In5 -xc1/1 -p5004 192.168.4.11 & ./nuttcp-6.2.6 -In6 -xc2/2 -p5005 192.168.5.11 & ./nuttcp-6.2.6 -In7 -xc2/2 -p5006 192.168.6.11 & ./nuttcp-6.2.6 -In8 -xc3/3 -p5007 192.168.7.11 & ./nuttcp-6.2.6 -In9 -xc3/3 -p5008 192.168.8.11
> > n2: 11505.2648 MB /  10.09 sec = 9566.2298 Mbps 37 %TX 55 %RX 0 retrans 0.10 msRTT
> > n3: 11727.4489 MB /  10.02 sec = 9815.7570 Mbps 39 %TX 44 %RX 0 retrans 0.10 msRTT
> > n4: 11770.1250 MB /  10.07 sec = 9803.9901 Mbps 39 %TX 51 %RX 0 retrans 0.10 msRTT
> > n5: 11837.9320 MB /  10.05 sec = 9876.5725 Mbps 39 %TX 47 %RX 0 retrans 0.10 msRTT
> > n6:  9096.8125 MB /  10.09 sec = 7559.3310 Mbps 30 %TX 32 %RX 0 retrans 0.10 msRTT
> > n7:  9100.1211 MB /  10.10 sec = 7559.7790 Mbps 30 %TX 44 %RX 0 retrans 0.10 msRTT
> > n8:  9095.6179 MB /  10.10 sec = 7557.9983 Mbps 31 %TX 33 %RX 0 retrans 0.10 msRTT
> > n9:  9075.5472 MB /  10.08 sec = 7551.0234 Mbps 31 %TX 33 %RX 0 retrans 0.11 msRTT
> > 
> > This used 4 dual-port Myricom 10-GigE NICs.  We also tested with
> > a fifth dual-port 10-GigE NIC, but the aggregate throughput stayed
> > at about 70 Gbps, due to the performance bottleneck between the
> > X58 and N200 chips.
> 
> This is also very excellent results!
> 
> Thanks a lot Bill !!!

We also achieved nearly 80 Gbps in bidirectional TCP tests (40 Gbps
simultaneously in each direction):

[root@i7raid-1 ~]# ./nuttcp-6.2.6 -In2 -xc0/0 -p5001 192.168.1.11 & ./nuttcp-6.2.6 -In3 -r -xc0/0 -p5002 192.168.2.11 & ./nuttcp-6.2.6 -In4 -xc1/1 -p5003 192.168.3.11 & ./nuttcp-6.2.6 -In5 -r -xc1/1 -p5004 192.168.4.11 & ./nuttcp-6.2.6 -In6 -xc2/2 -p5005 192.168.5.11 & ./nuttcp-6.2.6 -In7 -r -xc2/2 -p5006 192.168.6.11 & ./nuttcp-6.2.6 -In8 -xc3/3 -p5007 192.168.7.11 & ./nuttcp-6.2.6 -In9 -r -xc3/3 -p5008 192.168.8.11                                    
n2: 11542.6250 MB /  10.07 sec = 9619.9920 Mbps 44 %TX 51 %RX 0 retrans 0.12 msRTT                                                                      
n3: 11543.7143 MB /  10.06 sec = 9622.2153 Mbps 41 %TX 49 %RX 0 retrans 0.15 msRTT                                                   
n4: 11622.8125 MB /  10.05 sec = 9701.0296 Mbps 43 %TX 51 %RX 0 retrans 0.10 msRTT                                                                      
n5: 11523.6875 MB /  10.03 sec = 9638.8883 Mbps 43 %TX 50 %RX 0 retrans 0.15 msRTT                                                                      
n6: 11608.0141 MB /  10.04 sec = 9695.7388 Mbps 43 %TX 50 %RX 0 retrans 0.10 msRTT                                                                      
n7: 11580.1250 MB /  10.04 sec = 9679.3910 Mbps 43 %TX 50 %RX 0 retrans 0.13 msRTT                                                                      
n8: 11608.0000 MB /  10.06 sec = 9678.7596 Mbps 42 %TX 50 %RX 0 retrans 0.10 msRTT                                                                      
n9: 11553.3750 MB /  10.05 sec = 9643.7296 Mbps 45 %TX 50 %RX 0 retrans 0.11 msRTT                                                                      

This was using 2 dual-port 10-GigE NICs in the first two PCIe 2.0 slots.
We are using an Intel i7 965 quad-core 3.2 GHz Nehalem processor
(overclocked to 3.4 GHz) and 2000 MHz DDR3 memory.  Adding an additional
dual-port 10-GigE NIC on the Nvidia N200 chip does only marginally
better, as it appears we are basically CPU limited at this point for
this test (the sum of the TX and RX CPU utilization for each pair of
10-GigE interfaces is about 93%).

						-Bill
