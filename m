From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH v5 00/10] IPC: checkpoint/restore in userspace enhancements
Date: Wed, 19 Sep 2012 20:05:21 +0400
Message-ID: <20120919160430.11254.86848.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: manfred@colorfullife.com, a.p.zijlstra@chello.nl,
	netdev@vger.kernel.org, will.deacon@arm.com,
	linux-kernel@vger.kernel.org, cmetcalf@tilera.com,
	jmorris@namei.org, linux-driver@qlogic.com,
	linux-security-module@vger.kernel.org, hughd@google.com,
	ron.mercer@qlogic.com, viro@zeniv.linux.org.uk,
	james.l.morris@oracle.com, catalin.marinas@arm.com,
	casey@schaufler-ca.com, eparis@parisplace.org, sds@tycho.nsa.gov,
	jitendra.kalsaria@qlogic.com, devel@openvz.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:26707 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932260Ab2ISQHU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2012 12:07:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v5:
1) Several define-dependent compile bugs fixed
2) IPC message copy test updated
3) A couple of minor fixes.
4) Qlogic driver update: rename of its internal SEM_SET define into SEM_INIT
(compile error).

v4:
1) If MSG_COPY flag is specified, then "mtype" is not a type, but message
number to copy.
2) MSG_SET_COPY logic for sys_msgctl() was removed.

v3:
1) Copy messages to user-space under spinlock was replaced by allocation of
dummy message before queue lock and then copy of desired message to the dummy
one instead of unlinking it from queue list.
I.e. the message queue copy logic was changed: messages can be retrived one by
one (instead of receiving of the whole list at once).

This patch set is aimed to provide additional functionality for all IPC objects,
which is required for migration of these objects by user-space
checkpoint/restore utils (CRIU).

The main problem here was impossibility to set up object id. This patch set
solves the problem in two steps:
1) Makes it possible to create new object (shared memory, semaphores set or
messages queue) with ID, equal to passed key.
2) Makes it possible to change existent object key.

Another problem was to peek messages from queues without deleting them.
This was achived by introducing of new MSG_COPY flag for sys_msgrcv(). If
MSG_COPY flag is set, then msgtyp is interpreted as message number.

The following series implements...

---

Stanislav Kinsbursky (10):
      ipc: remove forced assignment of selected message
      ipc: "use key as id" functionality for resource get system call introduced
      ipc: segment key change helper introduced
      ipc: add new SHM_SET command for sys_shmctl() call
      ipc: add new MSG_SET command for sys_msgctl() call
      glge driver: rename internal SEM_SET macro to SEM_INIT
      ipc: add new SEM_SET command for sys_semctl() call
      IPC: message queue receive cleanup
      IPC: message queue copy feature introduced
      test: IPC message queue copy feture test


 drivers/net/ethernet/qlogic/qlge/qlge.h      |    4 
 drivers/net/ethernet/qlogic/qlge/qlge_main.c |   16 +-
 include/linux/ipc.h                          |    1 
 include/linux/msg.h                          |    7 +
 include/linux/sem.h                          |    1 
 include/linux/shm.h                          |    1 
 ipc/compat.c                                 |   45 +++--
 ipc/msg.c                                    |  112 +++++++++---
 ipc/msgutil.c                                |   38 ++++
 ipc/sem.c                                    |   14 +
 ipc/shm.c                                    |   17 +-
 ipc/util.c                                   |   69 +++++++
 ipc/util.h                                   |    6 +
 security/selinux/hooks.c                     |    3 
 security/smack/smack_lsm.c                   |    3 
 tools/testing/selftests/ipc/Makefile         |   28 +++
 tools/testing/selftests/ipc/msgque.c         |  251 ++++++++++++++++++++++++++
 17 files changed, 547 insertions(+), 69 deletions(-)
 create mode 100644 tools/testing/selftests/ipc/Makefile
 create mode 100644 tools/testing/selftests/ipc/msgque.c

-- 
Signature
