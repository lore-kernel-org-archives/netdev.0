From: Eyal Birger <eyal.birger@gmail.com>
Subject: Re: [PATCH net-next 4/7] net: packet: use skb->dev as storage for skb
 orig len instead of skb->cb[]
Date: Thu, 26 Feb 2015 20:55:34 +0200
Message-ID: <CAHsH6Gvr=g_htFbJfhu4aYbG+bKsF7QWZMBUfvZVZKSfrbKD8Q@mail.gmail.com>
References: <1424916612-744-1-git-send-email-eyal.birger@gmail.com>
	<1424916612-744-5-git-send-email-eyal.birger@gmail.com>
	<CA+FuTSfG+Se0L0tWdsj2+YHAcZRWLw2_qef6Q5xixwbQ_-OE8Q@mail.gmail.com>
	<CAHsH6GvDvcR9nGYRa10iZgc=iQC-5ypzq2jL2ixOnQJu4fbzQQ@mail.gmail.com>
	<CA+FuTSfNHsKjJPQZyp8pkohQM47sfFpv44=THk111+vKkZm_nA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	Marcel Holtmann <marcel@holtmann.org>,
	Network Development <netdev@vger.kernel.org>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f172.google.com ([209.85.160.172]:40901 "EHLO
	mail-yk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752991AbbBZSze (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 13:55:34 -0500
Received: by ykq142 with SMTP id 142so4973403ykq.7
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 10:55:34 -0800 (PST)
In-Reply-To: <CA+FuTSfNHsKjJPQZyp8pkohQM47sfFpv44=THk111+vKkZm_nA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 26, 2015 at 8:51 PM, Willem de Bruijn <willemb@google.com> wrote:
> On Thu, Feb 26, 2015 at 1:38 PM, Eyal Birger <eyal.birger@gmail.com> wrote:
>> Hi,
>>
>> On Thu, Feb 26, 2015 at 7:26 PM, Willem de Bruijn <willemb@google.com> wrote:
>>>
>>> Another option is to delay preparation of the full sockaddr_ll struct until
>>> when it's needed. It often is not used at all (if msg_name == NULL).
>>>
>>> sll_family, sll_protocol and sll_pkttype can be derived when needed
>>> in packet_recvmsg. The first two are the head of sockaddr_ll, so
>>> a shorter struct filled in in packet_rcv only from sll_ifindex onwards
>>> would save the 4B needed for origlen. Actually, a union is simpler:
>>>
>>> struct __packet_cb_sockaddr_ll {
>>>         union {
>>>                 struct {
>>>                         unsigned short  sll_family;
>>>                         __be16          sll_protocol;
>>>                  }
>>>                  unsigned int sll_origlen;
>>>         }
>>>     /* etc.. */
>>> };
>>>
>>> The family and protocol can just overwrite sll_origlen in packet_recvmsg
>>> before the memcpy into msg->msg_name.
>>>
>>
>> That's an interesting option.
>> My personal inclination is not to inline sockaddr_ll in the packet cb structure.
>
> It already is, isn't it?
>

I meant I prefer not to break out sockaddr_ll's individual fields in
packet_skb_cb.
Sorry for being ambiguous.

>> IMHO it would probably make sense to do it as part of your below suggestion.
>>
>>> Also interesting would be to avoid copying the address in the fast path
>>> as it may never be used, especially for long addresses (INFINIBAND_ALEN
>>> and FWNET_ALEN). From what I can tell, all but one header_ops.parse
>>> implementations return bytes from inside the packet, so could take an
>>> unsigned char ** as argument, store that pointer and postpone the
>>> memcpy to packet_recvmsg (handling skb_trim correctly). The exception is
>>> fwnet_header_parse, which would require some workaround.
>>
>> I think it may be interesting to pursue this option, though I don't
>> think it should
>> be part of this specific effort.
>
> Absolutely. This is a lot more work. Too much to fold into this patchset.
> I was more speculating in general. I may look into this at some point.
>
>>
>> Thanks!
>> Eyal.
