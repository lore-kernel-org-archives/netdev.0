From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next PATCH 5/5] virtio_net: XDP support for adjust_head
Date: Thu, 2 Feb 2017 20:02:55 -0800
Message-ID: <20170203040252.GA70530@ast-mbp.thefacebook.com>
References: <20170202231404.14366.64298.stgit@john-Precision-Tower-5810>
 <20170202232157.14366.63898.stgit@john-Precision-Tower-5810>
 <20170203043342-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>, kubakici@wp.pl,
        jasowang@redhat.com, ast@fb.com, john.r.fastabend@intel.com,
        netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34566 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752280AbdBCEC7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 23:02:59 -0500
Received: by mail-pg0-f67.google.com with SMTP id v184so810055pgv.1
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 20:02:59 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170203043342-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 03, 2017 at 05:42:54AM +0200, Michael S. Tsirkin wrote:
> On Thu, Feb 02, 2017 at 03:21:57PM -0800, John Fastabend wrote:
> > Add support for XDP adjust head by allocating a 256B header region
> > that XDP programs can grow into. This is only enabled when a XDP
> > program is loaded.
> > 
> > In order to ensure that we do not have to unwind queue headroom push
> > queue setup below bpf_prog_add. It reads better to do a prog ref
> > unwind vs another queue setup call.
> > 
> > At the moment this code must do a full reset to ensure old buffers
> > without headroom on program add or with headroom on program removal
> > are not used incorrectly in the datapath. Ideally we would only
> > have to disable/enable the RX queues being updated but there is no
> > API to do this at the moment in virtio so use the big hammer. In
> > practice it is likely not that big of a problem as this will only
> > happen when XDP is enabled/disabled changing programs does not
> > require the reset. There is some risk that the driver may either
> > have an allocation failure or for some reason fail to correctly
> > negotiate with the underlying backend in this case the driver will
> > be left uninitialized. I have not seen this ever happen on my test
> > systems and for what its worth this same failure case can occur
> > from probe and other contexts in virtio framework.
> > 
> > Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> 
> So I am currently testing what I consider a cleaner way to do this:
> 
> MERGEABLE_BUFFER_MIN_ALIGN_SHIFT by 1:
> -#define MERGEABLE_BUFFER_MIN_ALIGN_SHIFT ((PAGE_SHIFT + 1) / 2)
> +#define MERGEABLE_BUFFER_MIN_ALIGN_SHIFT (PAGE_SHIFT / 2 + 1)
> 
> and then we do not need a reset as we get a free bit to store presence
> of XDP buffer.

That does indeed sounds cleaner. Do you have an ETA for this?
Do you mind if John's set get applied for 4.11 while you're working
on a better version?
adjust_head support is a blocker for virtio+xdp adoption.
I think we need a compromise for 4.11.
