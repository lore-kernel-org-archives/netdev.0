From: Dave Jones <davej@redhat.com>
Subject: attempted oversize allocations in tcp_recvmsg.
Date: Wed, 28 Dec 2011 13:44:17 -0500
Message-ID: <20111228184416.GB7901@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24068 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753940Ab1L1Sxg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Dec 2011 13:53:36 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id pBSIrZQf019458
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 28 Dec 2011 13:53:36 -0500
Received: from gelk.kernelslacker.org (ovpn-113-57.phx2.redhat.com [10.3.113.57])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id pBSIiIB2009802
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 28 Dec 2011 13:44:19 -0500
Received: from gelk.kernelslacker.org (localhost [127.0.0.1])
	by gelk.kernelslacker.org (8.14.5/8.14.5) with ESMTP id pBSIiHFW006230
	for <netdev@vger.kernel.org>; Wed, 28 Dec 2011 13:44:17 -0500
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.5/8.14.5/Submit) id pBSIiHQw006229
	for netdev@vger.kernel.org; Wed, 28 Dec 2011 13:44:17 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I got this trace from the page allocator while fuzzing sys_recvfrom

WARNING: at mm/page_alloc.c:2089 __alloc_pages_nodemask+0x39b/0xa50()
Hardware name: X8DTN
Modules linked in: nfnetlink binfmt_misc ip6_queue can_raw can_bcm rfcomm ipt_ULOG cmtp kernelcapi bnep sctp libcrc32c ip_queue dccp_ipv6 dccp_ipv4 >
Pid: 26212, comm: trinity Not tainted 3.1.6-1.fc16.x86_64.debug #1
Call Trace:
 [<ffffffff8107940f>] warn_slowpath_common+0x7f/0xc0
 [<ffffffff8107946a>] warn_slowpath_null+0x1a/0x20
 [<ffffffff811461db>] __alloc_pages_nodemask+0x39b/0xa50
 [<ffffffff8117efa3>] alloc_pages_current+0xa3/0x110
 [<ffffffff81141604>] __get_free_pages+0x14/0x50
 [<ffffffff8118b57f>] kmalloc_order_trace+0x3f/0x170
 [<ffffffff8118bc08>] __kmalloc+0x268/0x290
 [<ffffffff8139a64d>] dma_pin_iovec_pages+0x9d/0x220
 [<ffffffff8157b7e7>] tcp_recvmsg+0x787/0xcb0
 [<ffffffff815a34cb>] inet_recvmsg+0x10b/0x180
 [<ffffffff81511ead>] sock_recvmsg+0x11d/0x140
 [<ffffffff815159e1>] sys_recvfrom+0xf1/0x170
 [<ffffffff816698c2>] system_call_fastpath+0x16/0x1b
---[ end trace 9a0c4dd55e1dbe8a ]---


The code in tcp_recvmsg that passes down the enormous size has these checks..

                if (skb)
                        available = TCP_SKB_CB(skb)->seq + skb->len - (*seq);
                if ((available < target) &&
                    (len > sysctl_tcp_dma_copybreak) && !(flags & MSG_PEEK) &&
                    !sysctl_tcp_low_latency &&
                    dma_find_channel(DMA_MEMCPY)) {
                        preempt_enable_no_resched();
                        tp->ucopy.pinned_list =
                                        dma_pin_iovec_pages(msg->msg_iov, len);
                } else {
                        preempt_enable_no_resched();
                }

I'm guessing there should be a (len < 65535) (or similar constant) in that check ?
Or should we be doing this even sooner in one of the earlier functions?

Also, when that dma_pin_iovec_pages fails, we still proceed through the rest of
tcp_recvmsg. Is that expected ? Or should it be doing a goto out; in that case ?

	Dave
