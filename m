From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH 1/2] socket: increase default maximum listen queue length
Date: Mon, 21 Mar 2011 00:04:41 +0100
Message-ID: <1300662282-24741-1-git-send-email-hagen@jauu.net>
References: <20110320121414.GC3038@nuttenaction>
Cc: Hagen Paul Pfeifer <hagen@jauu.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:39231 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751385Ab1CTXEy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Mar 2011 19:04:54 -0400
In-Reply-To: <20110320121414.GC3038@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sysctl_somaxconn (SOMAXCONN: 128) specifies the maximum number of
sockets in state SYN_RECV per listen socket queue. At listen(2) time the
backlog is adjusted to this limit if bigger then that.

Afterwards in reqsk_queue_alloc() the backlog value is checked again
(nr_table_entries == backlog):

    nr_table_entries = min_t(u32, nr_table_entries, sysctl_max_syn_backlog);
    nr_table_entries = max_t(u32, nr_table_entries, 8);
    nr_table_entries = roundup_pow_of_two(nr_table_entries + 1);

sysctl_max_syn_backlog on the other hand is dynamically adjusted,
depending on the memory characteristic of the system. Default is 256,
128 for small systems and up to 1024 for bigger systems.

For real server work the defacto sysctl_somaxconn limit seems inadequate:

    Experiments with real servers show, that it is absolutely not enough
    even at 100conn/sec. 256 cures most of problems.

Increase default sysctl_somaxconn from 128 to 256 to meet todays condition by
simultaneously limit nr_table_entries by sysctl_max_syn_backlog which is
based on memory condition (max(128, (tcp_hashinfo.ehash_mask + 1 / 256)).

Signed_off-by: Hagen Paul Pfeifer <hagen@jauu.net>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/socket.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/socket.h b/include/linux/socket.h
index edbb1d0..bf35ce2 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -237,7 +237,7 @@ struct ucred {
 #define PF_MAX		AF_MAX
 
 /* Maximum queue length specifiable by listen.  */
-#define SOMAXCONN	128
+#define SOMAXCONN	256
 
 /* Flags we can use with send/ and recv. 
    Added those for 1003.1g not all are supported yet
-- 
1.7.4.1.57.g0466.dirty

