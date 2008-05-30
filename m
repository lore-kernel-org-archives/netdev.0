From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: [PATCH BUGFIX -rc4] Smack: Respect 'unlabeled' netlabel mode
Date: Sat, 31 May 2008 02:36:03 +0300
Message-ID: <20080530233603.GA2994@ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Casey Schaufler <casey@schaufler-ca.com>,
	Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.189]:20614 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752787AbYE3Wkw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2008 18:40:52 -0400
Received: by mu-out-0910.google.com with SMTP id w8so288113mue.1
        for <netdev@vger.kernel.org>; Fri, 30 May 2008 15:40:51 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

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

diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index b5c8f92..03735f4 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -1292,6 +1292,8 @@ static void smack_to_secattr(char *smack, struct netlbl_lsm_secattr *nlsp)
 		}
 		break;
 	default:
+		nlsp->domain = kstrdup(smack_net_ambient, GFP_ATOMIC);
+		nlsp->flags = NETLBL_SECATTR_DOMAIN;
 		break;
 	}
 }

-- 

"Better to light a candle, than curse the darkness"

Ahmed S. Darwish
Homepage: http://darwish.07.googlepages.com
Blog: http://darwish-07.blogspot.com

