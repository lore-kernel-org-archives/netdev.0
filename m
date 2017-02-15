From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 net-next] virtio: Fix affinity for #VCPUs != #queue
 pairs
Date: Wed, 15 Feb 2017 19:42:26 +0200
Message-ID: <20170215185413-mutt-send-email-mst@kernel.org>
References: <20170207181506.36668-1-serebrin@google.com>
 <20170208205353-mutt-send-email-mst@kernel.org>
 <CAN+hb0Uen4_bHR8xPcUNZG+aKPYAvjUqY1Z4PA7WWOs7jG3EAA@mail.gmail.com>
 <20170214225629-mutt-send-email-mst@kernel.org>
 <CAF=yD-La6wL16Ej0jGw1ztiKOGpWoaY86E3Qe4KmskrjczrC_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Serebrin <serebrin@google.com>,
        Christian Borntraeger <borntraeger@de.ibm.com>,
        Network Development <netdev@vger.kernel.org>,
        Jason Wang <jasowang@redhat.com>,
        David Miller <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>,
        Venkatesh Srinivas <venkateshs@google.com>,
        "Jon Olson (Google Drive)" <jonolson@google.com>,
        Rick Jones <rick.jones2@hpe.com>,
        James Mattson <jmattson@google.com>,
        linux-s390 <linux-s390@vger.kernel.org>,
        "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56098 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751317AbdBORm2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Feb 2017 12:42:28 -0500
Content-Disposition: inline
In-Reply-To: <CAF=yD-La6wL16Ej0jGw1ztiKOGpWoaY86E3Qe4KmskrjczrC_A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 15, 2017 at 08:50:34AM -0800, Willem de Bruijn wrote:
> On Tue, Feb 14, 2017 at 1:05 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
> > On Tue, Feb 14, 2017 at 11:17:41AM -0800, Benjamin Serebrin wrote:
> >> On Wed, Feb 8, 2017 at 11:37 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
> >>
> >> > IIRC irqbalance will bail out and avoid touching affinity
> >> > if you set affinity from driver.  Breaking that's not nice.
> >> > Pls correct me if I'm wrong.
> >>
> >>
> >> I believe you're right that irqbalance will leave the affinity alone.
> >>
> >> Irqbalance has had changes that may or may not be in the versions bundled with
> >> various guests, and I don't have a definitive cross-correlation of irqbalance
> >> version to guest version.  But in the existing code, the driver does
> >> set affinity for #VCPUs==#queues, so that's been happening anyway.
> >
> > Right - the idea being we load all CPUs equally so we don't
> > need help from irqbalance - hopefully packets will be spread
> > across queues in a balanced way.
> >
> > When we have less queues the load isn't balanced so we
> > definitely need something fancier to take into account
> > the overall system load.
> 
> For pure network load, assigning each txqueue IRQ exclusively
> to one of the cores that generates traffic on that queue is the
> optimal layout in terms of load spreading. Irqbalance does
> not have the XPS information to make this optimal decision.

Try to add hints for it?

> Overall system load affects this calculation both in the case of 1:1
> mapping uneven queue distribution. In both cases, irqbalance
> is hopefully smart enough to migrate other non-pinned IRQs to
> cpus with lower overall load.

Not if everyone starts inserting hacks like this one in code.

> > But why the first N cpus? That's more or less the same as assigning them
> > at random.
> 
> CPU selection is an interesting point. Spreading equally across numa
> nodes would be preferable over first N. Aside from that, the first N
> should work best to minimize the chance of hitting multiple
> hyperthreads on the same core -- if all architectures lay out
> hyperthreads in the same way as x86_64.

That's another problem with this patch. If you care about hyperthreads
you want an API to probe for that.

-- 
MST
