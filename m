From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [Resend PATCH] RDS: fix race condition when sending a message on unbound socket
Date: Tue, 24 Nov 2015 17:13:21 -0500
Message-ID: <1448403201-1683-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, sasha.levin@oracle.com,
	ben@decadent.org.uk,
	Quentin Casasnovas <quentin.casasnovas@oracle.com>,
	stable@vger.kernel.org
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Quentin Casasnovas <quentin.casasnovas@oracle.com>

Sasha's found a NULL pointer dereference in the RDS connection code when
sending a message to an apparently unbound socket.  The problem is caused
by the code checking if the socket is bound in rds_sendmsg(), which checks
the rs_bound_addr field without taking a lock on the socket.  This opens a
race where rs_bound_addr is temporarily set but where the transport is not
in rds_bind(), leading to a NULL pointer dereference when trying to
dereference 'trans' in __rds_conn_create().

Vegard wrote a reproducer for this issue, so kindly ask him to share if
you're interested.

I cannot reproduce the NULL pointer dereference using Vegard's reproducer
with this patch, whereas I could without.

Complete earlier incomplete fix to CVE-2015-6937:

  74e98eb08588 ("RDS: verify the underlying transport exists before creating a connection")

Cc: David S. Miller <davem@davemloft.net>
Cc: stable@vger.kernel.org

Reviewed-by: Vegard Nossum <vegard.nossum@oracle.com>
Reviewed-by: Sasha Levin <sasha.levin@oracle.com>
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Signed-off-by: Quentin Casasnovas <quentin.casasnovas@oracle.com>
---
Dave,

Resending refreshed version from earlier patch which was missed out
for some reason.
	https://lkml.org/lkml/2015/10/16/530

It applies cleanly against linus master as well as net-next. I
have also pushed it on my tree below.
	git://git.kernel.org/pub/scm/linux/kernel/git/ssantosh/linux.git 4.4/net-next/rds-fix


 net/rds/connection.c | 6 ------
 net/rds/send.c       | 4 +++-
 2 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/net/rds/connection.c b/net/rds/connection.c
index d456403..e3b118c 100644
--- a/net/rds/connection.c
+++ b/net/rds/connection.c
@@ -186,12 +186,6 @@ static struct rds_connection *__rds_conn_create(struct net *net,
 		}
 	}
 
-	if (trans == NULL) {
-		kmem_cache_free(rds_conn_slab, conn);
-		conn = ERR_PTR(-ENODEV);
-		goto out;
-	}
-
 	conn->c_trans = trans;
 
 	ret = trans->conn_alloc(conn, gfp);
diff --git a/net/rds/send.c b/net/rds/send.c
index 827155c..c9cdb35 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -1013,11 +1013,13 @@ int rds_sendmsg(struct socket *sock, struct msghdr *msg, size_t payload_len)
 		release_sock(sk);
 	}
 
-	/* racing with another thread binding seems ok here */
+	lock_sock(sk);
 	if (daddr == 0 || rs->rs_bound_addr == 0) {
+		release_sock(sk);
 		ret = -ENOTCONN; /* XXX not a great errno */
 		goto out;
 	}
+	release_sock(sk);
 
 	if (payload_len > rds_sk_sndbuf(rs)) {
 		ret = -EMSGSIZE;
-- 
1.9.1
