From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Share network traffic between process with respect to a
 priority number.
Date: Wed, 25 Jul 2012 09:54:16 +0200
Message-ID: <1343202856.2626.11137.camel@edumazet-glaptop>
References: <500F9762.1090702@lxsameer.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Sameer Rahmani <lxsameer@lxsameer.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:58419 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755330Ab2GYHyW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2012 03:54:22 -0400
Received: by bkwj10 with SMTP id j10so285444bkw.19
        for <netdev@vger.kernel.org>; Wed, 25 Jul 2012 00:54:21 -0700 (PDT)
In-Reply-To: <500F9762.1090702@lxsameer.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-25 at 11:21 +0430, Sameer Rahmani wrote:
> Hi guys
> 
> for years i have problems with sharing my network bandwidth between my 
> processes. when one of my running processes (e.g axel) start to download 
> data my other processes that needs bandwidth stop working (because they 
> can't download their data) . i know that there is some tools like lartc 
> but i was thinking about a priority value like NICE for this matter. 
> kernel will share the bandwidth between process with respect to their 
> network priority number let's call it NNICE ( or what ever ) . The 
> process with highest NNICE will use the highest bandwidth.
> 
> It's just an raw idea, i want to know your idea about the basic , and 
> improve it.
> What do you think?

I think that's its hard to limit incoming data, on a general case.

Once frame is received, its too late, it already used the link
bandwidth.

A solution is to install a shaper on ingress, so that incoming tcp
frames might be delayed a bit _before_ incoming tcp stack, if they come
on a busy flow/link.

Using fq_codel sounds the right way : delay should be minimal for
interactive flows, and bigger for elephant flows.

It really should help you.

Check your kernel config has :

CONFIG_IFB=m
CONFIG_NET_SCH_INGRESS=y
CONFIG_NET_SCH_FQ_CODEL=m (or y)
CONFIG_NET_SCH_CBQ=m (or y)

Then adapt/use following script (can use HTB instead of CBQ of course)

ETH=eth0
IFB=ifb0
LOCALNETS="172.16.0.0/12 192.168.0.0/16 10.0.0.0/8"
RATE="rate 4Mbit bandwidth 4Mbit maxburst 80 minburst 40"
ALLOT="allot 8000" 

modprobe ifb
ip link set dev $IFB up

tc qdisc add dev $ETH ingress 2>/dev/null

tc filter add dev $ETH parent ffff: \
   protocol ip u32 match u32 0 0 flowid 1:1 action mirred egress \
   redirect dev $IFB

tc qdisc del dev $IFB root


# Lets say our NIC is 100Mbit
tc qdisc add dev $IFB root handle 1: cbq avpkt 1000 \
    rate 100Mbit bandwidth 100Mbit

tc class add dev $IFB parent 1: classid 1:1 cbq allot 10000 \
	mpu 64 rate 100Mbit prio 1 \
	bandwidth 100Mbit maxburst 150 avpkt 1500 bounded

# Class for traffic coming from Internet : limited to X Mbits
tc class add dev $IFB parent 1:1 classid 1:11 \
	cbq $ALLOT mpu 64      \
	$RATE prio 2 \
	avpkt 1400 bounded

tc qdisc add dev $IFB parent 1:11 handle 11: fq_codel


# Traffic from machines in our LAN : no limit
for privnet in $LOCALNETS
do
	tc filter add dev $IFB parent 1: protocol ip prio 2 u32 \
		match ip src $privnet flowid 1:1
done

tc filter add dev $IFB parent 1: protocol ip prio 2 u32 \
	match ip protocol 0 0x00 flowid 1:11
