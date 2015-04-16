From: Tejun Heo <tj@kernel.org>
Subject: [PATCHSET] printk, netconsole: implement reliable netconsole
Date: Thu, 16 Apr 2015 19:03:37 -0400
Message-ID: <1429225433-11946-1-git-send-email-tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: akpm@linux-foundation.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:34433 "EHLO
	mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753570AbbDPXER (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 19:04:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In a lot of configurations, netconsole is a useful way to collect
system logs; however, all netconsole does is simply emitting UDP
packets for the raw messages and there's no way for the receiver to
find out whether the packets were lost and/or reordered in flight.

printk already keeps log metadata which contains enough information to
make netconsole reliable.  This patchset does the followings.

* Make printk metadata available to console drivers.  A console driver
  can request this mode by setting CON_EXTENDED.  The metadata is
  emitted in the same format as /dev/kmsg.  This also makes all
  logging metadata including facility, loglevel and dictionary
  available to console receivers.

* Implement extended mode support in netconsole.  When enabled,
  netconsole transmits messages with extended header which is enough
  for the receiver to detect missing messages.

* Implement netconsole retransmission support.  Matching rx socket on
  the source port is automatically created for extended targets and
  the log receiver can request retransmission by sending reponse
  packets.  This is completely decoupled from the main write path and
  doesn't make netconsole less robust when things start go south.

* Implement netconsole ack support.  The response packet can
  optionally contain ack which enables emergency transmission timer.
  If acked sequence lags the current sequence for over 10s, netconsole
  repeatedly re-sends unacked messages with increasing interval.  This
  ensures that the receiver has the latest messages and also that all
  messages are transferred even while the kernel is failing as long as
  timer and netpoll are operational.  This too is completely decoupled
  from the main write path and doesn't make netconsole less robust.

* Implement the receiver library and simple receiver using it
  respectively in tools/lib/netconsole/libncrx.a and tools/ncrx/ncrx.
  In a simulated test with heavy packet loss (50%), ncrx logs all
  messages reliably and handle exceptional conditions including
  reboots as expected.

An obvious alternative for reliable loggin would be using a separate
TCP connection in addition to the UDP packets; however, I decided for
UDP based retransmission and ack mechanism for the following reasons.

* kernel side doesn't get simpler by using TCP.  It'd still need to
  transmit extended format messages, which BTW are useful regardless
  of reliable transmission, to match up UDP and TCP messages and
  detect missing ones from TCP send buffer filling up.  Also, the
  timeout and emergency transmission support would still be necessary
  to ensure that messages are transmitted in case of, e.g., network
  stack faiure.  It'd at least be about the same amount of code as the
  UDP based implementation.

* Receiver side might be a bit simpler but not by much.  It'd still
  need to keep track of the UDP based messages and then match them up
  with TCP messages and put messages from both sources in order (each
  stream may miss different ones) and would have to deal with
  reestablishing connections after reboots.  The only part which can
  completely go away would be the actual ack and retransmission part
  and that isn't a lot of logic.

* When the network condition is good, the only thing the UDP based
  implementation adds is occassional ack messages.  TCP based
  implementation would end up transmitting all messages twice which
  still isn't much but kinda silly given that using TCP doesn't lower
  the complexity in meaningful ways.

This patchset contains the following 16 patches.

 0001-printk-guard-the-amount-written-per-line-by-devkmsg_.patch
 0002-printk-factor-out-message-formatting-from-devkmsg_re.patch
 0003-printk-move-LOG_NOCONS-skipping-into-call_console_dr.patch
 0004-printk-implement-support-for-extended-console-driver.patch
 0005-printk-implement-log_seq_range-and-ext_log_from_seq.patch
 0006-netconsole-make-netconsole_target-enabled-a-bool.patch
 0007-netconsole-factor-out-alloc_netconsole_target.patch
 0008-netconsole-punt-disabling-to-workqueue-from-netdevic.patch
 0009-netconsole-replace-target_list_lock-with-console_loc.patch
 0010-netconsole-introduce-netconsole_mutex.patch
 0011-netconsole-consolidate-enable-disable-and-create-des.patch
 0012-netconsole-implement-extended-console-support.patch
 0013-netconsole-implement-retransmission-support-for-exte.patch
 0014-netconsole-implement-ack-handling-and-emergency-tran.patch
 0015-netconsole-implement-netconsole-receiver-library.patch
 0016-netconsole-update-documentation-for-extended-netcons.patch

0001-0005 implement extended console support in printk.

0006-0011 are prep patches for netconsole.

0012-0014 implement extended mode, retransmission and ack support.

0015 implements receiver library, libncrx, and a simple receiver using
the library, ncrx.

0016 updates documentation.

As the patchset touches both printk and netconsole, I'm not sure how
these patches should be routed once acked.  Either -mm or net should
work, I think.

This patchset is on top of linus#master[1] and available in the
following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/misc.git review-netconsole-ext

diffstat follows.  Thanks.

 Documentation/networking/netconsole.txt |   95 +++
 drivers/net/netconsole.c                |  800 +++++++++++++++++++++++-----
 include/linux/console.h                 |    1 
 include/linux/printk.h                  |   16 
 kernel/printk/printk.c                  |  411 +++++++++++---
 tools/Makefile                          |   16 
 tools/lib/netconsole/Makefile           |   36 +
 tools/lib/netconsole/ncrx.c             |  906 ++++++++++++++++++++++++++++++++
 tools/lib/netconsole/ncrx.h             |  204 +++++++
 tools/ncrx/Makefile                     |   14 
 tools/ncrx/ncrx.c                       |  143 +++++
 11 files changed, 2419 insertions(+), 223 deletions(-)

--
tejun

[1] 497a5df7bf6f ("Merge tag 'stable/for-linus-4.1-rc0-tag' of git://git.kernel.org/pub/scm/linux/kernel/git/xen/tip")
