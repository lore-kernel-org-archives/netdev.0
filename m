From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Quota in __qdisc_run()
Date: Tue, 07 Oct 2014 12:10:15 -0700
Message-ID: <1412709015.11091.158.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141007153050.792c9743@redhat.com>
	 <1412693013.4140057.176149461.0FBF6CBD@webmail.messagingengine.com>
	 <1412694080.11091.131.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141007.131938.1410434352331637585.davem@davemloft.net>
	 <20141007200329.5d20a27e@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, hannes@stressinduktion.org,
	netdev@vger.kernel.org, therbert@google.com, fw@strlen.de,
	dborkman@redhat.com, jhs@mojatatu.com, alexander.duyck@gmail.com,
	john.r.fastabend@intel.com, dave.taht@gmail.com, toke@toke.dk
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:53765 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753764AbaJGTKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 15:10:17 -0400
Received: by mail-pa0-f50.google.com with SMTP id kx10so7562263pab.23
        for <netdev@vger.kernel.org>; Tue, 07 Oct 2014 12:10:17 -0700 (PDT)
In-Reply-To: <20141007200329.5d20a27e@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-10-07 at 20:03 +0200, Jesper Dangaard Brouer wrote:

> According to my measurements, at 10Gbit/s TCP_STREAM test the BQL limit
> is 381528 bytes / 1514 = 252 packets, that will (potentially) be bulk
> dequeued at once (with your version of the patch).
> 

That's because you use a single queue maybe ?

In reality, 10Gbe NIC are used in multiqueue mode ...

Here we have limits around 2 TSO packets.

Even with only 4 tx queues I have :

# sar -n DEV 3 3 |grep eth1
12:05:19 PM      eth1 147217.67 809066.67   9488.71 1196207.78      0.00      0.00      0.00
12:05:22 PM      eth1 145958.00 807822.33   9407.48 1194366.73      0.00      0.00      0.00
12:05:25 PM      eth1 147502.33 804739.33   9507.26 1189804.23      0.00      0.00      0.33
Average:         eth1 146892.67 807209.44   9467.82 1193459.58      0.00      0.00      0.11


grep . /sys/class/net/eth1/queues/tx*/byte_queue_limits/{inflight,limit}
/sys/class/net/eth1/queues/tx-0/byte_queue_limits/inflight:115064
/sys/class/net/eth1/queues/tx-1/byte_queue_limits/inflight:0
/sys/class/net/eth1/queues/tx-2/byte_queue_limits/inflight:0
/sys/class/net/eth1/queues/tx-3/byte_queue_limits/inflight:0
/sys/class/net/eth1/queues/tx-0/byte_queue_limits/limit:102952
/sys/class/net/eth1/queues/tx-1/byte_queue_limits/limit:124148
/sys/class/net/eth1/queues/tx-2/byte_queue_limits/limit:102952
/sys/class/net/eth1/queues/tx-3/byte_queue_limits/limit:136260


> It seems to have the potential to exceed the weight_p(64) quite a lot.
> And with e.g. TX ring size 512, we also also challenge the drivers at
> this early adoption phase of tailptr writes.  Just saying...
> 

Yep, but remind we want to squeeze bugs out of the drivers, then add
additional knobs later.

Whatever limit we choose in core networking stack (being 64 packets for
example), hardware might have different constraints that need to be
taken care of in the driver.
