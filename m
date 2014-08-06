From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net] netlink: hold nl_sock_hash_lock during diag dump
Date: Thu, 7 Aug 2014 00:18:47 +0100
Message-ID: <20140806231847.GA3703@casper.infradead.org>
References: <CANaxB-ySsRXHPSEPOuExeKAvDX7esZ1WBZAVMTWQxtmfN2=i4w@mail.gmail.com>
 <CAHA+R7N0c83by=AAgw2nKPibYETNyv6JTEWnu5XOo-67fHMELw@mail.gmail.com>
 <20140806195127.GA26832@casper.infradead.org>
 <CAHA+R7OB_gTYPKtqw-iry+nfkTbmApw4GPpeKjqfXugcit4Guw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrey Wagin <avagin@gmail.com>, netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:44476 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753885AbaHFXSs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 19:18:48 -0400
Content-Disposition: inline
In-Reply-To: <CAHA+R7OB_gTYPKtqw-iry+nfkTbmApw4GPpeKjqfXugcit4Guw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/06/14 at 02:20pm, Cong Wang wrote:
> On Wed, Aug 6, 2014 at 12:51 PM, Thomas Graf <tgraf@suug.ch> wrote:
> > On 08/06/14 at 10:52am, Cong Wang wrote:
> >>
> >> Looks like we should hold rcu_read_lock() before calling __netlink_diag_dump().
> >
> > netlink_diag_dump() still acquires nl_table_lock which is pointless as
> > a separate mutex has been introduced to protect mutations. I will send
> > a patch to RCU'ify it properly.
> 
> Agreed, but that's likely a net-next material.
> 
> I think we need the following quick fix for net.

I came up with the exact same patch as you first but eventually
figured holding the mutex directly as below ias actually better
in this case:

[PATCH net] netlink: hold nl_sock_hash_lock during diag dump

Although RCU protection would be possible during diag dump, doing
so allows for concurrent table mutations which can render the
in-table offset between individual Netlink messages invalid and
thus cause legitimate sockets to be skipped in the dump.

Since the diag dump is relatively low volume and consistency is
more important than performance, the table mutex is held during
dump.

Reported-by: Andrey Wagin <avagin@gmail.com>
Signed-off-by: Thomas Graf <tgraf@suug.ch>
Fixes: e341694e3eb57fc ("netlink: Convert netlink_lookup() to use RCU protected hash table")
---
 net/netlink/af_netlink.c | 1 +
 net/netlink/af_netlink.h | 1 +
 net/netlink/diag.c       | 3 +++
 3 files changed, 5 insertions(+)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 479a344..a324b4b 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -104,6 +104,7 @@ static atomic_t nl_table_users = ATOMIC_INIT(0);
 
 /* Protects netlink socket hash table mutations */
 DEFINE_MUTEX(nl_sk_hash_lock);
+EXPORT_SYMBOL_GPL(nl_sk_hash_lock);
 
 static int lockdep_nl_sk_hash_is_held(void)
 {
diff --git a/net/netlink/af_netlink.h b/net/netlink/af_netlink.h
index 60f631f..b20a173 100644
--- a/net/netlink/af_netlink.h
+++ b/net/netlink/af_netlink.h
@@ -73,5 +73,6 @@ struct netlink_table {
 
 extern struct netlink_table *nl_table;
 extern rwlock_t nl_table_lock;
+extern struct mutex nl_sk_hash_lock;
 
 #endif
diff --git a/net/netlink/diag.c b/net/netlink/diag.c
index 7301850..de8c74a 100644
--- a/net/netlink/diag.c
+++ b/net/netlink/diag.c
@@ -170,6 +170,7 @@ static int netlink_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 
 	req = nlmsg_data(cb->nlh);
 
+	mutex_lock(&nl_sk_hash_lock);
 	read_lock(&nl_table_lock);
 
 	if (req->sdiag_protocol == NDIAG_PROTO_ALL) {
@@ -183,6 +184,7 @@ static int netlink_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	} else {
 		if (req->sdiag_protocol >= MAX_LINKS) {
 			read_unlock(&nl_table_lock);
+			mutex_unlock(&nl_sk_hash_lock);
 			return -ENOENT;
 		}
 
@@ -190,6 +192,7 @@ static int netlink_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	}
 
 	read_unlock(&nl_table_lock);
+	mutex_unlock(&nl_sk_hash_lock);
 
 	return skb->len;
 }
-- 
1.9.3
