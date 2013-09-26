From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net 1/2] ip_tunnel: Fix a memory corruption in
 ip_tunnel_xmit
Date: Thu, 26 Sep 2013 10:25:52 +0200
Message-ID: <20130926082552.GB7660@secunet.com>
References: <20130925055418.GV7660@secunet.com>
 <CALnjE+q1=EJGBBC9KC4_hcj2SPhSPQ3xNVt6RVFN2hZPFYM2TA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:33216 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751483Ab3IZIZz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Sep 2013 04:25:55 -0400
Content-Disposition: inline
In-Reply-To: <CALnjE+q1=EJGBBC9KC4_hcj2SPhSPQ3xNVt6RVFN2hZPFYM2TA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 25, 2013 at 09:55:50AM -0700, Pravin Shelar wrote:
> On Tue, Sep 24, 2013 at 10:54 PM, Steffen Klassert
> <steffen.klassert@secunet.com> wrote:
> > We might extend the used aera of a skb beyond the total
> > headroom when we install the ipip header. Fix this by
> > calling skb_cow_head() unconditionally.
> >
> It is better to call skb_cow_head() from ipip_tunnel_xmit() as it is
> consistent with gre.

I think this would just move the bug from ipip to gre. ipgre_xmit()
uses dev->needed_headroom which is based on the guessed output device
in ip_tunnel_bind_dev(). If the device we get from the route lookup
in ip_tunnel_xmit() is different from the guessed one and the resulting
max_headroom is bigger than dev->needed_headroom, we run into that bug
because skb_cow_head() will not be called with the updated
dev->needed_headroom.
