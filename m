From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 05/05: xt_recent: fix stack overread in compat code
Date: Fri, 24 Apr 2009 17:44:07 +0200 (MEST)
Message-ID: <20090424154402.28952.86241.sendpatchset@x2.localnet>
References: <20090424154355.28952.21443.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090424154355.28952.21443.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 37e55cf0ceb8803256bf69a3e45bd668bf90b76f
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Fri Apr 24 17:05:21 2009 +0200

    netfilter: xt_recent: fix stack overread in compat code
    
    Related-to: commit 325fb5b4d26038cba665dd0d8ee09555321061f0
    
    The compat path suffers from a similar problem. It only uses a __be32
    when all of the recent code uses, and expects, an nf_inet_addr
    everywhere. As a result, addresses stored by xt_recents were
    filled with whatever other stuff was on the stack following the be32.
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
    
    With a minor compile fix from Roman.
    
    Reported-and-tested-by: Roman Hoog Antink <rha@open.ch>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index 791e030..eb0ceb8 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -474,7 +474,7 @@ static ssize_t recent_old_proc_write(struct file *file,
 	struct recent_table *t = pde->data;
 	struct recent_entry *e;
 	char buf[sizeof("+255.255.255.255")], *c = buf;
-	__be32 addr;
+	union nf_inet_addr addr = {};
 	int add;
 
 	if (size > sizeof(buf))
@@ -506,14 +506,13 @@ static ssize_t recent_old_proc_write(struct file *file,
 		add = 1;
 		break;
 	}
-	addr = in_aton(c);
+	addr.ip = in_aton(c);
 
 	spin_lock_bh(&recent_lock);
-	e = recent_entry_lookup(t, (const void *)&addr, NFPROTO_IPV4, 0);
+	e = recent_entry_lookup(t, &addr, NFPROTO_IPV4, 0);
 	if (e == NULL) {
 		if (add)
-			recent_entry_init(t, (const void *)&addr,
-					  NFPROTO_IPV4, 0);
+			recent_entry_init(t, &addr, NFPROTO_IPV4, 0);
 	} else {
 		if (add)
 			recent_entry_update(t, e);
