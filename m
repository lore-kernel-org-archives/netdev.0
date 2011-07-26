From: Serge Hallyn <serge@hallyn.com>
Subject: [PATCH 03/14] keyctl: check capabilities against key's user_ns
Date: Tue, 26 Jul 2011 18:58:26 +0000
Message-ID: <1311706717-7398-4-git-send-email-serge@hallyn.com>
References: <1311706717-7398-1-git-send-email-serge@hallyn.com>
Cc: dhowells@redhat.com, ebiederm@xmission.com,
	containers@lists.linux-foundation.org, netdev@vger.kernel.org,
	akpm@osdl.org, "Serge E. Hallyn" <serge.hallyn@canonical.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1311706717-7398-1-git-send-email-serge@hallyn.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Serge E. Hallyn <serge.hallyn@canonical.com>

ATM, task should only be able to get his own user_ns's keys
anyway, so nsown_capable should also work, but there is no
advantage to doing that, while using key's user_ns is clearer.

changelog: jun 6:
	compile fix: keyctl.c (key_user, not key has user_ns)

Signed-off-by: Serge E. Hallyn <serge.hallyn@canonical.com>
Acked-by: David Howells <dhowells@redhat.com>
Cc: Eric W. Biederman <ebiederm@xmission.com>
---
 security/keys/keyctl.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/security/keys/keyctl.c b/security/keys/keyctl.c
index eca5191..fa7d420 100644
--- a/security/keys/keyctl.c
+++ b/security/keys/keyctl.c
@@ -745,7 +745,7 @@ long keyctl_chown_key(key_serial_t id, uid_t uid, gid_t gid)
 	ret = -EACCES;
 	down_write(&key->sem);
 
-	if (!capable(CAP_SYS_ADMIN)) {
+	if (!ns_capable(key->user->user_ns, CAP_SYS_ADMIN)) {
 		/* only the sysadmin can chown a key to some other UID */
 		if (uid != (uid_t) -1 && key->uid != uid)
 			goto error_put;
@@ -852,7 +852,8 @@ long keyctl_setperm_key(key_serial_t id, key_perm_t perm)
 	down_write(&key->sem);
 
 	/* if we're not the sysadmin, we can only change a key that we own */
-	if (capable(CAP_SYS_ADMIN) || key->uid == current_fsuid()) {
+	if (ns_capable(key->user->user_ns, CAP_SYS_ADMIN) ||
+	    key->uid == current_fsuid()) {
 		key->perm = perm;
 		ret = 0;
 	}
-- 
1.7.4.1
