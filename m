From: Michael Stone <michael@laptop.org>
Subject: [PATCH 3/3] Security: Document disablenetwork. (v4)
Date: Sat, 26 Dec 2009 20:07:08 -0500
Message-ID: <20091227010708.GA12216@heat>
References: <20091227010441.GA12077@heat>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Bryan Donlan <bdonlan@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>, Pavel Machek <pavel@ucw.cz>,
	Michael Stone <michael@laptop
To: linux-kernel@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091227010441.GA12077@heat>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Explain the purpose, implementation, and semantics of the disablenetwork
facility.

Also reference some example userland clients.

Signed-off-by: Michael Stone <michael@laptop.org>
---
  Documentation/disablenetwork.txt |   84 ++++++++++++++++++++++++++++++++++++++
  1 files changed, 84 insertions(+), 0 deletions(-)
  create mode 100644 Documentation/disablenetwork.txt

diff --git a/Documentation/disablenetwork.txt b/Documentation/disablenetwork.txt
new file mode 100644
index 0000000..c885502
--- /dev/null
+++ b/Documentation/disablenetwork.txt
@@ -0,0 +1,84 @@
+Disablenetwork Purpose
+----------------------
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
+
+Implementation
+--------------
+
+The initial userland interface for accessing the disablenetwork functionality
+is provided through the prctl() framework via a new pair of options named
+PR_{GET,SET}_NETWORK and a new flag named PR_NETWORK_OFF.
+
+The PR_{GET,SET}_NETWORK options access and modify a new (conditionally
+compiled) task_struct flags field named "network".
+
+Finally, the pre-existing
+
+  security_socket_create(),
+  security_socket_bind(),
+  security_socket_connect(),
+  security_socket_sendmsg(), and
+  security_ptrace_access_check()
+
+security hooks are modified to call the corresponding disablenetwork_*
+discretionary access control functions. These functions return -EPERM or 0 as
+described below.
+
+Semantics
+---------
+
+current->network is a task_struct flags field which is preserved across all
+variants of fork() and exec().
+
+Writes which attempt to clear bits in current->network return -EPERM.
+
+The default value for current->network is named PR_NETWORK_ON and is defined
+to be 0.
+
+Presently, only one flag is defined: PR_NETWORK_OFF.
+
+More flags may be defined in the future if they become needed.
+
+Attempts to set undefined flags result in -EINVAL.
+
+When PR_NETWORK_OFF is set, the disablenetwork security hooks for socket(),
+bind(), connect(), sendmsg(), and ptrace() will return -EPERM or 0.
+
+Exceptions are made for
+
+  * processes manipulating an AF_UNIX socket or,
+  * processes calling sendmsg() on a previously connected socket
+      (i.e. one with msg.msg_name == NULL && msg.msg_namelen == 0) or
+  * processes calling ptrace() on a target process which shares every
+    networking restriction flag set in current->network.
+
+References
+----------
+
+[1]: http://cr.yp.to/unix/disablenetwork.html
+[2]: http://wiki.laptop.org/go/OLPC_Bitfrost
+[3]: http://wiki.laptop.org/go/Rainbow
+[4]: http://plash.beasts.org/
-- 
1.6.6.rc2
