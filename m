From: Dave Jones <davej@redhat.com>
Subject: ipqueue allocation failure.
Date: Tue, 19 Apr 2011 21:42:22 -0400
Message-ID: <20110420014221.GC26949@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49648 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752690Ab1DTBmY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2011 21:42:24 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p3K1gO4g012883
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 19 Apr 2011 21:42:24 -0400
Received: from gelk.kernelslacker.org (ovpn-113-123.phx2.redhat.com [10.3.113.123])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id p3K1gN05001976
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 19 Apr 2011 21:42:24 -0400
Received: from gelk.kernelslacker.org (gelk [127.0.0.1])
	by gelk.kernelslacker.org (8.14.4/8.14.4) with ESMTP id p3K1gMZd029350
	for <netdev@vger.kernel.org>; Tue, 19 Apr 2011 21:42:22 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.4/8.14.4/Submit) id p3K1gMiA029348
	for netdev@vger.kernel.org; Tue, 19 Apr 2011 21:42:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not catastrophic, but ipqueue seems to be too trusting of what it gets
passed from userspace, and passes it on down to the page allocator,
where it will spew warnings if the page order is too high.

__ipq_rcv_skb has several checks for lengths too small, but doesn't
seem to have any for oversized ones.   I'm not sure what the maximum
we should check for is. I'll code up a diff if anyone has any ideas
on a sane maximum.

	Dave

------------[ cut here ]------------
WARNING: at mm/page_alloc.c:2032 __alloc_pages_nodemask+0x17d/0x7e6()
Hardware name: GA-MA78GM-S2H
Modules linked in: rfcomm hidp can_raw can_bcm sctp libcrc32c ip_queue decnet pppoe pppox ppp_generic slhc can ipx p8022 p8023 phonet bluetooth rfkill a]
Pid: 20393, comm: trinity Not tainted 2.6.39-rc4+ #6
Call Trace:
 [<ffffffff81056a9c>] warn_slowpath_common+0x83/0x9b
 [<ffffffff81056ace>] warn_slowpath_null+0x1a/0x1c
 [<ffffffff810ed743>] __alloc_pages_nodemask+0x17d/0x7e6
 [<ffffffff811206c9>] ? check_object+0x174/0x1ae
 [<ffffffff81120a43>] ? check_slab+0xc7/0xd5
 [<ffffffff813f42fe>] ? __alloc_skb+0x40/0x133
 [<ffffffff813f42fe>] ? __alloc_skb+0x40/0x133
 [<ffffffff814b7487>] kmalloc_large_node+0x56/0x95
 [<ffffffff811235c1>] __kmalloc_node_track_caller+0x32/0x139
 [<ffffffff81421b68>] ? netlink_ack+0x4a/0xe8
 [<ffffffffa0500475>] ? ipq_rcv_skb+0x27/0x340 [ip_queue]
 [<ffffffff813f4333>] __alloc_skb+0x75/0x133
 [<ffffffff81421b68>] netlink_ack+0x4a/0xe8
 [<ffffffffa050076a>] ipq_rcv_skb+0x31c/0x340 [ip_queue]
 [<ffffffff8142174a>] netlink_unicast+0xec/0x156
 [<ffffffff81421a33>] netlink_sendmsg+0x27f/0x2c0
 [<ffffffff813ed76c>] __sock_sendmsg+0x69/0x75
 [<ffffffff813ed834>] sock_aio_write+0xbc/0xcc
 [<ffffffff8113242b>] do_sync_write+0xbf/0xff
 [<ffffffff81206e18>] ? security_file_permission+0x2e/0x33
 [<ffffffff81132861>] ? rw_verify_area+0xb6/0xd3
 [<ffffffff81132b02>] vfs_write+0xb6/0xf6
 [<ffffffff8113400b>] ? fget_light+0x3a/0xa1
 [<ffffffff81132cf6>] sys_write+0x4d/0x74
 [<ffffffff814c5d82>] system_call_fastpath+0x16/0x1b
---[ end trace cd56dc75cfeab436 ]---

