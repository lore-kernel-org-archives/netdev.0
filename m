From: Dave Jones <davej@redhat.com>
Subject: ppp/l2tp doing oversized allocations ?
Date: Mon, 14 May 2012 12:29:23 -0400
Message-ID: <20120514162923.GA4439@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Fedora Kernel Team <kernel-team@fedoraproject.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45320 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757183Ab2ENQ32 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 May 2012 12:29:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We just got this trace from reported by a Fedora user running 3.3.4

:WARNING: at mm/page_alloc.c:2204 __alloc_pages_nodemask+0x231/0x8f0()
:Call Trace:
: [<ffffffff81057abf>] warn_slowpath_common+0x7f/0xc0
: [<ffffffff81057b1a>] warn_slowpath_null+0x1a/0x20
: [<ffffffff81129671>] __alloc_pages_nodemask+0x231/0x8f0
: [<ffffffff814e84db>] ? dev_queue_xmit+0x1db/0x640
: [<ffffffff8151f210>] ? ip_forward_options+0x1f0/0x1f0
: [<ffffffff814ef7a1>] ? neigh_direct_output+0x11/0x20
: [<ffffffff81520dee>] ? ip_finish_output+0x17e/0x2f0
: [<ffffffff8151f210>] ? ip_forward_options+0x1f0/0x1f0
: [<ffffffff811608d3>] alloc_pages_current+0xa3/0x110
: [<ffffffff811254b4>] __get_free_pages+0x14/0x50
: [<ffffffff8116b99f>] kmalloc_order_trace+0x3f/0xd0
: [<ffffffff8156d137>] ? xfrm4_output_finish+0x27/0x40
: [<ffffffff8116c8c7>] __kmalloc+0x177/0x1a0
: [<ffffffff81521196>] ? ip_queue_xmit+0x156/0x400
: [<ffffffff814dab07>] pskb_expand_head+0x87/0x310
: [<ffffffff8113dbf9>] ? __mod_zone_page_state+0x49/0x50
: [<ffffffffa05e84dd>] pppol2tp_xmit+0x1ed/0x220 [l2tp_ppp]
: [<ffffffffa05d3d5b>] ppp_push+0x15b/0x650 [ppp_generic]
: [<ffffffff814dacc4>] ? pskb_expand_head+0x244/0x310
: [<ffffffff811285ab>] ? free_compound_page+0x1b/0x20
: [<ffffffff8112cff3>] ? __put_compound_page+0x23/0x30
: [<ffffffff8112d175>] ? put_compound_page+0x125/0x1c0
: [<ffffffffa05d489f>] ppp_xmit_process+0x46f/0x660 [ppp_generic]
: [<ffffffffa05d4bc8>] ppp_start_xmit+0x138/0x1d0 [ppp_generic]
: [<ffffffff814e7f62>] dev_hard_start_xmit+0x332/0x6d0
: [<ffffffff81503e2a>] sch_direct_xmit+0xfa/0x1d0
: [<ffffffff81503fa6>] __qdisc_run+0xa6/0x130
: [<ffffffff814e84be>] dev_queue_xmit+0x1be/0x640
: [<ffffffff8151f210>] ? ip_forward_options+0x1f0/0x1f0
: [<ffffffff814ef7a1>] neigh_direct_output+0x11/0x20
: [<ffffffff81520dee>] ip_finish_output+0x17e/0x2f0
: [<ffffffff81521906>] ip_output+0x66/0xa0
: [<ffffffff81521002>] ? __ip_local_out+0xa2/0xb0
: [<ffffffff815792ae>] xfrm_output_resume+0x38e/0x3f0
: [<ffffffff8116c0db>] ? kfree+0x3b/0x150
: [<ffffffff81297a10>] ? cryptd_free+0x60/0x60
: [<ffffffffa04fc110>] esp_output_done+0x30/0x40 [esp4]
: [<ffffffffa05ed774>] authenc_request_complete+0x14/0x20 [authenc]
: [<ffffffffa05ede4e>] crypto_authenc_givencrypt_done+0x2e/0x40 [authenc]
: [<ffffffff8129728c>] cryptd_blkcipher_crypt+0x5c/0x70
: [<ffffffff812972dc>] cryptd_blkcipher_encrypt+0x1c/0x20
: [<ffffffff81297a66>] cryptd_queue_worker+0x56/0x80
: [<ffffffff810747ae>] process_one_work+0x11e/0x470
: [<ffffffff810755bf>] worker_thread+0x15f/0x360
: [<ffffffff81075460>] ? manage_workers+0x230/0x230
: [<ffffffff81079da3>] kthread+0x93/0xa0
: [<ffffffff815fd2a4>] kernel_thread_helper+0x4/0x10
: [<ffffffff81079d10>] ? kthread_freezable_should_stop+0x70/0x70
: [<ffffffff815fd2a0>] ? gs_change+0x13/0x13

That WARN statement is this in the page allocator..

2197         /*
2198          * In the slowpath, we sanity check order to avoid ever trying to
2199          * reclaim >= MAX_ORDER areas which will never succeed. Callers may
2200          * be using allocators in order of preference for an area that is
2201          * too large.
2202          */
2203         if (order >= MAX_ORDER) {
2204                 WARN_ON_ONCE(!(gfp_mask & __GFP_NOWARN));
2205                 return NULL;
2206         }



	Dave
