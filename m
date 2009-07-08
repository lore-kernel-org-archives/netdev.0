From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 1/2] c/r: Add AF_UNIX support (v5)
Date: Wed, 8 Jul 2009 09:01:52 -0500
Message-ID: <20090708140152.GC10787@us.ibm.com>
References: <1246994776-1882-1-git-send-email-danms@us.ibm.com> <1246994776-1882-2-git-send-email-danms@us.ibm.com> <4A543D82.5080408@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Smith <danms@us.ibm.com>, containers@lists.osdl.org,
	netdev@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>
To: Oren Laadan <orenl@cs.columbia.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:45382 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756089AbZGHOCM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 10:02:12 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n68Dw4KX024145
	for <netdev@vger.kernel.org>; Wed, 8 Jul 2009 07:58:04 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n68E22RE057030
	for <netdev@vger.kernel.org>; Wed, 8 Jul 2009 08:02:03 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n68E1skP019891
	for <netdev@vger.kernel.org>; Wed, 8 Jul 2009 08:01:59 -0600
Content-Disposition: inline
In-Reply-To: <4A543D82.5080408@cs.columbia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Oren Laadan (orenl@cs.columbia.edu):
> Dan Smith wrote:
> > +static int sock_read_buffer(struct ckpt_ctx *ctx,
> > +			    struct sock *sock,
> > +			    struct sk_buff **skb)
> > +{
> > +	struct ckpt_hdr h;
> > +	int ret = 0;
> > +	int len;
> > +
> > +	len = _ckpt_read_hdr_type(ctx, &h, CKPT_HDR_SOCKET_BUFFER);
> > +	if (len < 0)
> > +		return len;
> > +
> > +	if (len > SKB_MAX_ALLOC) {
> > +		ckpt_debug("Socket buffer too big (%i > %solu)",
> > +			   len, SKB_MAX_ALLOC);
> > +		return -ENOSPC;
> > +	}
> > +
> > +	*skb = sock_alloc_send_skb(sock, len, MSG_DONTWAIT, &ret);
> 
> I looked at the socket code again, and I suspect this is wrong.

...

> The problem stems from trying to imitate the network code instead
> of reusing it - for example, by really sending data from the source
> socket (or a dummy one, if original no longer exists) to the target
> socket.

That also caused you to skip a bunch of security_* calls (at
the least here, at the recv equivalent, do_sock_getname, and at your
bind at restore).

I don't think simply inserting them here is the right thing to do,
bc then as the main code changes this code is likely to fall out of
sync.  So like Oren says, I think you need to do more re-use of the
common code.  For the bind() case, for instance, write a common helper
used by both sys_bind() and your restart bind, which does the
security check and then calls sock->ops->bind().  It makes your
patchset a bit more intrusive, but easier to maintain.

-serge
