From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Subject: Re: Dropping NETIF_F_SG since no checksum
 feature.
Date: Wed, 11 Oct 2006 11:05:04 +0200
Message-ID: <20061011090504.GC2938@mellanox.co.il>
References: <20061010.191547.83619974.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	openib-general@openib.org,
	linux-kernel@vger.kernel.org,
	shemminger@osdl.org
Return-path: <openib-general-bounces@openib.org>
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20061010.191547.83619974.davem@davemloft.net>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

Quoting r. David Miller <davem@davemloft.net>:
> Subject: Re: Dropping NETIF_F_SG since no checksum feature.
> 
> From: "Michael S. Tsirkin" <mst@mellanox.co.il>
> Date: Wed, 11 Oct 2006 02:13:38 +0200
> 
> > Maybe I can patch linux to allow SG without checksum?
> > Dave, maybe you could drop a hint or two on whether this is worthwhile
> > and what are the issues that need addressing to make this work?
> > 
> > I imagine it's not just the matter of changing net/core/dev.c :).
> 
> You can't, it's a quality of implementation issue.  We sendfile()
> pages directly out of the filesystem page cache without any
> blocking of modifications to the page contents, and the only way
> that works is if the card computes the checksum for us.
> 
> If we sendfile() a page directly, we must compute a correct checksum
> no matter what the contents.  We can't do this on the cpu before the
> data hits the device because another thread of execution can go in and
> modify the page contents which would invalidate the checksum and thus
> invalidating the packet.  We cannot allow this.
> 
> Blocking modifications is too expensive, so that's not an option
> either.
> 

But copying still works fine, does it not?
Dave, could you clarify this please?

ssize_t tcp_sendpage(struct socket *sock, struct page *page, int offset,
                     size_t size, int flags)
{
        ssize_t res;
        struct sock *sk = sock->sk;

        if (!(sk->sk_route_caps & NETIF_F_SG) ||
            !(sk->sk_route_caps & NETIF_F_ALL_CSUM))
                return sock_no_sendpage(sock, page, offset, size, flags);


So, it seems that if I set NETIF_F_SG but clear NETIF_F_ALL_CSUM,
data will be copied over rather than sent directly.
So why does dev.c have to force set NETIF_F_SG to off then?

-- 
MST
