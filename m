From: jamal <hadi@cyberus.ca>
Subject: Re: [WIP][PATCHES] Network xmit batching
Date: Fri, 08 Jun 2007 07:31:07 -0400
Message-ID: <1181302267.4063.33.camel@localhost>
References: <OFB311484E.057E34E9-ON652572F3.001D5838-652572F3.0022766D@in.ibm.com>
	 <1181216629.4064.22.camel@localhost> <20070607161335.GA4987@2ka.mipt.ru>
	 <1181254996.4071.27.camel@localhost>  <20070608083807.GB11488@2ka.mipt.ru>
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
Received: from wx-out-0506.google.com ([66.249.82.226]:58760 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966955AbXFHLbM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2007 07:31:12 -0400
Received: by wx-out-0506.google.com with SMTP id t15so700931wxc
        for <netdev@vger.kernel.org>; Fri, 08 Jun 2007 04:31:11 -0700 (PDT)
In-Reply-To: <20070608083807.GB11488@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-08-06 at 12:38 +0400, Evgeniy Polyakov wrote:
> On Thu, Jun 07, 2007 at 06:23:16PM -0400, jamal (hadi@cyberus.ca) wrote:

> > I believe both are called with no lock. The idea is to avoid the lock
> > entirely when unneeded. That code may end up finding that the packet
[..]
> +	netif_tx_lock_bh(odev);
> +	if (!netif_queue_stopped(odev)) {
> +
> +		idle_start = getCurUs();
> +		pkt_dev->tx_entered++;
> +		ret = odev->hard_batch_xmit(&odev->blist, odev);

[..]
> The same applies to *_gso case.
> 

You missed an important piece which is grabbing of
__LINK_STATE_QDISC_RUNNING


> Without lock that would be wrong - it accesses hardware.

We are achieving the goal of only a single CPU entering that path. Are
you saying that is not good enough?

> I only saw results Krishna posted, 

Ok, sorry - i thought you saw the git log or earlier results where
other things are captured.

> and i also do not know, what service demand is :)

>From the explanation seems to be how much cpu was used while sending. Do
you have any suggestions for computing cpu use?
in pktgen i added code to count how many microsecs were used in
transmitting.

> Result looks good, but I still do not understand how it appeared, that
> is why I'm not that excited about idea - I just do not know it in
> details.

To add to KKs explanation on other email:
Essentially the value is in amortizing the cost of barriers and IO per
packet. For example the queue lock is held/released only once per X
packets. DMA kicking which includes both a PCI IO write and mbs is done
only once per X packets. There are still a lot of room for improvement
of such IO;

cheers,
jamal

