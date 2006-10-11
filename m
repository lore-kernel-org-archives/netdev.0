From: Steven Whitehouse <steve@chygwyn.com>
Subject: Re: Dropping NETIF_F_SG since no checksum feature.
Date: Wed, 11 Oct 2006 10:09:26 +0100
Message-ID: <20061011090926.GA15393@fogou.chygwyn.com>
References: <20061010.191547.83619974.davem@davemloft.net> <20061011090504.GC2938@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, shemminger@osdl.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	openib-general@openib.org, rolandd@cisco.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965214AbWJKJQB@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@mellanox.co.il>
Content-Disposition: inline
In-Reply-To: <20061011090504.GC2938@mellanox.co.il>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Wed, Oct 11, 2006 at 11:05:04AM +0200, Michael S. Tsirkin wrote:
> Quoting r. David Miller <davem@davemloft.net>:
> > Subject: Re: Dropping NETIF_F_SG since no checksum feature.
> > 
> > From: "Michael S. Tsirkin" <mst@mellanox.co.il>
> > Date: Wed, 11 Oct 2006 02:13:38 +0200
> > 
> > > Maybe I can patch linux to allow SG without checksum?
> > > Dave, maybe you could drop a hint or two on whether this is worthwhile
> > > and what are the issues that need addressing to make this work?
> > > 
> > > I imagine it's not just the matter of changing net/core/dev.c :).
> > 
> > You can't, it's a quality of implementation issue.  We sendfile()
> > pages directly out of the filesystem page cache without any
> > blocking of modifications to the page contents, and the only way
> > that works is if the card computes the checksum for us.
> > 
> > If we sendfile() a page directly, we must compute a correct checksum
> > no matter what the contents.  We can't do this on the cpu before the
> > data hits the device because another thread of execution can go in and
> > modify the page contents which would invalidate the checksum and thus
> > invalidating the packet.  We cannot allow this.
> > 
> > Blocking modifications is too expensive, so that's not an option
> > either.
> > 
>

I would argue that SG does make sense without checksum for protocols that
don't need/use a checksum. DECnet for example could do zero-copy without
caring about the checksum since it doesn't have one. One of these days
I'll get around to writing that bit of code :-)
 
> But copying still works fine, does it not?
> Dave, could you clarify this please?
> 
> ssize_t tcp_sendpage(struct socket *sock, struct page *page, int offset,
>                      size_t size, int flags)
> {
>         ssize_t res;
>         struct sock *sk = sock->sk;
> 
>         if (!(sk->sk_route_caps & NETIF_F_SG) ||
>             !(sk->sk_route_caps & NETIF_F_ALL_CSUM))
>                 return sock_no_sendpage(sock, page, offset, size, flags);
> 
> 
> So, it seems that if I set NETIF_F_SG but clear NETIF_F_ALL_CSUM,
> data will be copied over rather than sent directly.
> So why does dev.c have to force set NETIF_F_SG to off then?
>
I agree with that analysis,

Steve.
