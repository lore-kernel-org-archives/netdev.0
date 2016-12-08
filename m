From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v5 0/6] XDP for virtio_net
Date: Thu, 8 Dec 2016 12:46:07 -0800
Message-ID: <5849C68F.7080707@gmail.com>
References: <20161207200139.28121.4811.stgit@john-Precision-Tower-5810>
 <20161208.141702.1346950420275854265.davem@davemloft.net>
 <20161208193814.GA1954@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, mst@redhat.com, shm@cumulusnetworks.com,
        tgraf@suug.ch, john.r.fastabend@intel.com, netdev@vger.kernel.org,
        brouer@redhat.com, "Michael S. Tsirkin" <mst@redhat.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35064 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752257AbcLHUq1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 15:46:27 -0500
Received: by mail-pg0-f67.google.com with SMTP id p66so27839143pga.2
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 12:46:26 -0800 (PST)
In-Reply-To: <20161208193814.GA1954@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-12-08 11:38 AM, Alexei Starovoitov wrote:
> On Thu, Dec 08, 2016 at 02:17:02PM -0500, David Miller wrote:
>> From: John Fastabend <john.fastabend@gmail.com>
>> Date: Wed, 07 Dec 2016 12:10:47 -0800
>>
>>> This implements virtio_net for the mergeable buffers and big_packet
>>> modes. I tested this with vhost_net running on qemu and did not see
>>> any issues. For testing num_buf > 1 I added a hack to vhost driver
>>> to only but 100 bytes per buffer.
>>  ...
>>
>> So where are we with this?

There is one possible issue with a hang that Michael pointed out. I can
either spin a v6 or if you pull this v5 series in I can post a bugfix
for it. I am not seeing the issue in practice XDP virtio has been up
and running on my box here for days without issue.

All the concerns below are really future XDP ideas and unrelated to
this series or at least not required for this series to applied IMO.

>>
>> I'm not too thrilled with the idea of making XDP_TX optional or
>> something like that.  If someone enables XDP, there is a tradeoff.
>>
>> I also have reservations about the idea to make jumbo frames work
>> without giving XDP access to the whole packet.  If it wants to push or
>> pop a header, it might need to know the whole packet length.  How will
>> you pass that to the XDP program?
>>
>> Some kinds of encapsulation require trailers, thus preclusing access
>> to the entire packet precludes those kinds of transformations.
> 
> +1

This was sort of speculative on my side it is certainly not dependent on
the series here. I agree that we don't want to get into a state where
program X runs here and not there and only runs after doing magic
incantations, etc. I would only propose it if there is a clean way to
implement this.

> 
>> This is why we want simple, linear, buffer access for XDP.
>>
>> Even the most seemingly minor exception turns into a huge complicated
>> mess.
> 
> +1

Yep.

> 
> and from the other thread:
>>> Can't we disable XDP_TX somehow? Many people might only want RX drop,
>>> and extra queues are not always there.
>>>
>>
>> Alexei, Daniel, any thoughts on this?
> 
> I don't like it.
> 

OK alternatively we can make more queues available in virtio which might
be the better solution.

>> I know we were trying to claim some base level of feature support for
>> all XDP drivers. I am sympathetic to this argument though for DDOS we
>> do not need XDP_TX support. And virtio can become queue constrained
>> in some cases.
> 
> especially for ddos case doing lro/gro is not helpful.

Fair enough but disabling LRO to handle the case where you "might" get
a DDOS will hurt normal good traffic.

> I frankly don't see a use case where you'd want to steer a packet
> all the way into VM just to drop them there?

VM to VM traffic is my use case. And in that model we need XDP at the
virtio or vhost layer in case of malicious/broke/untrusted VM. I have
some vhost patches under development for when net-next opens up again.

> Without XDP_TX it's too crippled. adjust_head() won't be possible,

Just a nit but any reason not to support adjust_head and then XDP_PASS.
I don't have a use case in mind but also see no reason to preclude it.

> packet mangling would have to be disabled and so on.
> If xdp program doesn't see raw packet it can only parse the headers of
> this jumbo meta-packet and drop it, but for virtio it's really too late.
> ddos protection needs to be done at the earliest hw nic receive.

VM to VM traffic never touches hw nic.

> I think if driver claims xdp support it needs to support
> drop/pass/tx and adjust_head. For metadata passing up into stack from xdp
> we need adjust_head, for encap/decap we need it too. And lro is in the way
> of such transformations.
> We struggled a lot with cls_bpf due to all metadata inside skb that needs
> to be kept correct. Feeding non-raw packets into xdp is a rat hole.
> 

In summary:

I think its worth investigating getting LRO working but agree we can't
sacrifice any of the existing features or complicate the code to do it.
If the result of investigating is it can't be done then that is how it
is.

Jumbo frames I care very little about in reality so should not have
mentioned it.

Requiring XDP drivers to support all features is fine for me I can make
the virtio queue scheme a bit more flexible. Michael might have some
opinion on this though.

This series shouldn't be blocked by any of the above.

Thanks,
.John
