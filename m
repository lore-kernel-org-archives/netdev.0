From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Subject: Re: [PATCH] e100: Correct firmware memory leak
Date: Mon, 30 May 2011 11:05:18 +0200
Message-ID: <20110530110518.2ee637d8@marrow.netinsight.se>
References: <20110523090700.68cdf15a@marrow.netinsight.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>
To: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ernst.netinsight.se ([194.16.221.21]:26702 "HELO
	ernst.netinsight.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751164Ab1E3JF3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 May 2011 05:05:29 -0400
In-Reply-To: <20110523090700.68cdf15a@marrow.netinsight.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi again,

On Mon, 23 May 2011 09:07:00 +0200
Simon Kagstrom <simon.kagstrom@netinsight.net> wrote:

> kmemcheck reports
> 
> unreferenced object 0xcfaf4f00 (size 32):
>   comm "ifconfig", pid 682, jiffies 87369
>   backtrace:
>     [<c00252b4>] save_stack_trace+0x20/0x24
>     [<c00a5f98>] create_object+0x118/0x20c
>     [<c00a61a8>] kmemleak_alloc+0x40/0x84
>     [<c00a2de4>] kmem_cache_alloc+0x114/0x1a4
>     [<c016ce50>] _request_firmware+0x3c/0x540
>     [<c016d3f8>] request_firmware+0x14/0x18
>     [<c0170774>] e100_hw_init+0xf0/0x3d8
>     [<c0171340>] e100_up+0x38/0x16c
>     [<c0171494>] e100_open+0x20/0x54
>     [<c019779c>] dev_open+0xcc/0x134
>     [<c0196cf0>] dev_change_flags+0xb0/0x190
>     [<c01e0998>] devinet_ioctl+0x2f0/0x6fc
>     [<c01e1dc4>] inet_ioctl+0xcc/0x104
>     [<c01861d8>] sock_ioctl+0x200/0x25c
>     [<c00b4cbc>] vfs_ioctl+0x34/0x78
>     [<c00b5400>] do_vfs_ioctl+0x4e4/0x53c
> [..]
> diff --git a/drivers/net/e100.c b/drivers/net/e100.c
> index b0aa9e6..f2b44ef 100644
> --- a/drivers/net/e100.c
> +++ b/drivers/net/e100.c
> @@ -1320,6 +1320,8 @@ static void e100_setup_ucode(struct nic *nic, struct cb *cb,
>  	cb->u.ucode[min_size] |= cpu_to_le32((BUNDLESMALL) ? 0xFFFF : 0xFF80);
>  
>  	cb->command = cpu_to_le16(cb_ucode | cb_el);
> +
> +	release_firmware(fw);
>  }

This patch can be dropped, I've made a mistake. I think there is a
memory leak when the driver is unloaded, since  nic->fw  is never
released, but that has to be solved in another way.

It's also not as serious since it only happens on module unload, not on
taking down the interface as indicated above.

// Simon
