From: Anton Ivanov <anton.ivanov@cambridgegreys.com>
Subject: Re: BUG:af_packet fails to TX TSO frames
Date: Wed, 11 Oct 2017 16:54:09 +0100
Message-ID: <844d6e0f-6ee7-74bc-b961-faa77b240303@cambridgegreys.com>
References: <c3002d4f-62ff-1d0b-65fb-b366be45a6d8@cambridgegreys.com>
 <CAF=yD-+SxQTHxiU5Yi2f8dm6X1s7SA6PdkbeJP-K_9ZuTMAaTA@mail.gmail.com>
 <f2fe3f46-2ef1-0029-1c44-3576ca19d34b@cambridgegreys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ivanoab5.miniserver.com ([78.31.111.25]:36633 "EHLO
        www.kot-begemot.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755157AbdJKPyM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 11:54:12 -0400
In-Reply-To: <f2fe3f46-2ef1-0029-1c44-3576ca19d34b@cambridgegreys.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is that patch.

I rolled it back and immediately got it to work correctly on a Broadcom 
Tigon. I can test on all other scenarios, I have tried, I suspect it 
will come back alive on all of them.

I am going to try to trace it through and see exactly where it drops a 
skb which the card has no issues in accepting.

A.

On 10/11/17 14:50, Anton Ivanov wrote:
>
>
> On 10/11/17 14:39, Willem de Bruijn wrote:
>> On Wed, Oct 11, 2017 at 4:39 AM, Anton Ivanov
>> <anton.ivanov@cambridgegreys.com> wrote:
>>> Hi all,
>>>
>>> I am having an issue with af_packet.c
>>>
>>> It fails to transmit any TSO frame submitted via raw socket + vnet 
>>> headers.
>>> An identical frame is considered valid for tap.
>> This may be due to validation. As of commit 104ba78c9880 ("packet: on
>> direct_xmit, limit tso and csum to supported devices") the packet socket
>> code validates TSO packets and HW support in the direct_xmit path.
>
> I will look at it. I have tried with bridge+vEth (raw socket on the 
> vEth) and directly on a tg3 and e1000e. All of these should be tso 
> capable.
>
> CSUM definitely works in both cases, it is only TSO and only via raw 
> socket on TX which is refusing to work.
>
>>
>> Do you have a test program or packet (incl. vnet hdr) to reproduce this
>> with? I usually test this path with
>
> My test program at present is UML instance with my vector IO patches. 
> Latest version just went to the uml mailing list and can be pulled from
>
> http://foswiki.kot-begemot.co.uk/Main/EatYourOwnDogFoodOnUML
>
> I am going to dump one of the frames being produced and isolate it for 
> a standalone test case.
>
>>
>> https://github.com/wdebruij/kerneltools/blob/master/tests/psock_txring_vnet.c 
>>
>>
>>> The frames are generated out of legit linux skbufs (in UML) and vnet 
>>> headers
>>> work for checksumming on raw, so I should have the raw 
>>> initialization right.
>>>
>>> The header is supposedly parsed correctly and the newly formed skbuf 
>>> is sent
>>> to the device transmit routine (or enqueued) . I have debugged it as 
>>> far as
>>> it reaching the following line in packet_snd() (line 2592 in 4.13):
>>>
>>> err = po->xmit(skb);
>> That maps either on to packet_direct_xmit or dev_queue_xmit.
>
> I know. In my case it is direct_xmit as I have asked for QDISC bypass.
>
>>
>>> This returns NET_XMIT_DROP for any TSO capable device I tested.
>> You can also try
>>
>>    perf record -a -g -e skb:kfree_skb sleep 10
>>    perf report
>>
>> to see where these packets are dropped.
>
> Thanks, will try that.
>
>>
>>> They dislike
>>> the frame. Same frame is accepted by tap. I have went through the 
>>> header
>>> parsing and skb allocation code in both af_packet and tap several 
>>> times and
>>> I do not see any material difference (except the new zerocopy 
>>> stuff). So,
>>> frankly, I am stuck.
>>>
>>> Can someone help me to debug this. I do not see an easy way to debug 
>>> it, but
>>> this is not a part of the kernel I am familiar with. Is there a 
>>> suitable
>>> helper function to try to segment the frame and see exactly what is 
>>> wrong
>>> with it?
>>>
>>> Cc-ing DaveM as this has no specific maintainer so it falls under his
>>> umbrella remit.
>>>
>>> -- 
>>> Anton R. Ivanov
>>>
>>> Cambridge Greys Limited, England and Wales company No 10273661
>>> http://www.cambridgegreys.com/
>>>
>

-- 
Anton R. Ivanov

Cambridge Greys Limited, England and Wales company No 10273661
http://www.cambridgegreys.com/
