From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 0/4] enic: improve rq buff allocation and
 reduce dma mapping
Date: Mon, 2 Feb 2015 15:56:49 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAD8FD1@AcuExch.aculab.com>
References: <1422707290-939-1-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "ssujith@cisco.com" <ssujith@cisco.com>,
	"benve@cisco.com" <benve@cisco.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>
To: 'Govindarajulu Varadarajan' <_govind@gmx.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.182]:57440 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752806AbbBBP5Y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 10:57:24 -0500
In-Reply-To: <1422707290-939-1-git-send-email-_govind@gmx.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan
> The following series tries to address these two problem in rq buff allocation.
> 
> * Memory wastage because of large 9k allocation using kmalloc:
>   For 9k mtu buffer, netdev_alloc_skb_ip_align internally calls kmalloc for
>   size > 4096. In case of 9k buff, kmalloc returns pages for order 2, 16k.
>   And we use only ~9k of 16k. 7k memory wasted. Using the frag the frag
>   allocator in patch 1/2, we can allocate three 9k buffs in a 32k page size.
>   Typical enic configuration has 8 rq, and desc ring of size 4096.
>   Thats 8 * 4096 * (16*1024) = 512 MB. Using this frag allocator:
>   8 * 4096 * (32*1024/3) = 341 MB. Thats 171 MB of memory save.
> 
> * frequent dma_map() calls:
>   we call dma_map() for every buff we allocate. When iommu is on, This is very
>   cpu time consuming. From my testing, most of the cpu cycles are wasted
>   spinning on spin_lock_irqsave(&iovad->iova_rbtree_lock, flags) in
>   intel_map_page() .. -> ..__alloc_and_insert_iova_range()
> 
>   With this patch, we call dma_map() once for 32k page. i.e once for every three
>   9k desc, and once every twenty 1500 bytes desc.

Two questions:
1) How are you handling the skb's true_size ?
2) Memory fragmentation could easily make the allocation of 32k fail.

	David
