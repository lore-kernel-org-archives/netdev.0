From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: Can I limit the number of active tx per TCP socket?
Date: Fri, 07 Mar 2014 06:22:07 -0800
Message-ID: <1394202127.20149.14.camel@edumazet-glaptop2.roam.corp.google.com>
References: <063D6719AE5E284EB5DD2968C1650D6D0F6D3B91@AcuExch.aculab.com>
	 <5318ADB1.5050107@hp.com>
	 <CADVnQyn1+WRqS9HQmMn9JgpBz0Wajg=40yVhdyqv_AAo4tpWUA@mail.gmail.com>
	 <063D6719AE5E284EB5DD2968C1650D6D0F6D727E@AcuExch.aculab.com>
	 <063D6719AE5E284EB5DD2968C1650D6D0F6D755C@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: 'Neal Cardwell' <ncardwell@google.com>,
	Rick Jones <rick.jones2@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:58360 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750930AbaCGOWJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 09:22:09 -0500
Received: by mail-pa0-f45.google.com with SMTP id kl14so4217939pab.32
        for <netdev@vger.kernel.org>; Fri, 07 Mar 2014 06:22:09 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6D755C@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-03-07 at 12:29 +0000, David Laight wrote:

> I'll probably look at delaying the sends within our own code.

That would be bad.

Just use fq/pacing, this is way better. Its designed for this usage.

trick is to reduce 'quantum' as you mtu is 273+14 bytes.

QUANTUM=$((273+14))
tc qdisc replace dev eth0 root fq quantum $QUANTUM initial_quantum $QUANTUM

This will _perfectly_ pace packets every 34 ms.

If you share your ethernet device with this 64k destination, and other
uses, then you need a more complex setup with HTB plus two classes, and
fq running at the htb leaf

DEV=eth0

MTU=273
QUANTUM=$(($MTU+14))
DESTINATION=10.246.11.52/32   # change this to meet the network/host

tc qdisc del dev $DEV root &> /dev/null

tc qdisc add dev $DEV handle 1: root htb default 1

tc class add dev $DEV parent 1: classid 1:1 htb rate 1Gbit
tc class add dev $DEV parent 1: classid 1:2 htb rate 64kbit

tc filter add dev $DEV protocol ip parent 1:0 prio 1 u32 match ip dst $DESTINATION flowid 1:2

tc qdisc add dev $DEV parent 1:1 est 1sec 4sec fq
tc qdisc add dev $DEV parent 1:2 est 1sec 4sec fq quantum $QUANTUM initial_quantum $QUANTUM
