From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next PATCH v2 3/5] virtio_net: Add XDP support
Date: Mon, 28 Nov 2016 05:36:05 +0200
Message-ID: <20161128052211-mutt-send-email-mst@kernel.org>
References: <20161120024710.19187.31037.stgit@john-Precision-Tower-5810>
 <20161120025033.19187.11082.stgit@john-Precision-Tower-5810>
 <20161122011638-mutt-send-email-mst@kernel.org>
 <58340157.8060103@gmail.com>
 <20161122165400-mutt-send-email-mst@kernel.org>
 <5838ABF3.8060308@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: daniel@iogearbox.net, eric.dumazet@gmail.com, kubakici@wp.pl,
        shm@cumulusnetworks.com, davem@davemloft.net,
        alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        bblanco@plumgrid.com, john.r.fastabend@intel.com,
        brouer@redhat.com, tgraf@suug.ch
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58158 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751311AbcK1DgK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Nov 2016 22:36:10 -0500
Content-Disposition: inline
In-Reply-To: <5838ABF3.8060308@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 25, 2016 at 01:24:03PM -0800, John Fastabend wrote:
> On 16-11-22 06:58 AM, Michael S. Tsirkin wrote:
> > On Tue, Nov 22, 2016 at 12:27:03AM -0800, John Fastabend wrote:
> >> On 16-11-21 03:20 PM, Michael S. Tsirkin wrote:
> >>> On Sat, Nov 19, 2016 at 06:50:33PM -0800, John Fastabend wrote:
> >>>> From: Shrijeet Mukherjee <shrijeet@gmail.com>
> >>>>
> >>>> This adds XDP support to virtio_net. Some requirements must be
> >>>> met for XDP to be enabled depending on the mode. First it will
> >>>> only be supported with LRO disabled so that data is not pushed
> >>>> across multiple buffers. The MTU must be less than a page size
> >>>> to avoid having to handle XDP across multiple pages.
> >>>>
> >>>> If mergeable receive is enabled this first series only supports
> >>>> the case where header and data are in the same buf which we can
> >>>> check when a packet is received by looking at num_buf. If the
> >>>> num_buf is greater than 1 and a XDP program is loaded the packet
> >>>> is dropped and a warning is thrown. When any_header_sg is set this
> >>>> does not happen and both header and data is put in a single buffer
> >>>> as expected so we check this when XDP programs are loaded. Note I
> >>>> have only tested this with Linux vhost backend.
> >>>>
> >>>> If big packets mode is enabled and MTU/LRO conditions above are
> >>>> met then XDP is allowed.
> >>>>
> >>>> A follow on patch can be generated to solve the mergeable receive
> >>>> case with num_bufs equal to 2. Buffers greater than two may not
> >>>> be handled has easily.
> >>>
> >>>
> >>> I would very much prefer support for other layouts without drops
> >>> before merging this.
> >>> header by itself can certainly be handled by skipping it.
> >>> People wanted to use that e.g. for zero copy.
> >>
> >> OK fair enough I'll do this now rather than push it out.
> >>
> 
> Hi Michael,
> 
> The header skip logic however complicates the xmit handling a fair
> amount. Specifically when we release the buffers after xmit then
> both the hdr and data portions need to be released which requires
> some tracking.

I thought you disable all checksum offloads so why not discard the
header immediately?

> Is the header split logic actually in use somewhere today? It looks
> like its not being used in Linux case. And zero copy RX is currently as
> best I can tell not supported anywhere so I would prefer not to
> complicate the XDP path at the moment with a possible future feature.

Well it's part of the documented interface so we never
know who implemented it. Normally if we want to make
restrictions we would do the reverse and add a feature.

We can do this easily, but I'd like to first look into
just handling all possible inputs as the spec asks us to.
I'm a bit too busy with other stuff next week but will
look into this a week after that if you don't beat me to it.

> >>>
> >>> Anything else can be handled by copying the packet.
> 
> Any idea how to test this? At the moment I have some code to linearize
> the data in all cases with more than a single buffer. But wasn't clear
> to me which features I could negotiate with vhost/qemu to get more than
> a single buffer in the receive path.
> 
> Thanks,
> John

ATM you need to hack qemu. Here's a hack to make header completely
separate.


diff --git a/hw/net/virtio-net.c b/hw/net/virtio-net.c
index b68c69d..4866144 100644
--- a/hw/net/virtio-net.c
+++ b/hw/net/virtio-net.c
@@ -1164,6 +1164,7 @@ static ssize_t virtio_net_receive(NetClientState *nc, const uint8_t *buf, size_t
             offset = n->host_hdr_len;
             total += n->guest_hdr_len;
             guest_offset = n->guest_hdr_len;
+            continue;
         } else {
             guest_offset = 0;
         }



here's one that should cap the 1st s/g to 100 bytes:


diff --git a/hw/net/virtio-net.c b/hw/net/virtio-net.c
index b68c69d..7943004 100644
--- a/hw/net/virtio-net.c
+++ b/hw/net/virtio-net.c
@@ -1164,6 +1164,7 @@ static ssize_t virtio_net_receive(NetClientState *nc, const uint8_t *buf, size_t
             offset = n->host_hdr_len;
             total += n->guest_hdr_len;
             guest_offset = n->guest_hdr_len;
+            sg.iov_len = MIN(sg.iov_len, 100);
         } else {
             guest_offset = 0;
         }
