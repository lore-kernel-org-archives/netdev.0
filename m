From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: XDP redirect measurements, gotchas and tracepoints
Date: Wed, 23 Aug 2017 10:29:37 +0200
Message-ID: <20170823102937.79a9c4ed@redhat.com>
References: <20170821212506.1cb0d5d6@redhat.com>
        <CACKFLimAF9OYwz8EqG=1-N40hWuA-8C8k8ut0oFKYdduvZOxHA@mail.gmail.com>
        <599C7530.2010405@gmail.com>
        <1503426617.2434.5.camel@intel.com>
        <CACKFLimMWLto4FRxNE3tzrO5MU+p67J7wu=n1nmg0t8QGYjgrA@mail.gmail.com>
        <CAKgT0Uf=ZfVeK-wtvNxSyGEVZ3UseUOHiP3ZOg-SrzmqsR=LtQ@mail.gmail.com>
        <CACKFLinJ0N7b8Xhq4ZoHdB80uXp_MU_vVyzZa7Dq11XrXsvDbw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
        "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
        "john.fastabend@gmail.com" <john.fastabend@gmail.com>,
        "pstaszewski@itcare.pl" <pstaszewski@itcare.pl>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xdp-newbies@vger.kernel.org" <xdp-newbies@vger.kernel.org>,
        "andy@greyhouse.net" <andy@greyhouse.net>,
        "borkmann@iogearbox.net" <borkmann@iogearbox.net>,
        brouer@redhat.com
To: Michael Chan <michael.chan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45404 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753630AbdHWI3p (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Aug 2017 04:29:45 -0400
In-Reply-To: <CACKFLinJ0N7b8Xhq4ZoHdB80uXp_MU_vVyzZa7Dq11XrXsvDbw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 Aug 2017 23:59:05 -0700
Michael Chan <michael.chan@broadcom.com> wrote:

> On Tue, Aug 22, 2017 at 6:06 PM, Alexander Duyck
> <alexander.duyck@gmail.com> wrote:
> > On Tue, Aug 22, 2017 at 1:04 PM, Michael Chan <michael.chan@broadcom.com> wrote:  
> >>
> >> Right, but it's conceivable to add an API to "return" the buffer to
> >> the input device, right?

Yes, I would really like to see an API like this.

> >
> > You could, it is just added complexity. "just free the buffer" in
> > ixgbe usually just amounts to one atomic operation to decrement the
> > total page count since page recycling is already implemented in the
> > driver. You still would have to unmap the buffer regardless of if you
> > were recycling it or not so all you would save is 1.000015259 atomic
> > operations per packet. The fraction is because once every 64K uses we
> > have to bulk update the count on the page.
> >  
> 
> If the buffer is returned to the input device, the input device can
> keep the DMA mapping.  All it needs to do is to dma_sync it back to
> the input device when the buffer is returned.

Yes, exactly, return to the input device. I really think we should
work on a solution where we can keep the DMA mapping around.  We have
an opportunity here to make ndo_xdp_xmit TX queues use a specialized
page return call, to achieve this. (I imagine other arch's have a high
DMA overhead than Intel)

I'm not sure how the API should look.  The ixgbe recycle mechanism and
splitting the page (into two packets) actually complicates things, and
tie us into a page-refcnt based model.  We could get around this by
each driver implementing a page-return-callback, that allow us to
return the page to the input device?  Then, drivers implementing the
1-packet-per-page can simply check/read the page-refcnt, and if it is
"1" DMA-sync and reuse it in the RX queue.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
