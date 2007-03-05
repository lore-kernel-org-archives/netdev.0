From: Jim Chow <jchow@vmware.com>
Subject: [PATCH/RFC] Use of uninitialized data in udp_recvmsg().
Date: Mon, 5 Mar 2007 12:22:44 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0703051212350.21570@jchow-amax.eng.vmware.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.113.40.141]:50625 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933599AbXCEVZm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2007 16:25:42 -0500
Received: from mailhost2.vmware.com (mailhost2.vmware.com [10.16.64.160])
	by smtp-outbound-1.vmware.com (Postfix) with ESMTP id 6884D6C6C
	for <netdev@vger.kernel.org>; Mon,  5 Mar 2007 13:25:11 -0800 (PST)
Received: from jchow-amax.eng.vmware.com (jchow-amax.eng.vmware.com [10.17.161.214])
	by mailhost2.vmware.com (Postfix) with ESMTP id 6205090B54
	for <netdev@vger.kernel.org>; Mon,  5 Mar 2007 13:25:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After inspection of some networking code, it seems there is a use of
uninitialized data in udp_recvmsg(),
linux-2.6.20.1/net/ipv4/udp.c:843, while testing msg->msg_flags (see
the backtrace below).  It looks like sys_recvfrom() is not
initializing msg.msg_flags and, along the path given below, msg_flags
is tested (at #0) without (necessarily) being written to.

A simple fix for this particular problem is given below.

Alternatively, udp_recvmsg() could be changed to initialize msg_flags
for its caller, since udp_recvmsg() (always? [*]) uses msg_flags as an
output argument.

In any case, I wanted to verify the bug with the networking gurus to see 
if they agree.

#0 udp_recvmsg (linux-2.6.20.1/net/ipv4/udp.c:843)
#1 sock_common_recvmsg (linux-2.6.20.1/net/core/sock.c:1617)
#2 sock_recvmsg (linux-2.6.20.1/net/socket.c:630)
#3 sys_recvfrom (linux-2.6.20.1/net/socket.c:1608)
#4 sys_socketcall (linux-2.6.20.1/net/socket.c:2007)
#5 syscall_call (linux-2.6.20.1/arch/i386/kernel/entry.S:0)

Index: linux-2.6.20.1/net/socket.c
===================================================================
--- linux-2.6.20.1.orig/net/socket.c
+++ linux-2.6.20.1/net/socket.c
@@ -1601,6 +1601,7 @@
        iov.iov_base = ubuf;
        msg.msg_name = address;
        msg.msg_namelen = MAX_SOCK_ADDR;
+       msg.msg_flags = 0;
        if (sock->file->f_flags & O_NONBLOCK)
                flags |= MSG_DONTWAIT;
        err = sock_recvmsg(sock, &msg, size, flags);


------

[*] Although do_sock_read() linux-2.6.20.1/net/socket.c:704, for one,
    seems to want to initialize msg_flags nonzero, so maybe not.

