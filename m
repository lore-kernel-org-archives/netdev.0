From: Rahul Sharma <rsharma@arista.com>
Subject: Possible BUG in ipv6_find_hdr function for fragmented packets
Date: Wed, 31 Dec 2014 12:33:03 +0530
Message-ID: <CAFB3abyNNpMbX-XbJbVRNr98ns3w7VqEveiRqg2S__DrvZjT3Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:45030 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750726AbaLaHDF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 02:03:05 -0500
Received: by mail-wg0-f45.google.com with SMTP id b13so21618175wgh.32
        for <netdev@vger.kernel.org>; Tue, 30 Dec 2014 23:03:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello netdev,

I have observed a problem when I added an AH header before protocol
header (OSPFv3) while implementing authentication support for OSPFv3.

Problem: Fragmented packets which include authentication header don't
get reassembled in the kernel. This was because ipv6_find_hdr returns
ENOENT for the non-first fragment since AH is an extension header.

Firstly, this comment  "Note that non-1st fragment is special case
that "the protocol number of last header" is "next header" field in
Fragment header" ('last header' doesn't include AH or other extension
headers) before ipv6_find_hdr looks incorrect as per the description
of the fragmentation process in RFC2460. The rfc clearly states that
next header value in the fragments will be the first header of the
Fragmentable part of the original packet which could be AH (51) as in
our case.

This code looks like a problem:
if (_frag_off) {
253                                 if (target < 0 &&
254                                     ((!ipv6_ext_hdr(hp->nexthdr)) ||
255                                      hp->nexthdr == NEXTHDR_NONE)) {
256                                         if (fragoff)
257                                                 *fragoff = _frag_off;
258                                         return hp->nexthdr;
259                                 }
260                                 return -ENOENT;
261                         }

For non-first fragments, the 'next header' in the fragment header
would *always* be AUTH (or whatever extension header is the first
header in first fragment). But the above code will keep on returning
ENOENT for the non-first fragment in such cases.

Solution: I suggest we should get away with this check
((!ipv6_ext_hdr(hp->nexthdr)) ||hp->nexthdr == NEXTHDR_NONE))  and
simply return hp->nexthdr if the _frag_off is non zero. I tested it on
my machine and it works. Adding an special case for NEXTHDR_AUTH also
works for me.

Thanks,
Rahul
