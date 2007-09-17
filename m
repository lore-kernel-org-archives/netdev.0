From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/10 REV5] Implement skb batching and support in
 IPoIB/E1000
Date: Sun, 16 Sep 2007 20:13:18 -0700 (PDT)
Message-ID: <20070916.201318.71091570.davem@davemloft.net>
References: <1189995261.4230.61.camel@localhost>
	<20070916.192502.123919711.davem@davemloft.net>
	<1189998103.4230.76.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, johnpol@2ka.mipt.ru,
	herbert@gondor.apana.org.au, kaber@trash.net,
	shemminger@linux-foundation.org, jagana@us.ibm.com,
	Robert.Olsson@data.slu.se, rick.jones2@hp.com, xma@us.ibm.com,
	gaagaan@gmail.com, netdev@vger.kernel.org, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	jeff@garzik.org, mchan@broadcom.com, general@lists.openfabrics.org,
	kumarkr@linux.ibm.com, tgraf@suug.ch, randy.dunlap@oracle.com,
	sri@us.ibm.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51552
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750794AbXIQDNT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 23:13:19 -0400
In-Reply-To: <1189998103.4230.76.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Sun, 16 Sep 2007 23:01:43 -0400

> I think GSO is still useful on top of this.
> In my patches anything with gso gets put into the batch list and shot
> down the driver. Ive never considered checking whether the nic is TSO
> capable, that may be something worth checking into. The netiron allows
> you to shove upto 128 skbs utilizing one tx descriptor, which makes for
> interesting possibilities.

We're talking past each other, but I'm happy to hear that for
sure your code does the right thing :-)

Right now only TSO capable hardware sets the TSO capable bit,
except perhaps for the XEN netfront driver.

What Herbert and I want to do is basically turn on TSO for
devices that can't do it in hardware, and rely upon the GSO
framework to do the segmenting in software right before we
hit the device.

This only makes sense for devices which can 1) scatter-gather
and 2) checksum on transmit.  Otherwise we make too many
copies and/or passes over the data.

And we can only get the full benefit if we can pass all the
sub-segments down to the driver in one ->hard_start_xmit()
call.

> On a side note: My observation is that with large packets on a very busy
> system; bulk transfer type app, one approaches wire speed; with or
> without batching, the apps are mostly idling (Ive seen upto 90% idle
> time polling at the socket level for write to complete with a really
> busy system). This is the case with or without batching. cpu seems a
> little better with batching. As the aggregation of the apps gets more
> aggressive (achievable by reducing their packet sizes), one can achieve
> improved throughput and reduced cpu utilization. This all with UDP; i am
> still studying tcp. 

UDP apps spraying data tend to naturally batch well and load balance
amongst themselves because each socket fills up to it's socket send
buffer limit, then sleeps, and we then get a stream from the next UDP
socket up to it's limit, and so on and so forth.

UDP is too easy a test case in fact :-)
