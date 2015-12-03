From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ipsec impact on performance
Date: Thu, 03 Dec 2015 12:08:42 -0800
Message-ID: <1449173322.25029.13.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151201175953.GC21252@oracle.com>
	 <20151203.143328.1246663523839158336.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: sowmini.varadhan@oracle.com, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:34820 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753611AbbLCUPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 15:15:55 -0500
In-Reply-To: <20151203.143328.1246663523839158336.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-12-03 at 14:33 -0500, David Miller wrote:
> From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> Date: Tue, 1 Dec 2015 12:59:53 -0500
> 
> > I instrumented iperf with and without ipsec, just using esp-null, 
> > and 1 thread, to keep things simple. I'm seeing some pretty dismal 
> > performance numbers with ipsec, and trying to think of ways to
> > improve this. Here are my findings, please share feedback.
> 
> Doesn't skb_cow_data() contribute significantly to the ESP base cost,
> especially for TCP packets?
> 
> I mean, we're copying every TCP data frame.
> 
> If this is the case, even with GSO/whatever offloads, I expect that
> performance will be roughly halfed.

This reminds me this thing I noticed is that we (un)clone all xmit GRE
GSO packets because of following code in iptunnel_handle_offloads() :

        if (skb_is_gso(skb)) {
                err = skb_unclone(skb, GFP_ATOMIC);
                if (unlikely(err))
                        goto error;
                skb_shinfo(skb)->gso_type |= gso_type_mask;
                return skb;
        }

This is certainly something we should avoid, since we have ~1500 bytes
of payload in skb->head per TCP skb

Ideally, part of gso_type should belong to skb, not skb_shinfo(skb) :(
