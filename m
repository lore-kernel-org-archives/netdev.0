From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net] bridge: Only call /sbin/bridge-stp for the
	initial network namespace
Date: Mon, 30 Nov 2015 15:38:15 -0600
Message-ID: <87egf7183c.fsf_-_@x220.int.ebiederm.org>
References: <565B7F7D.80208@nod.at>
	<CAGXu5jJqQKAmFK0nL69E0QOpo8WSVDqStGZo7-m7gy3vnXBa=A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kees Cook <keescook@chromium.org>, "kernel-hardening@lists.openwall.com"
	<kernel-hardening@lists.openwall.com>, Richard Weinberger <richard@nod.at>,
	bridge@lists.linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <CAGXu5jJqQKAmFK0nL69E0QOpo8WSVDqStGZo7-m7gy3vnXBa=A@mail.gmail.com>
	(Kees Cook's message of "Mon, 30 Nov 2015 12:14:41 -0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org


There is no defined mechanism to pass network namespace information
into /sbin/bridge-stp therefore don't even try to invoke it except
for bridge devices in the initial network namespace.

It is possible for unprivileged users to cause /sbin/bridge-stp to be
invoked for any network device name which if /sbin/bridge-stp does not
guard against unreasonable arguments or being invoked twice on the same
network device could cause problems.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/bridge/br_stp_if.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
index 5396ff08af32..742fa89528ab 100644
--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -142,7 +142,9 @@ static void br_stp_start(struct net_bridge *br)
 	char *envp[] = { NULL };
 	struct net_bridge_port *p;
 
-	r = call_usermodehelper(BR_STP_PROG, argv, envp, UMH_WAIT_PROC);
+	r = -ENOENT;
+	if (dev_net(br->dev) == &init_net)
+		r = call_usermodehelper(BR_STP_PROG, argv, envp, UMH_WAIT_PROC);
 
 	spin_lock_bh(&br->lock);
 
-- 
2.2.1
