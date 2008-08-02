From: Mark Smith <ipng@69706e6720323030352d30312d31340a.nosense.org>
Subject: dev_queue_xmit() to now non-existing device
Date: Sat, 2 Aug 2008 21:38:28 +0930
Message-ID: <20080802213828.9dc4e53e.ipng@69706e6720323030352d30312d31340a.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.mail.adnap.net.au ([203.6.132.66]:51385 "EHLO
	smtp2.mail.adnap.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753254AbYHBNRU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Aug 2008 09:17:20 -0400
Received: from 219-90-248-244.ip.adam.com.au ([219.90.248.244] helo=mail.nosense.org)
	by smtp2.mail.adnap.net.au with esmtp (Exim 4.69 (FreeBSD))
	(envelope-from <ipng@69706e6720323030352d30312d31340a.nosense.org>)
	id 1KPFjP-0000vZ-Cx
	for netdev@vger.kernel.org; Sat, 02 Aug 2008 21:27:07 +0930
Received: from ubu.nosense.org (localhost.localdomain [127.0.0.1])
	by mail.nosense.org (Postfix) with SMTP id DF6A737B0E
	for <netdev@vger.kernel.org>; Sat,  2 Aug 2008 21:38:28 +0930 (CST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've been working on a simple request/reply protocol implementation, which can queue replies to requests for up to 30 seconds. I've used a private SKB queue to hold the pending replies, and kernel timers to send them off. This has all been working fine under normal circumstances. I've been developing against my Arch Linux 2.6.25 kernel.

I've now been thinking about how to deal with queued SKB replies that when dev_queue_xmit() is called for them, the outgoing skb->dev has gone, as the network card driver has been removed. With a delay of up to 30 seconds, I think the likelyhood of this happening could be fairly high, compared to other users of dev_queue_xmit() in the kernel.

My initial thought was that dev_queue_xmit() would check if the outgoing device exists when it is called, however, at least in 2.6.25, that doesn't seem to be the case. In the source, I can't seem to see a check to see if the supplied skb->dev is currently valid.

The other thing I tried was to have a routine called as part of the NETDEV_UNREGISTER notifier event that would delete any pending replies for the device that has now been removed. I failed at that (with a corresponding kernel panic of course), however it might have been because I hadn't shutdown any kernel timers that would be servicing the outgoing queue. However, thinking about it more, I realised that I'd probably need to wait until after the next firing of the kernel timer (even if I bring it forward), and that kernel timer function would call dev_queue_xmit() for a now non-existing outgoing device anyway. So I don't think it really fully solves the problem.

I've looked around the source a fair bit, and can't seem to find an examples where this problem has been solved. There seem to be a lot of users of dev_queue_xmit(), however they all seem to just assume the device the SKB will use exists when it is called. For the examples of private SKB queues I've found, none of them seem to have any routines that deal with queued SKBs for interfaces that have now disappeared.

Has anybody got any suggestions or pointers to where this problem has been solved? 

ps. please CC me, as I'm not subscribed to netdev.

Thanks very much,
Mark.
