From: Paul Moore <pmoore@redhat.com>
Subject: [PATCH] bluetooth: Properly clone LSM attributes to newly created
 child connections
Date: Fri, 07 Oct 2011 15:40:59 -0400
Message-ID: <20111007194059.12345.13398.stgit@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Bluetooth stack has internal connection handlers for all of the various
Bluetooth protocols, and unfortunately, they are currently lacking the LSM
hooks found in the core network stack's connection handlers.  I say
unfortunately, because this can cause problems for users who have have an
LSM enabled and are using certain Bluetooth devices.  See one problem
report below:

 * http://bugzilla.redhat.com/show_bug.cgi?id=741703

In order to keep things simple at this point in time, this patch fixes the
problem by cloning the parent socket's LSM attributes to the newly created
child socket.  If we decide we need a more elaborate LSM marking mechanism
for Bluetooth (I somewhat doubt this) we can always revisit this decision
in the future.

Reported-by: James M. Cape <jcape@ignore-your.tv>
Signed-off-by: Paul Moore <pmoore@redhat.com>
---
 net/bluetooth/l2cap_sock.c  |    4 ++++
 net/bluetooth/rfcomm/sock.c |    3 +++
 net/bluetooth/sco.c         |    5 ++++-
 security/security.c         |    1 +
 4 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
index 61f1f62..e829236 100644
--- a/net/bluetooth/l2cap_sock.c
+++ b/net/bluetooth/l2cap_sock.c
@@ -26,6 +26,8 @@
 
 /* Bluetooth L2CAP sockets. */
 
+#include <linux/security.h>
+
 #include <net/bluetooth/bluetooth.h>
 #include <net/bluetooth/hci_core.h>
 #include <net/bluetooth/l2cap.h>
@@ -933,6 +935,8 @@ static void l2cap_sock_init(struct sock *sk, struct sock *parent)
 		chan->force_reliable = pchan->force_reliable;
 		chan->flushable = pchan->flushable;
 		chan->force_active = pchan->force_active;
+
+		security_sk_clone(parent, sk);
 	} else {
 
 		switch (sk->sk_type) {
diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
index 482722b..5417f61 100644
--- a/net/bluetooth/rfcomm/sock.c
+++ b/net/bluetooth/rfcomm/sock.c
@@ -42,6 +42,7 @@
 #include <linux/device.h>
 #include <linux/debugfs.h>
 #include <linux/seq_file.h>
+#include <linux/security.h>
 #include <net/sock.h>
 
 #include <asm/system.h>
@@ -264,6 +265,8 @@ static void rfcomm_sock_init(struct sock *sk, struct sock *parent)
 
 		pi->sec_level = rfcomm_pi(parent)->sec_level;
 		pi->role_switch = rfcomm_pi(parent)->role_switch;
+
+		security_sk_clone(parent, sk);
 	} else {
 		pi->dlc->defer_setup = 0;
 
diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index 8270f05..a324b00 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -41,6 +41,7 @@
 #include <linux/debugfs.h>
 #include <linux/seq_file.h>
 #include <linux/list.h>
+#include <linux/security.h>
 #include <net/sock.h>
 
 #include <asm/system.h>
@@ -403,8 +404,10 @@ static void sco_sock_init(struct sock *sk, struct sock *parent)
 {
 	BT_DBG("sk %p", sk);
 
-	if (parent)
+	if (parent) {
 		sk->sk_type = parent->sk_type;
+		security_sk_clone(parent, sk);
+	}
 }
 
 static struct proto sco_proto = {
diff --git a/security/security.c b/security/security.c
index 0e4fccf..d9e1533 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1097,6 +1097,7 @@ void security_sk_clone(const struct sock *sk, struct sock *newsk)
 {
 	security_ops->sk_clone_security(sk, newsk);
 }
+EXPORT_SYMBOL(security_sk_clone);
 
 void security_sk_classify_flow(struct sock *sk, struct flowi *fl)
 {

