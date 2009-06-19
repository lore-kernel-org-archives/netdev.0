From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: can we reuse an skb
Date: Fri, 19 Jun 2009 14:41:14 -0400
Message-ID: <20090619184114.GG18237@hmsreliant.think-freely.org>
References: <962874.62146.qm@web94813.mail.in2.yahoo.com> <4A3B6A71.9060709@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Radha Mohan <radhamohan_ch@yahoo.com>, netdev@vger.kernel.org
To: Saikiran Madugula <hummerbliss@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48472 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751021AbZFSSlW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2009 14:41:22 -0400
Content-Disposition: inline
In-Reply-To: <4A3B6A71.9060709@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 19, 2009 at 11:37:37AM +0100, Saikiran Madugula wrote:
> Radha Mohan wrote:
> > Hi,
> > 
> > For an ethernet driver, we need to allocate some pool of SKBs for receiving packets. Is there any way we can reuse the same SKBs without the need to re-allocate in atomic every time one has been used up for netif_rx(). 
> > 
> > Any pointers will be helpful.
> http://kerneltrap.org/mailarchive/linux-netdev/2008/9/28/3433504
Thats usefull on the transmit side, This appears to be in relation to receive
side buffering.

The answer to the question I think is, yes, you probably could come up with some
method to recycle skb's on the recieve side, but in all honesty, you're not
likely to come up with a solution that doesn't kill your performance.  If you
want to recycle the same skbs to your hardware, you either have to detect when
an application has received that data at the top of the stack, or you have to
copy the data out of the skb you just got from your hardware, so you can reuse
it immediately.  Theres not much point in doing the latter, as it doesn't avoid
the skb allocation your trying to not make.  The former is technically feasible,
but it requires your driver to wait an indefinate amount of time while an
application (or applications, if you consider the multicast case) all get on the
scheduler and receive from their open sockets, so theres no easy way to size
your receive ring, and if you run out, you have to drop frames until someone
releases an skb to you.

Its far easier, and more efficient to just allocate a new skb, and insert that
your hardwares ring buffer.  And its really not that expensive considering the
caching effect that our various allocators have
Neil

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
