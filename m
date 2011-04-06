From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: ethtool support to configure number of channels
Date: Wed, 06 Apr 2011 23:18:08 +0100
Message-ID: <1302128288.2840.72.camel@bwh-desktop>
References: <1301652075-382-1-git-send-email-amit.salecha@qlogic.com>
	 <1301677824.4679.10.camel@bwh-desktop>
	 <99737F4847ED0A48AECC9F4A1974A4B80FD10E8D93@MNEXMB2.qlogic.org>
	 <1301712946.10056.179.camel@localhost>
	 <BEEA5B09-0726-463D-B542-234C4FB49FC5@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Amit Salecha <amit.salecha@qlogic.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:29396 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756493Ab1DFWSM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 18:18:12 -0400
In-Reply-To: <BEEA5B09-0726-463D-B542-234C4FB49FC5@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-04-01 at 22:47 -0700, Anirban Chakraborty wrote:
> On Apr 1, 2011, at 7:55 PM, Ben Hutchings wrote:
> 
> > On Fri, 2011-04-01 at 21:36 -0500, Amit Salecha wrote:
> >>> I'm not sure why you reduced this to a single count.  If if the driver
> >>> or hardware doesn't allow certain combinations of counts, it might be
> >>> necessary to configure several types at the same time
> >>>
> >>>> +/* Channel ID is made up of a type */
> >>>> +enum ethtool_channel_id {
> >>>> +   ETH_CHAN_TYPE_RX = 0x1,
> >>>> +   ETH_CHAN_TYPE_TX = 0x2
> >>>> +};
> >>> [...]
> >>>
> >>> enum ethtool_channel_id was meant to be an identifier of a specific
> >>> channel.  An enumeration of channel types should be named differently.
> >>>
> >>
> >> I will name it as ethtool_channel_type. Any other suggestion ?
> >>
> >>> This also omits the 'combined' and 'other' types.  Most multiqueue
> >>> drivers pair up RX and TX queues so that most channels combine RX and
> >>> TX
> >>> work.
> >>
> >> 'combined' is ok, what is use of 'other' ?
> >
> > Could be link interrupts, SR-IOV coordination, or something else.  Not
> > something you'd likely be able to change, but it could be useful to know
> > that some interrupts are allocated to them.  Actually, that does mean it
> > might be helpful for the 'get' operation to return a minimum value along
> > with the maximum value.
> 
> Are you thinking of using the 'other' field as a way to a represent a 'virtual port'
> that a VF could have. A virtual port could have a set of rx/tx rings, interrupts,
> QoS parameters, MAC filters, VLAN ids etc. etc. A VF could have one or many such
> channels. If thats the case, I would think that configuring these channels should
> be done via a PF rather than on a VF. It is possible I could get you totally wrong here,
> however it would be good to hear your thoughts.

The net device for a VF could have all sorts of channels, and their
numbers may or may not be configurable depending on limitations of the
hardware, firmware, driver or hypervisor.

The channel counts reported by a net device should include all those
IRQs allocated by the net device driver for its parent device (e.g. a
PCI device).

To be more concrete, here is how I would count channels:

1. RX queue with IRQ, exposed to the network stack => RX channel
2. TX queue with IRQ, exposed to the network stack => TX channel
3. RX and TX queue sharing IRQ, exposed to the network stack => combined channel
4. Link change IRQ => other channel
5. Queue(s) and IRQ for iSCSI traffic, not exposed to the network stack => other channel
6. Qeuue(s) and IRQ for coordination between PCI functions => other channel
7. Queue(s) and IRQ allocated to other PCI function => not counted

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

