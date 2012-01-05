From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH 2/6] net: pad skb data and shinfo as a whole rather
 than individually
Date: Thu, 5 Jan 2012 20:00:58 +0000
Message-ID: <1325793658.29084.21.camel@dagon.hellion.org.uk>
References: <1325783399.25206.413.camel@zakaz.uk.xensource.com>
	 <1325783624-14601-2-git-send-email-ian.campbell@citrix.com>
	 <1325785607.4759.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20120105.141331.83457091828476806.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:49654 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755357Ab2AEUBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 15:01:11 -0500
In-Reply-To: <20120105.141331.83457091828476806.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-01-05 at 19:13 +0000, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 05 Jan 2012 18:46:47 +0100
> 
> >> @@ -189,8 +189,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
> >>  	 * aligned memory blocks, unless SLUB/SLAB debug is enabled.
> >>  	 * Both skb->head and skb_shared_info are cache line aligned.
> >>  	 */
> >> -	size = SKB_DATA_ALIGN(size);
> >> -	size += SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
> >> +	size = SKB_DATA_ALIGN(size + sizeof(struct skb_shared_info));
> >>  	data = kmalloc_node_track_caller(size, gfp_mask, node);
> >>  	if (!data)
> >>  		goto nodata;
> > 
> > Unfortunately this makes the frequently use part of skb_shared_info not
> > any more in a single cache line.
> > 
> > This will slow down many operations like kfree_skb() of cold skbs (TX
> > completion for example)
> 
> My concerns match Eric's here.
> 
> Ian, you state that you attempted to look into schemes that put the
> destructor info somewhere other than skb_shared_info() and that none
> of them worked well.
> 
> But what kind of issues do you run into if you add this into struct
> page itself?  Other subsystems could then use this facility too, and
> if I recall there was even some talk of this.

This is what the old out of tree Xen stuff used to do and it was my
understanding that it had been nacked by the mm guys, although it was a
long while ago and I wasn't really involved at the time. I think space
in struct page is pretty tight and any addition is multiplied over the
number of pages in the system which makes it undesirable. AIUI there
were also complaints about the addition of a hook on the page free path,
which is quite a hot one.

I could run it by them again but...

Although this scheme works fine for Xen's netback I don't think it works
for other use cases like the NFS one (or basically any kernel_sendpage
usage). In those cases you don't want to wait for the last core mm ref
on the page to get dropped, you just want to wait for the last ref due
to the particular sendpage. If you use the core page_count() reference
count then you end up waiting for the process to exit (and drop the core
reference count) before the destructor fires and you can complete the
write, which is obviously not what is desired!

There's also issues with things like two threads simultaneously doing
I/O from the same page. If one lot of I/O is to NFS and the other to
iSCSI (assuming they both use this facility in the future) then they
will clash over the use of the struct page field. In fact even if they
were both to NFS I bet nothing good would happen...

Cheers,
Ian.
