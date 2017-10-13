From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [RFC] SIOCGSTAMP semantics
Date: Fri, 13 Oct 2017 21:54:38 +0100
Message-ID: <20171013205438.GJ21978@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:41596 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751186AbdJMUyk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 16:54:40 -0400
Received: from viro by ZenIV.linux.org.uk with local (Exim 4.87 #1 (Red Hat Linux))
        id 1e36yc-0005Ky-Un
        for netdev@vger.kernel.org; Fri, 13 Oct 2017 20:54:39 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	ioctl() in question
1) fails with EOPNOTSUPP on
	AF_ALG, AF_CAIF, AF_IUCV, AF_KEY, AF_NFC, AF_RXRPC, AF_VSOCK
2) fails with ENOTTY on
	AF_DECnet, AF_KCM, AF_LLC, AF_NETLINK, AF_PHONET, AF_PPPOX, AF_RDS,
	AF_TIPC, AF_UNIX
3) fails with EINVAL on
	AF_ISDN
4) sock_get_timestamp(sock->sk, arg)
	AF_INET, AF_INET6, AF_CAN, AF_ROSE, AF_PACKET, AF_IEEE802154,
	AF_ATMSVC, AF_ATMPVC, AF_APPLETALK
5) sock_get_timestamp(sock->sk, arg) under lock_sock(sock->sk)
	AF_AX25, AF_NETROM, AF_QRTR, AF_IPX
6) sock_get_timestamp(sock->sk, arg) after checking that sock->sk != NULL
	AF_X25, AF_IRDA

AF_BLUETOOTH is sometimes (1), sometimes (2), sometimes (4).  Not sure about
AF_SMC - sometimes it's (1), sometimes might be (4).

To make the things even less consistent, AF_CAN, AF_IPX and AF_QRTR lack
SIOCGSTAMPNS; everything else has it parallel to SIOCGSTAMP with s/timestamp/&ns/.

Am I right assuming that (5) and (6) should be like (4)?  IOW, that
lock_sock() is not needed for anyone and that sock->sk cannot be NULL on
anything that could be fed to ioctl()?  If the last assumption is not true,
we have a plenty of triggerable oopsen - other ioctls (handled on the top
level) do _not_ check that and dereference sock->sk directly.  I've grepped
around, and AFAICS NULL sock->sk on an opened socket should be impossible,
but confirmation would be nice.

Another question, of course, is whether anyone gives a damn about distinctions
between (1), (2) and (3) *and* if anything bad would've happenend from having
sock_get_timestamp() simply done to all sockets, right in net/socket.c.

Comments?
