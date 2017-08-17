From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH 1/6] bridge: learn dst metadata in FDB
Date: Thu, 17 Aug 2017 14:10:20 +0200
Message-ID: <20170817121020.GL773745@eidolon>
References: <20170816170202.456851-1-equinox@diac24.net>
 <20170816170202.456851-2-equinox@diac24.net>
 <1fbaa432-6241-fad0-5407-8b87abb965ae@cumulusnetworks.com>
 <20170817110324.GK773745@eidolon>
 <4d4c8d17-1e0b-b78f-983b-e419e153b2bf@cumulusnetworks.com>
 <d4265b8d-93bb-630f-8d39-5eb0a3a259b8@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Lamparter <equinox@diac24.net>, netdev@vger.kernel.org,
        amine.kherbouche@6wind.com, roopa@cumulusnetworks.com,
        stephen@networkplumber.org,
        "bridge@lists.linux-foundation.org"
        <bridge@lists.linux-foundation.org>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eidolon.nox.tf ([185.142.180.128]:49066 "EHLO eidolon.nox.tf"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752668AbdHQMKX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 08:10:23 -0400
Content-Disposition: inline
In-Reply-To: <d4265b8d-93bb-630f-8d39-5eb0a3a259b8@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 17, 2017 at 02:51:12PM +0300, Nikolay Aleksandrov wrote:
> On 17/08/17 14:39, Nikolay Aleksandrov wrote:
> > On 17/08/17 14:03, David Lamparter wrote:
> >> On Wed, Aug 16, 2017 at 11:38:06PM +0300, Nikolay Aleksandrov wrote:
[cut]
> >>> and hitting the fast path for everyone in a few different places for a
> >>> feature that the majority will not use does not sound acceptable to
> >>> me. We've been trying hard to optimize it, trying to avoid additional
> >>> cache lines, removing tests and keeping special cases to a minimum. 
> >>
> >> skb->dst is on the same cacheline as skb->len.
> >> fdb->md_dst is on the same cacheline as fdb->dst.
> >> Both will be 0 in a lot of cases, so this should be two null checks on
> >> data that is hot in the cache.  Are you sure this is an actual problem?
> >>
> > 
> > Sure - no, I haven't benchmarked it, but I don't see skb->len being on
> > the same cache line as _skb_refdst assuming 64 byte cache lines.
> 
> I should've been clearer - that obviously depends on the kernel config, but
> in order for them to be in the same line you need to disable either one of 
> conntrack, bridge_netfilter or xfrm, these are almost always enabled (at
> least in all major distributions).

Did I miscount somewhere?  This is what I counted:
offs    size
00      16      next/prev/other union bits
16      8       sk
24      8       dev
32	32      cb (first 32 bytes)
---- boundary @ 64
64      16      cb (last 16 bytes)
80      8       _skb_refdst
88      8       destructor
96      8 (0)   sp
104     8 (0)   _nfct
112     8 (0)   nf_bridge
120     4       len
124     4       data_len
---- boundary @ 128
128     2       mac_len
130     2       hdr_len


-David
