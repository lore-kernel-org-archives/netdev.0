From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 net-next] virtio: Fix affinity for #VCPUs != #queue
 pairs
Date: Wed, 15 Feb 2017 17:23:25 +0200
Message-ID: <20170214224033-mutt-send-email-mst@kernel.org>
References: <20170207181506.36668-1-serebrin@google.com>
 <20170208205353-mutt-send-email-mst@kernel.org>
 <CAN+hb0Uen4_bHR8xPcUNZG+aKPYAvjUqY1Z4PA7WWOs7jG3EAA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christian Borntraeger <borntraeger@de.ibm.com>,
        netdev@vger.kernel.org, Jason Wang <jasowang@redhat.com>,
        David Miller <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>,
        Venkatesh Srinivas <venkateshs@google.com>,
        "Jon Olson (Google Drive)" <jonolson@google.com>,
        willemdebruijn.kernel@gmail.com, Rick Jones <rick.jones2@hpe.com>,
        James Mattson <jmattson@google.com>,
        linux-s390 <linux-s390@vger.kernel.org>,
        "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>
To: Benjamin Serebrin <serebrin@google.com>
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAN+hb0Uen4_bHR8xPcUNZG+aKPYAvjUqY1Z4PA7WWOs7jG3EAA@mail.gmail.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 14, 2017 at 11:17:41AM -0800, Benjamin Serebrin wrote:
> On Wed, Feb 8, 2017 at 11:37 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
> 
> > IIRC irqbalance will bail out and avoid touching affinity
> > if you set affinity from driver.  Breaking that's not nice.
> > Pls correct me if I'm wrong.
> 
> 
> I believe you're right that irqbalance will leave the affinity alone.
> 
> Irqbalance has had changes that may or may not be in the versions bundled with
> various guests, and I don't have a definitive cross-correlation of irqbalance
> version to guest version.  But in the existing code, the driver does
> set affinity for #VCPUs==#queues, so that's been happening anyway.

Right but only for the case where we are very sure we are doing the
right thing, so we don't need any help from irqbalance.

> The (original) intention of this patch was to extend the existing behavior
> to the case where we limit queue counts, to avoid the surprising discontinuity
> when #VCPU != #queues.
> 
> It's not obvious that it's wrong to cause irqbalance to leave these
> queues alone:  Generally you want the interrupt to come to the core that
> caused the work, to have cache locality and avoid lock contention.
> Doing fancier things is outside the scope of this patch.

Doing fancier things like trying to balance the load would be in scope
for irqbalance so I think you need to find a way to supply default
affinity without disabling irqbalance.

> > Doesn't look like this will handle the case of num cpus < num queues well.
> 
> I believe it's correct.  The first #VCPUs queues will have one bit set in their
> xps mask, and the remaining queues have no bits set.  That means each VCPU uses
> its own assigned TX queue (and the TX interrupt comes back to that VCPU).
>
> Thanks again for the review!
> Ben
