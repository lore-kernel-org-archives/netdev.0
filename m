From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: HTB behaviour renders cburst feature useless
Date: Wed, 26 Dec 2007 07:33:09 +0200
Message-ID: <20071226051902.M97942@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:43984 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751234AbXLZFdT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Dec 2007 00:33:19 -0500
Received: from visp.net.lb (localhost [127.0.0.1])
	by usermail.globalproof.net (Postfix) with ESMTP id C1FE7BDBC0
	for <netdev@vger.kernel.org>; Wed, 26 Dec 2007 07:33:09 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi again

I am trying to use HTB for providing "double" speed shaper. It will looks 
like (graph):

XXXX
XXXX
XXXXYYYY
XXXXYYYY

Explanation:
For example user have bursty rate 1Mbit/s with "bucket"(derived from squid) 
size 10Mbyte, and then he will have 500Kbit/s if bucket is empty. Bucket 
refilled with speed 500Kbit/s. So if user downloading file with size 20Mbyte, 
he will get first 10Mbyte on speed 1Mbit/s, and second part with speed 
500Kbit/s. On TBF i can do this easily, but on HTB it is not trivial, and not 
working as it expected to work.

On HTB i set

#!/bin/sh
tc qdisc        del dev eth0 root
tc qdisc        add dev eth0 handle 1: root htb

#ROOT class is zero, just i am expecting when cburst finished, ceil will not 
be provided.

tc class        add dev eth0 parent 1:0 classid 1:1 htb rate 8bit ceil 8bit 
quantum 1514

#This is values as explained. 
tc class        add dev eth0 parent 1:1 classid 1:3 htb rate 500Kbit ceil 
1Mbit quantum 1514 cburst 10240kb
tc qdisc        add dev eth0 parent 1:3 handle 30 pfifo limit 1

tc filter       add dev eth0 parent 1:0 protocol ip prio 5 u32 match ip src 
192.168.1.1/32 flowid 1:3

But it works not as i am expecting.
1)I can send this 10Mbyte with any speed. It seems will not be limited at 
1Mbit/s.
2)After i reach 10Mbyte traffic will be blocked completely for some time! 
Even queue set as pfifo with 1 packet. It has to be sent with speed 500Kbit 
and all exceeding this value packets has to be dropped. But it is stopping 
whole class traffic completely.


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

