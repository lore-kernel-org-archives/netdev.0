From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] af_unix: revert "af_unix: use freezable blocking calls in read"
Date: Thu, 17 Nov 2016 14:09:24 -0800
Message-ID: <1479420564-15799-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: dvyukov@google.com, Cong Wang <xiyou.wangcong@gmail.com>,
        Tejun Heo <tj@kernel.org>, Colin Cross <ccross@android.com>,
        "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34605 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750855AbcKQWJm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 17:09:42 -0500
Received: by mail-pf0-f196.google.com with SMTP id y68so12210203pfb.1
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2016 14:09:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 2b15af6f95 ("af_unix: use freezable blocking calls in read")
converts schedule_timeout() to its freezable version, it was probably
correct at that time, but later, commit 2b514574f7e8
("net: af_unix: implement splice for stream af_unix sockets") breaks
the strong requirement for a freezable sleep, according to
commit 0f9548ca1091:

    We shouldn't try_to_freeze if locks are held.  Holding a lock can cause a
    deadlock if the lock is later acquired in the suspend or hibernate path
    (e.g.  by dpm).  Holding a lock can also cause a deadlock in the case of
    cgroup_freezer if a lock is held inside a frozen cgroup that is later
    acquired by a process outside that group.

The pipe_lock is still held at that point. So just revert commit 2b15af6f95.

Reported-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: Colin Cross <ccross@android.com>
Cc: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/unix/af_unix.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 5d1c14a..6f37f9e 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -116,7 +116,6 @@
 #include <linux/mount.h>
 #include <net/checksum.h>
 #include <linux/security.h>
-#include <linux/freezer.h>
 
 struct hlist_head unix_socket_table[2 * UNIX_HASH_SIZE];
 EXPORT_SYMBOL_GPL(unix_socket_table);
@@ -2220,7 +2219,7 @@ static long unix_stream_data_wait(struct sock *sk, long timeo,
 
 		sk_set_bit(SOCKWQ_ASYNC_WAITDATA, sk);
 		unix_state_unlock(sk);
-		timeo = freezable_schedule_timeout(timeo);
+		timeo = schedule_timeout(timeo);
 		unix_state_lock(sk);
 
 		if (sock_flag(sk, SOCK_DEAD))
-- 
2.1.0
