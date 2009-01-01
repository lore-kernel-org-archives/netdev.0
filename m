From: Mark Smith <ipng@69706e6720323030352d30312d31340a.nosense.org>
Subject: Correct use of NET_RX_SUCCESS, NET_RX_DROP or NET_RX_BAD?
Date: Thu, 1 Jan 2009 10:54:28 +1030
Message-ID: <20090101105428.91447b89.ipng@69706e6720323030352d30312d31340a.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.mail.adnap.net.au ([203.6.132.66]:58400 "EHLO
	smtp2.mail.adnap.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751836AbZAAAYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2008 19:24:47 -0500
Received: from 219-90-188-155.ip.adam.com.au ([219.90.188.155] helo=mail.nosense.org)
	by smtp2.mail.adnap.net.au with esmtp (Exim 4.69 (FreeBSD))
	(envelope-from <ipng@69706e6720323030352d30312d31340a.nosense.org>)
	id 1LIB3z-000CGo-S2
	for netdev@vger.kernel.org; Thu, 01 Jan 2009 10:35:23 +1030
Received: from ubu.nosense.org (localhost.localdomain [127.0.0.1])
	by mail.nosense.org (Postfix) with SMTP id ADF2727FC4
	for <netdev@vger.kernel.org>; Thu,  1 Jan 2009 10:54:28 +1030 (CST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm a bit confused as to when to return either NET_RX_SUCCESS or
NET_RX_DROP in a protocol rcv() function.

I've been following the use in IPv4's ip_rcv()/ip_rcv_finish()
routines. It seems that any time the incoming skb fails a test the
return is NET_RX_DROP e.g. from 2.6.28:

if (skb->pkt_type == PACKET_OTHERHOST)
                goto drop;

...

drop:
        kfree_skb(skb);
out:
        return NET_RX_DROP;


However, looking at protocol rcv functions for other protocols, such as
IPv6, IPX and CAN, it seems that they're returning NET_RX_SUCCESS in
the same or similar situations e.g. in ipv6_rcv():

        if (skb->pkt_type == PACKET_OTHERHOST) {
                kfree_skb(skb);
                return 0;
        }


where 0 corresponds to NET_RX_SUCCESS.

The comment in netdevice.h seems to suggest that these return values
are related to the kernel's internal congestion management. The
protocol I'm working on doesn't have any specific congestion condition,
the only thing that might indicate congestion is a failure of the
routine to create a new SKB for transmitting a packet in response to a
received one. So should I have my rcv() routine and all other routines
return NET_RX_SUCCESS, and return NET_RX_DROP if the kernel fails to
create a new SKB for a packet to be transmitted? It seems that
NET_RX_BAD - "/* packet dropped due to kernel error */" might also be a
correct alternative return for a failed SKB allocation.

Thanks,
Mark.
