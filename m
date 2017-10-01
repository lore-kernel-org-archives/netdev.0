From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [RFC] compat SIOCADDRT problems
Date: Sun, 1 Oct 2017 23:13:12 +0100
Message-ID: <20171001221312.GG21978@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ralf Baechle <ralf@linux-mips.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:56982 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751063AbdJAWNO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2017 18:13:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Handling of SIOC{ADD,DEL}RT for 32bit is somewhat odd.  AFAICS,
the rules for native ioctl look so:

AF_APPLETALK, AF_INET, AF_IPX, AF_PACKET: take struct rtentry.  The last one
doesn't have ->compat_ioctl() and 32bit automatically hits routing_ioctl()
in net/socket.c, the rest have ->compat_ioctl() but it doesn't recognize
SIOC{ADD,DEL}RT, so it ends up handled by the same code.

AF_INET6: takes struct in6_rtmsg.  Hits routing_ioctl(), which recognizes ipv6
and does the right thing.

AF_X25: takes x25_route_struct.  Layout is apparently identical for 32bit and
64bit.  Has ->compat_ioctl(), which does the same thing as ->ioctl() on those
two.

AF_AX25: takes struct ax25_routes_struct.  Again, identical layout on 32bit
and 64bit.  Unfortunately, there's no ->compat_ioctl() in this one, so we
end up hitting routing_ioctl() and get screwed.
AF_NETROM: same as previous, except that it takes struct nr_route_struct.
Apparently broken.
AF_ROSE: ditto, with struct rose_route_struct.

AF_QIPCRTR: explicitly recognizes and fails with -EINVAL.  Odd (other protocol
families without SIOCADDRT support fail with -ENOTTY), but clearly not an issue
for compat code.

Everything else: fails with -ENOTTY.


	Are AF_{AX25,NETROM,ROSE} really broken for 32bit processes on biarch
hosts, or am I missing something subtle in there?
