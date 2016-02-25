From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 3/7] net/mlx5e: Fix soft lockup when HW
 Timestamping is enabled
Date: Thu, 25 Feb 2016 16:31:06 -0500 (EST)
Message-ID: <20160225.163106.2304939289705309406.davem@davemloft.net>
References: <1456312733-22091-1-git-send-email-saeedm@mellanox.com>
	<1456312733-22091-4-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, talal@mellanox.com,
	eranbe@mellanox.com, tariqt@mellanox.com, galp@mellanox.com
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46292 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751734AbcBYVbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 16:31:09 -0500
In-Reply-To: <1456312733-22091-4-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Wed, 24 Feb 2016 13:18:49 +0200

> From: Eran Ben Elisha <eranbe@mellanox.com>
> 
> Readers/Writers lock for SW timecounter was acquired without disabling
> interrupts on local CPU.
> 
> The problematic scenario:
> * HW timestamping is enabled
> * Timestamp overflow periodic service task is running on local CPU and
>   holding write_lock for SW timecounter
> * Completion arrives, triggers interrupt for local CPU.
>   Interrupt routine calls napi_schedule(), which triggers rx/tx
>   skb process.
>   An attempt to read SW timecounter using read_lock is done, which is
>   already locked by a writer on the same CPU and cause soft lockup.
> 
> Add irqsave/irqrestore for when using the readers/writers lock.
> 
> Fixes: ef9814deafd0 ('net/mlx5e: Add HW timestamping (TS) support')
> Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>

I'd like to suggest a slight modification to this fix.

The canonical way to deal with this issue is to use IRQ disabling
for the write lock side, but not for the read lock side.

You only need to prevent a read lock via interrupt from nesting on
the same cpu where you took the write lock.

So you don't need the expensive IRQ disabling for the read lock side,
which is the more important path performance wise.

Thanks.
