From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 0/5 2.6.21-rc7] l2tp: introduce PPP over L2TP driver
Date: Mon, 23 Apr 2007 17:00:03 +0100
Message-ID: <200704231600.l3NG03gc030147@quickie.katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:33468 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753896AbXDWQAp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Apr 2007 12:00:45 -0400
Received: from jchapman.plus.com ([84.92.108.75] helo=quickie.katalix.com)
	by s36.avahost.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.63)
	(envelope-from <jchapman@katalix.com>)
	id 1Hg0y0-00023B-2D
	for netdev@vger.kernel.org; Mon, 23 Apr 2007 11:00:40 -0500
Received: from quickie.katalix.com (quickie.katalix.com [127.0.0.1])
	by quickie.katalix.com (8.13.5/8.13.5) with ESMTP id l3NG03W1030149
	for <netdev@vger.kernel.org>; Mon, 23 Apr 2007 17:00:03 +0100
Received: (from james@localhost)
	by quickie.katalix.com (8.13.5/8.13.5/Submit) id l3NG03gc030147
	for netdev@vger.kernel.org; Mon, 23 Apr 2007 17:00:03 +0100
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch set adds a driver for PPP over L2TP. Patches to follow.

The following changes have been made since the previous version
submitted 23-MAR-07, addressing review comments received so far:-

- Fold makefile changes into the patches that add new source files.

- Make API structures 64-bit safe by avoiding holes inserted by the
  compiler for field alignment.

- Fix list locking.

- Use inlines rather than macros for obtaining local context
  pointers. (Previous code obscured use of variables and labels in
  macros.)

- Use endian-annotated types where appropriate.

- Use skb_queue_walk() for walking skb lists.

- Add check that session doesn't already exist before allowing it to
  be created.

- Remove unnecessary try_module_get() / put_module() calls.

- No need to check for NULL before calling kfree().

- Use macros in jiffies.h for time/jiffy conversion.

- Minimize size of L2TP's private data that is stored in skb->cb[].

- Change transmit path to build UDP header locally and transmit using
  ip_queue_xmit() rather than use the UDP socket's sendmsg(). This
  change also avoids the use of a kernel thread to do the transmit.

- Fix seq file code to avoid potential buffer overflow when there are
  lots of tunnels/sessions.

- Fix some socket refcount/lock bugs. Fixes derived from recent pppoe
  patches. 

The implementation uses the existing PPPoX subsystem that is currently
used only by PPPoE. A userspace daemon handles all L2TP control
protocol messages, while a PPPoX socket carries user data. The system
architecture is similar to PPPoE, where a pppd plugin uses the PPPoX
socket to send/receive PPP frames over an L2TP tunnel. PPP control
frames are delivered to pppd while data frames are handled entirely by
the kernel.

There are 5 patches in the series:-

1 - Introduce skb_queue_walk_safe() macro.

2 - API changes for L2TP. Adds definitions for L2TP in existing headers.

3 - pppol2tp driver core. New code. Requires patches 1 & 2.

4 - Change to PPPoX core to allow PPPoX protocol modules such as
    pppol2tp to be autoloaded via modprobe.conf.

5 - Adds an entry to MAINTAINERS file.

The driver is being used on x86, ia64, ppc, arm, mips32 and possibly
other architectures. It is also known to work on multi-core SMP boxes.

--
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development
