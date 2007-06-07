From: jamal <hadi@cyberus.ca>
Subject: Re: [WIP][PATCHES] Network xmit batching
Date: Thu, 07 Jun 2007 18:23:16 -0400
Message-ID: <1181254996.4071.27.camel@localhost>
References: <OFB311484E.057E34E9-ON652572F3.001D5838-652572F3.0022766D@in.ibm.com>
	 <1181216629.4064.22.camel@localhost>  <20070607161335.GA4987@2ka.mipt.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	Gagan Arneja <gaagaan@gmail.com>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	Robert Olsson <Robert.Olsson@data.slu.se>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ag-out-0708.google.com ([72.14.246.247]:18253 "EHLO
	ag-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936935AbXFGWXV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 18:23:21 -0400
Received: by ag-out-0708.google.com with SMTP id 35so529247aga
        for <netdev@vger.kernel.org>; Thu, 07 Jun 2007 15:23:20 -0700 (PDT)
In-Reply-To: <20070607161335.GA4987@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-07-06 at 20:13 +0400, Evgeniy Polyakov wrote:

> Actually I wonder where the devil lives, but I do not see how that
> patchset can improve sending situation.
> Let me clarify: there are two possibilities to send data:
> 1. via batched sending, which runs via queue of packets and performs
> prepare call (which only setups some private flags, no work with 
> hardware) and then sending call.

I believe both are called with no lock. The idea is to avoid the lock
entirely when unneeded. That code may end up finding that the packet
is bogus and throw it out when it deems it useless.
If you followed the discussions on multi-ring, this call is where
i suggested to select the tx ring as well.

> 2. old xmit function (which seems to be unused by kernel now?)
> 

You can change that by turning off _BTX feature in the driver.
For WIP reasons it is on at the moment.

> Btw, prep_queue_frame seems to be always called under tx_lock, but it
> old e1000 xmit function calls it without lock. 

I think both call it without lock.

> Locked case is correct,
> since it accesses private registers via e1000_transfer_dhcp_info() for
> some adapters.

I am unsure about the value of that lock (refer to email to Auke). There
is only one CPU that can enter the tx path and the contention is
minimal.

> So, essentially batched sending is 
> lock
> while ((skb = dequue))
>   send
> unlock
> 
> where queue of skbs are prepared by stack using the same transmit lock.
> 
> Where is a gain?

The amortizing of the lock on tx is where the value is.
Did you see the numbers Evgeniy? ;->
Heres one i can vouch on a dual processor 2GHz that i tested with
pktgen;

----
    1) Original e1000 driver (no batching):
    a) We got a xmit throughput of 362Kpackets/second of 362K with
    the default setup (everything falls on cpu#0).
    b) With tying to CPU#1, i saw 401Kpps.

    2) Repeated the tests with batching patches (as in this commit)
    And got an outstanding 694Kpps throughput.

    5) Repeated #4 with binding to cpu #1.
    And throughput didnt improve that much - was hitting 697Kpps
    I think we are pretty much hitting upper limits here
    ...
----

I am actually testing as we speak on faster hardware - I will post
results shortly.

> Btw, this one forces a smile:
> 	if (unlikely(ret != NETDEV_TX_OK))
> 			return NETDEV_TX_OK;
> 

Dont wanna change the way e1000 behaves. It returns NETDEV_TX_OK even
when it netif_stops; this allows the top layer to exit. 

> P.S. I do not have e1000 hardware to test, the only testing machine has
> r8169 driver.

Send me your shipping address privately and i can send you some.


cheers,
jamal

