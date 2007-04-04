From: Patrick McHardy <kaber@trash.net>
Subject: Re: HTB/act_mirred problem [was: one more... iproute commands lockup
 whole system]
Date: Wed, 04 Apr 2007 16:13:07 +0200
Message-ID: <4613B273.4070801@trash.net>
References: <20070321175951.M73913@visp.net.lb> <46026717.9060909@trash.net> <20070322124533.M79867@visp.net.lb> <46027FF2.6020001@trash.net> <20070322101224.3e6bb899@freekitty>  <20070404000054.M58020@visp.net.lb> <1175649016.3957.10.camel@localhost> <461301C0.2050409@trash.net> <20070404020622.M69215@visp.net.lb> <1175684114.4088.12.camel@localhost> <20070404125231.M65138@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Denys <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59973 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753826AbXDDONJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2007 10:13:09 -0400
In-Reply-To: <20070404125231.M65138@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denys wrote:
> I have some interesting thing:
> 
> Rules:
> tc qdisc del dev eth0.5 root
> tc qdisc add dev eth0.5 handle 1: root htb
> tc class add dev eth0.5 parent 1:0 classid 1:2 htb rate 128Kbit
> 
> tc qdisc add dev eth0.5 parent 1:2 handle 2: prio
> 
> tc filter add dev eth0.5 parent 1: protocol ip prio 10 u32 \
> match ip src 195.69.208.253/32 flowid 1:2
> 
> tc filter add dev eth0.5 parent 2: protocol ip prio 10 u32 \
>     match ip src 195.69.208.253/32 flowid 2:1 \
>     action mirred egress redirect dev eth0.6
> 
> (it is not working, but just i tried few things)
> 
> At morning i wakeup and see in dmesg, also not sure if it's bug or result of 
> misconfiguration:
> 
> [46632.941527] KERNEL: assertion (!cl->level && cl->un.leaf.q && cl-
> 
>>un.leaf.q->q.qlen) failed at net/sched/sch_htb.c (585)


This seems to be due to be caused by act_mirred returning TC_ACT_STOLEN,
which is translated to NET_XMIT_SUCCESS within prio, causing HTB to
increase the q.qlen counter and activating the class despite no packet
beeing queued.

Jamal, we can't return NET_XMIT_SUCCESS unless we've really queued the
packet. I can't remeber the reason why this is done, could you remind
me?

