From: Piotr Wilczek <p.wilczek@samsung.com>
Subject: [PATCH net-next V2 0/2] send process status in SCM_PROCINFO
Date: Thu, 26 Jun 2014 14:55:52 +0200
Message-ID: <1403787354-15177-1-git-send-email-p.wilczek@samsung.com>
Cc: netdev@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>,
	Juho Son <juho80.son@samsung.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Jan Kaluza <jkaluza@redhat.com>,
	Piotr Wilczek <p.wilczek@samsung.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:26518 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752295AbaFZM4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 08:56:46 -0400
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N7S009AK1AL0920@mailout2.samsung.com> for
 netdev@vger.kernel.org; Thu, 26 Jun 2014 21:56:45 +0900 (KST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Server-like processes in many cases need credentials and other
metadata of the peer, to decide if the calling process is allowed to
request a specific action, or the server just wants to log away this
type of information for auditing tasks.

The current practice to retrieve such process metadata is to look that
information up in procfs with the $PID received over SCM_CREDENTIALS.
This is sufficient for long-running tasks, but introduces a race which
cannot be worked around for short-living processes; the calling
process and all the information in /proc/$PID/ is gone before the
receiver of the socket message can look it up.

Changes introduced in this patchset can also increase performance
of such server-like processes, because current way of opening and
parsing /proc/$PID/* files is much more expensive than receiving these
metadata using SCM.

As an example, this patch set improves systemd-journald performance
by about 20%. Generally, performance improvement depends on how heavily
procfs is read the calling process.
http://comments.gmane.org/gmane.comp.sysutils.systemd.devel/19467

This patch set is split in two patches:
- the first adds library to retrive process information without
dependency on procfs.
- the second introduces a new SCM type called SCM_PROCINFO to optionally
allow the direct attaching of process status to SCM.

This patchset is reworked version of:
https://lkml.org/lkml/2014/1/13/42

Changes for v2:
 - new patch with new proc info library
 - removed extern declaration
 - removed duplication code for parsing process information

Piotr Wilczek (2):
  lib:proc_info:add library to get process information
  Send process status in SCM_PROCINFO

 arch/alpha/include/uapi/asm/socket.h   |   2 +
 arch/avr32/include/uapi/asm/socket.h   |   2 +
 arch/cris/include/uapi/asm/socket.h    |   2 +
 arch/frv/include/uapi/asm/socket.h     |   2 +
 arch/ia64/include/uapi/asm/socket.h    |   2 +
 arch/m32r/include/uapi/asm/socket.h    |   2 +
 arch/mips/include/uapi/asm/socket.h    |   2 +
 arch/mn10300/include/uapi/asm/socket.h |   2 +
 arch/parisc/include/uapi/asm/socket.h  |   2 +
 arch/powerpc/include/uapi/asm/socket.h |   2 +
 arch/s390/include/uapi/asm/socket.h    |   2 +
 arch/sparc/include/uapi/asm/socket.h   |   2 +
 fs/proc/Kconfig                        |   1 +
 fs/proc/array.c                        | 476 +----------------------
 fs/proc/task_mmu.c                     |  66 ----
 fs/proc/task_nommu.c                   | 114 ------
 include/linux/net.h                    |   1 +
 include/linux/proc_info.h              |  35 ++
 include/linux/socket.h                 |   2 +
 include/net/af_unix.h                  |   9 +
 include/net/scm.h                      |  33 ++
 include/uapi/asm-generic/socket.h      |   2 +
 lib/Kconfig                            |   5 +
 lib/Makefile                           |   2 +
 lib/proc_info.c                        | 686 +++++++++++++++++++++++++++++++++
 net/Kconfig                            |   1 +
 net/core/scm.c                         | 166 ++++++++
 net/core/sock.c                        |  11 +
 net/unix/af_unix.c                     |  70 ++++
 29 files changed, 1057 insertions(+), 647 deletions(-)
 create mode 100644 include/linux/proc_info.h
 create mode 100644 lib/proc_info.c

-- 
1.9.1
