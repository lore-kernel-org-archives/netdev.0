From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next v1] ipvlan: don't use IDR for generating dev_id
Date: Fri, 06 Jan 2017 21:18:36 -0500 (EST)
Message-ID: <20170106.211836.1613373165796630636.davem@davemloft.net>
References: <20170107003311.22940-1-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maheshb@google.com, edumazet@google.com
To: mahesh@bandewar.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50204 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S940620AbdAGCSj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 21:18:39 -0500
In-Reply-To: <20170107003311.22940-1-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <mahesh@bandewar.net>
Date: Fri,  6 Jan 2017 16:33:11 -0800

> From: Mahesh Bandewar <maheshb@google.com>
> 
> The patch 009146d117b ("ipvlan: assign unique dev-id for each slave
> device.") used ida_simple_get() to generate dev_ids assigned to the
> slave devices. However (Eric has pointed out that) there is a shortcoming
> with that approach as it always uses the first available ID. This
> becomes a problem when a slave gets deleted and a new slave gets added.
> The ID gets reassigned causing the new slave to get the same link-local
> address. This side-effect is undesirable.
> 
> This patch replaces IDR logic with a simple per-port variable that keeps
> incrementing and wraps around when the MAX (0xFFFE) is reached. The
> only downside is that this is an inefficient (n^2) search if there are
> 64k (or close to 64k) slaves in the system, the dev-id search takes time.
> However having these many devices in the system has it's own challenges.
> 
> Fixes: 009146d117b ("ipvlan: assign unique dev-id for each slave device.")
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

I kind of cringe when I see yet another implementation of an integer ID
allocator.

I think it's much simpler to keep using ida_simple_alloc(), but alongside
it have start point you maintain based upon previous allocations.  Put it
in the ipvl_port, just like dev_id_base, but call it "dev_id_start".

Then your ID allocation sequence becomes:

	err = ida_simple_get(&port->ida, port->dev_id_start, 0xFFFE, GFP_KERNEL);
	if (err < 0)
		err = ida_simple_get(&port->ida, 0, port->dev_id_start, GFP_KERNEL);
	if (err < 0)
		goto destroy_ipvlan_port;

	dev->dev_id = err;

	port->dev_id_start = err;
	if (port->dev_id_start = 0FFFE)
		port->dev_id_start = 0;

Something like that.

Alternatively, IDR/IDA can be extended to have this kind of functionality
too.
