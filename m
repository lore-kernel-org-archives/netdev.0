From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: buggy check in netlink_mmap_sendmsg()
Date: Sun, 14 Jul 2013 10:36:19 +0100
Message-ID: <20130714093619.GH4165@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:42728 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751595Ab3GNJgU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Jul 2013 05:36:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This
        /* Netlink messages are validated by the receiver before processing.
         * In order to avoid userspace changing the contents of the message
         * after validation, the socket and the ring may only be used by a
         * single process, otherwise we fall back to copying.
         */
        if (atomic_long_read(&sk->sk_socket->file->f_count) > 2 ||  
            atomic_read(&nlk->mapped) > 1)
                excl = false;
looks very odd.  For one thing, descriptor table may be shared, with
one thread calling sendmsg() (which gives f_count equal to 2), while
another calls mmap() just as the first one gets past that check.
Moreover, we might very well have the damn thing mmapped, then clone(2)
creating another thread that shares address space, but not the descriptor
table.  Child closes the socket descriptor it got, then parent does
sendmsg(2) (f_count == 2, again, since this time descriptor table isn't
shared and sendmsg(2) doesn't grab a reference and we have 1 from descriptor
table and 1 from mapping).  Again, the child has it mapped and can play
with it as it wishes...
