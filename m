From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: testing crazy stuff with iproute2
Date: Wed, 26 Dec 2007 06:57:42 +0200
Message-ID: <20071226045037.M75814@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:51275 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159AbXLZFCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Dec 2007 00:02:39 -0500
Received: from visp.net.lb (localhost [127.0.0.1])
	by usermail.globalproof.net (Postfix) with ESMTP id 903AFBDBB2
	for <netdev@vger.kernel.org>; Wed, 26 Dec 2007 06:57:42 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I did rules:

tc qdisc        del dev eth0 root
tc qdisc        add dev eth0 handle 1: root htb

tc class        add dev eth0 parent 1:0 classid 1:2 htb rate 100Mbit ceil 
100Mbit quantum 1514
tc qdisc        add dev eth0 handle 2: parent 1:2 sfq

tc class        add dev eth0 parent 1:0 classid 1:3 htb rate 100Mbit ceil 
100Mbit quantum 1514
tc qdisc        add dev eth0 parent 1:3 handle 3: est 1sec 8sec tbf buffer 
1024kb latency 500ms rate 10240 peakrate 1024000 mtu 1500
tc qdisc        add dev eth0 parent 3:1 handle 30 pfifo limit 1

tc filter       add dev eth0 parent 1:0 protocol ip prio 5 u32 match ip src 
192.168.1.1/32 flowid 1:3

Probably it must not work at all (attaching tbf), but it works as expected in 
my understanding.

classid 1:2 just fake, not used at all
classid 1:3 is created, because i want to use tbf multiple times. 
I like burst introduced in TBF, and seems burst/cburst in HTB not doing same 
job, at least i had some difficulties with them (will research more).

filter don't want to attach with parent 3:0 or 3:1, so i had to attach it to 
1:3. It works fine, but i have to put high value in ceil to not be limited by 
htb. TBF working as expected. When rate-limit in TBF reached, it is queueing 
buffer in qdisc with handle 30

But i got few times in dmesg, during tests (probably when i set sfq instead 
pfifo, or etc).

[2090816.116000] htb: class 10003 isn't work conserving ?!

Is it a bug? And does it worth to do such "shaper"?


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

