From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] cxgb3i: ref count cdev access to prevent modification
 while in use
Date: Tue, 26 Jul 2011 06:50:02 -0400
Message-ID: <20110726105002.GA16987@hmsreliant.think-freely.org>
References: <1311623817-6417-1-git-send-email-nhorman@tuxdriver.com>
 <4E2DDDC5.8040405@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Steve Wise <swise@chelsio.com>,
	"David S. Miller" <davem@davemloft.net>,
	Karen Xie <kxie@chelsio.com>
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33773 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751579Ab1GZKuP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2011 06:50:15 -0400
Content-Disposition: inline
In-Reply-To: <4E2DDDC5.8040405@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 25, 2011 at 02:19:01PM -0700, Divy Le Ray wrote:
> On 07/25/2011 12:56 PM, Neil Horman wrote:
> >
> >This oops was reported recently:
> >d:mon> e
> >cpu 0xd: Vector: 300 (Data Access) at [c0000000fd4c7120]
> >    pc: d00000000076f194: .t3_l2t_get+0x44/0x524 [cxgb3]
> >    lr: d000000000b02108: .init_act_open+0x150/0x3d4 [cxgb3i]
> >    sp: c0000000fd4c73a0
> >   msr: 8000000000009032
> >   dar: 0
> > dsisr: 40000000
> >  current = 0xc0000000fd640d40
> >  paca    = 0xc00000000054ff80
> >    pid   = 5085, comm = iscsid
> >d:mon> t
> >[c0000000fd4c7450] d000000000b02108 .init_act_open+0x150/0x3d4 [cxgb3i]
> >[c0000000fd4c7500] d000000000e45378 .cxgbi_ep_connect+0x784/0x8e8
> >[libcxgbi]
> >[c0000000fd4c7650] d000000000db33f0 .iscsi_if_rx+0x71c/0xb18
> >[scsi_transport_iscsi2]
> >[c0000000fd4c7740] c000000000370c9c .netlink_data_ready+0x40/0xa4
> >[c0000000fd4c77c0] c00000000036f010 .netlink_sendskb+0x4c/0x9c
> >[c0000000fd4c7850] c000000000370c18 .netlink_sendmsg+0x358/0x39c
> >[c0000000fd4c7950] c00000000033be24 .sock_sendmsg+0x114/0x1b8
> >[c0000000fd4c7b50] c00000000033d208 .sys_sendmsg+0x218/0x2ac
> >[c0000000fd4c7d70] c00000000033f55c .sys_socketcall+0x228/0x27c
> >[c0000000fd4c7e30] c0000000000086a4 syscall_exit+0x0/0x40
> >--- Exception: c01 (System Call) at 00000080da560cfc
> >
> >The root cause was an EEH error, which sent us down the
> >offload_close path in
> >the cxgb3 driver, which in turn sets cdev->lldev to NULL, without
> >regard for
> >upper layer driver (like the cxgbi drivers) which might have
> >execution contexts
> >in the middle of its use. The result is the oops above, when
> >t3_l2t_get attempts
> >to dereference cdev->lldev right after the EEH error handler sets
> >it to NULL.
> >
> >The fix is to reference count the cdev structure.  When an EEH
> >error occurs, the
> >shutdown path:
> >t3_adapter_error->offload_close->cxgb3i_remove_clients->cxgb3i_dev_close
> >will now block until such time as the cdev pointer has a use count
> >of zero.
> >This coupled with the fact that lookups will now skip finding any
> >registered
> >cdev's in cxgbi_device_find_by_[lldev|netdev] with the
> >CXGBI_FLAG_ADAPTER_RESET
> >bit set ensures that on an EEH, the setting of lldev to NULL in
> >offload_close
> >will only happen after there are no longer any active users of the data
> >structure.
> >
> >This has been tested by the reporter and shown to fix the reproted oops
> >
> >Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> >CC: Divy Le Ray <divy@chelsio.com>
> >CC: Steve Wise <swise@chelsio.com>
> >CC: "David S. Miller" <davem@davemloft.net>
> >
> 
> Also cc-ing Karen.
> 
Thank you Divy. Karen, if you're going to be working on cxgb3i, would you mind
updating the MAINTINERS file so I and others don't forget to CC you in the
future?

Thanks!
Neil

