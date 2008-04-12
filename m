From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][AX25]: Potential ax25_uid_assoc-s leaks on module unload.
Date: Sat, 12 Apr 2008 16:05:44 +0400
Message-ID: <4800A598.10506@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-hams@vger.kernel.org
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:46047 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758130AbYDLMGr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Apr 2008 08:06:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ax25_uid_free call walks the ax25_uid_list and releases
entries from it. The problem is that after the fisrt call to
hlist_del_init the hlist_for_each_entry (which hides behind
the ax25_uid_for_each) will consider the current position to
be the last and will return.

Thus, the whole list will be left not freed.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ax25/ax25_uid.c b/net/ax25/ax25_uid.c
index 5f4eb73..57aeba7 100644
--- a/net/ax25/ax25_uid.c
+++ b/net/ax25/ax25_uid.c
@@ -218,9 +218,11 @@ void __exit ax25_uid_free(void)
 	struct hlist_node *node;
 
 	write_lock(&ax25_uid_lock);
+again:
 	ax25_uid_for_each(ax25_uid, node, &ax25_uid_list) {
 		hlist_del_init(&ax25_uid->uid_node);
 		ax25_uid_put(ax25_uid);
+		goto again;
 	}
 	write_unlock(&ax25_uid_lock);
 }
