From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/4] netfilter: synproxy_core: fix warning in __nf_ct_ext_add_length()
Date: Wed,  4 Sep 2013 15:00:23 +0200
Message-ID: <1378299625-4638-3-git-send-email-pablo@netfilter.org>
References: <1378299625-4638-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:36051 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756922Ab3IDNAj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Sep 2013 09:00:39 -0400
In-Reply-To: <1378299625-4638-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

With CONFIG_NETFILTER_DEBUG we get the following warning during SYNPROXY init:

[   80.558906] WARNING: CPU: 1 PID: 4833 at net/netfilter/nf_conntrack_extend.c:80 __nf_ct_ext_add_length+0x217/0x220 [nf_conntrack]()

The reason is that the conntrack template is set to confirmed before adding
the extension and it is invalid to add extensions to already confirmed
conntracks. Fix by adding the extensions before setting the conntrack to
confirmed.

Reported-by: Jesper Dangaard Brouer <jesper.brouer@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_synproxy_core.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_synproxy_core.c b/net/netfilter/nf_synproxy_core.c
index d23dc79..6fd967c 100644
--- a/net/netfilter/nf_synproxy_core.c
+++ b/net/netfilter/nf_synproxy_core.c
@@ -356,12 +356,12 @@ static int __net_init synproxy_net_init(struct net *net)
 		goto err1;
 	}
 
-	__set_bit(IPS_TEMPLATE_BIT, &ct->status);
-	__set_bit(IPS_CONFIRMED_BIT, &ct->status);
 	if (!nfct_seqadj_ext_add(ct))
 		goto err2;
 	if (!nfct_synproxy_ext_add(ct))
 		goto err2;
+	__set_bit(IPS_TEMPLATE_BIT, &ct->status);
+	__set_bit(IPS_CONFIRMED_BIT, &ct->status);
 
 	snet->tmpl = ct;
 
-- 
1.7.10.4
