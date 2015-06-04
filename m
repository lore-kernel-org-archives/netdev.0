From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next v2] rocker: move netevent neigh update to
 processes context
Date: Thu, 4 Jun 2015 17:20:48 +0900
Message-ID: <20150604082045.GA7709@vergenet.net>
References: <1433303008-32656-1-git-send-email-sfeldma@gmail.com>
 <20150603.233829.1362177764562847830.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfeldma@gmail.com, netdev@vger.kernel.org, jiri@resnulli.us,
	makita.toshiaki@lab.ntt.co.jp
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36381 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752114AbbFDIU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 04:20:59 -0400
Received: by pabqy3 with SMTP id qy3so24763725pab.3
        for <netdev@vger.kernel.org>; Thu, 04 Jun 2015 01:20:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150603.233829.1362177764562847830.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

On Wed, Jun 03, 2015 at 11:38:29PM -0700, David Miller wrote:
> From: sfeldma@gmail.com
> Date: Tue,  2 Jun 2015 20:43:28 -0700
> 
> > From: Scott Feldman <sfeldma@gmail.com>
> > 
> > v2:
> > 
> > Changes based on review:
> > 
> > - David Miller <davem@davemloft.net> raise problem with system_wq not
> >   preserving queue order to execution order.  To fix, use driver-private
> >   ordered workqueue to preserve ordering of queued work.
> > 
> > - Jiri Pirko <jiri@resnulli.us> small change on kfree of work queue item.
> > 
> > v1:
> > 
> > In review of Simon's patchset "rocker: transaction fixes". it was noted
> > that rocker->neigh_tbl_next_index was unprotected in the call path below
> > and could race with other contexts calling rocker_port_ipv4_neigh():
> 
> How it rocker->neigh_tbl_next_index not protected?
> 
> rocker->neigh_tbl_lock is _always_ held when it is accessed.
> 
> This patch, therefore, looks like completely unnecessary complexity
> to me.  Furthermore, I would completely prefer if the operation stays
> completely synchronous to the call path where the neigh operation
> occurs rather than throwing it out to a workqueue.

What I was seeing is as follows:

1. rocker_port_ipv4_nh() is called via switchdev_port_obj_add()
   with trans = SWITCHDEV_TRANS_PREPARE

2. rocker_port_ipv4_neigh() is called by rocker_neigh_update()
   with trans = SWITCHDEV_TRANS_NONE.

   The call chain goes up to arp_process() via neigh_update().

3. rocker_port_ipv4_nh() is called via switchdev_port_obj_add()
   with trans = SWITCHDEV_TRANS_COMMIT

#1 and #2 are guarded by rtl across those calls but
#2 is not guarded by rtnl.

Inside both rocker_port_ipv4_nh() and rocker_port_ipv4_neigh()
neigh_tbl_lock lock is taken but it is not held across the
two calls to rocker_port_ipv4_nh within a single prepare->commit transaction.

I can double check that the above still occurs, but I'm not aware of any
recent changes that would cause it not to occur any more.
