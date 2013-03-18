From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next v2] packet: packet fanout rollover during socket overload
Date: Mon, 18 Mar 2013 19:16:04 -0400
Message-ID: <CA+FuTSfvG8Wzn9Q12V-wsuzXv-VTth4NEkX1kFqdFKe42A-+9Q@mail.gmail.com>
References: <1363648051-5976-1-git-send-email-willemb@google.com> <1363648249.21184.11.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f177.google.com ([74.125.82.177]:40464 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751676Ab3CRXQg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 19:16:36 -0400
Received: by mail-we0-f177.google.com with SMTP id d7so5363634wer.22
        for <netdev@vger.kernel.org>; Mon, 18 Mar 2013 16:16:35 -0700 (PDT)
In-Reply-To: <1363648249.21184.11.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 18, 2013 at 7:10 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2013-03-18 at 19:07 -0400, Willem de Bruijn wrote:
>> Minimize packet drop in a fanout group. If one socket is full,
>> roll over packets to another from the group. Maintain flow
>> affinity during normal load using an rxhash fanout policy, while
>> dispersing unexpected traffic storms that hit a single cpu, such
>> as spoofed-source DoS flows. Rollover breaks affinity for flows
>> arriving at saturated sockets during those conditions.
>>
>> The patch adds a fanout policy ROLLOVER that rotates between sockets,
>> filling each socket before moving to the next. It also adds a fanout
>> flag ROLLOVER. If passed along with any other fanout policy, the
>> primary policy is applied until the chosen socket is full. Then,
>> rollover selects another socket, to delay packet drop until the
>> entire system is saturated.
>>
>> Probing sockets is not free. Selecting the last used socket, as
>> rollover does, is a greedy approach that maximizes chance of
>> success, at the cost of extreme load imbalance. In practice, with
>> sufficiently long queues to absorb bursts, sockets are drained in
>> parallel and load balance looks uniform in `top`.
>>
>> To avoid contention, scales counters with number of sockets and
>> accesses them lockfree. Values are bounds checked to ensure
>> correctness.
>>
>> Tested using an application with 9 threads pinned to CPUs, one socket
>> per thread and sufficient busywork per packet operation to limits each
>> thread to handling 32 Kpps. When sent 500 Kpps single UDP stream
>> packets, a FANOUT_CPU setup processes 32 Kpps in total without this
>> patch, 270 Kpps with the patch. Tested with read() and with a packet
>> ring (V1).
>>
>> Signed-off-by: Willem de Bruijn <willemb@google.com>
>> ---
>
> Reviewed-by: Eric Dumazet <edumazet@google.com>

Thanks Eric.

I need to rebase the patch once more to have it apply cleanly.

>
>
