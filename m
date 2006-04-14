From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [PATCH 05/10] e1000: Update truesize with the length of the
 packet for packet split
Date: Fri, 14 Apr 2006 15:13:31 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.63.0604141448520.2116@jbrandeb-desk.amr.corp.intel.com>
References: <20060414183423.3461.32772.stgit@gitlost.site>
 <20060414183658.3461.4975.stgit@gitlost.site> <4440112D.9040509@pobox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org,
	"Miller, David" <davem@davemloft.net>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeff" <Jeffrey.t.kirsher@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr20.intel.com ([134.134.136.19]:27795 "EHLO
	orsfmr005.jf.intel.com") by vger.kernel.org with ESMTP
	id S1030209AbWDNWOX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Apr 2006 18:14:23 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4440112D.9040509@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 14 Apr 2006, Jeff Garzik wrote:

> Kok, Auke wrote:
> > diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
> > index 2cc9955..7ba1b16 100644
> > --- a/drivers/net/e1000/e1000_main.c
> > +++ b/drivers/net/e1000/e1000_main.c
> > @@ -3770,6 +3770,7 @@ e1000_clean_rx_irq_ps(struct e1000_adapt
> >  			ps_page->ps_page[j] = NULL;
> >  			skb->len += length;
> >  			skb->data_len += length;
> > +			skb->truesize += length;
> 
> NAK, apparently this is adding a very serious bug.

I'm surprised to hear you say that, here's why.  Elaboration would be 
helpful.

our packet split receive code uses two buffers for any packet the hardware 
was able to split.  The skb when we're receiving say a 1000 byte IPv4 
packet looks like this:

skb -
    |- len = total packet length (1000)
    |- data_len = length in skb_shinfo(skb)->frags[] (1000 - headerlen)
    |- truesize = size of originally allocated skb (128 + NET_IP_ALIGN)

in this case, the stack is using truesize to figure out how much to charge 
the receive socket for our receive packet.

in the old driver we indicate a packet with truesize = 128, which has 1000 
bytes of data in it.  normally (for everyone using only an skb) skb->len, 
and skb->truesize are updated by skb_put();  In this case we don't have a 
kernel support function for adding length to skb->len *and* to 
skb->truesize when chaining on something to ->frags[]

see the code in do_tcp_sendpages for an example of what the stack does in 
setting up a packet for transmit using frags[]

it updates skb->len and skb->truesize, right after calling 
skb_fill_page_desc, just like we do.

interesingly, that is right where sk_forward_alloc is modified (but thats 
another thread)

Jesse
