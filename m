From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH net-next v2 2/6] 6lowpan: fix fragmentation on sending
 side
Date: Tue, 25 Feb 2014 02:21:57 +0100
Message-ID: <20140225012155.GA16712@omega>
References: <1393009142-1694-1-git-send-email-alex.aring@gmail.com>
 <1393009142-1694-3-git-send-email-alex.aring@gmail.com>
 <20140224.185213.1069306984692624378.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	martin.townsend@xsilon.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f42.google.com ([74.125.83.42]:35415 "EHLO
	mail-ee0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752212AbaBYBWE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 20:22:04 -0500
Received: by mail-ee0-f42.google.com with SMTP id e53so1986670eek.29
        for <netdev@vger.kernel.org>; Mon, 24 Feb 2014 17:22:03 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20140224.185213.1069306984692624378.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Mon, Feb 24, 2014 at 06:52:13PM -0500, David Miller wrote:
> From: Alexander Aring <alex.aring@gmail.com>
> Date: Fri, 21 Feb 2014 19:58:58 +0100
> 
> > +	err = lowpan_fragment_xmit(skb, head, header_length,
> > +				   frag_plen + lowpan_size, 0,
> > +				   LOWPAN_DISPATCH_FRAG1);
> >  	if (err) {
> >  		pr_debug("%s unable to send FRAG1 packet (tag: %d)",
> >  			 __func__, tag);
> >  		goto exit;
> >  	}
> >  
> > -	offset = LOWPAN_FRAG_SIZE;
> > +	offset = lowpan_size + frag_plen;
> > +	dgram_offset = mac_cb(skb)->frag_info.d_offset + frag_plen;
> 
> This isn't going to work.
> 
> Once you call dev_queue_xmit(), the skb control block can be reused by
> other layers.  In particular the device qdisc layer is going to
> scramble the control block on you.
> 
> Once a packet travels from one layer to another, SKB control block
> is likewise transferred.

thanks for your reply. If I understand it correctly so I can't be sure
that some other layer overwrites my skb control block with others
information.

In this case I can be sure we talking with ARPHRD_IEEE802154 devices only.
Which means I know that ARPHRD_IEEE802154 mac layer doesn't overwrites the
control block. Btw. at the moment the whole ieee802154 6lowpan implementation
is working on ARPHRD_IEEE802154 devices only, because the mac layer sets
many control block information for the upper layer. That's why we added
a check on this, see [1]. Simple put "The mac802154 layer and 6lowpan
layer share the same control block structure to make some 'layer
communication'".

The upper layer (6lowpan) use these information in control block which
is set by mac802154 layer. So we have a similar issue there.
The whole implementation is working only because the mac802154 and
6lowpan implementation share the control block information. A more
"correct" solution would be to drop the control block information and
evaluate the mac layer in 6lowpan also.



But you are right, that's a ugly solution. Anyway I can get the
mac_cb(skb)->frag_info.d_offset value when I evaluate the 6lowpan header
there aswell. So I will add a little helper function to get this information
and drop the unecessary information in mac_cb there.

Thanks.

- Alex

[1] http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/tree/net/ieee802154/6lowpan.c#n662
