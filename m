From: Robert Olsson <robert@herjulf.net>
Subject: Re: [PATCH] pktgen node allocation
Date: Mon, 22 Mar 2010 07:24:18 +0100
Message-ID: <19367.3346.643084.604021@gargle.gargle.HOWL>
References: <19363.14702.909265.380669@gargle.gargle.HOWL>
	<1268990933.3048.15.camel@edumazet-laptop>
	<19363.32154.39665.185451@gargle.gargle.HOWL>
	<1269006465.3048.39.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robert@herjulf.net, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, olofh@kth.se
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from av10-2-sn2.hy.skanova.net ([81.228.8.182]:36795 "EHLO
	av10-2-sn2.hy.skanova.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751538Ab0CVGWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 02:22:48 -0400
In-Reply-To: <1269006465.3048.39.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Eric Dumazet writes:

 > Well, you said "Tested this with 10 Intel 82599 ports w. TYAN S7025
 > E5520 CPU's. Was able to TX/DMA ~80 Gbit/s to Ethernet wires."
 > 
 > I am interested to know what particular setup you did to maximize
 > throughput then, or are you saing you managed to reduce it ? :)


Some notes from the experiment, It's getting
complex and hairy. Anyway results from the first
tests to give you an idea... My colleague Olof 
might have some comments/details

pktgen sending on 10 * 10g interfaces. 

[From pktgen script]
fn()
{
  i=$1  #ifname
  c=$2  #queue / cpu core
  n=$3  # numa node
  PGDEV=/proc/net/pktgen/kpktgend_$c
  pgset "add_device eth$i@$c  "
  PGDEV=/proc/net/pktgen/eth$i@$c
  pgset "node $n"
  pgset "$COUNT"
  pgset "flag NODE_ALLOC"
  pgset "$CLONE_SKB"
  pgset "$PKT_SIZE"
  pgset "$DELAY"
  pgset "dst 10.0.0.0" 
}      

remove_all
# Setup

# TYAN S7025 with two nodes.
# Each node has own bus with it's own TYLERSBURG bridge
# so eth0-eth3 is closest to node0 which in turn "owns"
# CPU-cores 0-3 in this HW setup. So we setup so 
# pktgen according to this. clone_skb=1000000.
# Used slots are PCIe-x16 except when PCIe-x8 is indicated.

# eth0 queue=0(CPU) node=0
fn 0 0 0
fn 1 1 0
fn 2 2 0
fn 3 3 0
fn 4 4 1
fn 5 5 1
fn 6 6 1
fn 7 7 1
fn 8 12 1
fn 9 13 1

Result "manually" tuned. 

eth0 9617.7 M bit/s      822 k pps 
eth1 9619.1 M bit/s      823 k pps 
eth2 9619.1 M bit/s      823 k pps 
eth3 9619.2 M bit/s      823 k pps 
eth4 5995.2 M bit/s      512 k pps  <-  PCIe-x8
eth5 5995.3 M bit/s      512 k pps  <-  PCIe-x8
eth6 9619.2 M bit/s      823 k pps 
eth7 9619.2 M bit/s      823 k pps 
eth8 9619.1 M bit/s      823 k pps 
eth9 9619.0 M bit/s      823 k pps 

> 90 Gbit/s

Result "manually" mistuned by switching node 0 and 1. 

eth0 9613.6 M bit/s      822 k pps 
eth1 9614.9 M bit/s      822 k pps 
eth2 9615.0 M bit/s      822 k pps 
eth3 9615.1 M bit/s      822 k pps 
eth4 2918.5 M bit/s      249 k pps  <-  PCIe-x8
eth5 2918.4 M bit/s      249 k pps  <-  PCIe-x8
eth6 8597.0 M bit/s      735 k pps 
eth7 8597.0 M bit/s      735 k pps 
eth8 8568.3 M bit/s      733 k pps 
eth9 8568.3 M bit/s      733 k pps 

A lot things is to be investgated...

Cheers
					--ro
