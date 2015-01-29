From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv2 net] sunvnet: set queue mapping when doing packet
 copies
Date: Thu, 29 Jan 2015 14:19:42 -0800
Message-ID: <1422569982.21689.36.camel@edumazet-glaptop2.roam.corp.google.com>
References: <54CA8D33.6020006@oracle.com>
	 <1422563996.21689.26.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54CAA7ED.5000100@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: David L Stevens <david.stevens@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:35098 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757263AbbA2WTp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 17:19:45 -0500
Received: by mail-ie0-f171.google.com with SMTP id tr6so552525ieb.2
        for <netdev@vger.kernel.org>; Thu, 29 Jan 2015 14:19:44 -0800 (PST)
In-Reply-To: <54CAA7ED.5000100@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-01-29 at 16:36 -0500, David L Stevens wrote:

> In general the destructor should match the allocator, right? So it bothers me
> here that we'd be replacing it in an skb allocated with alloc_and_align_skb(),
> with an an arbitrary destructor from an skb NOT allocated with alloc_and_align_skb().
> If it has a different destructor that does special handling related to the allocator,
> it is the original skb, not the new one, that needs the old destructor. This TCP
> accounting has less to do with the buffer destructor than with the freeing of the
> contents of the buffer, but that isn't necessarily true for all destructors.
> 
> Checking for a known, specific destructor is less troubling, so I don't want
> to remove the test entirely.
> 
> Since the concern here is specifically TCP flow control, do you think it's sufficient
> to substitute tcp_wfree for the sock_wfree here?

The concern is also for UDP.

Right now a single UDP flow can flood your network, even if application
or admin cared to set a low SO_SNDBUF.

I guess you can extend the test to sock_wfree and tcp_wfree, but :

You have to EXPORT_SYMBOL(tcp_wfree)

Add an #ifdef CONFIG_INET   (take a look at skb_orphan_partial())

Thanks
