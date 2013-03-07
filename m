From: pablo@netfilter.org
Subject: [PATCH 3/3] netfilter: nfnetlink: silence warning if CONFIG_PROVE_RCU isn't set
Date: Thu,  7 Mar 2013 12:00:02 +0100
Message-ID: <1362654002-4405-4-git-send-email-pablo@netfilter.org>
References: <1362654002-4405-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41588 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755967Ab3CGLAT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Mar 2013 06:00:19 -0500
In-Reply-To: <1362654002-4405-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Paul Bolle <pebolle@tiscali.nl>

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
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink.c |    7 +------
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
1.7.10.4
