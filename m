From: Alex Williamson <alex.williamson@hp.com>
Subject: Re: [PATCH 4/4] virtio_net: Add a MAC filter table
Date: Wed, 14 Jan 2009 09:20:31 -0700
Message-ID: <1231950031.7109.307.camel@lappy>
References: <1231881800.9095.189.camel@bling>
	 <1231928112.4944.292.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, kvm <kvm@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Mark McLoughlin <markmc@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1231928112.4944.292.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2009-01-14 at 10:15 +0000, Mark McLoughlin wrote:
> On Tue, 2009-01-13 at 14:23 -0700, Alex Williamson wrote:
> > Number of entries configurable via module param.
> 
> Could do with some more details here, like explaining that it means the
> we no longer run the NIC in promiscuous mode and the guest only receives
> packets destined for it.

Yep, thanks.

> > +	else {
> > +		unsigned int entries;
> > +
> > +		entries = mac_entries = min(mac_entries,
> > +					(unsigned int)(PAGE_SIZE / ETH_ALEN));
> > +		if (virtnet_send_command(vi, VIRTIO_NET_CTRL_MAC_TABLE,
> > +					 VIRTIO_NET_CTRL_MAC_TABLE_ALLOC,
> > +					 &entries, sizeof(entries)))
> > +			mac_entries = 0;
> > +	}
> 
> Should have a warning here.

I agree.

> Also, no need for the extra variable or the case, is there?

Initially, that's what I thought too... but it doesn't work, I always
got 0 on the backend.  I assume it has something to do with the memory
segment mac_entries lives in as a static variable.

> >  	/* Initialize our empty receive and send queues. */
> >  	skb_queue_head_init(&vi->recv);
> > diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
> > index 80cd7d3..31235a0 100644
> > --- a/include/linux/virtio_net.h
> > +++ b/include/linux/virtio_net.h
> > @@ -60,4 +60,8 @@ struct virtio_net_hdr_mrg_rxbuf {
> >   #define VIRTIO_NET_CTRL_RX_MODE_PROMISC      0
> >   #define VIRTIO_NET_CTRL_RX_MODE_ALLMULTI     1
> >  
> > +#define VIRTIO_NET_CTRL_MAC_TABLE  1
> > + #define VIRTIO_NET_CTRL_MAC_TABLE_ALLOC      0
> > + #define VIRTIO_NET_CTRL_MAC_TABLE_SET        1
> 
> I'd prefer:
> 
> #define VIRTIO_NET_CMD_ALLOC_MAC_TABLE 1
> #define VIRTIO_NET_CMD_SET_MAC_TABLE   2

Hmm, I'm still leaning towards the class/cmd, which would allow the
backend to logically split class commands into sub-functions.  But i'd
be happy to rename these to VIRTIO_NET_CMD_...

> Also, could do with some comments here to note e.g.:
> 
>   - alloc before set
>   - subsequent allocs will fail
>   - table limited to PAGE_SIZE (hmm, who's PAGE_SIZE?)
>   - format of the table

Agree, thanks for the comments.

Alex

-- 
Alex Williamson                             HP Open Source & Linux Org.

