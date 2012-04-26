From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] allow skb->head to point/alias to first skb frag
Date: Thu, 26 Apr 2012 11:10:02 +0200
Message-ID: <1335431402.2775.24.camel@edumazet-glaptop>
References: <alpine.DEB.2.00.1204241131580.735@wel-95.cs.helsinki.fi>
	 <1335257803.5205.133.camel@edumazet-glaptop>
	 <1335427854.2775.15.camel@edumazet-glaptop>
	 <20120426.043623.1317043382565428400.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, rick.jones2@hp.com,
	netdev@vger.kernel.org, therbert@google.com, ncardwell@google.com,
	maze@google.com, ycheng@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:60161 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753180Ab2DZJKI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 05:10:08 -0400
Received: by eekc41 with SMTP id c41so524102eek.19
        for <netdev@vger.kernel.org>; Thu, 26 Apr 2012 02:10:07 -0700 (PDT)
In-Reply-To: <20120426.043623.1317043382565428400.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-26 at 04:36 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 26 Apr 2012 10:10:54 +0200
> 
> > Idea would have :
> > 
> > 1) struct sk_buff
> > 2) skb->head points to frag (aliasing, no memory allocation)
> > 3) frag of 2048 (or PAGE_SIZE/2 or PAGE_SIZE)
> 
> What would you set skb->data_len and skb->len to?
> 
> How would you handle tailroom?  We have the rule that you can't append
> to the tail of a fragmented SKB (I mean append, the way that IPSEC
> wants to write data to the end of an SKB when encrypting, for
> example).  This is only allowed on fully linear SKBs.
> 
> So, for this reason and others, you can't pretend that this new
> construction is linear in any way.  It would break a bunch of things.


The 'frag' would have a known size : 2048 bytes

But the end of it would be used by struct skb_shared_info

so data_len would be 0 in fact.

This would look like a regular linear skb.

Just a bit set in skb to say : Warning, skb->head was not kmalloced :
replace kfree(head) by put_page(...)

And this bit would be tested in GRO or tcp merge to 'upgrade' this
skb->head to proper page/frag
