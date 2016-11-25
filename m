From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v2 3/5] virtio_net: Add XDP support
Date: Fri, 25 Nov 2016 13:24:03 -0800
Message-ID: <5838ABF3.8060308@gmail.com>
References: <20161120024710.19187.31037.stgit@john-Precision-Tower-5810>
 <20161120025033.19187.11082.stgit@john-Precision-Tower-5810>
 <20161122011638-mutt-send-email-mst@kernel.org> <58340157.8060103@gmail.com>
 <20161122165400-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, eric.dumazet@gmail.com, kubakici@wp.pl,
        shm@cumulusnetworks.com, davem@davemloft.net,
        alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        bblanco@plumgrid.com, john.r.fastabend@intel.com,
        brouer@redhat.com, tgraf@suug.ch
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34720 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751264AbcKYVZe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 16:25:34 -0500
Received: by mail-pf0-f195.google.com with SMTP id y68so3369222pfb.1
        for <netdev@vger.kernel.org>; Fri, 25 Nov 2016 13:24:35 -0800 (PST)
In-Reply-To: <20161122165400-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-11-22 06:58 AM, Michael S. Tsirkin wrote:
> On Tue, Nov 22, 2016 at 12:27:03AM -0800, John Fastabend wrote:
>> On 16-11-21 03:20 PM, Michael S. Tsirkin wrote:
>>> On Sat, Nov 19, 2016 at 06:50:33PM -0800, John Fastabend wrote:
>>>> From: Shrijeet Mukherjee <shrijeet@gmail.com>
>>>>
>>>> This adds XDP support to virtio_net. Some requirements must be
>>>> met for XDP to be enabled depending on the mode. First it will
>>>> only be supported with LRO disabled so that data is not pushed
>>>> across multiple buffers. The MTU must be less than a page size
>>>> to avoid having to handle XDP across multiple pages.
>>>>
>>>> If mergeable receive is enabled this first series only supports
>>>> the case where header and data are in the same buf which we can
>>>> check when a packet is received by looking at num_buf. If the
>>>> num_buf is greater than 1 and a XDP program is loaded the packet
>>>> is dropped and a warning is thrown. When any_header_sg is set this
>>>> does not happen and both header and data is put in a single buffer
>>>> as expected so we check this when XDP programs are loaded. Note I
>>>> have only tested this with Linux vhost backend.
>>>>
>>>> If big packets mode is enabled and MTU/LRO conditions above are
>>>> met then XDP is allowed.
>>>>
>>>> A follow on patch can be generated to solve the mergeable receive
>>>> case with num_bufs equal to 2. Buffers greater than two may not
>>>> be handled has easily.
>>>
>>>
>>> I would very much prefer support for other layouts without drops
>>> before merging this.
>>> header by itself can certainly be handled by skipping it.
>>> People wanted to use that e.g. for zero copy.
>>
>> OK fair enough I'll do this now rather than push it out.
>>

Hi Michael,

The header skip logic however complicates the xmit handling a fair
amount. Specifically when we release the buffers after xmit then
both the hdr and data portions need to be released which requires
some tracking.

Is the header split logic actually in use somewhere today? It looks
like its not being used in Linux case. And zero copy RX is currently as
best I can tell not supported anywhere so I would prefer not to
complicate the XDP path at the moment with a possible future feature.

>>>
>>> Anything else can be handled by copying the packet.

Any idea how to test this? At the moment I have some code to linearize
the data in all cases with more than a single buffer. But wasn't clear
to me which features I could negotiate with vhost/qemu to get more than
a single buffer in the receive path.

Thanks,
John
