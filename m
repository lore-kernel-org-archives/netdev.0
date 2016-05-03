From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH v1 net] net/mlx4: Avoid wrong virtual mappings
Date: Tue, 3 May 2016 10:45:43 +0300
Message-ID: <CAJ3xEMjomTc5JNNEknk-JMBUtvAcb5xY8La4zT4mKG2Ad=V85Q@mail.gmail.com>
References: <1461740820-15386-1-git-send-email-hagaya@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Sinan Kaya <okaya@codeaurora.org>,
	Timur Tabi <timur@codeaurora.org>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: Haggai Abramovsky <hagaya@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:34294 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779AbcECHpo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 03:45:44 -0400
Received: by mail-ob0-f181.google.com with SMTP id dm5so3628454obc.1
        for <netdev@vger.kernel.org>; Tue, 03 May 2016 00:45:44 -0700 (PDT)
In-Reply-To: <1461740820-15386-1-git-send-email-hagaya@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 27, 2016 at 10:07 AM, Haggai Abramovsky <hagaya@mellanox.com> wrote:
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
> The mlx4 driver contains code that does the equivalent of:
> vmap(virt_to_page(dma_alloc_coherent)), this results in an OOPs when the
> device is opened.
>
> Prevent Ethernet driver to run this problematic code by forcing it to
> allocate contiguous memory. As for the Infiniband driver, at first we
> are trying to allocate contiguous memory, but in case of failure roll
> back to work with fragmented memory.

Dave,

The patch changes the driver to do single allocation for potentially
very large HW WQE
descriptor buffers such as those used by the RDMA (mlx5_ib) driver.
The IB driver does
have the means to cope with fragmented allocations, and under RDMA use
cases, QPs
are being frequently set not only on system startup, but rather
throughout all the lifecycles
(e.g every now and then in production systems). As of all the above,
we prefer the patch
to go to net-next and not net. This will make the code (1) correct,
and (2) we have the chance
to do the whatever investigations needed and if required add a follow
up fix for 4.7-rc

Or.

> Signed-off-by: Haggai Abramovsky <hagaya@mellanox.com>
> Signed-off-by: Yishai Hadas <yishaih@mellanox.com>
> Reported-by: David Daney <david.daney@cavium.com>
> Tested-by: Sinan Kaya <okaya@codeaurora.org>
