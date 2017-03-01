From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC v2 00/12] socket sendmsg MSG_ZEROCOPY
Date: Tue, 28 Feb 2017 22:28:45 -0500 (EST)
Message-ID: <20170228.222845.1863678335516061180.davem@davemloft.net>
References: <CALCETrU3tohXaoOTMi8J4FdTggGhvauHt12KyLFV=Q0FjiDNbg@mail.gmail.com>
        <CAF=yD-K_0zO3pMeXf-UKGTsD4sNOdyN9KJkUb5MnCO_J5pisrA@mail.gmail.com>
        <CALCETrXogADnqymxaoqt=F3rDMpOYQ0xy7audng=t-Rx1bxqbw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: willemdebruijn.kernel@gmail.com, mtk.manpages@gmail.com,
        netdev@vger.kernel.org, willemb@google.com,
        linux-api@vger.kernel.org
To: luto@amacapital.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58918 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751037AbdCAD3n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 22:29:43 -0500
In-Reply-To: <CALCETrXogADnqymxaoqt=F3rDMpOYQ0xy7audng=t-Rx1bxqbw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 28 Feb 2017 13:06:49 -0800

> On Tue, Feb 28, 2017 at 12:43 PM, Willem de Bruijn
> <willemdebruijn.kernel@gmail.com> wrote:
>> On Tue, Feb 28, 2017 at 2:46 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>>> On Mon, Feb 27, 2017 at 10:57 AM, Michael Kerrisk
>>> <mtk.manpages@gmail.com> wrote:
>>>> [CC += linux-api@vger.kernel.org]
>>>>
>>>> Hi Willem
>>>>
>>>
>>>>> On a send call with MSG_ZEROCOPY, the kernel pins the user pages and
>>>>> creates skbuff fragments directly from these pages. On tx completion,
>>>>> it notifies the socket owner that it is safe to modify memory by
>>>>> queuing a completion notification onto the socket error queue.
>>>
>>> What happens if the user writes to the pages while it's not safe?
>>>
>>> How about if you're writing to an interface or a route that has crypto
>>> involved and a malicious user can make the data change in the middle
>>> of a crypto operation, thus perhaps leaking the entire key?  (I
>>> wouldn't be at all surprised if a lot of provably secure AEAD
>>> constructions are entirely compromised if an attacker can get the
>>> ciphertext and tag computed from a message that changed during the
>>> computation.
>>
>> Operations that read or write payload, such as this crypto example,
>> but also ebpf in tc or iptables, for instance, demand a deep copy using
>> skb_copy_ubufs before the operation.
>>
>> This blacklist approach requires caution, but these paths should be
>> few and countable. It is not possible to predict at the socket layer
>> whether a packet will encounter any such operation, so white-listing
>> a subset of end-to-end paths is not practical.
> 
> How about hardware that malfunctions if the packet changes out from
> under it?  A whitelist seems quite a bit safer.

These device are already choking, because as I stated this can already
be done via sendfile().

Networking card wise this isn't an issue, chips bring the entire packet
into their FIFO, compute checksums on the fly mid-stream, and then write
the 16-bit checksum field before starting to write the packet onto the
wire.

I think this is completely a non-issue, and we thought about this right
from the start when sendfile() support was added nearly two decades ago.
If network cards from back then didn't crap out in this situation I
think the ones out there now are probably ok.
