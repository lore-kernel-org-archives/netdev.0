From: Dave Jones <davej@redhat.com>
Subject: limit allocation size in ieee802154_sock_sendmsg
Date: Wed, 11 Jul 2012 18:12:09 -0400
Message-ID: <20120711221209.GA30506@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59237 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932203Ab2GKWMN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2012 18:12:13 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q6BMCDNX002427
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 11 Jul 2012 18:12:13 -0400
Received: from gelk.kernelslacker.org (ovpn-112-42.phx2.redhat.com [10.3.112.42])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id q6BMCBrY022242
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 11 Jul 2012 18:12:12 -0400
Received: from gelk.kernelslacker.org (localhost [127.0.0.1])
	by gelk.kernelslacker.org (8.14.5/8.14.5) with ESMTP id q6BMCAKN001341
	for <netdev@vger.kernel.org>; Wed, 11 Jul 2012 18:12:10 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.5/8.14.5/Submit) id q6BMC9De001339
	for netdev@vger.kernel.org; Wed, 11 Jul 2012 18:12:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sasha reported this last November (https://lkml.org/lkml/2011/11/22/41)
and I keep walking into it while fuzz testing.

Length of the packet is passed in from userspace, and passed down to the
page allocator unchecked. If the allocation size is bigger than MAX_ORDER,
we get this backtrace from the page allocator.

 WARNING: at mm/page_alloc.c:2298 __alloc_pages_nodemask+0x46d/0xb00()
 Call Trace:
  [<ffffffff81064b2f>] warn_slowpath_common+0x7f/0xc0
  [<ffffffff81064b8a>] warn_slowpath_null+0x1a/0x20
  [<ffffffff8116105d>] __alloc_pages_nodemask+0x46d/0xb00
  [<ffffffff8155ed3b>] ? __alloc_skb+0x4b/0x230
  [<ffffffff810d43dd>] ? trace_hardirqs_on+0xd/0x10
  [<ffffffff816ace3f>] kmalloc_large_node+0x66/0xab
  [<ffffffff811ad9b5>] __kmalloc_node_track_caller+0x1b5/0x200
  [<ffffffff81559701>] ? sock_alloc_send_pskb+0x271/0x3e0
  [<ffffffff8155ed68>] __alloc_skb+0x78/0x230
  [<ffffffff81559701>] sock_alloc_send_pskb+0x271/0x3e0
  [<ffffffff8156d331>] ? dev_getfirstbyhwtype+0x161/0x250
  [<ffffffff8156d1d0>] ? rps_may_expire_flow+0x220/0x220
  [<ffffffff81559885>] sock_alloc_send_skb+0x15/0x20
  [<ffffffffa4a73347>] dgram_sendmsg+0xe7/0x340 [af_802154]
  [<ffffffffa4a72044>] ieee802154_sock_sendmsg+0x14/0x20 [af_802154]
  [<ffffffff81553787>] sock_sendmsg+0x117/0x130
  [<ffffffff810cdb7d>] ? trace_hardirqs_off+0xd/0x10
  [<ffffffff816b81c7>] ? _raw_spin_unlock_irqrestore+0x77/0x80
  [<ffffffff8134312b>] ? debug_object_activate+0x12b/0x1a0
  [<ffffffff816b81c7>] ? _raw_spin_unlock_irqrestore+0x77/0x80
  [<ffffffff81556b60>] sys_sendto+0x140/0x190
  [<ffffffff816c5014>] ? bad_to_user+0x5e/0x80a
  [<ffffffff8133c04e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
  [<ffffffff816c15e9>] system_call_fastpath+0x16/0x1b

Signed-off-by: Dave Jones <davej@redhat.com>

diff --git a/net/ieee802154/af_ieee802154.c b/net/ieee802154/af_ieee802154.c
index 40e606f..1da228a 100644
--- a/net/ieee802154/af_ieee802154.c
+++ b/net/ieee802154/af_ieee802154.c
@@ -108,6 +108,9 @@ static int ieee802154_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 {
 	struct sock *sk = sock->sk;
 
+	if (len > MAX_ORDER_NR_PAGES * PAGE_SIZE)
+		return -EINVAL;
+
 	return sk->sk_prot->sendmsg(iocb, sk, msg, len);
 }
 
