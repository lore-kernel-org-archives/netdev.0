From: Joerg Marx <joerg.marx@secunet.com>
Subject: [PATCH] nf_conntrack_core.c: fix for dead connection after flushing
 conntrack cache
Date: Wed, 05 May 2010 16:46:25 +0200
Message-ID: <4BE184C1.7020402@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:35895 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760407Ab0EEPPo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 May 2010 11:15:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

we encountered a weird problem of a 'stalled' connection when using
'conntrack -F' on a box with heavy network load. 'conntrack -L' gave us
sometimes a [UNREPLIED] entry for the traffic in question, but no traffic
flow, no matching of packets in or out, only the timer went down from 600
to 0 (it was ESP traffic - the default generic timeout = 600 seconds).
After the entry vanished by timeout (or doing a 'conntrack -F' once more),
all worked normal again.

The reason we finally found, is a race window in 'nf_conntrack_confirm'
when calling '__nf_conntrack_confirm':

In 'nf_conntrack_confirm' is checked (without holding a lock), if the entry
to be confirmed is possibly dying: !nf_ct_is_dying(ct).
If not, then __nf_conntrack_confirm will do some sanity checking, grab a
spin_lock_bh and insert the 'ct' into the lookup cache.

Now consider the following scenario:

1. a connection has seen the first packet already -> state is UNREPLIED
2. now the answer is to be sent, conntrack wants to confirm the connection
3. the !nf_ct_is_dying(ct) check is passed, __nf_conntrack_confirm is just
started
4. in a user context a 'conntrack -F' command is running right now e.g. on
another CPU
5. this will flag all unconfirmed connections as 'dying' in
get_next_corpse(...), including the entry going to be confirmed!
6. now the already 'dying' entry is included into the hash cache in
__nf_conntrack_confirm - BOOM!

After this step the connection in question is dead, because no packets are
forwarded until the entry is purged from hash cache. This was a big blocker
for us, because each dead IPsec tunnel is a dead branch network for 10
minutes...

For every packet from now on 'nf_conntrack_find_get' will ignore the entry,
because it is dying and because __nf_conntrack_confirm finds the hash in
the cache already, it will NF_DROP the packet.

The key for finding this was 'NF_CT_STAT_INC(net, insert_failed)' in
__nf_conntrack_confirm.

The suggested solution is to check for '!nf_ct_is_dying(ct)' again, _after_
the spin_lock_bh is grabbed in __nf_conntrack_confirm. So it is clear, that
no other softirq or user context can set that 'evil' dying flag ;-)
The return value in this case should be NF_ACCEPT, so we loose no packets
then, this is also important for us.


---
 net/netfilter/nf_conntrack_core.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c
b/net/netfilter/nf_conntrack_core.c
index 1374179..e2c8bfe 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -413,6 +413,11 @@ __nf_conntrack_confirm(struct sk_buff *skb)

 	spin_lock_bh(&nf_conntrack_lock);

+	if (unlikely(nf_ct_is_dying(ct))) {
+		spin_unlock_bh(&nf_conntrack_lock);
+		return NF_ACCEPT;
+	}
+
 	/* See if there's one in the list already, including reverse:
 	   NAT could have grabbed it without realizing, since we're
 	   not in the hash.  If there is, we lost race. */
-- 1.5.6.5

Best regards
Joerg.


-- 
