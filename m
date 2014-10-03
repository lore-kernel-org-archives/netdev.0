From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] sunvnet: Packet processing in
 non-interrupt context.
Date: Fri, 03 Oct 2014 12:08:02 -0700 (PDT)
Message-ID: <20141003.120802.1213573830649867131.davem@davemloft.net>
References: <20141002201203.GA6001@oracle.com>
	<20141002.134346.2291749763304558513.davem@davemloft.net>
	<20141003144024.GA12448@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: raghuram.kothakota@oracle.com, netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58373 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753288AbaJCTF4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 15:05:56 -0400
In-Reply-To: <20141003144024.GA12448@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Fri, 3 Oct 2014 10:40:24 -0400

> On (10/02/14 13:43), David Miller wrote:
>> For example, you can now move everything into software IRQ context,
>> just disable the VIO interrupt and unconditionally go into NAPI
>> context from the VIO event.
>> No more irqsave/irqrestore.
>> Then the TX path even can run mostly lockless, it just needs
>> to hold the VIO lock for a minute period of time.  The caller
>> holds the xmit_lock of the network device to prevent re-entry
>> into the ->ndo_start_xmit() path.
>> 
> 
> let me check into this and get back. I think the xmit path
> may also need to have some kind of locking for the dring access
> and ldc_write? I think you are suggesting that I should also
> move the control-packet processing to vnet_event_napi(), which
> I have not done in my patch. I will examine where that leads.

I think you should be able to get rid of all of the in-driver
locking in the fast paths.

NAPI ->poll() is non-reentrant, so all RX processing occurs
strictly in a serialized environment.

Once you do TX reclaim in NAPI context, then all you have to do is
take the generic netdev TX queue lock during the evaluation of whether
to wakeup the TX queue or not.  Worst case you need to hold the
TX netdev queue lock across the whole TX reclaim operation.

The VIO lock really ought to be entirely superfluous in the data
paths.
