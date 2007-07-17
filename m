From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Socket Buffers and Memory Managment
Date: Tue, 17 Jul 2007 20:41:29 +0100
Message-ID: <20070717204129.79e7fe0d@oldman>
References: <551531.35231.qm@web82912.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vinay ravuri <vinaynyc@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:59475 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753014AbXGQTlj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2007 15:41:39 -0400
In-Reply-To: <551531.35231.qm@web82912.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 17 Jul 2007 10:20:58 -0700 (PDT)
vinay ravuri <vinaynyc@yahoo.com> wrote:

> Hi,
> 
> I am fairly new to linux socket buffers and have the
> following questions!
> 
> I am working with a custom ethernet MAC that does not
> allow me to specify a particular memory location for
> the h/w to DMA the packet into (Rx side).  Instead, it
> has a pool of fixed size buffers with some h/w
> specific headers around each buffer that are managed
> by h/w and will pick a free buffer and DMA the packet.

Sounds like sucky hardware...
You need to copy to a newly allocated skb, see 8139too.c

>  It appears dev_alloc_skb() actually allocates the
> physical memory and doesn't allow the user to specify
> the skb.data to something specific to what I want
> which is a problem for me.  First is my assumption
> correct that I am cannot pick an arbitrary skb.data
> location in struct sk_buff?  I want to avoid copying
> the dma'ed data into a new socket buffer as it is
> expense.  Is there any ways around this problem?

You could play tricks with skb frags but it would be fragile
and not worth the trouble. The problem is that the receive
skb can stay in the system for a really long time (until the application
reads the data) so your fixed size buffer pool in hardware
would get exhausted.
 
> Also, if the h/w gives me a single packet in multiple
> locations (i.e. non-contiguous chunks of memory), can
> socket buffers handle chains of buffers?  I am looking
> for a facility like mbuf's in netbsd where one can
> chain multiple buffers together to make construct a
> single packet.

Yes, skb frag list could be used for that but you don't
want to do that. See above. Copy the data into an new
skb and reserve any necessary bytes so IP header is
aligned.  I.e. if using ethernet header (14 bytes), do
skb_reserve(skb, 2) before copying the data.
