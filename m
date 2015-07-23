From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net 0/4] inet: ip defrag bug fixes
Date: Thu, 23 Jul 2015 12:05:36 +0200
Message-ID: <1437645940-7895-1-git-send-email-fw@strlen.de>
Cc: Johan Schuijt <johan@transip.nl>,
	Frank Schreuder <fschreuder@transip.nl>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:41973 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752758AbbGWKjm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 06:39:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johan Schuijt and Frank Schreuder reported crash and softlockup after the
inet workqueue eviction change:

general protection fault: 0000 [#1] SMP
CPU: 0 PID: 4 Comm: kworker/0:0 Not tainted 3.18.18-transip-1.5 #1
Workqueue: events inet_frag_worker
task: ffff880224935130 ti: ffff880224938000 task.ti: ffff880224938000
RIP: 0010:[<ffffffff8149288c>] [<ffffffff8149288c>] inet_evict_bucket+0xfc/0x160
RSP: 0018:ffff88022493bd58  EFLAGS: 00010286
RAX: ffff88021f4f3e80 RBX: dead000000100100 RCX: 000000000000006b
RDX: 000000000000006c RSI: ffff88021f4f3e80 RDI: dead0000001000a8
RBP: 0000000000000002 R08: ffff880222273900 R09: ffff880036e49200
R10: ffff8800c6e86500 R11: ffff880036f45500 R12: ffffffff81a87100
R13: ffff88022493bd70 R14: 0000000000000000 R15: ffff8800c9b26280
[..]
Call Trace:
 [<ffffffff814929e0>] ? inet_frag_worker+0x60/0x210
 [<ffffffff8107e3a2>] ? process_one_work+0x142/0x3b0
 [<ffffffff8107eb94>] ? worker_thread+0x114/0x440
[..]

A second issue results in softlockup since the evictor may restart the
eviction loop for a (potentially) unlimited number of times while local
softirqs are disabled.

Frank reports that test system remained stable for 14 hours of testing
(before, crash occured within half an hour in their setup).

Florian Westphal (3):
      inet: frag: don't re-use chainlist for evictor
      inet: frag: change *_frag_mem_limit functions to take netns_frags as argument
      inet: frag: don't wait for timer deletion when evicting

Nikolay Aleksandrov (1):
      inet: frags: remove INET_FRAG_EVICTED and use list_evictor for the test

 include/net/inet_frag.h                 |   17 ++++++++-----
 net/ieee802154/6lowpan/reassembly.c     |    6 ++--
 net/ipv4/inet_fragment.c                |   40 ++++++++++++--------------------
 net/ipv4/ip_fragment.c                  |   12 ++++-----
 net/ipv6/netfilter/nf_conntrack_reasm.c |    6 ++--
 net/ipv6/reassembly.c                   |    8 +++---
 6 files changed, 42 insertions(+), 47 deletions(-)
