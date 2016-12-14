From: Dave Jones <davej@codemonkey.org.uk>
Subject: ipv6: handle -EFAULT from skb_copy_bits
Date: Wed, 14 Dec 2016 10:47:29 -0500
Message-ID: <20161214154729.g4yg4mxcgkvpe5w7@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arcturus.aphlor.org ([188.246.204.175]:36068 "EHLO
        arcturus.aphlor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932404AbcLNPsL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 10:48:11 -0500
Received: from c-65-96-119-39.hsd1.ma.comcast.net ([65.96.119.39] helo=wopr.kernelslacker.org)
        by arcturus.aphlor.org with esmtpsa (TLS1.2:ECDHE_RSA_AES_256_GCM_SHA384:256)
        (Exim 4.87)
        (envelope-from <davej@codemonkey.org.uk>)
        id 1cHBmF-0008UF-1S
        for netdev@vger.kernel.org; Wed, 14 Dec 2016 15:47:31 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems to be possible to craft a packet for sendmsg that triggers
the -EFAULT path in skb_copy_bits resulting in a BUG_ON that looks like:

RIP: 0010:[<ffffffff817c6390>] [<ffffffff817c6390>] rawv6_sendmsg+0xc30/0xc40
RSP: 0018:ffff881f6c4a7c18  EFLAGS: 00010282
RAX: 00000000fffffff2 RBX: ffff881f6c681680 RCX: 0000000000000002
RDX: ffff881f6c4a7cf8 RSI: 0000000000000030 RDI: ffff881fed0f6a00
RBP: ffff881f6c4a7da8 R08: 0000000000000000 R09: 0000000000000009
R10: ffff881fed0f6a00 R11: 0000000000000009 R12: 0000000000000030
R13: ffff881fed0f6a00 R14: ffff881fee39ba00 R15: ffff881fefa93a80

Call Trace:
 [<ffffffff8118ba23>] ? unmap_page_range+0x693/0x830
 [<ffffffff81772697>] inet_sendmsg+0x67/0xa0
 [<ffffffff816d93f8>] sock_sendmsg+0x38/0x50
 [<ffffffff816d982f>] SYSC_sendto+0xef/0x170
 [<ffffffff816da27e>] SyS_sendto+0xe/0x10
 [<ffffffff81002910>] do_syscall_64+0x50/0xa0
 [<ffffffff817f7cbc>] entry_SYSCALL64_slow_path+0x25/0x25

Handle this in rawv6_push_pending_frames and jump to the failure path.

Signed-off-by: Dave Jones <davej@codemonkey.org.uk>

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 291ebc260e70..35aa82faa052 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -591,7 +591,9 @@ static int rawv6_push_pending_frames(struct sock *sk, struct flowi6 *fl6,
 	}
 
 	offset += skb_transport_offset(skb);
-	BUG_ON(skb_copy_bits(skb, offset, &csum, 2));
+	err = skb_copy_bits(skb, offset, &csum, 2);
+	if (err < 0)
+		goto out;
 
 	/* in case cksum was not initialized */
 	if (unlikely(csum))
