From: Will Drewry <wad@chromium.org>
Subject: [PATCH v17 02/15] Fix apparmor for PR_{GET,SET}_NO_NEW_PRIVS
Date: Thu, 29 Mar 2012 15:01:47 -0500
Message-ID: <1333051320-30872-3-git-send-email-wad@chromium.org>
References: <1333051320-30872-1-git-send-email-wad@chromium.org>
Reply-To: kernel-hardening@lists.openwall.com
Cc: linux-security-module@vger.kernel.org,
	linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org,
	x86@kernel.org,
	arnd@arndb.de,
	davem@davemloft.net,
	hpa@zytor.com,
	mingo@redhat.com,
	oleg@redhat.com,
	peterz@infradead.org,
	rdunlap@xenotime.net,
	mcgrathr@chromium.org,
	tglx@linutronix.de,
	luto@mit.edu,
	eparis@redhat.com,
	serge.hallyn@canonical.com,
	djm@mindrot.org,
	scarybeasts@gmail.com,
	indan@nul.nu,
	pmoore@redhat.com,
	akpm@linux-foundation.org,
	corbet@lwn.net,
	eric.dumazet@gmail.com,
	markus@chromium.org,
	coreyb@linux.vnet.ibm.com,
	keescook@chromium.org,
	jmorris@namei.org,
	John Johansen <john.johansen@canonical.com>,
	Andy Lutomirski <luto@amacapital.net>
To: linux-kernel@vger.kernel.org
Return-path: <kernel-hardening-return-1176-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <1333051320-30872-1-git-send-email-wad@chromium.org>
List-Id: netdev.vger.kernel.org

From: John Johansen <john.johansen@canonical.com>

Signed-off-by: John Johansen <john.johansen@canonical.com>
Signed-off-by: Andy Lutomirski <luto@amacapital.net>
---
 security/apparmor/domain.c |   39 +++++++++++++++++++++++++++++++++++----
 1 files changed, 35 insertions(+), 4 deletions(-)

diff --git a/security/apparmor/domain.c b/security/apparmor/domain.c
index 18c88d0..b81ea10 100644
--- a/security/apparmor/domain.c
+++ b/security/apparmor/domain.c
@@ -360,10 +360,6 @@ int apparmor_bprm_set_creds(struct linux_binprm *bprm)
 	if (bprm->cred_prepared)
 		return 0;
 
-	/* XXX: no_new_privs is not usable with AppArmor yet */
-	if (bprm->unsafe & LSM_UNSAFE_NO_NEW_PRIVS)
-		return -EPERM;
-
 	cxt = bprm->cred->security;
 	BUG_ON(!cxt);
 
@@ -398,6 +394,11 @@ int apparmor_bprm_set_creds(struct linux_binprm *bprm)
 			new_profile = find_attach(ns, &ns->base.profiles, name);
 		if (!new_profile)
 			goto cleanup;
+		/*
+		 * NOTE: Domain transitions from unconfined are allowed
+		 * even when no_new_privs is set because this aways results
+		 * in a further reduction of permissions.
+		 */
 		goto apply;
 	}
 
@@ -459,6 +460,16 @@ int apparmor_bprm_set_creds(struct linux_binprm *bprm)
 		/* fail exec */
 		error = -EACCES;
 
+	/*
+	 * Policy has specified a domain transition, if no_new_privs then
+	 * fail the exec.
+	 */
+	if (bprm->unsafe & LSM_UNSAFE_NO_NEW_PRIVS) {
+		aa_put_profile(new_profile);
+		error = -EPERM;
+		goto cleanup;
+	}
+
 	if (!new_profile)
 		goto audit;
 
@@ -613,6 +624,14 @@ int aa_change_hat(const char *hats[], int count, u64 token, bool permtest)
 	const char *target = NULL, *info = NULL;
 	int error = 0;
 
+	/*
+	 * Fail explicitly requested domain transitions if no_new_privs.
+	 * There is no exception for unconfined as change_hat is not
+	 * available.
+	 */
+	if (current->no_new_privs)
+		return -EPERM;
+
 	/* released below */
 	cred = get_current_cred();
 	cxt = cred->security;
@@ -754,6 +773,18 @@ int aa_change_profile(const char *ns_name, const char *hname, bool onexec,
 	cxt = cred->security;
 	profile = aa_cred_profile(cred);
 
+	/*
+	 * Fail explicitly requested domain transitions if no_new_privs
+	 * and not unconfined.
+	 * Domain transitions from unconfined are allowed even when
+	 * no_new_privs is set because this aways results in a reduction
+	 * of permissions.
+	 */
+	if (current->no_new_privs && !unconfined(profile)) {
+		put_cred(cred);
+		return -EPERM;
+	}
+
 	if (ns_name) {
 		/* released below */
 		ns = aa_find_namespace(profile->ns, ns_name);
-- 
1.7.5.4
