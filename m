From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Subject: Re: Dropping NETIF_F_SG since no checksum feature.
Date: Wed, 11 Oct 2006 11:46:49 +0200
Message-ID: <20061011094649.GD2701@mellanox.co.il>
References: <20061011.022015.63051509.davem@davemloft.net>
Reply-To: "Michael S. Tsirkin" <mst@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, openib-general@openib.org,
	rolandd@cisco.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932168AbWJKJrb@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20061011.022015.63051509.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting r. David Miller <davem@davemloft.net>:
> Subject: Re: Dropping NETIF_F_SG since no checksum feature.
> 
> From: "Michael S. Tsirkin" <mst@mellanox.co.il>
> Date: Wed, 11 Oct 2006 11:05:04 +0200
> 
> > So, it seems that if I set NETIF_F_SG but clear NETIF_F_ALL_CSUM,
> > data will be copied over rather than sent directly.
> > So why does dev.c have to force set NETIF_F_SG to off then?
> 
> Because it's more efficient to copy into a linear destination
> buffer of an SKB than page sub-chunks when doing checksum+copy.
> 

Thanks for the explanation.
Obviously its true as long as you can allocate the skb that big.
I think you won't realistically be able to get 64K in a
linear SKB on a busy system, though, is not that right?

OTOH, having large MTU (e.g. 64K) helps performance a lot since it
reduces receive side processing overhead.

So, if I understand what you are saying correctly,
things do work correctly (just slower for small skb) if NETIF_F_SG is set bug
clear, it seems that all we need to do is drop the following in dev.c:

        /* Fix illegal SG+CSUM combinations. */
        if ((dev->features & NETIF_F_SG) &&
            !(dev->features & NETIF_F_ALL_CSUM)) {
                printk(KERN_NOTICE "%s: Dropping NETIF_F_SG since no checksum feature.\n",
                       dev->name);
                dev->features &= ~NETIF_F_SG;
        }

is that right?

-- 
MST
