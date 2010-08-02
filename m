From: Franchoze Eric <franchoze@yandex.ru>
Subject: Re: shape traffic on tun interfaces
Date: Mon, 02 Aug 2010 11:46:11 +0400
Message-ID: <474381280735172@web82.yandex.ru>
References: <301941280614170@web105.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: lartc@mailman.ds9a.nl, netdev@vger.kernel.org
To: alex@digriz.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward8.mail.yandex.net ([77.88.61.38]:43645 "EHLO
	forward8.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753143Ab0HBHqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 03:46:15 -0400
In-Reply-To: <301941280614170@web105.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>Do the QoS on your next hop router 
There is no next router. And QoS should be on the same machine.

>or on the interface all your de-encapsulated VPN traffic flows over (ie. 'eth0') instead.

It is not a problem to find interface with de-encapsulated traffic. The problem is that tc rules should be written accoring to network device.
And it is really uncinvinient clone this rules which are differ only with destination IP.

For example look here. It's needed to create subclass for each destination IP.

#class
tc class add dev $DEV parent 1: classid 1:1 htb rate ${SPEED}kbit
#subclass
# high priority traffic (where we get money, http for example)
tc class add dev $DEV parent 1:1 classid 1:2 htb rate ${SPEED}kbit ceil ${SPEED}kbit prio 0
# low priority trafic - no adds - now money - low speed
tc class add dev $DEV parent 1:1 classid 1:3 htb rate ${SPEED}/2kbit ceil ${SPEED}kbit prio 1
#handle
tc qdisc add dev $DEV parent 1:2 handle 2: sfq perturb 10
tc qdisc add dev $DEV parent 1:3 handle 3: sfq perturb 10
#connect with
tc filter add dev $DEV parent 1:0 prio 0 protocol ip handle 2 fw flowid 1:1001
tc filter add dev $DEV parent 1:0 prio 0 protocol ip handle 3 fw flowid 1:1002 

