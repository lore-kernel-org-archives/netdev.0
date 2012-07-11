From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/9] IB/ipoib: Add support for acting as VIF
Date: Wed, 11 Jul 2012 12:27:33 +0200
Message-ID: <1342002453.3265.7447.camel@edumazet-glaptop>
References: <4FFD33B8.5010604@mellanox.com>
	 <20120711.011912.2063611962030549397.davem@davemloft.net>
	 <4FFD4E8D.7040608@mellanox.com>
	 <20120711.030639.1906839917411889365.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, roland@kernel.org, netdev@vger.kernel.org,
	ali@mellanox.com, sean.hefty@intel.com, erezsh@mellanox.co.il
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:38857 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751764Ab2GKK1l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 06:27:41 -0400
Received: by bkwj10 with SMTP id j10so888320bkw.19
        for <netdev@vger.kernel.org>; Wed, 11 Jul 2012 03:27:40 -0700 (PDT)
In-Reply-To: <20120711.030639.1906839917411889365.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-11 at 03:06 -0700, David Miller wrote:
> From: Or Gerlitz <ogerlitz@mellanox.com>
> Date: Wed, 11 Jul 2012 12:59:41 +0300
> 
> > On 7/11/2012 11:19 AM, David Miller wrote:
> >> handle_ing() goes into the packet scheduler and qdisc layer, the qdisc
> >> layer uses skb->cb[] via struct qdisc_skb_cb
> > 
> > Oh, I knew that the qdisc layer touches skb->cb[] but thought it only
> > happens on the TX flow...
> 
> We have them on the RX flow too, they are called ingress qdiscs (as
> opposed to egress qdiscs on the TX side).
> 
> There is nothing mysterious about them, they've been there for more
> than 15 years.

Sample script 

ETH=eth0
IFB=ifb0
LOCALNETS="172.16.0.0/12 192.168.0.0/16 10.0.0.0/8"
RATE="rate 7Mbit bandwidth 7Mbit maxburst 80 minburst 40"
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
