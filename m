From: Doru Theodor Petrescu <pdoru.kernel@evox.ro>
Subject: Re: tc match MAC destination - nothing matches on protocol 802_3
Date: Thu, 16 Jun 2011 10:56:52 +0300
Message-ID: <1308211012.12982.36365.camel@u.evox.ro>
References: <1308125523.30324.64.camel@ierdnac-hp>
	 <20110615092907.2b79ee66@s6510.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ierdnah@gmail.com, linux-kernel@vger.kernel.org,
	pdoru.kernel@evox.ro, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110615092907.2b79ee66@s6510.ftrdhcpuser.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



I updated my scripts to use the 'tc filter ... match ether src/dst'
syntax. it really makes reading the script easier. thanks for the tip!

however the problem persists. I changed the rule to match ANY pachet of
type 802_3 and redirect it to ifb1. but nothing arrives on ifb1.

I tried to redirect ARP pachets using 'protocol arp' filter and it works
perfectly as expected.

so at this point the problem is no longer 'how to match ethernet header'
but rather 'how to match a pachet of type 802_3'. My feeling is that
there is a bug somewhere in kernel where the 'protocol 802_3' matching
happens.


I attach part of the script I use to generate the filters and classes. I
removed everything related to HTB and IP pachets because there is no
problem there. in case the formating is lost, you can download it from
here: http://evox.ro/kernel_netdev_tc_protocol_802.3/


Thx for any help,
Doru Theodor Petrescu
CTO, Evox Solutions SRL
http://evox.ro/



for DEV in bond0.2199 bond1.2199 bond0.3000 bond1.3001 ; do


   tc qdisc  del dev $DEV root

   tc qdisc  add dev $DEV root handle 1: htb default 2
   tc class  add dev $DEV parent 1: classid 1:1 htb rate 930000kbit ceil
930000kbit quantum 1600
   
   tc filter add dev $DEV parent 1: prio 5 protocol ip u32
# ==> 800:

   tc filter add dev $DEV parent 1: prio 1 protocol 0x0806 u32
# ==> 801:      protocol ARP
   tc filter add dev $DEV parent 1: prio 1 handle 801:0:7 protocol
0x0806 u32  match u32 0 0 flowid 1:3

   tc filter add dev $DEV parent 1: prio 2 protocol 802_3 u32
# ==> 802:

   tc filter add dev $DEV parent 1: prio 6 protocol ip u32
# ==> 803:


   tc filter replace dev $DEV parent 1: prio 2 handle 802:0:3  protocol
802_3 u32 match u16 0 0 at 0 flowid 1:3 action mirred egress mirror dev
ifb1
   tc filter replace dev $DEV parent 1: prio 2 handle 802:0:9  protocol
802_3 u32 match ether src 01:00:0c:cc:cc:cd flowid 1:3 action mirred
egress mirror dev ifb1
   tc filter replace dev $DEV parent 1: prio 2 handle 802:0:10 protocol
802_3 u32 match ether dst 01:00:0c:cc:cc:cd flowid 1:3 action mirred
egress mirror dev ifb1

done


# the 802_3 pachet filter:   
# 
# 802:0:3 should match ANY pachet of type 802_3 and mirror it to ifb1
# 802:0:9 and 802:0:10 should match any pachet with src/dst
01:00:0c:cc:cc:cd and mirror it to ifb1
#
# however NOTHING is going to ifb1    try 'tcpdump -nltve -i ifb1'
# at the same time 'tcpdump -nltve -i bond1.2199 ether host
0100.0ccc.cccd' will show about one pachet every second
# 


# at the same time the ARP filter works. you can mirror all ARP trafic
to IFB1 like this:
# tc filter replace dev $DEV parent 1: prio 1 handle 801:0:7 protocol
0x0806 u32  match u32 0 0 flowid 1:3 action mirred egress mirror dev
ifb1
