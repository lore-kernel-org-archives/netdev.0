From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Fri, 7 Aug 2009 18:12:11 -0400
Message-ID: <20090807221211.GA16874@localhost.localdomain>
References: <20090807170600.9a2eff2e.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Network Developers <netdev@vger.kernel.org>, brice@myri.com,
	gallatin@myri.com
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39910 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753245AbZHGWMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 18:12:21 -0400
Content-Disposition: inline
In-Reply-To: <20090807170600.9a2eff2e.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 07, 2009 at 05:06:00PM -0400, Bill Fink wrote:
> I've run into a major receive side performance issue with multi-10-GigE
> on a NUMA system.  The system is using a SuperMicro X8DAH+-F motherboard
> with 2 3.2 GHz quad-core Intel Xeon 5580 processors and 12 GB of
> 1333 MHz DDR3 memory.  It is a Fedora 10 system but using the latest
> 2.6.29.6 kernel from Fedora 11 (originally tried the 2.6.27.29 kernel
> from Fedora 10).
> 
> The test setup is:
> 
> 	i7test1----(6)----xeontest1----(6)----i7test2
> 	         10-GigE             10-GigE
> 
> So xeontest1 has 6 dual-port Myricom 10-GigE NICs for a total
> of 12 10-GigE interfaces.  eth2 through eth7 (which are on the
> second Intel 5520 I/O Hub) are connected to i7test1 while
> eth8 through eth13 (which are on the first Intel 5520 I/O Hub)
> are connected to i7test2.
> 
> Previous direct testing between i7test1 and i7test2 (which use an
> Asus P6T6 WS Revolution motherboard) demonstrated that they could
> achieve ~70 Gbps performance for either transmit or receive using
> 8 10-GigE interfaces.
> 
> The transmit side performance of xeontest1 is fantastic:
> 
> [root@xeontest1 ~]# numactl --membind=2 nuttcp -In2 -xc1/0 -p5001 192.168.1.10 & numactl --membind=2 nuttcp -In3 -xc3/0 -p5002 192.168.2.10 & numactl --membind=2 nuttcp -In4 -xc5/1 -p5003 192.168.3.10 & numactl --membind=2 nuttcp -In5 -xc7/1 -p5004 192.168.4.10 & nuttcp -In8 -xc0/0 -p5007 192.168.7.11 & nuttcp -In9 -xc2/0 -p5008 192.168.8.11 & nuttcp -In10 -xc4/1 -p5009 192.168.9.11 & nuttcp -In11 -xc6/1 -p5010 192.168.10.11 & numactl --membind=2 nuttcp -In6 -xc5/2 -p5005 192.168.5.10 & numactl --membind=2 nuttcp -In7 -xc7/3 -p5006 192.168.6.10 & nuttcp -In12 -xc4/2 -p5011 192.168.11.11 & nuttcp -In13 -xc6/3 -p5012 192.168.12.11 &
> n12:  9648.0522 MB /  10.00 sec = 8091.4066 Mbps 49 %TX 26 %RX 0 retrans 0.18 msRTT
> n9: 11130.5320 MB /  10.01 sec = 9328.3224 Mbps 47 %TX 37 %RX 0 retrans 0.19 msRTT
> n11:  9418.1250 MB /  10.00 sec = 7897.5848 Mbps 50 %TX 30 %RX 0 retrans 0.18 msRTT
> n10:  9279.4758 MB /  10.01 sec = 7778.7146 Mbps 49 %TX 28 %RX 0 retrans 0.12 msRTT
> n8: 11142.6574 MB /  10.01 sec = 9340.3789 Mbps 47 %TX 35 %RX 0 retrans 0.18 msRTT
> n13:  9422.1492 MB /  10.01 sec = 7897.4115 Mbps 49 %TX 25 %RX 0 retrans 0.17 msRTT
> n3: 11471.2500 MB /  10.01 sec = 9613.9477 Mbps 49 %TX 32 %RX 0 retrans 0.15 msRTT
> n6:  9339.6354 MB /  10.01 sec = 7828.5345 Mbps 50 %TX 25 %RX 0 retrans 0.19 msRTT
> n4:  9093.2500 MB /  10.01 sec = 7624.1589 Mbps 49 %TX 28 %RX 0 retrans 0.15 msRTT
> n5:  9121.8367 MB /  10.01 sec = 7646.8646 Mbps 50 %TX 29 %RX 0 retrans 0.17 msRTT
> n7:  9292.2500 MB /  10.01 sec = 7789.1574 Mbps 49 %TX 26 %RX 0 retrans 0.17 msRTT
> n2: 11487.1150 MB /  10.01 sec = 9627.2690 Mbps 49 %TX 46 %RX 0 retrans 0.19 msRTT
> 
> Aggregate performance:			100.4637 Gbps
> 
> The problem is with the receive side performance.
> 
> [root@xeontest1 ~]# numactl --membind=2 nuttcp -In2 -r -xc1/0 -p5001 192.168.1.10 & numactl --membind=2 nuttcp -In3 -r -xc3/0 -p5002 192.168.2.10 & numactl --membind=2 nuttcp -In4 -r -xc5/1 -p5003 192.168.3.10 & numactl --membind=2 nuttcp -In5 -r -xc7/1 -p5004 192.168.4.10 & nuttcp -In8 -r -xc0/0 -p5007 192.168.7.11 & nuttcp -In9 -r -xc2/0 -p5008 192.168.8.11 & nuttcp -In10 -r -xc4/1 -p5009 192.168.9.11 & nuttcp -In11 -r -xc6/1 -p5010 192.168.10.11 & numactl --membind=2 nuttcp -In6 -r -xc5/2 -p5005 192.168.5.10 & numactl --membind=2 nuttcp -In7 -r -xc7/3 -p5006 192.168.6.10 & nuttcp -In12 -r -xc4/2 -p5011 192.168.11.11 & nuttcp -In13 -r -xc6/3 -p5012 192.168.12.11 &
> n11:  6983.6359 MB /  10.09 sec = 5803.2293 Mbps 13 %TX 26 %RX 0 retrans 0.11 msRTT
> n10:  7000.1557 MB /  10.11 sec = 5807.5978 Mbps 13 %TX 26 %RX 0 retrans 0.12 msRTT
> n9:  2451.7206 MB /  10.21 sec = 2014.8397 Mbps 4 %TX 13 %RX 0 retrans 0.11 msRTT
> n13:  2453.0887 MB /  10.20 sec = 2016.8751 Mbps 3 %TX 11 %RX 0 retrans 0.10 msRTT
> n12:  2446.5303 MB /  10.24 sec = 2004.4638 Mbps 4 %TX 11 %RX 0 retrans 0.10 msRTT
> n8:  2462.5890 MB /  10.26 sec = 2014.0272 Mbps 3 %TX 11 %RX 0 retrans 0.12 msRTT
> n4:  2763.5091 MB /  10.26 sec = 2258.4871 Mbps 4 %TX 14 %RX 0 retrans 0.10 msRTT
> n5:  2770.0887 MB /  10.28 sec = 2261.2562 Mbps 4 %TX 15 %RX 0 retrans 0.10 msRTT
> n2:  1777.7277 MB /  10.32 sec = 1444.9054 Mbps 2 %TX 11 %RX 0 retrans 0.11 msRTT
> n6:  1772.7962 MB /  10.31 sec = 1442.0346 Mbps 3 %TX 10 %RX 0 retrans 0.11 msRTT
> n3:  1779.4535 MB /  10.32 sec = 1446.0090 Mbps 2 %TX 11 %RX 0 retrans 0.15 msRTT
> n7:  1770.8359 MB /  10.35 sec = 1435.4757 Mbps 2 %TX 11 %RX 0 retrans 0.12 msRTT
> 
> Aggregate performance:			29.9492 Gbps
> 
> I suspected that this was because the memory being allocated by the
> myri10ge driver was not being allocated on the optimum NUMA node.
> BTW the NUMA nodes on the system are 0 and 2 instead of 0 and 1 which
> is what I would have expected, but this is my first experience with
> a NUMA system.
> 
> Based upon a patch by Peter Zijlstra that I discovered through Google
> searching, I tried patching the myri10ge driver to change its memory
> allocation of memory pages from alloc_pages() to alloc_pages_node()
> and specifying the NUMA node of the parent device of the Myricom 10-GigE
> device, which IIUC should be the PCIe switch.  This didn't help.
> 
> This could be because I discovered that if I did:
> 
> 	find /sys -name numa_node -exec grep . {} /dev/null \;
> 
> that the numa_node associated with all the PCI devices was always 0,
> and if IIUC then I believe some of the PCI devices should have been
> associated with NUMA node 2.  Perhaps this is what is causing all
> the memory pages allocated by the myri10ge driver to be on NUMA
> node 0, and thus causing the major performance issue.
> 
> To kludge around this, I made a different patch to the myri10ge driver.
> This time I hardcoded the NUMA node in the call to alloc_pages_node()
> to 2 for devices with an IRQ between 113 and 118 (eth2 through eth7)
> and to 0 for devices with an IRQ between 119 and 124 (eth8 through eth13).
> This is of course very specific to our specific system (NUMA node ids
> and Myricom 10-GigE device IRQs), and is not something that would be
> generically applicable.  But it was useful as a test, and it did
> improve the receive side performance substantially!
> 
> [root@xeontest1 ~]# numactl --membind=2 nuttcp -In2 -r -xc1/0 -p5001 192.168.1.10 & numactl --membind=2 nuttcp -In3 -r -xc3/0 -p5002 192.168.2.10 & numactl --membind=2 nuttcp -In4 -r -xc5/1 -p5003 192.168.3.10 & numactl --membind=2 nuttcp -In5 -r -xc7/1 -p5004 192.168.4.10 & nuttcp -In8 -r -xc0/0 -p5007 192.168.7.11 & nuttcp -In9 -r -xc2/0 -p5008 192.168.8.11 & nuttcp -In10 -r -xc4/1 -p5009 192.168.9.11 & nuttcp -In11 -r -xc6/1 -p5010 192.168.10.11 & numactl --membind=2 nuttcp -In6 -r -xc5/2 -p5005 192.168.5.10 & numactl --membind=2 nuttcp -In7 -r -xc7/3 -p5006 192.168.6.10 & nuttcp -In12 -r -xc4/2 -p5011 192.168.11.11 & nuttcp -In13 -r -xc6/3 -p5012 192.168.12.11 &
> n5:  8221.2911 MB /  10.09 sec = 6836.0343 Mbps 17 %TX 31 %RX 0 retrans 0.12 msRTT
> n4:  8237.9524 MB /  10.10 sec = 6840.2379 Mbps 16 %TX 31 %RX 0 retrans 0.11 msRTT
> n11:  7935.3750 MB /  10.11 sec = 6586.2476 Mbps 15 %TX 29 %RX 0 retrans 0.16 msRTT
> n2:  4543.1621 MB /  10.13 sec = 3763.0669 Mbps 9 %TX 21 %RX 0 retrans 0.12 msRTT
> n10:  7916.3925 MB /  10.13 sec = 6555.5210 Mbps 15 %TX 28 %RX 0 retrans 0.13 msRTT
> n7:  4558.4817 MB /  10.14 sec = 3771.6557 Mbps 7 %TX 22 %RX 0 retrans 0.10 msRTT
> n13:  4390.1875 MB /  10.14 sec = 3633.6421 Mbps 6 %TX 21 %RX 0 retrans 0.12 msRTT
> n3:  4572.6478 MB /  10.15 sec = 3778.2596 Mbps 9 %TX 21 %RX 0 retrans 0.14 msRTT
> n6:  4564.4776 MB /  10.14 sec = 3774.4373 Mbps 9 %TX 21 %RX 0 retrans 0.11 msRTT
> n8:  4409.8551 MB /  10.16 sec = 3642.1920 Mbps 8 %TX 19 %RX 0 retrans 0.12 msRTT
> n9:  4412.7836 MB /  10.16 sec = 3643.7788 Mbps 8 %TX 20 %RX 0 retrans 0.14 msRTT
> n12:  4413.4061 MB /  10.16 sec = 3645.2544 Mbps 8 %TX 21 %RX 0 retrans 0.11 msRTT
> 
> Aggregate performance:			56.4703 Gbps
> 
> This was basically double the previous receive side performance
> without the patch.
> 
> I don't know if this is fundamentally a myri10ge driver issue or
> some underlying Linux kernel issue, so it's not clear to me what
> a proper fix would be.
> 
> Finally, while definitely a major improvement, I think it should be
> possible to do even better, since we achieved 70 Gbps in the i7 to i7
> tests, and probably could have done 80 Gbps except for an Asus
> motherboard restriction with the interconnect between the Intel X58
> and Nvidia NF200 chips.  It's definitely a big step in the right
> direction though if this issue can be resolved.
> 
> Any help greatly appreicated in advance.
> 
> 						-Thanks
> 
> 						-Bill
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

You're timing is impeccable!  I just posted a patch for an ftrace module to help
detect just these kind of conditions:
http://marc.info/?l=linux-netdev&m=124967650218846&w=2

Hope that helps you out
Neil

