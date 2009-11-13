From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RACE] net: in process_backlog
Date: Thu, 12 Nov 2009 16:11:23 -0800
Message-ID: <20091112161123.561d87fe@nehalam>
References: <412e6f7f0911120050w740377c7j2cdf24ef9fd2ca59@mail.gmail.com>
	<20091112085739.1137f690@nehalam>
	<412e6f7f0911121554n22a6f975h1fb5df59bd4b84a2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52911 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755815AbZKMAL3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 19:11:29 -0500
In-Reply-To: <412e6f7f0911121554n22a6f975h1fb5df59bd4b84a2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Nov 2009 07:54:14 +0800
Changli Gao <xiaosuo@gmail.com> wrote:

> On Fri, Nov 13, 2009 at 12:57 AM, Stephen Hemminger
> <shemminger@vyatta.com> wrote:
> > On Thu, 12 Nov 2009 16:50:53 +0800
> > Changli Gao <xiaosuo@gmail.com> wrote:
> >
> >
> > There is are a couple of issues here, but it is not what you though=
t
> > you saw.
> >
> > The receive process is always done in soft IRQ context. The backlog=
 queue's
> > are per-cpu. When a device is deleted an IPI is sent to all cpu's t=
o
> > scan there backlog queue. =C2=A0What should protect the skb is the =
fact that
> > the network device destruction process waits for an RCU grace perio=
d.
> > So skb->dev points to valid data.
>=20
> Yea, if the process waits for a RCU grace period, there will be no
> race. But think about another case:
> 1. flush_backlog().
After flush backlog there should be no more skb's with that device
in the queue, and if more are added, the device is buggy.

> 2. dev_hold(skb->dev); netif_rx(). dev_put(skb->dev);
There is no dev_hold in netif_rx path.

> 3. wait_for_refs();
> 4. free(dev);
> 5. netif_receive_skb(); //skb->dev doesn't present.
> flush_backlog() can't prevent new skbs are added to backlog. If we
> swap the flush_backlog() and wait_for_refs(), this case will be OK
> too.

It is still up to device driver not to add skb's to queue when stopped.

--=20
