From: Chema Gonzalez <chema@google.com>
Subject: Re: [PATCH] filter: added BPF random opcode
Date: Wed, 16 Apr 2014 17:19:57 -0700
Message-ID: <CA+ZOOTPs8cpjqttv2DxU14GGZF1zETnN74_0t0KVjTZV2uY3nQ@mail.gmail.com>
References: <1397585816-1267-1-git-send-email-chema@google.com>
	<CAMEtUuw3-LEuwJ2cAQ+F-tu_-wzy4HK4ZteAuJpYfY9hW66+FA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:41092 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753240AbaDQAT6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2014 20:19:58 -0400
Received: by mail-ob0-f181.google.com with SMTP id gq1so3329610obb.40
        for <netdev@vger.kernel.org>; Wed, 16 Apr 2014 17:19:58 -0700 (PDT)
In-Reply-To: <CAMEtUuw3-LEuwJ2cAQ+F-tu_-wzy4HK4ZteAuJpYfY9hW66+FA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 15, 2014 at 11:24 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> On Tue, Apr 15, 2014 at 11:16 AM, Chema Gonzalez <chema@google.com> wrote:
>> This should allow random packet sampling.
>
> I think commit log should have more than one line,
> especially for the new feature that affects uapi
I will beef it up in the next version (this time I'll wait for the
net-next window to open).

> In particular I don't find the reason of moving random
> packet sampling into kernel to be that great.
> pcap cannot receive them quickly enough anyway,
> so there are drops already.
> Just randomly pick packets that reached the user space.
> Why add this to the kernel? I don't see how it can improve accuracy.
The main use I see for this is random packet sampling. If you're
getting packet drops in pcap, you definitely want the kernel to do the
sampling. Sampling the packets that survived all the way through
userspace instead of the packets that arrived to the nic is biased.

The new message will be:

"""
filter: added BPF random opcode

Added a new ancillary load (bpf call in eBPF parlance) that produces
a 32-bit random number. We are implementing it as an ancillary load
(instead of an ISA opcode) because (a) it is simpler, (b) allows easy
JITing, and (c) seems more in line with generic ISAs that do not have
"get a random number" as a instruction, but as an OS call.

The main use for this ancillary load is to perform random packet sampling.
"""

> At the same time I think the extension technic itself is nice and clean :)
> The call approach is definitely how we envisioned it to be used.
> Right now we have only x86-64 jit that is waiting for net-next to be opened,
> but this extension will be automatically jit-ed due to 'call approach'. Nice.
>
> When you post patch revision please add vN tag.
I will.

>> +/* note that this only generates 32-bit random numbers */
>> +static u64 __skb_get_random(u64 ctx, u64 A, u64 X, u64 r4, u64 r5)
>
> function name is misleading. It has nothing to do with 'skb'. Please
> drop that prefix.
I renamed the function "__get_random_u32".

>> +{
>> +       return (u64)prandom_u32();
>
> we have 64-bit registers now, so would be nice to generalize it to 64-bit random
> since 8/16/32 can be made with bpf_and operation.
> but I don't see how to cleanly do it yet, so I guess the current form is fine.
>
> I like the approach, but would be nice to hear better justification
> for extending uapi.

-Chema
