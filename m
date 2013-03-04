From: Paul Bolle <pebolle@tiscali.nl>
Subject: [PATCH] netfilter: nfnetlink: silence warning if CONFIG_PROVE_RCU
 isn't set
Date: Mon, 04 Mar 2013 13:45:41 +0100
Message-ID: <1362401141.16460.24.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since commit c14b78e7decd0d1d5add6a4604feb8609fe920a9 ("netfilter:
nfnetlink: add mutex per subsystem") building nefnetlink.o without
CONFIG_PROVE_RCU set, triggers this GCC warning:
    net/netfilter/nfnetlink.c:65:22: warning: =E2=80=98nfnl_get_lock=E2=
=80=99 defined but not used [-Wunused-function]

The cause of that warning is, in short, that rcu_lockdep_assert()
compiles away if CONFIG_PROVE_RCU is not set. Silence this warning by
open coding nfnl_get_lock() in the sole place it was called, which
allows to remove that function.

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
0) Compile tested only, but without CONFIG_PROVE_RCU set! This patch
needs building and running by someone who actually uses that option.

1) This patch triggers a checkpatch "line over 80 characters" warning.
But note that it actually shortens the line checkpatch complains about
(by one character!).

 net/netfilter/nfnetlink.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index d578ec2..0b1b32c 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -62,11 +62,6 @@ void nfnl_unlock(__u8 subsys_id)
 }
 EXPORT_SYMBOL_GPL(nfnl_unlock);
=20
-static struct mutex *nfnl_get_lock(__u8 subsys_id)
-{
-	return &table[subsys_id].mutex;
-}
-
 int nfnetlink_subsys_register(const struct nfnetlink_subsystem *n)
 {
 	nfnl_lock(n->subsys_id);
@@ -199,7 +194,7 @@ replay:
 			rcu_read_unlock();
 			nfnl_lock(subsys_id);
 			if (rcu_dereference_protected(table[subsys_id].subsys,
-				lockdep_is_held(nfnl_get_lock(subsys_id))) !=3D ss ||
+				lockdep_is_held(&table[subsys_id].mutex)) !=3D ss ||
 			    nfnetlink_find_client(type, ss) !=3D nc)
 				err =3D -EAGAIN;
 			else if (nc->call)
--=20
1.7.11.7
