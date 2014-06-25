From: Willem de Bruijn <willemb@google.com>
Subject: Re: net-timestamp: MSG_TSTAMP flags and bytestream support
Date: Wed, 25 Jun 2014 17:11:01 -0400
Message-ID: <CA+FuTScFL-J95Q6LLVcY2vtOZZZjN=GWVGpO-m2_ZjhYQ0oZLw@mail.gmail.com>
References: <1403624632-17327-1-git-send-email-willemb@google.com> <20140625073215.GB5566@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f172.google.com ([209.85.216.172]:51662 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753181AbaFYVLc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 17:11:32 -0400
Received: by mail-qc0-f172.google.com with SMTP id o8so2308934qcw.17
        for <netdev@vger.kernel.org>; Wed, 25 Jun 2014 14:11:32 -0700 (PDT)
In-Reply-To: <20140625073215.GB5566@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for taking a look, Richard. I will reply inline to the individual emails.

On Wed, Jun 25, 2014 at 3:32 AM, Richard Cochran
<richardcochran@gmail.com> wrote:
> On Tue, Jun 24, 2014 at 11:43:45AM -0400, Willem de Bruijn wrote:
>> This patchset extends socket timestamping in a number of related ways.
>> Most notably:
>>
>> 2 MSG_TSTAMP: request a single tx timestamp by passing a flag on send
>> 6 MSG_TSTAMP_ENQ: request a tx timestamp before traffic shaping.
>> 5 MSG_TSTAMP_ACK: request a tx timestamp after acknowledgements (TCP)
>> 4 TCP support for all three flags
>
> Can you tell us a bit about the use case?  It sounds like that this is
> for performance monitoring.

There are a couple of use cases: 24/7 sampled background monitoring,
detailed analysis of (tail) latency and application delivery
notifications, for example.

The MSG flags enable sampled measurement, both random sampling for the
first use case, and explicit communication of application data unit
delimiters to the kernel in the case of bytestreams. It is quite
common to embed discrete message protocols in a TCP stream to gain
reliability, flow control, ... In that case, only the send() call that
writes the final byte of a message will generate a timestamp that is
relevant to the application.

The new measurement points are indeed for performance monitoring,
specifically for debugging of tail latency root causes. Traffic
shaping, TCP pacing, byte queue limits and other queuing can affect
latency. Measurement points along the skb lifecycle help pinpoint the
specific root cause.

>> Each individual patch commit message gives more detail about the
>> specific feature.
>>
>> The other patches support the main feature:
>> 1 explicitly define the timestamp response API
>> 3 optionally avoid looping large packets onto the socket error queue.
>> 7 documentation and an example test.
>
> I think #2 and #3 could be improvements to the so_timestamping api.
>
> The others probably need their own, separate api. I can't imagine
> wanting to mix so_timestamping with these new tcp time stamps, but
> maybe you want to explain the expected scenario?

I think that a single coherent timestamping API would be better than a
fragmented experience with disjoint feature set. Both depend
internally on the same SKBTX_.. flags and the same skb_tstamp_tx
plumbing. I think that they should also implement the same set feature
set and return timestamps in the same format (where possible given
legacy API constraints).

This requires extensions to both to cover the other's feature set,
e.g., MSG_TSTAMP_HW and SOF_TIMESTAMPING_TX_ENQUEUE. But those are
minor changes. I'd be happy to work on those as follow on work.




>
> Thanks,
> Richard
