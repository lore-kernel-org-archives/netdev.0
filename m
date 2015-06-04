From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] rocker: move netevent neigh update to
 processes context
Date: Thu, 04 Jun 2015 01:34:09 -0700 (PDT)
Message-ID: <20150604.013409.228829580818256337.davem@davemloft.net>
References: <1433303008-32656-1-git-send-email-sfeldma@gmail.com>
	<20150603.233829.1362177764562847830.davem@davemloft.net>
	<20150604082045.GA7709@vergenet.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, netdev@vger.kernel.org, jiri@resnulli.us,
	makita.toshiaki@lab.ntt.co.jp
To: simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45167 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752282AbbFDIeL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 04:34:11 -0400
In-Reply-To: <20150604082045.GA7709@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>
Date: Thu, 4 Jun 2015 17:20:48 +0900

> What I was seeing is as follows:
> 
> 1. rocker_port_ipv4_nh() is called via switchdev_port_obj_add()
>    with trans = SWITCHDEV_TRANS_PREPARE
> 
> 2. rocker_port_ipv4_neigh() is called by rocker_neigh_update()
>    with trans = SWITCHDEV_TRANS_NONE.
> 
>    The call chain goes up to arp_process() via neigh_update().
> 
> 3. rocker_port_ipv4_nh() is called via switchdev_port_obj_add()
>    with trans = SWITCHDEV_TRANS_COMMIT
> 
> #1 and #2 are guarded by rtl across those calls but
> #2 is not guarded by rtnl.
> 
> Inside both rocker_port_ipv4_nh() and rocker_port_ipv4_neigh()
> neigh_tbl_lock lock is taken but it is not held across the
> two calls to rocker_port_ipv4_nh within a single prepare->commit transaction.
> 
> I can double check that the above still occurs, but I'm not aware of any
> recent changes that would cause it not to occur any more.

Ok, thanks for explaining.

I still don't want this to be moved asynchronosly from the ARP neigh
update event code path.

And therefore I'd like folks to look into another mechanism to fix
this.

If that means the prepare/commit engine is given a spinlock by the
driver to be held across the two calls, so be it.
