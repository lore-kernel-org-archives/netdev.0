From: Krishna Kumar <kumarkr@linux.vnet.ibm.com>
Subject: RE: [PATCH 1/2] qdisc_restart - readability changes, one bug fix.
Date: Mon, 18 Jun 2007 09:41:25 +0530
Message-ID: <1182139885.6082.3.camel@localhost.localdomain>
References: <D5C1322C3E673F459512FB59E0DDC329030A0E5F@orsmsx414.amr.corp.intel.com>
Reply-To: kumarkr@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hadi@cyberus.ca, herbert@gondor.apana.org.au,
	tgraf@suug.ch, kaber@trash.net, netdev@vger.kernel.org
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp05.au.ibm.com ([202.81.18.154]:53198 "EHLO
	ausmtp05.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750971AbXFREKz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 00:10:55 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp05.au.ibm.com (8.13.8/8.13.8) with ESMTP id l5I4CEbs9019466
	for <netdev@vger.kernel.org>; Mon, 18 Jun 2007 14:12:15 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.250.237])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5I4EHJI082740
	for <netdev@vger.kernel.org>; Mon, 18 Jun 2007 14:14:18 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5I4AhKD022105
	for <netdev@vger.kernel.org>; Mon, 18 Jun 2007 14:10:44 +1000
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC329030A0E5F@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-06-15 at 11:01 -0700, Waskiewicz Jr, Peter P wrote:

Hi Peter,

> I agree that the case shouldn't happen, and will only surface if the
> driver is indeed buggy.  I've thought about this conditional being
> removed for awhile, since it will protect against a poorly written
> driver wrt locking, but then again a driver behaving like that shouldn't
> be making it into the kernel.  That being said, out-of-tree drivers are
> heavily used (we have an out-of-tree e1000), and something like this
> could be missed.  But since that is the corner case of a crappy driver,
> I'm ok with this being removed.

Removing this check will work more efficiently for correctly written
drivers, but it will also catch the wrongly written drivers and free
up all the skbs (and print messages) as without this change, nothing
happens and resources are never freed up.

> These, at a glance, look very similar to the qdisc ->enqueue() and
> ->dequeue() function pointers.  I know I had to look a few times to
> realize they were separate calls through the qdisc and this new function
> name.  Perhaps dequeue_skb() can become dev_dequeue_skb() and
> requeue_skb() can be dev_requeue_skb()?  Something that helps
> differentiate these from the function pointers of the qdisc_ops might
> help distinguish what layer the operation is running on.

That is definitely required, I will send out a revised patch.

> I know there's been discussion on the driver side of the world to stop
> using unlikely() and likely() clauses.  I personally think it's ok in
> situations like this where you have one corner-case conditional without
> an else, but it's something to keep in mind when using them in
> new/rewritten code like this.

OK. The reason I had put the unlikely is that we are executing qdisc_restart
due to the synchronous queuing of a packet, or since we were rescheduled
after either :
	a. not getting tx lock (and when qdisc_restart had atleast one
	   packet in the queue, look for the qdisc_qlen return value in
	   handle_dev_cpu_collision).
	b. tx was busy and packet was requeue'd.

So in most (all?) cases, an skb should be found (I was not able to find a
case where skb can be NULL).

> The patch looks fine to me outside of the choice of names for
> dequeue_skb() and requeue_skb(), but I can be easily swayed.

I will send an updated patch for review. Thanks for your review comments.

- KK


