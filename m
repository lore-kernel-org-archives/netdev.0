From: Florian Westphal <fw@strlen.de>
Subject: Re: Revert 462fb2af9788a82a534f8184abfde31574e1cfa0 (bridge :
 Sanitize skb before it enters the IP stack)
Date: Mon, 19 May 2014 19:09:15 +0200
Message-ID: <20140519170915.GB24523@breakpoint.cc>
References: <537621AC.1060409@davidnewall.com>
 <5379FFFD.1050705@davidnewall.com>
 <20140519140119.GA24523@breakpoint.cc>
 <537A12EA.4060604@davidnewall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: David Newall <davidn@davidnewall.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <537A12EA.4060604@davidnewall.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Newall <davidn@davidnewall.com> wrote:

[ remove lkml and cc nf-devel ]

> I tried to persevere with the commit: I recalculated checksum, which
> left routes and times improperly updated in options.  Then I tried
> calling ip_forward_options, which looks like it would correctly
> update RR and TS (not to mention checksum)m but that bombed because
> skb_rtable returned NULL.

Yes.  bridge<->netfilter wiring is pure duct tape.
The glue code will set up a fake rtable for the skb after the
prerouting hook. [ see br_nf_pre_routing_finish() ].

> I see three ways to progress:
> 
> 1. Possibly call ip_forward_option, but that requires somebody who
> understands this code to help;
> 2. Just recalculate the checksum, leaving crap in the options; or
> 3. Revert the commit.

I think none of these are an option.

I fail to understand why a bridge should honor/modifiy IP options.

For the 'local delivery' case the ip stack will take care of
option parsing, for forwarding it should be sufficient to do
sanity tests (for netfilters sake).

>From a quick glance, it should be sufficient to edit
br_parse_ip_options() and remove everything after

memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));

A 2nd step would be to move a copy of ip_options_compile()
into br_netfilter.c and trim it down to only validate the
ipv4 header without modifying it.

If there is a good reason to mangle options on a bridge i'd
prefer a comment explaining them...
