From: Josh Hunt <johunt@akamai.com>
Subject: Re: [RFC PATCH] sock: add SO_RCVQUEUE_SIZE getsockopt
Date: Mon, 13 Mar 2017 18:34:41 -0500
Message-ID: <9f775c33-01f4-fbd8-4d4d-4ca67f0f6d3b@akamai.com>
References: <1489420786-19547-1-git-send-email-johunt@akamai.com>
 <CANn89iJ21dhirFW2OdNqHWfOgq-EieVMm5ou9pZ7g2oUz=+bfA@mail.gmail.com>
 <522a2e2d-c288-7019-3f12-2b624d6aa921@akamai.com>
 <20170313.123933.1813218797817423920.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, arnd@arndb.de, soheil@google.com,
        willemb@google.com, pabeni@redhat.com, linux-arch@vger.kernel.org,
        netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay08.akamai.com ([96.6.114.112]:54748 "EHLO
        prod-mail-xrelay08.akamai.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751243AbdCMXep (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 19:34:45 -0400
In-Reply-To: <20170313.123933.1813218797817423920.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/13/2017 02:39 PM, David Miller wrote:
> From: Josh Hunt <johunt@akamai.com>
> Date: Mon, 13 Mar 2017 12:38:39 -0500
>
>> On 03/13/2017 11:12 AM, Eric Dumazet wrote:
>>> On Mon, Mar 13, 2017 at 8:59 AM, Josh Hunt <johunt@akamai.com> wrote:
>>>> Allows application to read the amount of data sitting in the receive
>>>> queue.
>>>>
>>>> Signed-off-by: Josh Hunt <johunt@akamai.com>
>>>> ---
>>>>
>>>> A team here is looking for a way to get the amount of data in a UDP
>>>> socket's
>>>> receive queue. It seems like this should be SIOCINQ, but for UDP
>>>> sockets that
>>>> returns the size of the next pending datagram. I implemented the patch
>>>> below,
>>>> but am wondering if this is the right place for this change? I was
>>>> debating
>>>> between this or a new UDP ioctl.
>>>
>>> But what is the 'amount of data' exactly ?
>>> Number of packets, amount of bytes to read from these packets ?
>>
>> I meant bytes. I will clarify in the next version.
>
> As Eric is hinting, the calculation you are using doesn't represent
> this.
>
> You need to do something like walk the receive queue and add the
> skb->len values together.
>
> sk->sk_rmem_alloc is usually much larger than the sum of the skb->len
> values in the socket receive queue.  I don't see how this culmination
> of skb->truesize values is useful, whereas I can see how an application
> could want the summation of the skb->len values.
>

In this particular case they really do want to know total # of bytes in 
the receive queue, not the data bytes they can consume from an 
application pov. The kernel currently only exposes this value through 
netlink or /proc/net/udp from what I saw.

I believe Eric's suggestion in his previous mail was to export all of 
these meminfo metrics via a single socket option call similar to how its 
done in netlink. We could then use that for both call sites.

I agree that it would be useful to also have the data you and Eric are 
suggesting exposed somewhere, the total # of skb->len bytes sitting in 
the receive queue. I could add that as a second socket option.

Does this sound reasonable?

Josh
