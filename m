From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: very odd check in caif_seqpkt_sendmsg()
Date: Thu, 20 Nov 2014 08:54:25 +0000
Message-ID: <20141120085425.GM7996@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:58369 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755849AbaKTIy0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 03:54:26 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This check is very odd:
        if (unlikely(msg->msg_iov->iov_base == NULL))
                goto err;
What happens if we get call it with msg_iovlen being 0?  verify_iovec()
(or rw_copy_check_uvector(), for that matter) is just fine with that -
sendmsg() purely for msg_control is normal on e.g. AF_UNIX sockets.
And we end with ->msg_iov pointing to iovstack[], with iovstack[0] being
uninitialized.  So at the very least your check is going to yield random
results in that case.

What is it supposed to check for?  Note that memcpy_fromiovec() won't blow
up on NULL ->iov_base - with zero len it won't even look there and with
non-zero it'll fail with -EFAULT.

Was that intended to be if (unlikely(!len)) fail with EINVAL?  Something
entirely different?
