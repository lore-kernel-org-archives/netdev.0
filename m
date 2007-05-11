From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Fri, 11 May 2007 13:32:02 +0400
Message-ID: <20070511093202.GB24695@2ka.mipt.ru>
References: <20070511090138.GA24695@2ka.mipt.ru> <OF251384FB.93952CAB-ON652572D8.00324514-652572D8.00331BB3@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Ian McDonald <ian.mcdonald@jandi.co.nz>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:32986 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755531AbXEKJcm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2007 05:32:42 -0400
Content-Disposition: inline
In-Reply-To: <OF251384FB.93952CAB-ON652572D8.00324514-652572D8.00331BB3@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 11, 2007 at 02:48:14PM +0530, Krishna Kumar2 (krkumar2@in.ibm.com) wrote:
> > And what if you have thousand(s) of packets queued and first one has
> > failed, requeing all the rest one-by-one is not a solution. If it is
> > being done under heavy lock (with disabled irqs especially) it becomes a
> > disaster.
> 
> If first one failed for other reasons from described below, it is freed up
> and the next one attempted. There are three cases where we cannot continue
> :
> no slots, device blocked, no lock.
> 
> Jamal had suggested to get information on #available slots from the driver.
> The queue_stopped is checked before linking packets, so the only other
> error case is not getting a lock. And this too is true only in the ~LLTX
> case,
> which optionally could be a check to enable this linking. Also, there could
> be limits to how many packets are queue'd. I tried tx_queue_len as well as
> tx_queue_len/2, but there could be other options.

Why stack should ever know what hardware is being used?
If you are going to break things, break it with scary sound :)

Design new interface, where driver has access to the queue (say only
using one helper dequeue_first_packet()), stack can only queue packets
to the tail, driver can also stop that by setting a bit (which was there
likely before we had knew word Linux).

That is all, driver does not access qdisk, it only gets the first skb.
Transmit function is completely lockless (until something is shared with
receive path/interrupts, but it is private driver's part), stack will
not be changed at all (except new helper to dequeue first packet from
the qdisk, actually it is already there, it just needs to be exported),
driver's xit function sets a flag that there are packets (or it can be
even empty, since packet's presense can be detected via the same qdisk
interface). You read qdisk len, setup several descriptors in one go,
dequeue set of skbs and commit them. If something has failed, it is not
requeued, but resent (or even dropped after fair amount of attempts).
No locks, no requeues? Seems simple imho.

-- 
	Evgeniy Polyakov
