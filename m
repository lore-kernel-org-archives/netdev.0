From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 0/5 2.6.21] L2TP: Introduce PPP-over-L2TP driver
Date: Mon, 30 Apr 2007 10:51:01 +0100
Message-ID: <200704300951.l3U9p17K031833@quickie.katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:42103 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031516AbXD3Jvn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2007 05:51:43 -0400
Received: from jchapman.plus.com ([84.92.108.75] helo=quickie.katalix.com)
	by s36.avahost.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.63)
	(envelope-from <jchapman@katalix.com>)
	id 1HiSXl-00060S-7o
	for netdev@vger.kernel.org; Mon, 30 Apr 2007 04:51:41 -0500
Received: from quickie.katalix.com (quickie.katalix.com [127.0.0.1])
	by quickie.katalix.com (8.13.5/8.13.5) with ESMTP id l3U9p1xx031835
	for <netdev@vger.kernel.org>; Mon, 30 Apr 2007 10:51:01 +0100
Received: (from james@localhost)
	by quickie.katalix.com (8.13.5/8.13.5/Submit) id l3U9p17K031833
	for netdev@vger.kernel.org; Mon, 30 Apr 2007 10:51:01 +0100
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch set adds a driver for PPP over L2TP. Patches to follow.

The following changes have been made since the previous version
submitted 23-APR-07.

- Hold list lock while processing reorder queue in
  pppol2tp_recv_dequeue().

- Fix more __be type annotations.

- Add a new UDP encapsulation socket type for L2TP (new patch). Modify
  driver receive path so that it hooks on udp_encap_rcv() rather than
  overload the socket's sk_data_ready() for skb reception.

- Remove pppol2tp_fget() and friends. Previous code needed to find the
  tunnel fd from a context other than the one that created the
  socket. I now use the PPPoX management socket creation (which is
  done by the same process that creates the UDP socket, i.e. l2tpd) to
  derive the socket of the UDP tunnel using sockfd_lookup().

- Reorder some functions in proc file handling code to avoid needing
  function prototypes.

- Remove code that sorted entries which are output in
  /proc/net/pppol2tp. Output now shows tunnels and sessions unordered.

- Remove stupid userland conditional includes from the if_pppox.h
  changes.

- Remove skb_queue_walk_safe and pppox-autoload patches from the
  series since they have now been applied.

- Add in-kernel documentation (new patch).

- Rebased to 2.6.21.

The code still uses sk->sk_destruct() on the tunnel socket to cleanup
internal contexts if the tunnel UDP socket is destroyed.


About this patch series:

The implementation uses the existing PPPoX subsystem that is currently
used only by PPPoE. A userspace daemon handles all L2TP control
protocol messages, while a PPPoX socket carries user data. The system
architecture is similar to PPPoE, where a pppd plugin uses the PPPoX
socket to send/receive PPP frames over an L2TP tunnel. PPP control
frames are delivered to pppd while data frames are handled entirely by
the kernel.

There are 5 patches in the series:-

1 - Introduce new UDP encapsulation type for L2TP.

2 - API changes for L2TP. Adds definitions for L2TP in existing headers.

3 - pppol2tp driver core. New code. Requires patches 1, 2, and the 
    recently applied skb_queue_walk_safe patch.

4 - Add an entry to MAINTAINERS file for this driver.

5 - Add in-kernel documentation.

The driver is being used on x86, ia64, ppc, arm, mips32 and possibly
other architectures. It is also known to work on multi-core SMP boxes.

--
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development
