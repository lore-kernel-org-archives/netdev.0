From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH net-next] rocker: move netevent neigh update to processes
 context
Date: Thu, 21 May 2015 17:53:17 +0900
Message-ID: <555D9CFD.6010001@lab.ntt.co.jp>
References: <1432184707-27252-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, simon.horman@netronome.com
To: sfeldma@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:58877 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751750AbbEUIxj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 04:53:39 -0400
In-Reply-To: <1432184707-27252-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015/05/21 14:05, sfeldma@gmail.com wrote:
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

Hi Scott,

Thank you for fixing this.
Note that this also fixes incorrect use of GFP_KERNEL in
__rocker_port_mem_alloc() and rocker_wait_event_timeout() in interrupt
context, as well as the neigh_tbl_next_index problem stated above.

There seem to be another transactions performed in interrupt context or
process context with bh disabled, where we cannot call
rocker_wait_event_timeout() which could sleep.
Problematic cases I have found so far are those through br_set_state():
- br_stp_rcv() ... -> br_set_state() ... -> rocker_port_attr_set()
- del_nbp() -> br_stp_disable_port() -> br_set_state() ...

Thanks,
Toshiaki Makita
