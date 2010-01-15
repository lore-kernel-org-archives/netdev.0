From: Michael Stone <michael@laptop.org>
Subject: disablenetwork (v5): Simplify the disablenetwork sendmsg hook.
Date: Fri, 15 Jan 2010 03:12:46 -0500
Message-ID: <20100115081246.GA14426@heat>
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
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754584Ab0AOIK3@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100115081028.GA14004@heat>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The idea is that calls like

   sendto(fd, buffer, len, 0, NULL, 0);
   send(fd, buffer, len, 0)
   write(fd, buffer, len)

are all to be permitted but that calls like

   sendto(fd, buffer, len, 0, (struct sockadr *) &addr, sizeof(addr));

are to be rejected when the current task's network is disabled on the grounds
that the former calls must use previously connected sockets but that the latter
socket need not have been previously connected.

Signed-off-by: Michael Stone <michael@laptop.org>
---
  security/disablenetwork.c |    9 ++++-----
  1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/security/disablenetwork.c b/security/disablenetwork.c
index f45ddfc..27b88d7 100644
--- a/security/disablenetwork.c
+++ b/security/disablenetwork.c
@@ -56,11 +56,10 @@ int disablenetwork_security_socket_connect(struct socket * sock,
  int disablenetwork_security_socket_sendmsg(struct socket * sock,
  					   struct msghdr * msg, int size)
  {
-	if (sock->sk->sk_family != PF_UNIX &&
-		current->network &&
-		(msg->msg_name != NULL || msg->msg_namelen != 0))
-		return -EPERM;
-	return 0;
+	/* permit sockets which are PF_UNIX or connected; check others. */
+	if (sock->sk->sk_family == PF_UNIX || msg->msg_name == NULL)
+		return 0;
+	return maybe_allow();
  }
  
  int disablenetwork_security_ptrace_access_check(struct task_struct *child,
-- 
1.6.6.rc2
