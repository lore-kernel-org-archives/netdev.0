From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH v2 0/9] bql: Byte Queue Limits
Date: Tue, 09 Aug 2011 00:41:23 -0700 (PDT)
Message-ID: <20110809.004123.2080217558650594315.davem@davemloft.net>
References: <20110808105529.4c8c52e1@nehalam.ftrdhcpuser.net>
	<CA+mtBx_bdCGvR+xBMq9px0vOV6a6kFn0wYyJH26+CdSPLtvgfw@mail.gmail.com>
	<20110808111917.4b2669de@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51180 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751468Ab1HIHl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 03:41:27 -0400
In-Reply-To: <20110808111917.4b2669de@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 8 Aug 2011 11:19:17 -0700

> On Mon, 8 Aug 2011 11:01:57 -0700
> Tom Herbert <therbert@google.com> wrote:
> 
>> > Since transmit completion means calling dev_kfree_skb() why not account
>> > there? You could add some info to netdev if necessary to get compile
>> > the statistics.
>> >
>> The algorithm depends on knowing the total number of packets competed
>> in a single execution of transmit completion (epic based).  We only
>> want to recalculate the limits once per completion, which happens when
>> the completion function is called.
> 
> So just add some stats to netdev and count the number of dev_kfree_skb
> calls and do your work at napi complete.

No, I think what Tom's doing here is reasonable.

First off, drivers have never been required to do specific things if
they return success for ->ndo_start_xmit().  They can kfree_skb(skb)
and return NET_TX_SUCCESS, and that's fine.

This mean we can't use ->ndo_start_xmit() return values to drive the
BQL engine.

So we simply have a way for the driver to say when it really does
queue up a packet, and that might be useful for other things.

Second, you absolutely do not want to run the BQL engine on every
single dev_kfree_skb() call.  You want to batch it, and that's what
Tom's new interface does, and that is therefore quite reasonable
too.

In fact, I think the best part about this revision of the BQL patches
is the device driver interface. :-)

