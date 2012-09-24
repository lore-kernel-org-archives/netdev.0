From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] gre: conform to RFC6040 ECN progogation
Date: Mon, 24 Sep 2012 15:30:13 -0700
Message-ID: <20120924153013.553f0b76@nehalam.linuxnetplumber.net>
References: <20120924184304.727711327@vyatta.com>
	<20120924185050.162920909@vyatta.com>
	<20120924205822.GI26494@x200.localdomain>
	<20120924141133.3c97e9de@nehalam.linuxnetplumber.net>
	<20120924212226.GJ26494@x200.localdomain>
	<20120924144457.0c76bce2@nehalam.linuxnetplumber.net>
	<1348525536.26828.1885.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Chris Wright <chrisw@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54394 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750778Ab2IXWap (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2012 18:30:45 -0400
In-Reply-To: <1348525536.26828.1885.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 Sep 2012 00:25:36 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Mon, 2012-09-24 at 14:44 -0700, Stephen Hemminger wrote:
> > Linux GRE was likely written before this RFC and therefore does not
> > conform to one of the rules in Section 4.2.  Default Tunnel Egress Behaviour.
> > 
> > The new code addresses:
> >  o If the inner ECN field is Not-ECT, the decapsulator MUST NOT
> >       propagate any other ECN codepoint onwards.  This is because the
> >       inner Not-ECT marking is set by transports that rely on dropped
> >       packets as an indication of congestion and would not understand or
> >       respond to any other ECN codepoint [RFC4774].  Specifically:
> > 
> >       *  If the inner ECN field is Not-ECT and the outer ECN field is
> >          CE, the decapsulator MUST drop the packet.
> > 
> >       *  If the inner ECN field is Not-ECT and the outer ECN field is
> >          Not-ECT, ECT(0), or ECT(1), the decapsulator MUST forward the
> >          outgoing packet with the ECN field cleared to Not-ECT.
> > 
> > This was caught by Chris Wright while reviewing VXLAN.
> > This code has not been tested with real ECN through tunnel.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> It seems dangerous to me without any logging ?
> 
> One could argue that the outer ECN field should not be CE if the inner
> was Not-ECT
> 
> It means :
> 1) the encapsulator set ECT(0), or ECT(1) and a congestioned hop set CE
> 2) the encapsulator set CE
> 
> 1) or 2) while inner was not-ECT (!!!)
> 
> If a router does such a thing, we should log a message to help
> diagnostics.
> 
> By the way other tunnels probably have the same issues.

Logging is a bad idea in this case since the tunnel might be from a remote
host/protocol and the log would be filled with crap.

The tunnels in general do need to have rx_dropped counter, but it looks
like that isn't being done right either.
