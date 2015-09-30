From: Tycho Andersen <tycho.andersen@canonical.com>
Subject: [PATCH v3 4/5] kcmp: add KCMP_FILE_PRIVATE_DATA
Date: Wed, 30 Sep 2015 12:13:39 -0600
Message-ID: <1443636820-17083-5-git-send-email-tycho.andersen@canonical.com>
References: <1443636820-17083-1-git-send-email-tycho.andersen@canonical.com>
Cc: Will Drewry <wad@chromium.org>, Oleg Nesterov <oleg@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-api@vger.kernel.org,
	Tycho Andersen <tycho.andersen@canonical.com>
To: Kees Cook <keescook@chromium.org>,
	Alexei Starovoitov <ast@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:36600 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933289AbbI3SOi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 14:14:38 -0400
Received: by igcrk20 with SMTP id rk20so108813407igc.1
        for <netdev@vger.kernel.org>; Wed, 30 Sep 2015 11:14:37 -0700 (PDT)
In-Reply-To: <1443636820-17083-1-git-send-email-tycho.andersen@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This command allows comparing the underling private data of two fds. This
is useful e.g. to find out if a seccomp filter is inherited, since struct
seccomp_filter are unique across tasks and are the private_data seccomp
fds.

Signed-off-by: Tycho Andersen <tycho.andersen@canonical.com>
CC: Kees Cook <keescook@chromium.org>
CC: Will Drewry <wad@chromium.org>
CC: Oleg Nesterov <oleg@redhat.com>
CC: Andy Lutomirski <luto@amacapital.net>
CC: Pavel Emelyanov <xemul@parallels.com>
CC: Serge E. Hallyn <serge.hallyn@ubuntu.com>
CC: Alexei Starovoitov <ast@kernel.org>
CC: Daniel Borkmann <daniel@iogearbox.net>
---
 include/uapi/linux/kcmp.h |  1 +
 kernel/kcmp.c             | 14 ++++++++++++++
 2 files changed, 15 insertions(+)

diff --git a/include/uapi/linux/kcmp.h b/include/uapi/linux/kcmp.h
index 84df14b..ed389d2 100644
--- a/include/uapi/linux/kcmp.h
+++ b/include/uapi/linux/kcmp.h
@@ -10,6 +10,7 @@ enum kcmp_type {
 	KCMP_SIGHAND,
 	KCMP_IO,
 	KCMP_SYSVSEM,
+	KCMP_FILE_PRIVATE_DATA,
 
 	KCMP_TYPES,
 };
diff --git a/kernel/kcmp.c b/kernel/kcmp.c
index 0aa69ea..9ae673b 100644
--- a/kernel/kcmp.c
+++ b/kernel/kcmp.c
@@ -165,6 +165,20 @@ SYSCALL_DEFINE5(kcmp, pid_t, pid1, pid_t, pid2, int, type,
 		ret = -EOPNOTSUPP;
 #endif
 		break;
+	case KCMP_FILE_PRIVATE_DATA: {
+		struct file *filp1, *filp2;
+
+		filp1 = get_file_raw_ptr(task1, idx1);
+		filp2 = get_file_raw_ptr(task2, idx2);
+
+		if (filp1 && filp2)
+			ret = kcmp_ptr(filp1->private_data,
+				       filp2->private_data,
+				       KCMP_FILE_PRIVATE_DATA);
+		else
+			ret = -EBADF;
+		break;
+	}
 	default:
 		ret = -EINVAL;
 		break;
-- 
2.5.0
