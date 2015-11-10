From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] netfilter: nfnetlink_log: work around uninitialized variable warning
Date: Tue, 10 Nov 2015 13:08:15 +0100
Message-ID: <17817903.Md6b3ydRpX@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, Ken-ichirou MATSUZAWA <chamaken@gmail.com>,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After a recent (correct) change, gcc started warning about the use
of the 'flags' variable in nfulnl_recv_config()

net/netfilter/nfnetlink_log.c: In function 'nfulnl_recv_config':
net/netfilter/nfnetlink_log.c:320:14: warning: 'flags' may be used uninitialized in this function [-Wmaybe-uninitialized]
net/netfilter/nfnetlink_log.c:828:6: note: 'flags' was declared here

The warning first shows up in ARM s3c2410_defconfig with gcc-4.3 or
higher (including 5.2.1, which is the latest version I checked) I
tried working around it by rearranging the code but had no success
with that.

As a last resort, this initializes the variable to zero, which shuts
up the warning, but means that we don't get a warning if the code
is ever changed in a way that actually causes the variable to be
used without first being written.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 8cbc870829ec ("netfilter: nfnetlink_log: validate dependencies to avoid breaking atomicity")
---

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 06eb48fceb42..740cce4685ac 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -825,7 +825,7 @@ nfulnl_recv_config(struct sock *ctnl, struct sk_buff *skb,
 	struct net *net = sock_net(ctnl);
 	struct nfnl_log_net *log = nfnl_log_pernet(net);
 	int ret = 0;
-	u16 flags;
+	u16 flags = 0;
 
 	if (nfula[NFULA_CFG_CMD]) {
 		u_int8_t pf = nfmsg->nfgen_family;

