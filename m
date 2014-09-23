From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net] ip_tunnel: Don't allow to add the same tunnel
 multiple times.
Date: Tue, 23 Sep 2014 13:30:51 +0200
Message-ID: <20140923113051.GZ6390@secunet.com>
References: <20140922071108.GY6390@secunet.com>
 <20140922.164556.736459936247558402.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:48815 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755269AbaIWLa6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2014 07:30:58 -0400
Content-Disposition: inline
In-Reply-To: <20140922.164556.736459936247558402.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 22, 2014 at 04:45:56PM -0400, David Miller wrote:
> From: Steffen Klassert <steffen.klassert@secunet.com>
> Date: Mon, 22 Sep 2014 09:11:08 +0200
> 
> > When we try to add an already existing tunnel, we don't return
> > an error. Instead we continue and call ip_tunnel_update().
> > This means that we can change existing tunnels by adding
> > the same tunnel multiple times. It is even possible to change
> > the tunnel endpoints of the fallback device.
> > 
> > We fix this by returning an error if we try to add an existing
> > tunnel.
> > 
> > Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> > ---
> > 
> > I was not able to find a commit that introduced this bug.
> > Looks like ipip and ip_gre had similar bugs already with
> > the initial git commit.
> 
> I'm not so sure about this, perhaps the behavior of being able to
> change a configuration using an ADD call is intentional?

Hm, I don't think so. Initially it was the same like with ipv6.
It was possible to add the same tunnel muliple times without
getting an error, no config change was made. The possibilty
to change the configuration by adding the same tunnel a second
time came with the tunnel code unification.

I think we should return an error if a tunnel configuration
is added a second time. Otherwise we can do something like:

ip tunnel add name tunl1 mode ipip local 0.0.0.0 remote 0.0.0.0
ip tunnel add name tunl2 mode ipip local 0.0.0.0 remote 0.0.0.0
ip tunnel add name tunl3 mode ipip local 0.0.0.0 remote 0.0.0.0

None of these tunnels is created because the configuration
matches the fallback tunnel, but we don't notify the user
about that.
