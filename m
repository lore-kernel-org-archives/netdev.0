From: =?UTF-8?Q?Nie=C5=9Bcierowicz_Adam?= <adam.niescierowicz@justnet.pl>
Subject: tc adding two filters with different protocols
Date: Mon, 12 Nov 2012 20:45:51 +0100
Message-ID: <1ca4bd93df74882980e199ca3fcf83a3@justnet.pl>
Reply-To: <adam.niescierowicz@justnet.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host-91.230.163.37.ltv.pl ([91.230.163.37]:39155 "EHLO
	mail.justnet.pl" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751576Ab2KLTqD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2012 14:46:03 -0500
Received: from [91.230.163.37] (helo=mail.justnet.pl)
	by service with esmtpa (Exim 4.72)
	(envelope-from <adam.niescierowicz@justnet.pl>)
	id 1TXzx9-0002zv-V5
	for netdev@vger.kernel.org; Mon, 12 Nov 2012 20:45:52 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

writes the qos where i want classify traffic for two protocol: ip and
pppoe. Example below

---
tc qdisc del root dev eth2
tc qdisc add dev eth2 root handle 1: htb
tc class add dev eth2 parent 1:0 classid 1:1 htb rate 500Mbit ceil 
500Mbit


tc filter add dev eth2 parent 1:0 prio 5 protocol ip u32
tc filter add dev eth2 parent 1:0 prio 5 handle 9: protocol ip u32 
divisor 256
tc filter add dev eth2 protocol ip parent 1:0 prio 5 u32 ht 800:: match 
ip dst 172.16.0.0/22 hashkey mask 0x000000ff at 16 link 9:


tc filter add dev eth2 parent 1:0 prio 6 protocol ppp_ses u32
tc filter add dev eth2 parent 1:0 prio 6 handle 4a: protocol ppp_ses 
u32 divisor 256
tc filter add dev eth2 protocol ppp_ses parent 1:0 prio 6 u32 ht 800:: 
match ip dst 31.41.209.0/24 at 24 hashkey mask 0x000000ff at 24 link 4a:
---

Unfortunately, when you add lines "tc filter add dev eth2 protocol 
ppp_ses parent 1:0 prio 6 u32 ht 800:: match ip dst 31.41.209.0/24 at 24 
hashkey mask 0x000000ff at 24 link 4a:" protocol change to ip

command "tc -s -d filter show dev eth2" shows
---
filter parent 1: protocol ip pref 5 u32
filter parent 1: protocol ip pref 5 u32 fh 9: ht divisor 256
filter parent 1: protocol ip pref 5 u32 fh 800: ht divisor 1
filter parent 1: protocol ip pref 5 u32 fh 800::800 order 2048 key ht 
800 bkt 0 link 9:  (rule hit 557082 success 0)
   match ac100000/fffffc00 at 16 (success 267341 )
     hash mask 000000ff at 16
filter parent 1: protocol ip pref 5 u32 fh 800::801 order 2049 key ht 
800 bkt 0 link 4a:  (rule hit 557039 success 0)
   match 1f29d100/ffffff00 at 24 (success 0 )
     hash mask 000000ff at 24
filter parent 1: protocol ppp_ses pref 6 u32
filter parent 1: protocol ppp_ses pref 6 u32 fh 4a: ht divisor 256
filter parent 1: protocol ppp_ses pref 6 u32 fh 801: ht divisor 1
---
if i change order and first protocol is ppp_ses the hashkey for ip 
protocol is changed to ppp_ses.

Is this correct behavior and I do something wrong?


Thanks
Adam N.
