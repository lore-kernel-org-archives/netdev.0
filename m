From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv3] ipv6: Enable enough of the code to handle GSO when
 disabled.
Date: Wed, 17 Oct 2012 21:33:59 +0200
Message-ID: <1350502439.26103.892.camel@edumazet-glaptop>
References: <1350488802-24071-1-git-send-email-vyasevic@redhat.com>
	 <1350490397.26103.647.camel@edumazet-glaptop> <507F02F1.5010501@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:50636 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757433Ab2JQTeC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2012 15:34:02 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr13so6588482wgb.1
        for <netdev@vger.kernel.org>; Wed, 17 Oct 2012 12:34:01 -0700 (PDT)
In-Reply-To: <507F02F1.5010501@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-10-17 at 15:11 -0400, Vlad Yasevich wrote:
> On 10/17/2012 12:13 PM, Eric Dumazet wrote:
> > On Wed, 2012-10-17 at 11:46 -0400, Vlad Yasevich wrote:
> >
> >> This patch attempts to solve this by enabling just enough code so GSO
> >> is correctly processed.  However, I should point out that if IPv6 is
> >> simply blacklisted or not built for the kernel, this problem will
> >> still persist.
> >
> > So I guess this should be done in a different way ?
> >
> > We currently use a single structure (struct packet_type) to hold
> > pointers to different methods. (The .func() field, and the gso/gro
> > stuff)
> >
> > We probably need to split it in two parts, and make one part linked into
> > kernel, even if CONFIG_IPV6=n, so that GRO/GSO is fully IPv4/IPv6
> > functional.
> 
> The thing about this approach is that if there are any other protocols 
> that could have to provide their own segmentation functionality, such 
> functionality would always have to be part of the kernel.  I wasn't sure 
> how much I liked that.

Well, an hypervisor probably has to handle IPv6, at least to a certain
extent.

Make this part a module of its own, or statically linked into vmlinux,
instead of adding some stubs in IPv6 'module'


> 
> >
> > By the way, do we really need a hash table for this ?
> > It seems we only have IPv4 (ETH_P_IP) and IPv6 (ETH_P_IPV6) to take care
> > of ?
> 
> Which hash are you talking about?  I didn't add any hashes.

I suspect you didnt really understood what I said then.

packet_type structures are hashed into ptype_base[]

struct list_head *head = &ptype_base[ntohs(type) & PTYPE_HASH_MASK];

Now let say we split the structure into 2 parts.

ptype_base[] would be used for pre GRO/GSO stuff (packet handlers)

So we would need to add a second hash for the GRO/GSO stuff.
