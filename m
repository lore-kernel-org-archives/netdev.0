From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [WIP][PATCHES] Network xmit batching
Date: Fri, 8 Jun 2007 12:38:07 +0400
Message-ID: <20070608083807.GB11488@2ka.mipt.ru>
References: <OFB311484E.057E34E9-ON652572F3.001D5838-652572F3.0022766D@in.ibm.com> <1181216629.4064.22.camel@localhost> <20070607161335.GA4987@2ka.mipt.ru> <1181254996.4071.27.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	Gagan Arneja <gaagaan@gmail.com>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	Robert Olsson <Robert.Olsson@data.slu.se>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:34487 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936547AbXFHJNX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jun 2007 05:13:23 -0400
Content-Disposition: inline
In-Reply-To: <1181254996.4071.27.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 07, 2007 at 06:23:16PM -0400, jamal (hadi@cyberus.ca) wrote:
> On Thu, 2007-07-06 at 20:13 +0400, Evgeniy Polyakov wrote:
> 
> > Actually I wonder where the devil lives, but I do not see how that
> > patchset can improve sending situation.
> > Let me clarify: there are two possibilities to send data:
> > 1. via batched sending, which runs via queue of packets and performs
> > prepare call (which only setups some private flags, no work with 
> > hardware) and then sending call.
> 
> I believe both are called with no lock. The idea is to avoid the lock
> entirely when unneeded. That code may end up finding that the packet
> is bogus and throw it out when it deems it useless.
> If you followed the discussions on multi-ring, this call is where
> i suggested to select the tx ring as well.

Hmm...

+	netif_tx_lock_bh(odev);
+	if (!netif_queue_stopped(odev)) {
+
+		idle_start = getCurUs();
+		pkt_dev->tx_entered++;
+		ret = odev->hard_batch_xmit(&odev->blist, odev);


+	if (!spin_trylock_irqsave(&tx_ring->tx_lock, flags)) {
+		/* Collision - tell upper layer to requeue */
+		return NETDEV_TX_LOCKED;
+	}
+
+	while ((skb = __skb_dequeue(list)) != NULL) {
+#ifdef coredoesnoprep
+		ret = netdev->hard_prep_xmit(skb, netdev);
+		if (ret != NETDEV_TX_OK)
+			continue;
+#endif
+
+		/*XXX: This may be an opportunity to not give nit
+		 * the packet if the dev ix TX BUSY ;-> */
+		dev_do_xmit_nit(skb, netdev);
+		ret = e1000_queue_frame(skb, netdev);

The same applies to *_gso case.

> > 2. old xmit function (which seems to be unused by kernel now?)
> > 
> 
> You can change that by turning off _BTX feature in the driver.
> For WIP reasons it is on at the moment.
> 
> > Btw, prep_queue_frame seems to be always called under tx_lock, but it
> > old e1000 xmit function calls it without lock. 
> 
> I think both call it without lock.

Without lock that would be wrong - it accesses hardware.

> > Locked case is correct,
> > since it accesses private registers via e1000_transfer_dhcp_info() for
> > some adapters.
> 
> I am unsure about the value of that lock (refer to email to Auke). There
> is only one CPU that can enter the tx path and the contention is
> minimal.
> 
> > So, essentially batched sending is 
> > lock
> > while ((skb = dequue))
> >   send
> > unlock
> > 
> > where queue of skbs are prepared by stack using the same transmit lock.
> > 
> > Where is a gain?
> 
> The amortizing of the lock on tx is where the value is.
> Did you see the numbers Evgeniy? ;->
> Heres one i can vouch on a dual processor 2GHz that i tested with
> pktgen;

I only saw results Krishna posted, and i also do not know, what
service demand is :)

> ----
>     1) Original e1000 driver (no batching):
>     a) We got a xmit throughput of 362Kpackets/second of 362K with
>     the default setup (everything falls on cpu#0).
>     b) With tying to CPU#1, i saw 401Kpps.
> 
>     2) Repeated the tests with batching patches (as in this commit)
>     And got an outstanding 694Kpps throughput.
> 
>     5) Repeated #4 with binding to cpu #1.
>     And throughput didnt improve that much - was hitting 697Kpps
>     I think we are pretty much hitting upper limits here
>     ...
> ----
> 
> I am actually testing as we speak on faster hardware - I will post
> results shortly.

Result looks good, but I still do not understand how it appeared, that
is why I'm not that excited about idea - I just do not know it in
details.

-- 
	Evgeniy Polyakov
