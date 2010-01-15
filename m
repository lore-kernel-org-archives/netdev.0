From: Michael Stone <michael@laptop.org>
Subject: disablenetwork (v5): Update documentation for PR_NETWORK_ENABLE_DN.
Date: Fri, 15 Jan 2010 03:13:22 -0500
Message-ID: <20100115081322.GA14460@heat>
References: <20100115081028.GA14004@heat>
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
	Al Viro <viro@ZenIV.linux.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.laptop.org ([18.85.2.145]:37618 "EHLO mail.laptop.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754122Ab0AOIK7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jan 2010 03:10:59 -0500
Content-Disposition: inline
In-Reply-To: <20100115081028.GA14004@heat>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michael Stone <michael@laptop.org>
---
  Documentation/disablenetwork.txt |   43 ++++++++++++++++++++++++++++---------
  1 files changed, 32 insertions(+), 11 deletions(-)

diff --git a/Documentation/disablenetwork.txt b/Documentation/disablenetwork.txt
index c885502..5d376e6 100644
--- a/Documentation/disablenetwork.txt
+++ b/Documentation/disablenetwork.txt
@@ -30,11 +30,19 @@ Implementation
  
  The initial userland interface for accessing the disablenetwork functionality
  is provided through the prctl() framework via a new pair of options named
-PR_{GET,SET}_NETWORK and a new flag named PR_NETWORK_OFF.
+PR_{GET,SET}_NETWORK and a pair of flags named PR_NETWORK_ENABLE_DN and
+PR_NETWORK_OFF.
  
  The PR_{GET,SET}_NETWORK options access and modify a new (conditionally
  compiled) task_struct flags field named "network".
  
+prctl(PR_SET_NETWORK) takes its argument by value rather than by address to
+avoid a time-of-check-to-time-of-use race between security_prctl() and
+prctl_set_network().
+
+However, prctl(PR_GET_NETWORK) returns the value of the "network" field via a
+pointer argument so that its return code can represent errors like ENOSYS.
+
  Finally, the pre-existing
  
    security_socket_create(),
@@ -58,22 +66,35 @@ Writes which attempt to clear bits in current->network return -EPERM.
  The default value for current->network is named PR_NETWORK_ON and is defined
  to be 0.
  
-Presently, only one flag is defined: PR_NETWORK_OFF.
-
+Presently, two flags are defined: PR_NETWORK_ENABLE_DN and PR_NETWORK_OFF.
  More flags may be defined in the future if they become needed.
  
  Attempts to set undefined flags result in -EINVAL.
  
-When PR_NETWORK_OFF is set, the disablenetwork security hooks for socket(),
-bind(), connect(), sendmsg(), and ptrace() will return -EPERM or 0.
+CAP_SETPCAP is required in order to set PR_NETWORK_ENABLE_DN. We believe that
+this restriction will protect privileged legacy system configurations from
+unprivileged misuse of disablenetwork. (Thanks to Pavel Machek and Serge Hallyn
+for analyzing the problem and for suggesting this compromise approach.)
+
+We say that "disablenetwork is active" when both PR_NETWORK_ENABLE_DN and
+PR_NETWORK_OFF are set. Otherwise, we say that it is "inactive".
+
+When the disablenetwork is inactive, the disablenetwork_* security hooks for
+socket(), bind(), connect(), sendmsg(), and ptrace() will return 0.
+
+When disablenetwork is active -EPERM or 0 as follows:
+
+The hooks will return 0 when disablenetwork is active for the current process
+and when an exception applies: i.e. when the current process is
  
-Exceptions are made for
+  * manipulating an AF_UNIX socket or,
+  * calling sendmsg() on a previously connected socket (i.e. one with
+    msg.msg_name == NULL && msg.msg_namelen == 0) or
+  * calling ptrace() on a target process in which disablenetwork is also
+    active.
  
-  * processes manipulating an AF_UNIX socket or,
-  * processes calling sendmsg() on a previously connected socket
-      (i.e. one with msg.msg_name == NULL && msg.msg_namelen == 0) or
-  * processes calling ptrace() on a target process which shares every
-    networking restriction flag set in current->network.
+When disablenetwork is active in non-exceptional circumstances, the hooks will
+return -EPERM.
  
  References
  ----------
-- 
1.6.6.rc2
