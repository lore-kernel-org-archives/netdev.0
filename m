From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in
	RCU.
Date: Fri, 18 Jul 2008 09:10:24 -0400
Message-ID: <1216386624.4833.94.camel@localhost>
References: <487F4327.1000107@trash.net>
	 <1216301732.4726.26.camel@localhost>	<487F50EC.80008@trash.net>
	 <20080717.152447.89672084.davem@davemloft.net>  <487FDA67.30902@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	johannes@sipsolutions.net, linux-wireless@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.227]:2609 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758045AbYGRNK2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 09:10:28 -0400
Received: by wr-out-0506.google.com with SMTP id 69so210548wri.5
        for <netdev@vger.kernel.org>; Fri, 18 Jul 2008 06:10:26 -0700 (PDT)
In-Reply-To: <487FDA67.30902@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-18-07 at 01:48 +0200, Patrick McHardy wrote:
> David Miller wrote:

> > I think from certain perspectives it frankly doesn't matter.
> > 
> > It's not like the skb->priority field lets the SKB bypass the packets
> > already in the TX ring of the chip with a lower priority.
> > 
> > It is true that, once the TX ring is full, the skb->priority thus
> > begins to have an influence on which packets are moved from the
> > qdisc to the TX ring of the device.
> > 

Indeed QoS is irrelevant unless there is congestion. 
The question is whether the packets sitting on the fifo qdisc are being
sorted fairly when congestion kicks in. Remember there is still a single
wire still even on multiple rings;->
If Woz (really) showed up at 9am and the Broussards at 3 am[1] on that
single (congestion-buffering) FIFO waiting for the shop/wire to open up,
then Woz should jump the queue (if he deserves it) when shop opens at
10am.

If queues are building up, then by definition you have congestion
somewehere - IOW some resource (wire bandwidth, code-efficiency/cpu,
bus, remote being slow etc) is not keeping up.

I am sorry havent read the patches sufficiently to answer that question
but i suspect that stashing the packets into different hardware queues
already solves this since the hardware does whatever scheduling it needs
to on the rings. 

> > However, I wonder if we're so sure that we want to give normal users
> > that kind of powers.  Let's say for example that you set the highest
> > priority possible in the TOS socket option, and you do this for a ton
> > of UDP sockets, and you just blast packets out as fast as possible.
> > This backlogs the device TX ring, and if done effectively enough could
> > keep other sockets blocked out of the device completely.
> > 
> > Are we really really sure it's OK to let users do this?  :)

We do today - if it is a concern, one could make the setsock opts
preferential (example via selinux or setting caps in the kernel etc).

> > To me, as a default, I think TOS and DSCP really means just on-wire
> > priority.

Agreed - with the caveat above on congestion. i.e it is still a single
wire even with multi rings.

> > If we absolutely want to, we can keep the old pfifo_fast around and use
> > it (shared on multiq) if a certain sysctl knob is set.
> 
> No, I fully agree that this is too much detail :) Its highly
> unlikely that this default behaviour is important on a per
> packet level :) I just meant to point out that using a pfifo
> is not going to be the same behaviour as previously.

IMO, if non-multiq drivers continue to work as before with the prios,
then nice. multiq could be tuned over a period of time.

cheers,
jamal

