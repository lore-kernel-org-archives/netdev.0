From: Xiaofei Wu <xiaofei_wu08@yahoo.com>
Subject: Re: [iproute2] tc action mirred    question
Date: Mon, 14 Sep 2009 06:44:15 -0700 (PDT)
Message-ID: <833118.87017.qm@web111618.mail.gq1.yahoo.com>
References: <404956.88336.qm@web111607.mail.gq1.yahoo.com>  <1252376168.5244.11.camel@dogo.mojatatu.com>  <313388.35529.qm@web111617.mail.gq1.yahoo.com>  <1252534266.4119.5.camel@dogo.mojatatu.com>  <204967.7557.qm@web111613.mail.gq1.yahoo.com>  <1252671940.25158.5.camel@dogo.mojatatu.com>  <510605.34044.qm@web111611.mail.gq1.yahoo.com> <1252704524.25158.42.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux netdev <netdev@vger.kernel.org>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from n9a.bullet.mail.mud.yahoo.com ([209.191.87.108]:45569 "HELO
	n9a.bullet.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751276AbZINNu2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 09:50:28 -0400
In-Reply-To: <1252704524.25158.42.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> 

>> How to do this. Could you show me the example commands?   Thank you.
>> 
>Add the rule to mirror on lo
>Add the rule to pedit for mirrored packet on eth0


I did two expriments. One is OK. The result of the other is not the same as I expected. I don't know why.

(1)
 A
| |
 C

A: eth0  192.168.1.242/24
   wlan1 192.168.4.5/24

C: wlan1 192.168.4.202/24
   eth0  192.168.1.215/24
On node A, I mirrored packets to wlan1(eth0 -> wlan1), modified dst,src MAC (transmit to wlan1 of node C).
When I run 'ping 192.168.1.215' on node A, one request will get two replies. It's OK.

(2)
 A
/ |
B |
\ |
 C

A: eth0  192.168.1.242/24
   wlan1 192.168.2.5/24

B: wlan1 192.168.2.11/24
   wlan2 192.168.4.11/24

C: wlan1 192.168.4.202/24
   eth0  192.168.1.215/24

On node A, I run this to mirror, pedit packets.
---
#tc qdisc add dev eth0 handle 1: root prio
#tc filter add dev eth0 parent 1: protocol ip prio 10 u32 \
match ip src 192.168.1.0/24 flowid 1:16 \
action mirred egress mirror dev wlan1

#tc qdisc add dev wlan1 handle 1: root prio
#tc filter add dev wlan1 parent 1: protocol ip prio 10 u32 \
match ip src 192.168.1.0/24 flowid 1:16 \
action pedit munge offset -14 u16 set 0x0023 \
munge offset -12 u32 set 0xcdafecda \
munge offset -8 u32 set 0x0023cdaf \
munge offset -4 u32 set 0xd0740800
---

the routing table 0f node B
---
#route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
192.168.4.0     0.0.0.0         255.255.255.0   U     0      0        0 wlan2
192.168.2.0     0.0.0.0         255.255.255.0   U     0      0        0 wlan1
0.0.0.0         192.168.4.202     0.0.0.0       UG    0      0        0 wlan2

#cat /proc/sys/net/ipv4/ip_forward
1
---

On node A I run 'ping 192.168.1.215'(IP addr of node C eth0) on node A, one request 'only' get one reply. It's strange.
On node B,
window1:  'tcpdump -i wlan1 -n -e', I can see the mirroring packets.
window2:  'tcpdump -i wlan2 -n -e', I see noting.
It seems that node B didn't forward the mirroring packects. So I did anotner experiment to check it. 
I am sure node B can forward packets. But it didn't forward the mirroring packets, why?  (something wrong with the mirroring packets?)



regards,
wu


      

