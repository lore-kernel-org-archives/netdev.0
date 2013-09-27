From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net 1/2] ip_tunnel: Fix a memory corruption in
 ip_tunnel_xmit
Date: Fri, 27 Sep 2013 09:45:30 +0200
Message-ID: <20130927074530.GD7660@secunet.com>
References: <20130925055418.GV7660@secunet.com>
 <CALnjE+q1=EJGBBC9KC4_hcj2SPhSPQ3xNVt6RVFN2hZPFYM2TA@mail.gmail.com>
 <20130926082552.GB7660@secunet.com>
 <CALnjE+ofaXQa3gsPPxqdWZeBxgML6M1vnC9mmc5dufwy0gJO-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:37787 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751258Ab3I0Hpd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Sep 2013 03:45:33 -0400
Content-Disposition: inline
In-Reply-To: <CALnjE+ofaXQa3gsPPxqdWZeBxgML6M1vnC9mmc5dufwy0gJO-Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 26, 2013 at 11:25:01AM -0700, Pravin Shelar wrote:
> On Thu, Sep 26, 2013 at 1:25 AM, Steffen Klassert
> <steffen.klassert@secunet.com> wrote:
> > On Wed, Sep 25, 2013 at 09:55:50AM -0700, Pravin Shelar wrote:
> >> On Tue, Sep 24, 2013 at 10:54 PM, Steffen Klassert
> >> <steffen.klassert@secunet.com> wrote:
> >> > We might extend the used aera of a skb beyond the total
> >> > headroom when we install the ipip header. Fix this by
> >> > calling skb_cow_head() unconditionally.
> >> >
> >> It is better to call skb_cow_head() from ipip_tunnel_xmit() as it is
> >> consistent with gre.
> >
> > I think this would just move the bug from ipip to gre. ipgre_xmit()
> > uses dev->needed_headroom which is based on the guessed output device
> > in ip_tunnel_bind_dev(). If the device we get from the route lookup
> > in ip_tunnel_xmit() is different from the guessed one and the resulting
> > max_headroom is bigger than dev->needed_headroom, we run into that bug
> > because skb_cow_head() will not be called with the updated
> > dev->needed_headroom.
> >
> Thats why ip_tunnel_xmit() update dev->needed_headroom.
> Just to be clear I was talking abt calling skb_cow_head with
> dev->needed_headroom in ipip_xmit and leave ip_tunnel_xmit as it is.
> So that most of cases we will not need to adjust headroom in ip_tunnel
> xmit.

skb_cow_head() does not do much if there is enough headroom, so
calling it here is uncritical. But we should adjust the headroom
as soon as we know that it is insufficient.

Also, I really wonder how you want to adjust the headroom in
ipip_tunnel_xmit() to a correct value. We know the needed
headroom after the route lookup in ip_tunnel_xmit() and
we have to adust it here because ip_tunnel_xmit() calls
iptunnel_xmit() which does a __skb_push() before it
installs the IP header.

Please keep in mind tat this is a bug fix that might be interesting
for stable too, we should try to keep the changes at a minimum.

Another thing that I noticed, with commit 0e6fbc5b
(ip_tunnels: extend iptunnel_xmit()) you moved the IP header
installation to iptunnel_xmit() and changed skb_push()
to __skb_push(). This made this bug quite hard to track
down because instead of triggering a skb under panic,
it did a silent memory corruption and crashed at random
other places. Maybe we should change this back to skb_push().
