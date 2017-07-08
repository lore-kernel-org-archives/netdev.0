From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [RFC] get_compat_bpf_fprog(): don't copyin field-by-field
Date: Sat, 8 Jul 2017 19:22:49 +0100
Message-ID: <20170708182249.GT10672@ZenIV.linux.org.uk>
References: <20170708182100.GR10672@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:54798 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753037AbdGHSWv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Jul 2017 14:22:51 -0400
Received: from viro by ZenIV.linux.org.uk with local (Exim 4.87 #1 (Red Hat Linux))
        id 1dTuNV-0002sk-KP
        for netdev@vger.kernel.org; Sat, 08 Jul 2017 18:22:49 +0000
Content-Disposition: inline
In-Reply-To: <20170708182100.GR10672@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
diff --git a/net/compat.c b/net/compat.c
index dba5e222a0e5..6ded6c821d7a 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -313,15 +313,15 @@ struct sock_fprog __user *get_compat_bpf_fprog(char __user *optval)
 {
 	struct compat_sock_fprog __user *fprog32 = (struct compat_sock_fprog __user *)optval;
 	struct sock_fprog __user *kfprog = compat_alloc_user_space(sizeof(struct sock_fprog));
-	compat_uptr_t ptr;
-	u16 len;
-
-	if (!access_ok(VERIFY_READ, fprog32, sizeof(*fprog32)) ||
-	    !access_ok(VERIFY_WRITE, kfprog, sizeof(struct sock_fprog)) ||
-	    __get_user(len, &fprog32->len) ||
-	    __get_user(ptr, &fprog32->filter) ||
-	    __put_user(len, &kfprog->len) ||
-	    __put_user(compat_ptr(ptr), &kfprog->filter))
+	struct compat_sock_fprog f32;
+	struct sock_fprog f;
+
+	if (copy_from_user(&f32, fprog32, sizeof(*fprog32)))
+		return NULL;
+	memset(&f, 0, sizeof(f));
+	f.len = f32.len;
+	f.filter = compat_ptr(f32.filter);
+	if (copy_to_user(kfprog, &f, sizeof(struct sock_fprog)))
 		return NULL;
 
 	return kfprog;
