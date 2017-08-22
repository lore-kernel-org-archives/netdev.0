From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: XDP redirect measurements, gotchas and tracepoints
Date: Tue, 22 Aug 2017 11:17:20 -0700
Message-ID: <599C7530.2010405@gmail.com>
References: <20170821212506.1cb0d5d6@redhat.com> <CACKFLimAF9OYwz8EqG=1-N40hWuA-8C8k8ut0oFKYdduvZOxHA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "xdp-newbies@vger.kernel.org" <xdp-newbies@vger.kernel.org>,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Andy Gospodarek <andy@greyhouse.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>,
        Alexander H Duyck <alexander.h.duyck@intel.com>
To: Michael Chan <michael.chan@broadcom.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:38273 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751289AbdHVSRm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 14:17:42 -0400
In-Reply-To: <CACKFLimAF9OYwz8EqG=1-N40hWuA-8C8k8ut0oFKYdduvZOxHA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/22/2017 11:02 AM, Michael Chan wrote:
> On Mon, Aug 21, 2017 at 12:25 PM, Jesper Dangaard Brouer
> <brouer@redhat.com> wrote:
>>
>> I'be been playing with the latest XDP_REDIRECT feature, that was
>> accepted in net-next (for ixgbe), see merge commit[1].
>>  [1] https://git.kernel.org/davem/net-next/c/6093ec2dc31
>>
> 
> Just catching on XDP_REDIRECT and I have a very basic question.  The
> ingress device passes the XDP buffer to the egress device for XDP
> redirect transmission.  When the egress device has transmitted the
> packet, is it supposed to just free the buffer?  Or is it supposed to
> be recycled?
> 
> In XDP_TX, the buffer is recycled back to the rx ring.
> 

With XDP_REDIRECT we must "just free the buffer" in ixgbe this means
page_frag_free() on the data. There is no way to know where the xdp
buffer came from it could be a different NIC for example.

However with how ixgbe is coded up recycling will work as long as
the memory is free'd before the driver ring tries to use it again. In
normal usage this should be the case. And if we are over-running a device
it doesn't really hurt to slow down the sender a bit.

I think this is a pretty good model, we could probably provide a set
of APIs for drivers to use so that we get some consistency across
vendors here, ala Jesper's page pool ideas.

(+Alex, for ixgbe details)

Thanks,
John
