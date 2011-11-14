From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: qfq getting "stuck"
Date: Mon, 14 Nov 2011 21:01:59 +0200
Message-ID: <4ea60e68434702559a004fad3ae4fc1d@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>, <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:58914 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752654Ab1KNTKq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 14:10:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Hi

 Just did setup for QFQ (also testing SFB)
 i686/kernel 3.1.0
 tc utility, iproute2-ss111010

 SFB works fine, while QFQ are "freezing" after while.

 I cannot apply much patches there, since it is "production" customer, 
 but i can try few.
 Please let me know if you need additional info.

 64 bytes from 10.0.1.102: icmp_req=23 ttl=128 time=46.2 ms
 64 bytes from 10.0.1.102: icmp_req=24 ttl=128 time=30.6 ms
 ping: sendmsg: No buffer space available
 ping: sendmsg: No buffer space available
 ping: sendmsg: No buffer space available
 ping: sendmsg: No buffer space available

 Script:
 DEV="tun0"

 ethtool -K eth1.732 tso off gso off gro off
 ethtool -K eth1 tso off gso off gro off
 ethtool -K tun0 tso off gso off gro off
 ethtool -K ifb0 tso off gso off gro off

 tc qdisc del dev $DEV root
 echo add root
 tc qdisc add dev $DEV root handle 1 htb default 7
 echo add class
 tc class add dev $DEV parent 1: classid 1:1 htb rate 3800Kbit ceil 
 3800Kbit prio 3

 tc class add dev $DEV parent 1:1 classid 1:7 htb rate 3800Kbit ceil 
 3800Kbit prio 3
 echo add qdisc
 tc qdisc add dev $DEV parent 1:7 handle 11: est 0.5sec 2sec qfq

 tc filter add dev $DEV protocol ip parent 11: handle 3 \
     flow hash keys dst divisor 64

 for i in `seq 1 64`
 do
   classid=11:$(printf %x $i)
   tc class add dev $DEV classid $classid qfq.
   tc qdisc add dev $DEV parent $classid pfifo limit 10
 done

 tc filter add dev $DEV protocol ip parent 1: prio 4 u32 match ip dst 
 0.0.0.0/0 flowid 1:7

 Stats when it is freezed:
 class htb 1:1 root rate 3800Kbit ceil 3800Kbit burst 1599b/8 mpu 0b 
 overhead 0b cburst 1599b/8 mpu 0b overhead 0b level 7
  Sent 14289365 bytes 13366 pkt (dropped 0, overlimits 0 requeues 0)
  rate 9672bit 1pps backlog 0b 0p requeues 0
  lended: 0 borrowed: 0 giants: 0
  tokens: -46804 ctokens: -46804

 class htb 1:7 parent 1:1 leaf 11: prio 3 quantum 47500 rate 3800Kbit 
 ceil 3800Kbit burst 1599b/8 mpu 0b overhead 0b cburst 1599b/8 mpu 0b 
 overhead 0b level 0
  Sent 14348426 bytes 13535 pkt (dropped 3258, overlimits 0 requeues 0)
  rate 9856bit 1pps backlog 0b 169p requeues 0
  lended: 13366 borrowed: 0 giants: 0
  tokens: -46804 ctokens: -46804

 class qfq 11:11 root leaf 841b: weight 1 maxpkt 2048
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
 class qfq 11:10 root leaf 841a: weight 1 maxpkt 2048
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
 class qfq 11:13 root leaf 841d: weight 1 maxpkt 2048
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
 class qfq 11:12 root leaf 841c: weight 1 maxpkt 2048
  Sent 5712 bytes 39 pkt (dropped 169, overlimits 0 requeues 0)
  backlog 1720b 10p requeues 0
 class qfq 11:15 root leaf 841f: weight 1 maxpkt 2048
  Sent 58 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 29b 1p requeues 0
 class qfq 11:14 root leaf 841e: weight 1 maxpkt 2048
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
 class qfq 11:17 root leaf 8421: weight 1 maxpkt 2048
  Sent 27473 bytes 91 pkt (dropped 131, overlimits 0 requeues 0)
  backlog 520b 10p requeues 0
 class qfq 11:16 root leaf 8420: weight 1 maxpkt 2048
  Sent 4037380 bytes 2743 pkt (dropped 261, overlimits 0 requeues 0)
  backlog 13584b 10p requeues 0
 class qfq 11:19 root leaf 8423: weight 1 maxpkt 2048
  Sent 5132 bytes 37 pkt (dropped 131, overlimits 0 requeues 0)
  backlog 755b 10p requeues 0

 ...
 class qfq 11:2f root leaf 8439: weight 1 maxpkt 2048
  Sent 89 bytes 1 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
 class qfq 11:2c root leaf 8436: weight 1 maxpkt 2048
  Sent 3977870 bytes 3239 pkt (dropped 989, overlimits 0 requeues 0)
  backlog 13521b 10p requeues 0
 class qfq 11:2d root leaf 8437: weight 1 maxpkt 2048
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
 class qfq 11:40 root leaf 844a: weight 1 maxpkt 2048
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0


 ---
 System administrator
 Denys Fedoryshchenko
 Virtual ISP S.A.L.
