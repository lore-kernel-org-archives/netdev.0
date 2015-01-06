From: Rahul Sharma <rsharma@arista.com>
Subject: Re: Possible BUG in ipv6_find_hdr function for fragmented packets
Date: Wed, 7 Jan 2015 03:13:12 +0530
Message-ID: <CAFB3abz06ROw=FQzkpifq-ymQM-paSKPnDLmKdHo-MQgmRxTWg@mail.gmail.com>
References: <CAFB3abyNNpMbX-XbJbVRNr98ns3w7VqEveiRqg2S__DrvZjT3Q@mail.gmail.com>
	<1420551094.32369.34.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:43338 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932536AbbAFVnO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 16:43:14 -0500
Received: by mail-wi0-f179.google.com with SMTP id ex7so360056wid.12
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 13:43:12 -0800 (PST)
In-Reply-To: <1420551094.32369.34.camel@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hannes

On Tue, Jan 6, 2015 at 7:01 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Hi Rahul,
>
> On Mi, 2014-12-31 at 12:33 +0530, Rahul Sharma wrote:
>> I have observed a problem when I added an AH header before protocol
>> header (OSPFv3) while implementing authentication support for OSPFv3.
>>
>> Problem: Fragmented packets which include authentication header don't
>> get reassembled in the kernel. This was because ipv6_find_hdr returns
>> ENOENT for the non-first fragment since AH is an extension header.
>>
>> Firstly, this comment  "Note that non-1st fragment is special case
>> that "the protocol number of last header" is "next header" field in
>> Fragment header" ('last header' doesn't include AH or other extension
>> headers) before ipv6_find_hdr looks incorrect as per the description
>> of the fragmentation process in RFC2460. The rfc clearly states that
>> next header value in the fragments will be the first header of the
>> Fragmentable part of the original packet which could be AH (51) as in
>> our case.
>>
>> This code looks like a problem:
>> if (_frag_off) {
>> 253                                 if (target < 0 &&
>> 254                                     ((!ipv6_ext_hdr(hp->nexthdr)) ||
>> 255                                      hp->nexthdr == NEXTHDR_NONE)) {
>> 256                                         if (fragoff)
>> 257                                                 *fragoff = _frag_off;
>> 258                                         return hp->nexthdr;
>> 259                                 }
>> 260                                 return -ENOENT;
>> 261                         }
>>
>> For non-first fragments, the 'next header' in the fragment header
>> would *always* be AUTH (or whatever extension header is the first
>> header in first fragment). But the above code will keep on returning
>> ENOENT for the non-first fragment in such cases.
>>
>> Solution: I suggest we should get away with this check
>> ((!ipv6_ext_hdr(hp->nexthdr)) ||hp->nexthdr == NEXTHDR_NONE))  and
>> simply return hp->nexthdr if the _frag_off is non zero. I tested it on
>> my machine and it works. Adding an special case for NEXTHDR_AUTH also
>> works for me.
>
> The packets do get dropped in netfilter code? Do you have any idea were
> specifically?
>
> Your suggestion seems correct to me, can you provide a patch to fix
> this?
>
> Thanks,
> Hannes
>
>

Yes, the packets get dropped in the netfilter code. ip6table_raw_hook
was returning NF_DROP for the second fragment.
This was because of xt_action_param structure's hotdrop flag being set
to true for this fragment when ip6t_do_table tries to call
ip6_packet_match which in turn calls ipv6_find_hdr which was returning
ENOENT.

I have also emailed the patch.

Thanks
