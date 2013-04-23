From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next v4] rps: selective flow shedding during softnet overflow
Date: Tue, 23 Apr 2013 17:37:34 -0400
Message-ID: <CA+FuTSfaZNEN-_pZzUZen4qUy1R1oPah_YX-jik45ho+kNsN_A@mail.gmail.com>
References: <CA+FuTSfPjrzVqKj-jrzivM_mBP47Dtkuj2P+bJ3VwWTscoT=yA@mail.gmail.com>
 <1366749094-5982-1-git-send-email-willemb@google.com> <20130423142333.15479dfa@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:55842 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754099Ab3DWViF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 17:38:05 -0400
Received: by mail-ie0-f174.google.com with SMTP id 10so1296993ied.33
        for <netdev@vger.kernel.org>; Tue, 23 Apr 2013 14:38:04 -0700 (PDT)
In-Reply-To: <20130423142333.15479dfa@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 23, 2013 at 5:23 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Tue, 23 Apr 2013 16:31:34 -0400
> Willem de Bruijn <willemb@google.com> wrote:
>
>> A cpu executing the network receive path sheds packets when its input
>> queue grows to netdev_max_backlog. A single high rate flow (such as a
>> spoofed source DoS) can exceed a single cpu processing rate and will
>> degrade throughput of other flows hashed onto the same cpu.
>>
>> This patch adds a more fine grained hashtable. If the netdev backlog
>> is above a threshold, IRQ cpus track the ratio of total traffic of
>> each flow (using 4096 buckets, configurable). The ratio is measured
>> by counting the number of packets per flow over the last 256 packets
>> from the source cpu. Any flow that occupies a large fraction of this
>> (set at 50%) will see packet drop while above the threshold.
>>
>> Tested:
>> Setup is a muli-threaded UDP echo server with network rx IRQ on cpu0,
>> kernel receive (RPS) on cpu0 and application threads on cpus 2--7
>> each handling 20k req/s. Throughput halves when hit with a 400 kpps
>> antagonist storm. With this patch applied, antagonist overload is
>> dropped and the server processes its complete load.
>>
>> The patch is effective when kernel receive processing is the
>> bottleneck. The above RPS scenario is a extreme, but the same is
>> reached with RFS and sufficient kernel processing (iptables, packet
>> socket tap, ..).
>>
>> Signed-off-by: Willem de Bruijn <willemb@google.com>
>
> What about just having a smarter ingress qdisc?

For filtering, as this patch does, that is an interesting approach.
Similar to fanout rollover, I plan to evaluate redistributing overload
instead of filtering. That is not acceptable for TCP connections due
to reordering, but may help protect against tcp synfloods, where most
packets will not be part of a connection and can be processed by any
cpu with cycles to spare. Moreover, all this processing takes place in
the kernel receive path, so this is the type of workload that is most
likely to overflow the input_pkt_queue. Frankly, that part requires
much more evaluation to see if it makes sense, which is why I had not
made this context clear: filtering by itself is already useful. An
ingress qdisc is worth evaluating in that regard.
