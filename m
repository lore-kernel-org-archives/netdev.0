From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Thu, 10 May 2007 13:21:50 -0700
Message-ID: <adazm4czaxt.fsf@cisco.com>
References: <20070510145351.1390.77066.sendpatchset@K50wks273871wss.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:10506 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755635AbXEJUVv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 16:21:51 -0400
In-Reply-To: <20070510145351.1390.77066.sendpatchset@K50wks273871wss.in.ibm.com> (Krishna Kumar's message of "Thu, 10 May 2007 20:23:51 +0530")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is pretty interesting to me for IP-over-InfiniBand, for a couple
of reasons.  First of all, I can push multiple send requests to the
underlying adapter in one go, which saves taking and dropping the same
lock and also probably allows fewer MMIO writes for doorbells.

However the second reason this is useful is actually more
interesting.  Right now we request a send completion interrupt for
every packet we send because most current IB adapters don't really
have very good interrupt mitigation features.  If we don't signal a
send completion for every packet, then we might run into a situation
where we don't get a completion for the last packet that gets sent and
end up stalling the interface because the stack never gives us another
packet to send.  However, if I have a whole queue of packets passed to
my xmit routine, then I only have to request a completion for the last
packet in the list, which could potentially cut down on interrupts and
completion processing a lot.

 - R.
