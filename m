From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED]: cls_fw: fix NULL pointer dereference
Date: Mon, 04 Dec 2006 16:34:46 +0100
Message-ID: <45744016.8080707@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060001090006000803020506"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>, jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47377 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937005AbWLDPbk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 10:31:40 -0500
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060001090006000803020506
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Fix a regression from my nfmark mask patch for cls_fw.

Thomas, Jamal, do you have an idea what this "old method" stuff
is used for? It seems it is only used during the below mentioned
race.


--------------060001090006000803020506
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NET_SCHED]: cls_fw: fix NULL pointer dereference

When the first fw classifier is initialized, there is a small window
between the ->init() and ->change() calls, during which the classifier
is active but not entirely set up and tp->root is still NULL (->init()
does nothing).

When a packet is queued during this window a NULL pointer dereference
occurs in fw_classify() when trying to dereference head->mask;

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 07aac6f7b7e43bc1bb960b2f41a02e81d4e25ead
tree 523108861c92ec7e513fbc8561a57b5e1c56c1eb
parent d916faace3efc0bf19fe9a615a1ab8fa1a24cd93
author Patrick McHardy <kaber@trash.net> Mon, 04 Dec 2006 16:29:07 +0100
committer Patrick McHardy <kaber@trash.net> Mon, 04 Dec 2006 16:29:07 +0100

 net/sched/cls_fw.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index f59a2c4..c797d6a 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -101,9 +101,10 @@ static int fw_classify(struct sk_buff *s
 	struct fw_head *head = (struct fw_head*)tp->root;
 	struct fw_filter *f;
 	int r;
-	u32 id = skb->mark & head->mask;
+	u32 id = skb->mark;
 
 	if (head != NULL) {
+		id &= head->mask;
 		for (f=head->ht[fw_hash(id)]; f; f=f->next) {
 			if (f->id == id) {
 				*res = f->res;

--------------060001090006000803020506--
