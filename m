From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 19/19] netfilter: gre: fix resource leak when
 unregister gre proto
Date: Sat, 5 Jan 2013 04:50:48 +0100
Message-ID: <20130105035048.GA20027@1984>
References: <1356662206-2260-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1356662206-2260-20-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Kj7319i9nmIyA2yE"
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	canqunzhang@gmail.com, kaber@trash.net, ebiederm@xmission.com
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41565 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754775Ab3AEDuy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jan 2013 22:50:54 -0500
Content-Disposition: inline
In-Reply-To: <1356662206-2260-20-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Kj7319i9nmIyA2yE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Gao,

On Fri, Dec 28, 2012 at 10:36:46AM +0800, Gao feng wrote:
> Currectly we unregister proto before all conntrack entries of
> this proto being destroyed. so in function destroy_conntrack
> we can't find proper l4proto to call l4proto->destroy.
> this will cause resource leak.

Good catch.

But better to remove the entries before unregistering the protocol
tracker, so l4proto->destroy is always called.

Patch attached.

--Kj7319i9nmIyA2yE
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-netfilter-nf_conntrack-fix-memory-leak-during-unregi.patch"

>From 1c082b3ef4c9bf8bfd0159142ce6ffc49aa7bab2 Mon Sep 17 00:00:00 2001
From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Fri, 4 Jan 2013 22:09:44 +0100
Subject: [PATCH] netfilter: nf_conntrack: fix memory leak during
 unregistration with GRE entries

Protocol trackers are unregistered before conntrack entries of that
type are removed. For that reason, l4proto->destroy is never called
and that results in leaking the keymap.

Fix this by releasing entries before unregistering protocols.

Reported-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_proto.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 51e928d..29cd353 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -488,6 +488,9 @@ void nf_conntrack_l4proto_unregister(struct net *net,
 {
 	struct nf_proto_net *pn = NULL;
 
+	/* Remove all contrack entries before unregistration */
+	nf_ct_iterate_cleanup(net, kill_l4proto, l4proto);
+
 	if (net == &init_net)
 		nf_conntrack_l4proto_unregister_net(l4proto);
 
@@ -497,9 +500,6 @@ void nf_conntrack_l4proto_unregister(struct net *net,
 
 	pn->users--;
 	nf_ct_l4proto_unregister_sysctl(net, pn, l4proto);
-
-	/* Remove all contrack entries for this protocol */
-	nf_ct_iterate_cleanup(net, kill_l4proto, l4proto);
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_unregister);
 
-- 
1.7.10.4


--Kj7319i9nmIyA2yE--
