From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v2] filter: added BPF random opcode
Date: Mon, 21 Apr 2014 15:20:18 -0700
Message-ID: <CAMEtUuzBuK+82EvvSZmBTJtTJcTr0-r-AMOUNnYqF7aoQgtLdA@mail.gmail.com>
References: <1397585816-1267-1-git-send-email-chema@google.com>
	<1398097284-20528-1-git-send-email-chema@google.com>
	<CAMEtUuw=trzxSC9Dc+UAEU5HyHk1Ym3cW7L+7tmvOe2hzHmXMw@mail.gmail.com>
	<CA+ZOOTNnfUkqLT9wrmoHtP+-a5+7UzLvO0qeNjtknZX1K9kn3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Network Development <netdev@vger.kernel.org>
To: Chema Gonzalez <chema@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:45611 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754560AbaDUWUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 18:20:19 -0400
Received: by mail-wg0-f48.google.com with SMTP id l18so3192824wgh.7
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2014 15:20:19 -0700 (PDT)
In-Reply-To: <CA+ZOOTNnfUkqLT9wrmoHtP+-a5+7UzLvO0qeNjtknZX1K9kn3g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 21, 2014 at 2:54 PM, Chema Gonzalez <chema@google.com> wrote:
> On Mon, Apr 21, 2014 at 2:46 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>> as I was saying in the other thread, would be nice to see more
>> realistic example, since "icmp 1 in 4" can be done in user space...
>> What is the real problem being solved?
>> I suspect for true packet sampling you'd need to have the knowledge
>> of packet rate, potentially computing time delta within filter with
>> another extension?
>> The patch itself looks good to me.
> Random sampling. There's a huge performance penalty if you do this in
> user-space. You don't want to send all the packets to user-space to
> just get (e.g.) 1 in 1000 and discard all the others.

Of course.
Just 1 out of 4 example you gave wasn't very real.

> From http://www.icir.org/vern/papers/secondary-path-raid06.pdf:

Nice. Now I see where it's going :)
The article helps a lot.

Acked-by: Alexei Starovoitov <ast@plumgrid.com>

btw it's funny how different people think of similar things.
It seems to complete what you wanted in the article you'd need
table access from the filter.
Did you have a chance to look at my bpf table proposal?
It seems it will fit perfectly to your use case as well.

Here is the copy paste from the other thread:
-----
Similar basic interface I'm proposing to use for bpf tables.
Probably makes sense to drop 'bpf' prefix, since they're just
hash tables. Little to do with bpf.
Have a netlink API from user into kernel:
- create hash table (num_of_entries, key_size, value_size, id)
- dump table via netlink
- add/remove key/value pair
Some kernel module may use it to transfer the data between
kernel and userspace.
This can be a generic kernel/user data sharing facility.

Also let bpf programs do 'table_lookup/update', so that
filters can store interesting data.
--------
I've posted early bpf_table patches back in September...
Now in process of redoing them with cleaner interface.

Thanks

> When dealing with large volumes of network traffic, we can often
> derive significant
> benefit while minimizing the processing cost by employing sampling.
> Generally, this
> is done on either a per-packet or per-connection basis. BPF does not
> provide access
> to pseudo-random numbers, so applications have had to rely on proxies
> for random-
> ness in terms of network header fields with some semblance of entropy
> across packets
> (checksum and IP fragment identifier fields) or connections (ephemeral
> ports). These
> sometimes provide acceptable approximations to random sampling, but
> can also suffer
> from significant irregularities due to lack of entropy or aliasing;
> see [11] for an analysis.
>
> -Chema
