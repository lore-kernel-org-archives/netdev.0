From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/5] soreuseport: infrastructure
Date: Tue, 15 Jan 2013 08:14:04 -0800
Message-ID: <1358266444.8744.5892.camel@edumazet-glaptop>
References: <alpine.DEB.2.00.1301141152130.3433@pokey.mtv.corp.google.com>
	 <20130115075323.64b2fdc7@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	davem@davemloft.net, netdev@markandruth.co.uk
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:52321 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754173Ab3AOQOK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 11:14:10 -0500
Received: by mail-pb0-f50.google.com with SMTP id wz7so126067pbc.37
        for <netdev@vger.kernel.org>; Tue, 15 Jan 2013 08:14:09 -0800 (PST)
In-Reply-To: <20130115075323.64b2fdc7@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-01-15 at 07:53 -0800, Stephen Hemminger wrote:
> On Mon, 14 Jan 2013 12:00:18 -0800 (PST)
> Tom Herbert <therbert@google.com> wrote:
> 
> > +/* Pseudo random number generator from numerical recipes. */
> > +static inline u32 next_pseudo_random32(u32 seed)
> > +{
> > +	return seed * 1664525 + 1013904223;
> > +}
> > +
> 
> Don't reimplement a pseudo random number generator, there already
> exists net_random() 

net_random() is way more expensive and not needed in this context.

If you have 32 listeners bound on the same port, we can call this 32
times per SYN message.

Initial seed is random enough (phash = inet_ehashfn(net, daddr,
hnum,saddr,sport)

Anyway, the full idea of distributing SYN using a random generator is
not the best one for a multi queue NIC, and/or if RPS/RFS is used.

Ideally, we should chose a target given by the current CPU number, in
case SYN messages are spread on all cpus or a set of cpus.

(same idea than PACKET_FANOUT_CPU in net/packet/af_packet.c)
