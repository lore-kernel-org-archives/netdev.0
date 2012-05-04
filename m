From: akpm@linux-foundation.org
Subject: [patch 1/1] connector/userns: replace netlink uses of cap_raised() with capable()
Date: Fri, 04 May 2012 14:34:03 -0700
Message-ID: <20120504213403.BD3A4A0367@akpm.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ASCII
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	ebiederm@xmission.com, dhowells@redhat.com,
	james.l.morris@oracle.com, kaber@trash.net, morgan@kernel.org,
	philipp.reisner@linbit.com, segoon@openwall.com,
	serge.hallyn@canonical.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f74.google.com ([74.125.82.74]:64229 "EHLO
	mail-wg0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757746Ab2EDVeG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 17:34:06 -0400
Received: by wgbdt11 with SMTP id dt11so193589wgb.1
        for <netdev@vger.kernel.org>; Fri, 04 May 2012 14:34:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman <ebiederm@xmission.com>
Subject: connector/userns: replace netlink uses of cap_raised() with capable()

In 2009 Philip Reiser notied that a few users of netlink connector
interface needed a capability check and added the idiom
cap_raised(nsp->eff_cap, CAP_SYS_ADMIN) to a few of them, on the premise
that netlink was asynchronous.

In 2011 Patrick McHardy noticed we were being silly because netlink is
synchronous and removed eff_cap from the netlink_skb_params and changed
the idiom to cap_raised(current_cap(), CAP_SYS_ADMIN).

Looking at those spots with a fresh eye we should be calling
capable(CAP_SYS_ADMIN).  The only reason I can see for not calling capable
is that it once appeared we were not in the same task as the caller which
would have made calling capable() impossible.

In the initial user_namespace the only difference between between
cap_raised(current_cap(), CAP_SYS_ADMIN) and capable(CAP_SYS_ADMIN) are a
few sanity checks and the fact that capable(CAP_SYS_ADMIN) sets
PF_SUPERPRIV if we use the capability.

Since we are going to be using root privilege setting PF_SUPERPRIV seems
the right thing to do.

The motivation for this that patch is that in a child user namespace
cap_raised(current_cap(),...) tests your capabilities with respect to that
child user namespace not capabilities in the initial user namespace and
thus will allow processes that should be unprivielged to use the kernel
services that are only protected with cap_raised(current_cap(),..).

To fix possible user_namespace issues and to just clean up the code
replace cap_raised(current_cap(), CAP_SYS_ADMIN) with
capable(CAP_SYS_ADMIN).

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Philipp Reisner <philipp.reisner@linbit.com>
Acked-by: Serge E. Hallyn <serge.hallyn@canonical.com>
Acked-by: Andrew G. Morgan <morgan@kernel.org>
Cc: Vasiliy Kulikov <segoon@openwall.com>
Cc: David Howells <dhowells@redhat.com>
Reviewed-by: James Morris <james.l.morris@oracle.com>
Cc: David Miller <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/block/drbd/drbd_nl.c           |    2 +-
 drivers/md/dm-log-userspace-transfer.c |    2 +-
 drivers/video/uvesafb.c                |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff -puN drivers/block/drbd/drbd_nl.c~connector-userns-replace-netlink-uses-of-cap_raised-with-capable drivers/block/drbd/drbd_nl.c
--- a/drivers/block/drbd/drbd_nl.c~connector-userns-replace-netlink-uses-of-cap_raised-with-capable
+++ a/drivers/block/drbd/drbd_nl.c
@@ -2297,7 +2297,7 @@ static void drbd_connector_callback(stru
 		return;
 	}
 
-	if (!cap_raised(current_cap(), CAP_SYS_ADMIN)) {
+	if (!capable(CAP_SYS_ADMIN)) {
 		retcode = ERR_PERM;
 		goto fail;
 	}
diff -puN drivers/md/dm-log-userspace-transfer.c~connector-userns-replace-netlink-uses-of-cap_raised-with-capable drivers/md/dm-log-userspace-transfer.c
--- a/drivers/md/dm-log-userspace-transfer.c~connector-userns-replace-netlink-uses-of-cap_raised-with-capable
+++ a/drivers/md/dm-log-userspace-transfer.c
@@ -134,7 +134,7 @@ static void cn_ulog_callback(struct cn_m
 {
 	struct dm_ulog_request *tfr = (struct dm_ulog_request *)(msg + 1);
 
-	if (!cap_raised(current_cap(), CAP_SYS_ADMIN))
+	if (!capable(CAP_SYS_ADMIN))
 		return;
 
 	spin_lock(&receiving_list_lock);
diff -puN drivers/video/uvesafb.c~connector-userns-replace-netlink-uses-of-cap_raised-with-capable drivers/video/uvesafb.c
--- a/drivers/video/uvesafb.c~connector-userns-replace-netlink-uses-of-cap_raised-with-capable
+++ a/drivers/video/uvesafb.c
@@ -73,7 +73,7 @@ static void uvesafb_cn_callback(struct c
 	struct uvesafb_task *utask;
 	struct uvesafb_ktask *task;
 
-	if (!cap_raised(current_cap(), CAP_SYS_ADMIN))
+	if (!capable(CAP_SYS_ADMIN))
 		return;
 
 	if (msg->seq >= UVESAFB_TASKS_MAX)
_
