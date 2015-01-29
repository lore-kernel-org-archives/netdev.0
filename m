From: David L Stevens <david.stevens@oracle.com>
Subject: Re: [PATCHv2 net] sunvnet: set queue mapping when doing packet copies
Date: Thu, 29 Jan 2015 16:36:45 -0500
Message-ID: <54CAA7ED.5000100@oracle.com>
References: <54CA8D33.6020006@oracle.com> <1422563996.21689.26.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:39175 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751877AbbA2Vgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 16:36:50 -0500
In-Reply-To: <1422563996.21689.26.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 01/29/2015 03:39 PM, Eric Dumazet wrote:

> Sorry, but you should remove this test.
> 
> (TCP uses another destructor, not sock_wfree())
> 
> All sent packets will support these swap() operations,
> regardless of destructor.

In general the destructor should match the allocator, right? So it bothers me
here that we'd be replacing it in an skb allocated with alloc_and_align_skb(),
with an an arbitrary destructor from an skb NOT allocated with alloc_and_align_skb().
If it has a different destructor that does special handling related to the allocator,
it is the original skb, not the new one, that needs the old destructor. This TCP
accounting has less to do with the buffer destructor than with the freeing of the
contents of the buffer, but that isn't necessarily true for all destructors.

Checking for a known, specific destructor is less troubling, so I don't want
to remove the test entirely.

Since the concern here is specifically TCP flow control, do you think it's sufficient
to substitute tcp_wfree for the sock_wfree here?

							+-DLS
