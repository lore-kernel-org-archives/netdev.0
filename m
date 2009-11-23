From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 1/1] Defer skb allocation for both mergeable buffers and big packets in virtio_net
Date: Tue, 24 Nov 2009 08:54:23 +1030
Message-ID: <200911240854.24054.rusty@rustcorp.com.au>
References: <1258697745.7416.20.camel@localhost.localdomain> <200911231138.30755.rusty@rustcorp.com.au> <1258992421.5022.19.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, Avi Kivity <avi@redhat.com>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, Hollis Blanchard <hollisb@us.ibm.com>
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:41453 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757006AbZKWWYW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2009 17:24:22 -0500
In-Reply-To: <1258992421.5022.19.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 Nov 2009 02:37:01 am Shirley Ma wrote:
> > > +             skb = (struct sk_buff *)buf;
> > This cast is unnecessary, but a comment would be nice:
> 
> Without this cast there is a compile warning. 

Hi Shirley,

   Looks like buf is a void *, so no cast should be necessary.  But I could
be reading the patch wrong.

> > However, I question whether making it 16 byte is the right thing: the
> > ethernet header is 14 bytes long, so don't we want 8 bytes of padding?
> 
> Because in QEMU it requires 10 bytes header in a separately, so one page
> is used to share between virtio_net_hdr header which is 10 bytes head
> and rest of data. So I put 6 bytes offset here between two buffers. I
> didn't look at the reason why a seperate buf is used for virtio_net_hdr
> in QEMU.

It's a qemu bug.  It insists the header be an element in the scatterlist by
itself.  Unfortunately we have to accommodate it.

However, there's no reason for the merged rxbuf and big packet layout to be
the same: for the big packet case you should layout as follows:

#define BIG_PACKET_PAD (NET_SKB_PAD - sizeof(struct virtio_net_hdr) + NET_IP_ALIGN)
struct big_packet_page {
	struct virtio_net_hdr hdr;
	char pad[BIG_PACKET_PAD];
	/* Actual packet data starts here */
	unsigned char data[PAGE_SIZE - BIG_PACKET_PAD - sizeof(struct virtio_net_hdr)];
};

Then use this type as the template for registering the sg list for the
big packet case.

> > I think you can move the memcpy outside the if, like so:
> > 
> >         memcpy(&hdr, p, hdr_len);
> 
> I didn't move it out, because num_buf = hdr->mhdr.num_buffers;

Yes, that has to stay inside, but the memcpy can move out.  It's just a bit
neater to have more common code.

Thanks,
Rusty.
