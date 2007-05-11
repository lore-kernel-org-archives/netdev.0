From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Fri, 11 May 2007 13:01:38 +0400
Message-ID: <20070511090138.GA24695@2ka.mipt.ru>
References: <5640c7e00705101159w68750a47xc06495e4395de583@mail.gmail.com> <OFC32212EC.5585A74E-ON652572D8.001B86BB-652572D8.001BDDAD@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Ian McDonald <ian.mcdonald@jandi.co.nz>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:34528 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755598AbXEKJCL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2007 05:02:11 -0400
Content-Disposition: inline
In-Reply-To: <OFC32212EC.5585A74E-ON652572D8.001B86BB-652572D8.001BDDAD@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 11, 2007 at 10:34:22AM +0530, Krishna Kumar2 (krkumar2@in.ibm.com) wrote:
> Not combining packets, I am sending them out in the same sequence it was
> queued. If the xmit failed, the driver's new API returns the skb which
> failed to be sent. This skb and all other linked skbs are requeue'd in
> the reverse order (fofi?) till the next time it is tried again. I see
> that sometimes I can send tx_queue_len packets in one shot and all
> succeeds. But the downside is that in failure case, the packets have to
> be requeue'd.

And what if you have thousand(s) of packets queued and first one has
failed, requeing all the rest one-by-one is not a solution. If it is
being done under heavy lock (with disabled irqs especially) it becomes a
disaster.

I thought of a bit different approach: driver maintains own queue (or
has access to stack's one) and only uses lock to dequeue a packet. If
transmit fails, nothing is requeued, but the same packet is tried until
transmit is completed. If number of transmits failed in order, driver
says it is broken and/or stops queue. Thus one can setup several
descriptors in one go and do it without any locks. Stack calls driver's
xmit function which essentially sets bit that new packets are available,
but driver must have access to qdisk.

If e1000 driver would not be so... so 'uncommon' compared to another
small gige drivers I would try to cook up a patch, but I will not with
e1000 :)

-- 
	Evgeniy Polyakov
