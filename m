From: Ido Shamay <idos@dev.mellanox.co.il>
Subject: Re: [PATCH RFC] net/mlx4: Remove improper usage of dma_alloc_coherent().
Date: Tue, 07 Apr 2015 22:43:30 +0300
Message-ID: <55243362.5040207@dev.mellanox.co.il>
References: <1428361229-31542-1-git-send-email-ddaney.cavm@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <roland@kernel.org>,
	Sean Hefty <sean.hefty@intel.com>,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Matan Barak <matanb@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Moni Shoua <monis@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.co.il>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Yuval Atias <yuvala@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	David Daney <david.daney@cavium.com>, liranl@mellanox.com,
	gdror@mellanox.com
To: David Daney <ddaney.cavm@gmail.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:37489 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752720AbbDGTnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 15:43:35 -0400
Received: by wiaa2 with SMTP id a2so32002166wia.0
        for <netdev@vger.kernel.org>; Tue, 07 Apr 2015 12:43:34 -0700 (PDT)
In-Reply-To: <1428361229-31542-1-git-send-email-ddaney.cavm@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/7/2015 2:00 AM, David Daney wrote:
> From: David Daney <david.daney@cavium.com>
>
> The dma_alloc_coherent() function returns a virtual address which can
> be used for coherent access to the underlying memory.  On some
> architectures, like arm64, undefined behavior results if this memory is
> also accessed via virtual mappings that are not coherent.  Because of
> their undefined nature, operations like virt_to_page() return garbage
> when passed virtual addresses obtained from dma_alloc_coherent().  Any
> subsequent mappings via vmap() of the garbage page values are unusable
> and result in bad things like bus errors (synchronous aborts in ARM64
> speak).
>
> The MLX4 driver contains code that does the equivalent of:
>
>    vmap(virt_to_page(dma_alloc_coherent))
>
> This results in an OOPs when the device is opened.
>
> To fix this...
>
> Always use result of dma_alloc_coherent() directly.
Hi David,

I'm not sure this solution is good enough for the common case(s).
Typical allocation size will be around 64KB (with default 1K ring size).
We can't rely on the system to always provide us with that amount of 
contiguous memory.

Current code allocation scheme is more robust, max_direct is typically 2 
* PAGE_SIZE,
so pages from order 1 are far more available then higher order.

I need to check why the code is written as it is today,  and not as in 
this RFC (which is much more trivial).
I'll continue to investigate tomorrow, will get back with some answers.

Ido
> Remove 'max_direct' parameter to mlx4_buf_alloc(), as it is unused,
> and adjust all callers.
>
> Remove mlx4_en_map_buffer() and mlx4_en_unmap_buffer() as they now do
> nothing, and adjust all callers.
>
> Remove 'page_list' element from struct mlx4_buf as it is unused.
>
> Signed-off-by: David Daney <david.daney@cavium.com>
