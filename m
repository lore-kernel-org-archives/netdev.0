From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] vhost-net: fall back to vmalloc if high-order allocation fails
Date: Thu, 24 Jan 2013 09:45:50 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B711E@saturn3.aculab.com>
References: <87k3r31vbc.fsf@silenus.orebokech.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <kvm@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: "Romain Francoise" <romain@orebokech.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <87k3r31vbc.fsf@silenus.orebokech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +	n = kmalloc(sizeof *n, GFP_KERNEL | __GFP_NOWARN);
> +	if (!n)
> +		n = vmalloc(sizeof *n);

I'm slightly confused by this construct.
I thought kmalloc(... GFP_KERNEL) would sleep waiting for
memory (rather than return NULL).

I realise that (for multi-page sizes) that kmalloc() and
vmalloc() both need to find a contiguous block of kernel
virtual addresses - in different address ranges, and
that vmalloc() then has to find physical memory pages
(which will not be contiguous).

I think this means that kmalloc() is likely to be faster
(if it doesn't have to sleep), but that vmalloc() is
allocating from a much larger resource.

This make me that that large allocations that are not
temporary should probably be allocated with vmalloc().

Is there a 'NO_SLEEP' flag to kmalloc()? is that all
GFP_ATOMIC requests? If so you might try a non-sleeping
kmalloc() with a vmalloc() if it fails.

This all looks as though there should be a GFP_NONCONTIG
flag (or similar) so that kmalloc() can make a decision itself.

Of at least a wrapper - like the one for free().

	David
