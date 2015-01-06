From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Possible BUG in ipv6_find_hdr function for fragmented packets
Date: Tue, 06 Jan 2015 14:31:34 +0100
Message-ID: <1420551094.32369.34.camel@stressinduktion.org>
References: <CAFB3abyNNpMbX-XbJbVRNr98ns3w7VqEveiRqg2S__DrvZjT3Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Rahul Sharma <rsharma@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:53157 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753908AbbAFNhy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 08:37:54 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 02EE5208C1
	for <netdev@vger.kernel.org>; Tue,  6 Jan 2015 08:31:35 -0500 (EST)
In-Reply-To: <CAFB3abyNNpMbX-XbJbVRNr98ns3w7VqEveiRqg2S__DrvZjT3Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rahul,

On Mi, 2014-12-31 at 12:33 +0530, Rahul Sharma wrote:
> I have observed a problem when I added an AH header before protocol
> header (OSPFv3) while implementing authentication support for OSPFv3.
> 
> Problem: Fragmented packets which include authentication header don't
> get reassembled in the kernel. This was because ipv6_find_hdr returns
> ENOENT for the non-first fragment since AH is an extension header.
> 
> Firstly, this comment  "Note that non-1st fragment is special case
> that "the protocol number of last header" is "next header" field in
> Fragment header" ('last header' doesn't include AH or other extension
> headers) before ipv6_find_hdr looks incorrect as per the description
> of the fragmentation process in RFC2460. The rfc clearly states that
> next header value in the fragments will be the first header of the
> Fragmentable part of the original packet which could be AH (51) as in
> our case.
> 
> This code looks like a problem:
> if (_frag_off) {
> 253                                 if (target < 0 &&
> 254                                     ((!ipv6_ext_hdr(hp->nexthdr)) ||
> 255                                      hp->nexthdr == NEXTHDR_NONE)) {
> 256                                         if (fragoff)
> 257                                                 *fragoff = _frag_off;
> 258                                         return hp->nexthdr;
> 259                                 }
> 260                                 return -ENOENT;
> 261                         }
> 
> For non-first fragments, the 'next header' in the fragment header
> would *always* be AUTH (or whatever extension header is the first
> header in first fragment). But the above code will keep on returning
> ENOENT for the non-first fragment in such cases.
> 
> Solution: I suggest we should get away with this check
> ((!ipv6_ext_hdr(hp->nexthdr)) ||hp->nexthdr == NEXTHDR_NONE))  and
> simply return hp->nexthdr if the _frag_off is non zero. I tested it on
> my machine and it works. Adding an special case for NEXTHDR_AUTH also
> works for me.

The packets do get dropped in netfilter code? Do you have any idea were
specifically?

Your suggestion seems correct to me, can you provide a patch to fix
this?

Thanks,
Hannes
