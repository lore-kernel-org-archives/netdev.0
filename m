From: Florian Westphal <fw@strlen.de>
Subject: Re: [RFC 1/3] tcp: randomize tcp timestamp offsets for each
 connection
Date: Fri, 26 Aug 2016 01:46:57 +0200
Message-ID: <20160825234657.GA13469@breakpoint.cc>
References: <1471524527-10029-1-git-send-email-fw@strlen.de>
 <1471524527-10029-2-git-send-email-fw@strlen.de>
 <1472162771.14381.167.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:52102 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1758836AbcHYXrM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 19:47:12 -0400
Content-Disposition: inline
In-Reply-To: <1472162771.14381.167.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2016-08-18 at 14:48 +0200, Florian Westphal wrote:
> > commit ceaa1fef65a7c2e ("tcp: adding a per-socket timestamp offset")
> > added the main infrastructure that is needed for per-connection
> > randomization, in particular writing/reading the on-wire tcp header
> > format takes the offset into account so rest of stack can use normal
> > tcp_time_stamp (jiffies).

[..]

> > +secure_tcpv6_sequence_number(const __be32 *saddr, const __be32 *daddr,
> > +			     __be16 sport, __be16 dport)
> >  {
> >  	u32 secret[MD5_MESSAGE_BYTES / 4];
> >  	u32 hash[MD5_DIGEST_WORDS];
> > +	struct secure_tcp_seq seq;
> >  	u32 i;
> >  
> >  	net_secret_init();
> > @@ -58,7 +60,9 @@ __u32 secure_tcpv6_sequence_number(const __be32 *saddr, const __be32 *daddr,
> >  
> >  	md5_transform(hash, secret);
> >  
> > -	return seq_scale(hash[0]);
> > +	seq.seq = seq_scale(hash[0]);
> > +	seq.tsoff = hash[1];
> > +	return seq;
> >  }
> 
> 
> I am not a super fan of this "struct secure_tcp_seq" being returned by
> functions. This adds unnecessary overhead.
>
> I would instead add a "u32 *ts_off" parameter, as you already did for
> tcp_v4_init_sequence()
>
> Patch on top of yours :
[..]

Looks great, I squashed it into my working branch.

Wrt. making randomization optional:

Would you go for another sysctl or should I just change
secure_tcpvX_sequence_number to check for tcp_timestamps == 2 mode?

	*tsoff  = sysctl_tcp_timestamps == 2 ? hash[1] : 0;

Could also use a static key but I don't think its worth it vs. md5 cost.
What do you think?

Thanks,
Florian
