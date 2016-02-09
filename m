From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net PATCH] net: Copy inner L3 and L4 headers as unaligned on GRE TEB
Date: Tue, 9 Feb 2016 16:36:06 +0100
Message-ID: <CAKgT0Ud--ruzbDWR2dK+2LY6uMXo8iRSE_6cwAw0eb0f4eC3cQ@mail.gmail.com>
References: <20160209141234.19305.82202.stgit@localhost.localdomain>
	<CALx6S34nhTqC71XqRtOfaeDwhXQQfpM2iQHiVvTGJhmpUMYuTw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:33492 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756449AbcBIPgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 10:36:07 -0500
Received: by mail-io0-f175.google.com with SMTP id f81so21004729iof.0
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2016 07:36:07 -0800 (PST)
In-Reply-To: <CALx6S34nhTqC71XqRtOfaeDwhXQQfpM2iQHiVvTGJhmpUMYuTw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 9, 2016 at 3:33 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Tue, Feb 9, 2016 at 3:14 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
>> This patch corrects the unaligned accesses seen on GRE TEB tunnels when
>> generating hash keys.  Specifically what this patch does is make it so that
>> we force the use of skb_copy_bits when the GRE inner headers will be
>> unaligned due to NET_IP_ALIGNED being a non-zero value.
>>
>> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
>> ---
>>
>> I don't have the ability to test it but this should fix flow dissector for
>> GRE TEB tunnels traffic seen on architectures that require network and
>> transport headers to be 4 byte aligned.
>>
>>  net/core/flow_dissector.c |    7 +++++++
>>  1 file changed, 7 insertions(+)
>>
>> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
>> index 699b2c415cb0..9c181ba7263e 100644
>> --- a/net/core/flow_dissector.c
>> +++ b/net/core/flow_dissector.c
>> @@ -402,6 +402,13 @@ ip_proto_again:
>>                                 goto out_bad;
>>                         proto = eth->h_proto;
>>                         nhoff += sizeof(*eth);
>> +
>> +                       /* Cap headers that we access via pointers at the
>> +                        * end of the Ethernet header as our maximum alignment
>> +                        * at that point is only 2 bytes.
>> +                        */
>> +                       if (NET_IP_ALIGN)
>> +                               hlen = nhoff;
>
> I think this should be:
>
> if (NET_IP_ALIGN)
>      goto out_good;
>

That is no good since we already updated proto with the inner header
protocol value.  I would prefer to parse the entire header and just
keep the behavior consistent between IP aligned and DMA aligned
systems.

The only change in behavior is that the reported header length from
the function eth_get_headlen will only pull to the end of the Ethernet
header since we are now only reporting the aligned IP header length.

Otherwise if we need to exit we should probably exit with "goto out_bad"

- Alex
