From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Get rxhash fixes and RFS support in tun
Date: Wed, 20 Nov 2013 17:12:32 -0800
Message-ID: <20131120171232.518c29bb@nehalam.linuxnetplumber.net>
References: <alpine.DEB.2.02.1311201220510.19725@tomh.mtv.corp.google.com>
	<20131120.190252.940036939480739452.davem@davemloft.net>
	<CA+mtBx91hSmYKrbUsPrtnXRjYR8QDGZ+GAAnMixauUqw9LFkiQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Jerry Chu <hkchu@google.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:47344 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753481Ab3KUBMg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 20:12:36 -0500
Received: by mail-pd0-f181.google.com with SMTP id p10so2772550pdj.12
        for <netdev@vger.kernel.org>; Wed, 20 Nov 2013 17:12:35 -0800 (PST)
In-Reply-To: <CA+mtBx91hSmYKrbUsPrtnXRjYR8QDGZ+GAAnMixauUqw9LFkiQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Nov 2013 17:09:01 -0800
Tom Herbert <therbert@google.com> wrote:

> On Wed, Nov 20, 2013 at 4:02 PM, David Miller <davem@davemloft.net> wrote:
> > From: Tom Herbert <therbert@google.com>
> > Date: Wed, 20 Nov 2013 12:25:48 -0800 (PST)
> >  
> >> This patch series fixes some subtle bugs in tun use of skb->rxhash, all
> >> rxhash hash not be cleared appropraitely, and adds support for tun flows
> >> to work with RFS.
> >>
> >> Testing, in particular with tun, hasn't been completed yet.  
> >
> > I think this needs to be reworked slightly.
> >
> > We really only have two boolean states:
> >
> > 1) Is the rxhash value in this SKB valid?
> >
> > 2) Is it a full L4 tuple hash?
> >
> > You are adding a "this is a SW computed hash" boolean state but I do
> > not think you should distinguish sw vs. hw especially.  If the
> > hardware computed the rxhash on a tunneled packet in the
> > pre-decapsulated state, we very much want to recompute it, in
> > software, upon tunnel decapsulation in ip_tunnel_core.c
> >  
> In either case it would be recomputed in SW if L4 hash was not set
> (i.e. no flow_dissector done finding L4).  If L4 hash is set, that
> should refer to the hash of the inner 4-tuple, so I don't think you'd
> need to recompute it.  I suppose there could be a case like encap in
> UDP where there are potentially two 4-tuples to deal with, but then
> the rxhash could just be cleared in decap to force recomputing hash
> over the inner packet-- even better I would hope that the trick of
> using outer source port to hold the hash of the inner packet (like in
> nvgre) is used so that the hash on the outer header is good for L4.
> 
> The primary reason for sw_rhash is to know whether it is a comparable
> value to match against that of a flow whose hash was computed in SW
> (tun case).

You can't guarantee that two hardware hashes from different devices
are the same.
