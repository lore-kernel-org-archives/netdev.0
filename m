From: David Miller <davem@davemloft.net>
Subject: Re: af_packet.c flush_dcache_page
Date: Wed, 31 Oct 2007 15:57:49 -0700 (PDT)
Message-ID: <20071031.155749.26538335.davem@davemloft.net>
References: <47288C42.5010603@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48961
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751323AbXJaW5u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 18:57:50 -0400
In-Reply-To: <47288C42.5010603@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 31 Oct 2007 15:08:02 +0100

> I'm currently adding mmap support to af_netlink based on the
> af_packet implementation and I'm wondering about this code in
> tpacket_rcv():
> 
>          h->tp_status = status;
>          smp_mb();
> 
>          {
>                  struct page *p_start, *p_end;
>                  u8 *h_end = (u8 *)h + macoff + snaplen - 1;
> 
>                  p_start = virt_to_page(h);
>                  p_end = virt_to_page(h_end);
>                  while (p_start <= p_end) {
>                          flush_dcache_page(p_start);
>                          p_start++;
>                  }
>          }
> 
> Shouldn't the flushing be done in reverse order to make sure
> that the page containing tp_status is flushed last and userspace
> doesn't start looking at following pages before all dcache entries
> are flushed?
> 
> A related question: Documentation/cachetlb.txt mentions that
> flushing also needs to be done for reading of shared+writable
> mapped pages, so it seems like we also need to call flush_dcache_page 
> before the tp_status check earlier in that function and packet_poll().

Thanks for bringing up this topic.

Instead of answering your questions, I'm going to show you
how to avoid having to do any of this cache flushing crap :-)

You can avoid having to flush anything as long as the virtual
addresses on the kernel side are modulo SHMLBA the virtual addresses
on the userland side.

We have some (decidedly awkward) mechanisms to try and achieve
this in the kernel, but they are cumbersome and not air tight.

Instead, I would recommend simply that you access the ring
buffer directly in userspace.  This avoids all of the cache
aliasing issues.

Yes, this means you have to do the ring buffer accesses in
the context of the user, but it simplifies so much that I think
it'd be worth it.

Another option is to use the "copy_to_user_page()" and
"copy_from_user_page()" interfaces which will do all of
the necessary cache flushing for you.

Actually it might be nice to convert AF_PACKET's mmap() code
over to using those things.
