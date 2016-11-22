From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v2 3/5] virtio_net: Add XDP support
Date: Tue, 22 Nov 2016 00:27:03 -0800
Message-ID: <58340157.8060103@gmail.com>
References: <20161120024710.19187.31037.stgit@john-Precision-Tower-5810>
 <20161120025033.19187.11082.stgit@john-Precision-Tower-5810>
 <20161122011638-mutt-send-email-mst@kernel.org>
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
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33029 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755568AbcKVI1g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 03:27:36 -0500
Received: by mail-pf0-f195.google.com with SMTP id 144so959711pfv.0
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 00:27:35 -0800 (PST)
In-Reply-To: <20161122011638-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-11-21 03:20 PM, Michael S. Tsirkin wrote:
> On Sat, Nov 19, 2016 at 06:50:33PM -0800, John Fastabend wrote:
>> From: Shrijeet Mukherjee <shrijeet@gmail.com>
>>
>> This adds XDP support to virtio_net. Some requirements must be
>> met for XDP to be enabled depending on the mode. First it will
>> only be supported with LRO disabled so that data is not pushed
>> across multiple buffers. The MTU must be less than a page size
>> to avoid having to handle XDP across multiple pages.
>>
>> If mergeable receive is enabled this first series only supports
>> the case where header and data are in the same buf which we can
>> check when a packet is received by looking at num_buf. If the
>> num_buf is greater than 1 and a XDP program is loaded the packet
>> is dropped and a warning is thrown. When any_header_sg is set this
>> does not happen and both header and data is put in a single buffer
>> as expected so we check this when XDP programs are loaded. Note I
>> have only tested this with Linux vhost backend.
>>
>> If big packets mode is enabled and MTU/LRO conditions above are
>> met then XDP is allowed.
>>
>> A follow on patch can be generated to solve the mergeable receive
>> case with num_bufs equal to 2. Buffers greater than two may not
>> be handled has easily.
> 
> 
> I would very much prefer support for other layouts without drops
> before merging this.
> header by itself can certainly be handled by skipping it.
> People wanted to use that e.g. for zero copy.

OK fair enough I'll do this now rather than push it out.

> 
> Anything else can be handled by copying the packet.

This though I'm not so sure about. The copy is going to be slow and
I wonder if someone could craft a packet to cause this if it could
be used to slow down a system.

Also I can't see what would cause this to happen. With mergeable
buffers and LRO off the num_bufs is either 1 or 2 depending on where
the header is. Otherwise with LRO off it should be in a single page.
At least this is the Linux vhost implementation, I guess other
implementation might meet spec but use num_buf > 2 or multiple pages
even in the non LRO case.

I tend to think dropping the packet out right is better than copying
it around. At very least if we do this we need to put in warnings so
users can see something is mis-configured.

.John
