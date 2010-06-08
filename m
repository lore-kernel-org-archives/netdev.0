From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH v7 01/19] Add a new structure for skb buffer from
	external.
Date: Tue, 8 Jun 2010 15:27:44 +1000
Message-ID: <20100608052744.GA21547@gondor.apana.org.au>
References: <1275732899-5423-1-git-send-email-xiaohui.xin@intel.com> <20100606161348.427822fb@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xiaohui.xin@intel.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, jdike@linux.intel.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100606161348.427822fb@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 06, 2010 at 04:13:48PM -0700, Stephen Hemminger wrote:
> Still not sure this is a good idea for a couple of reasons:
> 
> 1. We already have lots of special cases with skb's (frags and fraglist),
>    and skb's travel through a lot of different parts of the kernel.  So any
>    new change like this creates lots of exposed points for new bugs. Look
>    at cases like MD5 TCP and netfilter, and forwarding these SKB's to ipsec
>    and ppp and ...
> 
> 2. SKB's can have infinite lifetime in the kernel. If these buffers come from
>    a fixed size pool in an external device, they can easily all get tied up
>    if you have a slow listener. What happens then?

I agree with Stephen on this.

FWIW I don't think we even need the external pages concept in
order to implement zero-copy receive (which I gather is the intent
here).

Here is one way to do it, simply construct a completely non-linear
packet in the driver, as you would if you were using the GRO frags
interface (grep for napi_gro_frags under drivers/net for examples).

This way you can transfer the entire contents of the packet without
copying through to the other side, provided that the host stack does
not modify the packet.

If the host side did modify the packet then we have to incur the
memory cost anyway.

IOW I think the only feature provided by the external pages
construct is allowing the skb->head area to be shared without
copying.  I'm claiming that this can be done by simply making
skb->head empty.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
