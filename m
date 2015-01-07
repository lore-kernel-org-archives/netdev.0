From: Rahul Sharma <rsharma@arista.com>
Subject: Re: [PATCH net] ipv6: Prevent ipv6_find_hdr() from returning ENOENT
 for valid non-first fragments
Date: Wed, 7 Jan 2015 11:11:17 +0530
Message-ID: <CAFB3abwKpR1VqZXUrsexqveAZrA2LTSmTe8a=-H7z2HjAptjwA@mail.gmail.com>
References: <CAFB3abzYNYqtzd_n+Ym0Lo=DYbV0HPU=Tqw=stALNnu188hMKQ@mail.gmail.com>
	<20150106224706.GA7416@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150106224706.GA7416@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pablo,

On Wed, Jan 7, 2015 at 4:17 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> On Wed, Jan 07, 2015 at 03:03:20AM +0530, Rahul Sharma wrote:
>> ipv6_find_hdr() currently assumes that the next-header field in the
>> fragment header of the non-first fragment is the "protocol number of
>> the last header" (here last header excludes any extension header
>> protocol numbers ) which is incorrect as per RFC2460. The next-header
>> value is the first header of the fragmentable part of the original
>> packet (which can be extension header as well).
>> This can create reassembly problems. For example: Fragmented
>> authenticated OSPFv3 packets (where AH header is inserted before the
>> protocol header). For the second fragment, the next header value in
>> the fragment header will be NEXTHDR_AUTH which is correct but
>> ipv6_find_hdr will return ENOENT since AH is an extension header
>> resulting in second fragment getting dropped. This check for the
>> presence of non-extension header needs to be removed.
>>
>> Signed-off-by: Rahul Sharma <rsharma@arista.com>
>> ---
>> --- linux-3.18.1/net/ipv6/exthdrs_core.c.orig   2015-01-06
>> 10:25:36.411419863 -0800
>> +++ linux-3.18.1/net/ipv6/exthdrs_core.c        2015-01-06
>> 10:51:45.819364986 -0800
>> @@ -171,10 +171,11 @@ EXPORT_SYMBOL_GPL(ipv6_find_tlv);
>>   * If the first fragment doesn't contain the final protocol header or
>>   * NEXTHDR_NONE it is considered invalid.
>>   *
>> - * Note that non-1st fragment is special case that "the protocol number
>> - * of last header" is "next header" field in Fragment header. In this case,
>> - * *offset is meaningless and fragment offset is stored in *fragoff if fragoff
>> - * isn't NULL.
>> + * Note that non-1st fragment is special case that "the protocol number of the
>> + * first header of the fragmentable part of the original packet" is
>> + * "next header" field in the Fragment header. In this case, *offset is
>> + * meaningless and fragment offset is stored in *fragoff if fragoff isn't
>> + * NULL.
>>   *
>>   * if flags is not NULL and it's a fragment, then the frag flag
>>   * IP6_FH_F_FRAG will be set. If it's an AH header, the
>> @@ -250,9 +251,7 @@ int ipv6_find_hdr(const struct sk_buff *
>>
>>                         _frag_off = ntohs(*fp) & ~0x7;
>>                         if (_frag_off) {
>> -                               if (target < 0 &&
>> -                                   ((!ipv6_ext_hdr(hp->nexthdr)) ||
>
> This check assumes that the following headers cannot show up in the
> fragmented part of the IPv6 packet:
>
>  12 bool ipv6_ext_hdr(u8 nexthdr)
>  13 {
>  14         /*
>  15          * find out if nexthdr is an extension header or a protocol
>  16          */
>  17         return   (nexthdr == NEXTHDR_HOP)       ||
>  18                  (nexthdr == NEXTHDR_ROUTING)   ||
>  19                  (nexthdr == NEXTHDR_FRAGMENT)  ||
>  20                  (nexthdr == NEXTHDR_AUTH)      ||
>  21                  (nexthdr == NEXTHDR_NONE)      ||
>  22                  (nexthdr == NEXTHDR_DEST);
>
>> -                                    hp->nexthdr == NEXTHDR_NONE)) {
>> +                               if (target < 0) {
>>                                         if (fragoff)
>>                                                 *fragoff = _frag_off;
>>                                         return hp->nexthdr;
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

I think this is incorrect. Authentication header shows up in the
fragmentable part of the original IPv6 packet. So, for the non-first
fragments the next-header field value can be NEXTHDR_AUTH.

Thanks
