From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [WIP][PATCHES] Network xmit batching
Date: Thu, 7 Jun 2007 20:13:35 +0400
Message-ID: <20070607161335.GA4987@2ka.mipt.ru>
References: <OFB311484E.057E34E9-ON652572F3.001D5838-652572F3.0022766D@in.ibm.com> <1181216629.4064.22.camel@localhost>
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
Received: from relay.2ka.mipt.ru ([194.85.82.65]:59086 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751947AbXFGQQd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jun 2007 12:16:33 -0400
Content-Disposition: inline
In-Reply-To: <1181216629.4064.22.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 07, 2007 at 07:43:49AM -0400, jamal (hadi@cyberus.ca) wrote:
> Folks, we need help. Please run this on different hardware. Evgeniy, i
> thought this kind of stuff excites you, no? ;-> (wink, wink).
> Only the sender needs the patch but the receiver must be a more powerful
> machine (so that it is not the bottleneck).
> A very interesting test will be say 10K flows serving different packet
> sizes to simulate a busy server.

Actually I wonder where the devil lives, but I do not see how that
patchset can improve sending situation.
Let me clarify: there are two possibilities to send data:
1. via batched sending, which runs via queue of packets and performs
prepare call (which only setups some private flags, no work with 
hardware) and then sending call.
2. old xmit function (which seems to be unused by kernel now?)

Btw, prep_queue_frame seems to be always called under tx_lock, but it
old e1000 xmit function calls it without lock. Locked case is correct,
since it accesses private registers via e1000_transfer_dhcp_info() for
some adapters.

So, essentially batched sending is 
lock
while ((skb = dequue))
  send
unlock

where queue of skbs are prepared by stack using the same transmit lock.

Where is a gain?

Btw, this one forces a smile:
	if (unlikely(ret != NETDEV_TX_OK))
			return NETDEV_TX_OK;

P.S. I do not have e1000 hardware to test, the only testing machine has
r8169 driver.

-- 
	Evgeniy Polyakov
