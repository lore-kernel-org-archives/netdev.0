From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 21/22] fscache: fix fscache_objlist_show format processing
Date: Fri, 14 Jul 2017 14:07:13 +0200
Message-ID: <20170714120720.906842-22-arnd@arndb.de>
References: <20170714120720.906842-1-arnd@arndb.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Guenter Roeck <linux@roeck-us.net>, akpm@linux-foundation.org,
        netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        "James E . J . Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K . Petersen" <martin.petersen@oracle.com>,
        linux-scsi@vger.kernel.org, x86@kernel.org,
        Arnd Bergmann <arnd@arndb.de>,
        James Morris <james.l.morris@oracle.com>,
        linux-cachefs@redhat.com
To: linux-kernel@vger.kernel.org, David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.24]:62281 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754032AbdGNMOk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2017 08:14:40 -0400
In-Reply-To: <20170714120720.906842-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gcc points out a minor bug in the handling of unknown
cookie types, which could result in a string overflow
when the integer is copied into a 3-byte string:

fs/fscache/object-list.c: In function 'fscache_objlist_show':
fs/fscache/object-list.c:265:19: error: 'sprintf' may write a terminating nul past the end of the destination [-Werror=format-overflow=]
 sprintf(_type, "%02u", cookie->def->type);
                ^~~~~~
fs/fscache/object-list.c:265:4: note: 'sprintf' output between 3 and 4 bytes into a destination of size 3

This is currently harmless as no code sets a type other
than 0 or 1, but it makes sense to use snprintf() here
to avoid overflowing the array if that changes.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 fs/fscache/object-list.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/fscache/object-list.c b/fs/fscache/object-list.c
index 67f940892ef8..b5ab06fabc60 100644
--- a/fs/fscache/object-list.c
+++ b/fs/fscache/object-list.c
@@ -262,7 +262,8 @@ static int fscache_objlist_show(struct seq_file *m, void *v)
 			type = "DT";
 			break;
 		default:
-			sprintf(_type, "%02u", cookie->def->type);
+			snprintf(_type, sizeof(_type), "%02u",
+				 cookie->def->type);
 			type = _type;
 			break;
 		}
-- 
2.9.0
