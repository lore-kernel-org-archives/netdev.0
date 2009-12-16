From: Michael Stone <michael@laptop.org>
Subject: [PATCH] Security: Document prctl(PR_{GET,SET}_NETWORK).
Date: Wed, 16 Dec 2009 10:32:45 -0500
Message-ID: <1260977565-2379-3-git-send-email-michael@laptop.org>
References: <1260977452-2334-1-git-send-email-michael@laptop.org>
Cc: Michael Stone <michael@laptop.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	"Andi Kleen" <andi@firstfloor.org>, "David Lang" <david@lang.hm>,
	"Oliver Hartkopp" <socketcan@hartkopp.net>,
	"Alan Cox" <alan@lxorguk.ukuu.org.uk>,
	"Herbert Xu" <herbert@gondor.apana.org.au>,
	"Valdis Kletnieks" <Valdis.Kletnieks@vt.edu>,
	"Bryan Donlan" <bdonlan@gmail.com>,
	"Evgeniy Polyakov" <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	"James Morris" <jmorris@namei.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"Bernie Innocenti" <bernie@codewiz.org>,
	"Mark Seaborn" <mrs@mythic-beasts.com>
To: Ulrich Drepper <drepper@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933644AbZLPPbe@vger.kernel.org>
In-Reply-To: <1260977452-2334-1-git-send-email-michael@laptop.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Explain the purpose, interface, and semantics of the
prctl(PR_{GET,SET}_network) facility.

Also reference some example userland clients.

Signed-off-by: Michael Stone <michael@laptop.org>
---
 Documentation/prctl_network.txt |   69 +++++++++++++++++++++++++++++++++++++++
 1 files changed, 69 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/prctl_network.txt

diff --git a/Documentation/prctl_network.txt b/Documentation/prctl_network.txt
new file mode 100644
index 0000000..bcf2f72
--- /dev/null
+++ b/Documentation/prctl_network.txt
@@ -0,0 +1,69 @@
+Purpose
+-------
+
+Daniel Bernstein has observed [1] that security-conscious userland processes
+may benefit from the ability to irrevocably remove their ability to create,
+bind, connect to, or send messages except in the case of previously connected
+sockets or AF_UNIX filesystem sockets.
+
+This facility is particularly attractive to security platforms like OLPC
+Bitfrost [2] and to isolation programs like Rainbow [3] and Plash [4] because:
+
+  * it integrates well with standard techniques for writing privilege-separated
+    Unix programs
+
+  * it integrates well with the need to perform limited socket I/O, e.g., when
+    running X clients
+
+  * it's available to unprivileged programs
+
+  * it's a discretionary feature available to all of distributors,
+    administrators, authors, and users
+
+  * its effect is entirely local, rather than global (like netfilter)
+
+  * it's simple enough to have some hope of being used correctly
+
+Implementation
+--------------
+
+After considering implementations based on the Linux Security Module (LSM)
+framework, on SELinux in particular, on network namespaces (CLONE_NEWNET), and
+on direct modification of the kernel syscall and task_struct APIs, we came to
+the conclusion that the best way to implement this feature was to extend the
+prctl() framework with a new pair of options named PR_{GET,SET}_NETWORK. These
+options cause prctl() to read or modify "current->network".
+
+Semantics
+---------
+
+current->network is a flags field which is preserved across all variants of
+fork() and exec().
+
+Writes which attempt to clear bits in current->network return -EPERM.
+
+The default value for current->network is named PR_NETWORK_OFF and is defined
+to be 0.
+
+Presently, only one flag is defined: PR_NETWORK_OFF.
+
+More flags may be defined in the future if they become needed.
+
+Attempts to set undefined flags result in -EINVAL.
+
+When PR_NETWORK_OFF is set, implementations of syscalls which may be used by
+the current process to perform autonomous networking will return -EPERM. For
+example, calls to socket(), bind(), connect(), sendmsg(), and ptrace() will
+return -EPERM except for cases we are manipulating an AF_UNIX socket whose name
+does not begin with \0 or, in the case of sendmsg(), unless we are manipulating
+a previously connected socket, i.e. one with
+
+  msg.msg_name == NULL && msg.msg_namelen == 0.
+
+References
+----------
+
+[1]: http://cr.yp.to/unix/disablenetwork.html
+[2]: http://wiki.laptop.org/go/OLPC_Bitfrost
+[3]: http://wiki.laptop.org/go/Rainbow
+[4]: http://plash.beasts.org/
-- 
1.5.6.5
