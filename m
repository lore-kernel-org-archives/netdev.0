From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2.4 NETLINK]: Unhash sockets correctly
Date: Wed, 16 Feb 2005 19:54:17 +0100
Message-ID: <421396D9.2030405@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050500020804090602010302"
Cc: Maillist netdev <netdev@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050500020804090602010302
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi Dave,

this patch fixes a nasty bug introduced by the pid-hash backport.
Sockets are only unhashed if they are contained in the first hash
bucket. This leads to leaking sockets and, over time, to bind
conflicts which confuse iproute and result in sporadic failure.

Regards
Patrick


--------------050500020804090602010302
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/02/16 19:32:38+01:00 kaber@coreworks.de 
#   [NETLINK]: Unhash sockets correctly
#   
#   netlink_remove() only unhashes sockets contained in the
#   first hash bucket. This leads to leaking sockets and,
#   over time, to bind conflicts which confuse iproute.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/netlink/af_netlink.c
#   2005/02/16 19:32:36+01:00 kaber@coreworks.de +2 -1
#   [NETLINK]: Unhash sockets correctly
#   
#   netlink_remove() only unhashes sockets contained in the
#   first hash bucket. This leads to leaking sockets and,
#   over time, to bind conflicts which confuse iproute.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
--- a/net/netlink/af_netlink.c	2005-02-16 19:32:51 +01:00
+++ b/net/netlink/af_netlink.c	2005-02-16 19:32:51 +01:00
@@ -327,10 +327,11 @@
 	struct sock **skp;
 	struct netlink_table *table = &nl_table[sk->protocol];
 	struct nl_pid_hash *hash = &table->hash;
+	u32 pid = nlk_sk(sk)->pid;
 
 	netlink_table_grab();
 	hash->entries--;
-	for (skp = hash->table; *skp; skp = &((*skp)->next)) {
+	for (skp = nl_pid_hashfn(hash, pid); *skp; skp = &((*skp)->next)) {
 		if (*skp == sk) {
 			*skp = sk->next;
 			__sock_put(sk);

--------------050500020804090602010302--
