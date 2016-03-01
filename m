From: Alan Cox <alan@linux.intel.com>
Subject: Re: Sending short raw packets using sendmsg() broke
Date: Tue, 01 Mar 2016 23:34:25 +0000
Message-ID: <1456875265.7064.28.camel@linux.intel.com>
References: <alpine.DEB.2.10.1602252105250.32432@jazz.he.fi>
	 <20160225.152628.1230785666614750970.davem@davemloft.net>
	 <1456497874.7064.7.camel@linux.intel.com>
	 <CAF=yD-JOQZZnU6XE9FhEVbxstKmsB-ds58e5v678SiO24VV0+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Heikki Hannikainen <hessu@hes.iki.fi>,
	Network Development <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:52793 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750843AbcCAXel (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2016 18:34:41 -0500
In-Reply-To: <CAF=yD-JOQZZnU6XE9FhEVbxstKmsB-ds58e5v678SiO24VV0+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-02-26 at 12:33 -0500, Willem de Bruijn wrote:
> On Fri, Feb 26, 2016 at 9:44 AM, Alan Cox <alan@linux.intel.com>
> wrote:
> > On Thu, 2016-02-25 at 15:26 -0500, David Miller wrote:
> > > From: Heikki Hannikainen <hessu@hes.iki.fi>
> > > Date: Thu, 25 Feb 2016 21:36:07 +0200 (EET)
> > > 
> > > > Commit 9c7077622dd9174 added a check, ll_header_truncated(),
> > > > which
> > > > requires that a packet transmitted using sendmsg() with
> > > > PF_PACKET,
> > > > SOCK_RAW must be longer than dev->hard_header_len.
> > > 
> > > Fixed by:
> > > 
> > > commit 880621c2605b82eb5af91a2c94223df6f5a3fb64
> > > Author: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
> > > Date:   Sun Nov 22 17:46:09 2015 +0100
> > > 
> > >     packet: Allow packets with only a header (but no payload)
> > 
> > The AX.25 case the header is variable length so this still doesn't
> > fix
> > the regression as far as I can see.
> 
> Right. The simplest, if hacky, fix is to add something along the
> lines of
> 
>   static unsigned short netdev_min_hard_header_len(struct net_device
> *dev)
>   {
>       if (unlikely(dev->type ==ARPHDR_AX25))
>         return AX25_KISS_HEADER_LEN;
>       else
>         return dev->hard_header_len;
>   }

AX.25 is not unique in this. Also there are protocols where the minimum
header length for a valid raw frame is not the same as the minimum
sized header for encapsulation of an IP frame because the IP frame is
encapsulated with an extra header block.

> Depending on how the variable encoding scheme works, a basic min
> 
> length check may still produce buggy headers that confuse the stack
> or
> driver. I need to read up on AX25. If so, then extending header_ops
> with an optional validate() function is a more generic approach of
> checking header sanity.

A validate() method is doable for NetROM, AX.25 and friends. So
something like

            if (likely(len >= dev->hard_header_len)) 
			return good;
	    if (proto->validate && proto->validate(skb))
			return good;
	    return bad;

works for amateur radio at least, and I think could be extended ok for
any other cases like tunnels.

Alan
