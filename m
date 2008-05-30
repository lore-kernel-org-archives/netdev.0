From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: [PATCH BUGFIX -v2 -rc4] Smack: Respect 'unlabeled' netlabel mode
Date: Sat, 31 May 2008 02:57:51 +0300
Message-ID: <20080530235751.GA6888@ubuntu>
References: <20080530233603.GA2994@ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Casey Schaufler <casey@schaufler-ca.com>,
	Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.188]:32479 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753211AbYE3XCl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2008 19:02:41 -0400
Received: by mu-out-0910.google.com with SMTP id w8so294577mue.1
        for <netdev@vger.kernel.org>; Fri, 30 May 2008 16:02:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080530233603.GA2994@ubuntu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!,

[ Sorry, Fix: Acquire smack_ambient_lock before reading smack_net_ambient ]

-->

In case of Smack 'unlabeled' netlabel option, Smack passes a _zero_
initialized 'secattr' to label a packet/sock. This causes an 
[unfound domain label error]/-ENOENT by netlbl_sock_setattr().
Above Netlabel failure leads to Smack socket hooks failure causing 
an always-on socket() -EPERM error.

Such packets should have a netlabel domain agreed with netlabel to 
represent unlabeled packets. Fortunately Smack net ambient label 
packets are agreed with netlabel to be treated as unlabeled packets. 

Treat all packets coming out from a 'unlabeled' Smack system as
coming from the smack net ambient label.

Signed-off-by: Ahmed S. Darwish <darwish.07@gmail.com>
---

diff --git a/security/smack/smack.h b/security/smack/smack.h
index 4a4477f..81b94ba 100644
--- a/security/smack/smack.h
+++ b/security/smack/smack.h
@@ -16,6 +16,7 @@
 #include <linux/capability.h>
 #include <linux/spinlock.h>
 #include <linux/security.h>
+#include <linux/mutex.h>
 #include <net/netlabel.h>
 
 /*
@@ -178,6 +179,7 @@ u32 smack_to_secid(const char *);
 extern int smack_cipso_direct;
 extern int smack_net_nltype;
 extern char *smack_net_ambient;
+extern struct mutex smack_ambient_lock;
 
 extern struct smack_known *smack_known;
 extern struct smack_known smack_known_floor;
diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index b5c8f92..0d9c7dc 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -1292,6 +1292,11 @@ static void smack_to_secattr(char *smack, struct netlbl_lsm_secattr *nlsp)
 		}
 		break;
 	default:
+		mutex_lock(&smack_ambient_lock);
+		nlsp->domain = kstrdup(smack_net_ambient, GFP_ATOMIC);
+		mutex_unlock(&smack_ambient_lock);
+
+		nlsp->flags = NETLBL_SECATTR_DOMAIN;
 		break;
 	}
 }
diff --git a/security/smack/smackfs.c b/security/smack/smackfs.c
index 271a835..cc357dc 100644
--- a/security/smack/smackfs.c
+++ b/security/smack/smackfs.c
@@ -46,7 +46,7 @@ enum smk_inos {
  */
 static DEFINE_MUTEX(smack_list_lock);
 static DEFINE_MUTEX(smack_cipso_lock);
-static DEFINE_MUTEX(smack_ambient_lock);
+DEFINE_MUTEX(smack_ambient_lock);
 
 /*
  * This is the "ambient" label for network traffic.

-- 

"Better to light a candle, than curse the darkness"

Ahmed S. Darwish
Homepage: http://darwish.07.googlepages.com
Blog: http://darwish-07.blogspot.com

