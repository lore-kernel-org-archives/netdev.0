From: David Howells <dhowells@redhat.com>
Subject: Transforming code to using ICMP packet accessors
Date: Thu, 26 Apr 2007 12:23:39 +0100
Message-ID: <11959.1177586619@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:53998 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754644AbXDZLXn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 07:23:43 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l3QBNgGK017608
	for <netdev@vger.kernel.org>; Thu, 26 Apr 2007 07:23:42 -0400
Received: from warthog.cambridge.redhat.com (warthog.cambridge.redhat.com [172.16.18.73])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l3QBNfru022136
	for <netdev@vger.kernel.org>; Thu, 26 Apr 2007 07:23:41 -0400
Received: from redhat.com (localhost.localdomain [127.0.0.1])
	by warthog.cambridge.redhat.com (8.13.8/8.13.8) with ESMTP id l3QBNdIM011960
	for <netdev@vger.kernel.org>; Thu, 26 Apr 2007 12:23:40 +0100
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


How do I convert:

	addr = *(__be32 *)(skb->nh.raw + serr->addr_offset);

to use the ICMP accessor macros now that skb->nh is no longer available?  I
was using this to pluck an address out of the ICMP packet payload, but 

	void rxrpc_UDP_error_report(struct sock *sk)
	{
		struct sock_exterr_skb *serr;
	...
		struct sk_buff *skb;
		__be32 addr;
		__be16 port;
	...

		skb = skb_dequeue(&sk->sk_error_queue);
		if (!skb) {
			_leave("UDP socket errqueue empty");
			return;
		}
	...

		serr = SKB_EXT_ERR(skb);
		addr = *(__be32 *)(skb->nh.raw + serr->addr_offset);
		port = serr->port;

		_net("Rx UDP Error from "NIPQUAD_FMT":%hu",
		     NIPQUAD(addr), ntohs(port));
	...
	}

Should I do this?:

	addr = *(__be32 *)(skb_network_header(skb) + serr->addr_offset);

David
