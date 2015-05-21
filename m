From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next] rocker: move netevent neigh update to processes
 context
Date: Thu, 21 May 2015 16:37:17 +0900
Message-ID: <20150521073714.GA14316@vergenet.net>
References: <1432184707-27252-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	makita.toshiaki@lab.ntt.co.jp
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:36363 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927AbbEUHh1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 03:37:27 -0400
Received: by pdfh10 with SMTP id h10so98973779pdf.3
        for <netdev@vger.kernel.org>; Thu, 21 May 2015 00:37:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1432184707-27252-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 20, 2015 at 10:05:07PM -0700, sfeldma@gmail.com wrote:
> From: Scott Feldman <sfeldma@gmail.com>
> 
> In review of Simon's patchset "rocker: transaction fixes". it was noted
> that rocker->neigh_tbl_next_index was unprotected in the call path below
> and could race with other contexts calling rocker_port_ipv4_neigh():
> 
> 	arp_process()
> 	neigh_update()
> 	rocker_neigh_update()
> 	rocker_port_ipv4_neigh()
> 
> To fix, move the neigh_update() event processing to process contexts and
> hold rtnl_lock to call rocker_port_ipv4_neigh().  This will protect
> rocker->neigh_tbl_next_index accesses and is more consistent with the rest
> of the driver code where non-I/O processing is done under process context
> with rtnl_lock held.
> 
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Hi Scott,

this patch does what it says on the wrapper and in itself looks good.

Reviewed-by: Simon Horman <simon.horman@netronome.com>

However, this patch seems to expose another bug.
With it applied I see the following:

ip addr add 10.0.99.192/24 dev eth0
ip link set up dev eth0
ip route add 10.0.97.0/24 via 10.0.99.135

1. Prepare Phase:

   rocker_port_ipv4_nh() -> rocker_port_ipv4_resolve()

   In rocker_port_ipv4_resolve() n->nud_state & NUD_VALID is false
   and rocker_port_ipv4_neigh() is not called.

2. Commit Phase:

   rocker_port_ipv4_nh() -> rocker_port_ipv4_resolve()

   In rocker_port_ipv4_resolve() n->nud_state & NUD_VALID is now true
   and rocker_port_ipv4_neigh() is called.

   rocker_port_ipv4_neigh() calls rocker_port_kzalloc() which
   reports a bug because there was no corresponding call during the prepare
   phase.

In a nutshell the rocker_port_*alloc calls are not symmetric in the two
phases because of an external state change (in the neighbour table
in the core of the network stack).
