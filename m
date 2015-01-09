From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6: Prevent ipv6_find_hdr() from returning ENOENT for
 valid non-first fragments
Date: Fri, 09 Jan 2015 12:34:15 +0100
Message-ID: <1420803255.1978819.211762005.707EFFB9@webmail.messagingengine.com>
References: <CAFB3abzYNYqtzd_n+Ym0Lo=DYbV0HPU=Tqw=stALNnu188hMKQ@mail.gmail.com>
 <20150106224706.GA7416@salvia>
 <CAFB3abwKpR1VqZXUrsexqveAZrA2LTSmTe8a=-H7z2HjAptjwA@mail.gmail.com>
 <1420627396.26870.36.camel@stressinduktion.org>
 <20150108205328.GA3361@salvia>
 <1420756756.1755002.211556745.0418D128@webmail.messagingengine.com>
 <20150109000546.GA3488@salvia>
 <CAFB3abwrjp61LLOk3RWwXYEq1g4QZUC8OTKuO2cAr+GbV3n4rw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Rahul Sharma <rsharma@arista.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:48183 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932684AbbAILeQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 06:34:16 -0500
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id B6C45205A9
	for <netdev@vger.kernel.org>; Fri,  9 Jan 2015 06:34:15 -0500 (EST)
In-Reply-To: <CAFB3abwrjp61LLOk3RWwXYEq1g4QZUC8OTKuO2cAr+GbV3n4rw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, Jan 9, 2015, at 08:18, Rahul Sharma wrote:
> Hi Pablo,
> 
> On Fri, Jan 9, 2015 at 5:35 AM, Pablo Neira Ayuso <pablo@netfilter.org>
> wrote:
> > On Thu, Jan 08, 2015 at 11:39:16PM +0100, Hannes Frederic Sowa wrote:
> >> Hi Pablo,
> >>
> >> On Thu, Jan 8, 2015, at 21:53, Pablo Neira Ayuso wrote:
> >> > I'm afraid we cannot just get rid of that !ipv6_ext_hdr() check. The
> >> > ipv6_find_hdr() function is designed to return the transport protocol.
> >> > After the proposed change, it will return extension header numbers.
> >> > This will break existing ip6tables rulesets since the `-p' option
> >> > relies on this function to match the transport protocol.
> >> >
> >> > Note that the AH header is skipped (see code a bit below this
> >> > problematic fragmentation handling) so the follow up header after the
> >> > AH header is returned as the transport header.
> >> >
> >> > We can probably return the AH protocol number for non-1st fragments.
> >> > However, that would be something new to ip6tables since nobody has
> >> > ever seen packet matching `-p ah' rules. Thus, we restore control to
> >> > the user to allow this, but we would accept all kind of fragmented AH
> >> > traffic through the firewall since we cannot know what transport
> >> > protocol contains from non-1st fragments (unless I'm missing anything,
> >> > I need to have a closer look at this again tomorrow with fresher
> >> > mind).
> >>
> >> The code in question is guarded by (_frag_off != 0), so we are
> >> definitely processing a non-1st fragment currently. The -p match would
> >> happen at the time when the packet is reassembled and thus ipv6_find_hdr
> >> will find the real transport (final) header at this point (I hope I
> >> followed the code correctly here).
> >
> > Then, Rahul should get things working by modprobing nf_defrag_ipv6.
> 
> I already had nf_defrag_ipv6 installed when the issue occured. But I
> see ip6table_raw_hook returning NF_DROP for the second fragment.

That's what I expected. I think the change only affects hooks before
reassembly.
Pablo, do we care about that, otherwise we should start audit the
callers?

Bye,
Hannes
