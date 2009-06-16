From: David Howells <dhowells@redhat.com>
Subject: [PATCH 2/2] AFS: Correctly translate auth error aborts and don't
	failover in such cases
Date: Tue, 16 Jun 2009 21:36:49 +0100
Message-ID: <20090616203649.4447.82940.stgit@warthog.procyon.org.uk>
References: <20090616203644.4447.24960.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-afs@lists.infradead.org,
	netdev@vger.kernel.org, David Howells <dhowells@redhat.com>
To: torvalds@osdl.org, akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:59436 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758194AbZFPUiE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jun 2009 16:38:04 -0400
In-Reply-To: <20090616203644.4447.24960.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Authentication error abort codes should be translated to appropriate Linux
error codes, rather than all being translated to EREMOTEIO - which indicates
that the server had internal problems.

Additionally, a server shouldn't be marked unavailable and the next server
tried if an authentication error occurs.  This will quickly make all the
servers unavailable to the client.  Instead the error should be returned
straight to the user.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/misc.c      |   16 ++++++++++++++++
 fs/afs/vlocation.c |    2 ++
 2 files changed, 18 insertions(+), 0 deletions(-)


diff --git a/fs/afs/misc.c b/fs/afs/misc.c
index 2d33a5f..0dd4daf 100644
--- a/fs/afs/misc.c
+++ b/fs/afs/misc.c
@@ -12,6 +12,7 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/errno.h>
+#include <rxrpc/packet.h>
 #include "internal.h"
 #include "afs_fs.h"
 
@@ -54,6 +55,21 @@ int afs_abort_to_error(u32 abort_code)
 	case 0x2f6df24:		return -ENOLCK;
 	case 0x2f6df26:		return -ENOTEMPTY;
 	case 0x2f6df78:		return -EDQUOT;
+
+	case RXKADINCONSISTENCY: return -EPROTO;
+	case RXKADPACKETSHORT:	return -EPROTO;
+	case RXKADLEVELFAIL:	return -EKEYREJECTED;
+	case RXKADTICKETLEN:	return -EKEYREJECTED;
+	case RXKADOUTOFSEQUENCE: return -EPROTO;
+	case RXKADNOAUTH:	return -EKEYREJECTED;
+	case RXKADBADKEY:	return -EKEYREJECTED;
+	case RXKADBADTICKET:	return -EKEYREJECTED;
+	case RXKADUNKNOWNKEY:	return -EKEYREJECTED;
+	case RXKADEXPIRED:	return -EKEYEXPIRED;
+	case RXKADSEALEDINCON:	return -EKEYREJECTED;
+	case RXKADDATALEN:	return -EKEYREJECTED;
+	case RXKADILLEGALLEVEL:	return -EKEYREJECTED;
+
 	default:		return -EREMOTEIO;
 	}
 }
diff --git a/fs/afs/vlocation.c b/fs/afs/vlocation.c
index ec2a743..6e68920 100644
--- a/fs/afs/vlocation.c
+++ b/fs/afs/vlocation.c
@@ -65,6 +65,8 @@ static int afs_vlocation_access_vl_by_name(struct afs_vlocation *vl,
 				goto out;
 			goto rotate;
 		case -ENOMEDIUM:
+		case -EKEYREJECTED:
+		case -EKEYEXPIRED:
 			goto out;
 		default:
 			ret = -EIO;

