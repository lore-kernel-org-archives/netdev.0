From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [IPV4] UDP: Always checksum even if without socket
 filter
Date: Sat, 17 Nov 2007 16:09:26 -0800 (PST)
Message-ID: <20071117.160926.232024605.davem@davemloft.net>
References: <E1IssYb-0000KG-00@gondolin.me.apana.org.au>
	<473D19EC.6030903@cn.fujitsu.com>
	<p73bq9tau2x.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wangchen@cn.fujitsu.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34250
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752811AbXKRAJ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Nov 2007 19:09:27 -0500
In-Reply-To: <p73bq9tau2x.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <andi@firstfloor.org>
Date: Sat, 17 Nov 2007 14:18:46 +0100

> Wang Chen <wangchen@cn.fujitsu.com> writes:
> 
> > Herbert Xu said the following on 2007-11-16 12:11:
> >> Wang Chen <wangchen@cn.fujitsu.com> wrote:
> >>> So, I think the checksum in udp_queue_rcv_skb() actually does
> >>> the work, not that in udp_recvmsg() and udp_poll().
> >>>
> >>> If I am wrong, please point out.
> >> 
> >> We may have a bug in the accounting area.  Check the recent
> >> patch made to UDP/IPv6 which is probably needed here as well.
> >> 
> >
> > Like dave said, decrementing the InDataGrams in this case is an
> > option.
> > I will check the same place of UDP/IPv6.
> 
> And like Benny pointed out it's probably a bad idea because
> decrementing counters will be an unexpected ABI change for monitoring 
> programs who have no other way to detect overflow.

We could defer the increment until we check the checksum,
but that is likely to break even more things because people
(as Wang Chen did initially) will send a packet to some
port with an app that doesn't eat the packets, and expect the
InDatagrams counter to increase once the stack eats the packet.
But it won't until the application does the read.

All of our options suck, we just have to choose the least sucking one
and right now to me that's decrementing the counter as much as I
empathize with the SNMP application overflow detection issue.

