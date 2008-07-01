From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: kmemcheck detected possible information leak to userspace?
Date: Tue, 1 Jul 2008 14:25:00 +0400
Message-ID: <20080701102459.GB30248@2ka.mipt.ru>
References: <19f34abd0807010216k11a60382xf7a27b4b27f0819@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>,
	Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org
To: Vegard Nossum <vegard.nossum@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:42832 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753266AbYGAKZP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jul 2008 06:25:15 -0400
Content-Disposition: inline
In-Reply-To: <19f34abd0807010216k11a60382xf7a27b4b27f0819@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 01, 2008 at 11:16:15AM +0200, Vegard Nossum (vegard.nossum@gmail.com) wrote:
> Hi,
> 
> Running kmemcheck on -tip gives me the following warning:
> 
> kmemcheck: Caught 32-bit read from uninitialized memory (c72daa2e)
> iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiuuuuiiiiuuuuuuuuuu
>                                               ^

...

> ..which is a bit worrying, because it means that we are copying
> uninitialized data into userspace, i.e. this could be a data leak.
> Most likely it's not very critical, but it would be nice to fix
> anyway.
> 
> Relevant source lines are:
> 
> $ addr2line -e vmlinux -i c04ade71 # memcpy_toiovec
> net/core/iovec.c:87
> 
> $ addr2line -e vmlinux -i c04ae461 # skb_copy_datagram_iovec
> net/core/datagram.c:277
> 
> $ addr2line -e vmlinux -i c05325c7 # packet_recvmsg
> net/packet/af_packet.c:1093
 
This gives:
	copied = skb->len;
	if (copied > len)
	{
		copied=len;
		msg->msg_flags|=MSG_TRUNC;
	}

	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);

So everything looks ok, but driver could setup skb->len and/or
skb->data_len to be slightly more than it placed data. Does
above 'uuuu' bytes are at the end of the skb->data?

-- 
	Evgeniy Polyakov
