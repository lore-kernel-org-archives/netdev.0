From: David Howells <dhowells@redhat.com>
Subject: [PATCH 12/59] CRED: Wrap task credential accesses in the network
	device drivers
Date: Wed, 27 Aug 2008 14:46:44 +0100
Message-ID: <20080827134644.19980.53700.stgit@warthog.procyon.org.uk>
References: <20080827134541.19980.61042.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-security-module@vger.kernel.org,
	David Howells <dhowells@redhat.com>,
	Serge Hallyn <serue@us.ibm.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20080827134541.19980.61042.stgit@warthog.procyon.org.uk>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wrap access to task credentials so that they can be separated more easily from
the task_struct during the introduction of COW creds.

Change most current->(|e|s|fs)[ug]id to current_(|e|s|fs)[ug]id().

Change some task->e?[ug]id to task_e?[ug]id().  In some places it makes more
sense to use RCU directly rather than a convenient wrapper; these will be
addressed by later patches.

Signed-off-by: David Howells <dhowells@redhat.com>
Reviewed-by: James Morris <jmorris@namei.org>
Acked-by: Serge Hallyn <serue@us.ibm.com>
Cc: netdev@vger.kernel.org
---

 drivers/net/tun.c      |    4 ++--
 drivers/net/wan/sbni.c |    9 +++++----
 2 files changed, 7 insertions(+), 6 deletions(-)


diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 6daea0c..70ff2bb 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -712,9 +712,9 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 
 		/* Check permissions */
 		if (((tun->owner != -1 &&
-		      current->euid != tun->owner) ||
+		      current_euid() != tun->owner) ||
 		     (tun->group != -1 &&
-		      current->egid != tun->group)) &&
+		      current_egid() != tun->group)) &&
 		     !capable(CAP_NET_ADMIN))
 			return -EPERM;
 	}
diff --git a/drivers/net/wan/sbni.c b/drivers/net/wan/sbni.c
index e59255a..1ae5bae 100644
--- a/drivers/net/wan/sbni.c
+++ b/drivers/net/wan/sbni.c
@@ -1302,6 +1302,7 @@ sbni_ioctl( struct net_device  *dev,  struct ifreq  *ifr,  int  cmd )
 {
 	struct net_local  *nl = (struct net_local *) dev->priv; 
 	struct sbni_flags  flags;
+	uid_t euid = current_euid();
 	int  error = 0;
 
 #ifdef CONFIG_SBNI_MULTILINE
@@ -1317,7 +1318,7 @@ sbni_ioctl( struct net_device  *dev,  struct ifreq  *ifr,  int  cmd )
 		break;
 
 	case  SIOCDEVRESINSTATS :
-		if( current->euid != 0 )	/* root only */
+		if (euid != 0)	/* root only */
 			return  -EPERM;
 		memset( &nl->in_stats, 0, sizeof(struct sbni_in_stats) );
 		break;
@@ -1334,7 +1335,7 @@ sbni_ioctl( struct net_device  *dev,  struct ifreq  *ifr,  int  cmd )
 		break;
 
 	case  SIOCDEVSHWSTATE :
-		if( current->euid != 0 )	/* root only */
+		if (euid != 0)	/* root only */
 			return  -EPERM;
 
 		spin_lock( &nl->lock );
@@ -1355,7 +1356,7 @@ sbni_ioctl( struct net_device  *dev,  struct ifreq  *ifr,  int  cmd )
 #ifdef CONFIG_SBNI_MULTILINE
 
 	case  SIOCDEVENSLAVE :
-		if( current->euid != 0 )	/* root only */
+		if (euid != 0)	/* root only */
 			return  -EPERM;
 
 		if (copy_from_user( slave_name, ifr->ifr_data, sizeof slave_name ))
@@ -1370,7 +1371,7 @@ sbni_ioctl( struct net_device  *dev,  struct ifreq  *ifr,  int  cmd )
 		return  enslave( dev, slave_dev );
 
 	case  SIOCDEVEMANSIPATE :
-		if( current->euid != 0 )	/* root only */
+		if (euid != 0)	/* root only */
 			return  -EPERM;
 
 		return  emancipate( dev );

