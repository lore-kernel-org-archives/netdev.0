From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 08/14] mlx4: use order-0 pages for RX
Date: Tue, 14 Feb 2017 12:04:26 -0500 (EST)
Message-ID: <20170214.120426.2032015522492111544.davem@davemloft.net>
References: <20170214131206.44b644f6@redhat.com>
	<CANn89i+udp6Y42D9wqmz7U6LGn1mtDRXpQGHAOAeX25eD0dGnQ@mail.gmail.com>
	<cd4f3d91-252b-4796-2bd2-3030c18d9ee6@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, brouer@redhat.com, alexander.duyck@gmail.com,
 netdev@vger.kernel.org, tariqt@mellanox.com, kafai@fb.com,
 saeedm@mellanox.com, willemb@google.com, bblanco@plumgrid.com,
 ast@kernel.org, eric.dumazet@gmail.com, linux-mm@kvack.org
To: ttoukan.linux@gmail.com
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <cd4f3d91-252b-4796-2bd2-3030c18d9ee6@gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: Tariq Toukan <ttoukan.linux@gmail.com>
Date: Tue, 14 Feb 2017 16:56:49 +0200

> Internally, I already implemented "dynamic page-cache" and
> "page-reuse" mechanisms in the driver, and together they totally
> bridge the performance gap.

I worry about a dynamically growing page cache inside of drivers
because it is invisible to the rest of the kernel.

It responds only to local needs.

The price of the real page allocator comes partly because it can
respond to global needs.

If a driver consumes some unreasonable percentage of system memory, it
is keeping that memory from being used from other parts of the system
even if it would be better for networking to be slightly slower with
less cache because that other thing that needs memory is more
important.

I think this is one of the primary reasons that the MM guys severely
chastise us when we build special purpose local caches into networking
facilities.

And the more I think about it the more I think they are right.

One path I see around all of this is full integration.  Meaning that
we can free pages into the page allocator which are still DMA mapped.
And future allocations from that device are prioritized to take still
DMA mapped objects.

Yes, we still need to make the page allocator faster, but this kind of
work helps everyone not just 100GB ethernet NICs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
