From: Rick Jones <rick.jones2@hp.com>
Subject: large degradation in ip netns add/exec performance in 3.13?
Date: Tue, 04 Feb 2014 11:57:17 -0800
Message-ID: <52F1461D.8050703@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:44015 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755039AbaBDT5S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Feb 2014 14:57:18 -0500
Received: from g5t0030.atlanta.hp.com (g5t0030.atlanta.hp.com [16.228.8.142])
	by g5t0006.atlanta.hp.com (Postfix) with ESMTP id A3E63C002
	for <netdev@vger.kernel.org>; Tue,  4 Feb 2014 19:57:17 +0000 (UTC)
Received: from [16.103.148.51] (swa01lbdc1025-026-vl250-snat1.atlanta.hp.com [16.228.13.91])
	by g5t0030.atlanta.hp.com (Postfix) with ESMTP id 80D4214002
	for <netdev@vger.kernel.org>; Tue,  4 Feb 2014 19:57:17 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi -

I have a dinky little script which creates what I've been calling "fake 
routers."  It is far from a complete fake router, but it shows what 
appears to be a very large degradation in performance in 3.13 compared 
to 3.12.9 which itself is slow compared to a 3.5.0-44 kernel canonical 
kernel with some upstream commits included:


Start/End    Average Rate of Creation per Second
"Router" Count  3.5.0-44+  3.12.9  3.13.0
------------------------------------------------------
0 to 250          7.58      5.56    2.55
250 to 500        7.14      5.81    2.55
500 to 750        6.41      5.56    2.55
750 to 1000       6.10      4.90    2.55
1000 to 1250      5.68      4.39    2.50
1250 to 1500      5.21      4.24    2.36
1500 to 1750      5.00      3.85    2.23
1750 to 2000      4.81      3.62    2.21
2000 to 2250      4.55      3.47    2.21
2250 to 2500      4.31      3.29    2.14
2500 to 2750      4.03      3.09    2.05
2750 to 3000      3.73      3.09    2.02
3000 to 3250      3.62      2.81    2.02
3250 to 3500      3.38      2.72    1.97
3500 to 3750      3.21      2.55    1.92
3750 to 4000      3.01      2.48    1.87

Here is what the script is doing each time it is called:

#Assumed to be called as add_fake_router <sudo>
SUDO=$1
j=`uuidgen`
$SUDO ip netns add bar-${j}
$SUDO ip netns exec bar-${j} ip link set lo up
$SUDO ip netns exec bar-${j} sysctl -w net.ipv4.ip_forward=1 > /dev/null
k=`echo $j | cut -b -11`
$SUDO /home/rjones2/iproute2_tot/ip/ip link add ro-${k} type veth peer 
name ri-${k} netns bar-${j}
$SUDO /home/rjones2/iproute2_tot/ip/ip link add go-${k} type veth peer 
name gi-${k} netns bar-${j}

There is a calling script which provides a timestamp every 250 fake routers.

I am using a top of trunk ip command to get commit
f0124b0f0aa0e5b9288114eb8e6ff9b4f8c33ec8 which removed an unnecessary
ll_init_map call.  The sudo I am using is one which is also top of its
trunk, with an option enabled to not grab the list of interfaces on
the system each time it is called.

This is all a single stream of creations.  The added commits to the 
Canonical 3.5.0-44 kernel (apart from whatever they've put into -44) are 
665e205c16c1f902ac6763b8ce8a0a3a1dcefe59 and 
32263dd1b43378b4f7d7796ed713f77e95f27e8a plus 
http://marc.info/?l=linux-netdev&m=138546807821170&w=2

The system on which I can reproduce this is mine for the duration, so I 
can experiment with things and gather other information as requested.  I 
have some timings of the individual commands of the script at 0 and 4000 
"fake routers" present which I can provide if desired.  My look at it 
thusfar suggests it may be in the exec but I'm not certain.

happy benchmarking,

rick jones
