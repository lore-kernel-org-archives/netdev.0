From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 02/04: nf_ct_dccp: add missing DCCP protocol changes in event cache
Date: Wed, 27 May 2009 16:35:27 +0200 (MEST)
Message-ID: <20090527143525.4649.25643.sendpatchset@x2.localnet>
References: <20090527143521.4649.73610.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090527143521.4649.73610.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit b38b1f616867c832301f24eaf259889494d495b3
Author: Pablo Neira Ayuso <Pablo Neira Ayuso>
Date:   Mon May 25 17:29:43 2009 +0200

    netfilter: nf_ct_dccp: add missing DCCP protocol changes in event cache
    
    This patch adds the missing protocol state-change event reporting
    for DCCP.
    
    $ sudo conntrack -E
        [NEW] dccp     33 240 src=192.168.0.2 dst=192.168.1.2 sport=57040 dport=5001 [UNREPLIED] src=192.168.1.2 dst=192.168.1.100 sport=5001 dport=57040
    
    With this patch:
    
    $ sudo conntrack -E
        [NEW] dccp     33 240 REQUEST src=192.168.0.2 dst=192.168.1.2 sport=57040 dport=5001 [UNREPLIED] src=192.168.1.2 dst=192.168.1.100 sport=5001 dport=57040
    
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index 8e757dd..aee0d6b 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -22,6 +22,7 @@
 #include <linux/netfilter/nfnetlink_conntrack.h>
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_l4proto.h>
+#include <net/netfilter/nf_conntrack_ecache.h>
 #include <net/netfilter/nf_log.h>
 
 static DEFINE_RWLOCK(dccp_lock);
@@ -553,6 +554,9 @@ static int dccp_packet(struct nf_conn *ct, const struct sk_buff *skb,
 	ct->proto.dccp.state = new_state;
 	write_unlock_bh(&dccp_lock);
 
+	if (new_state != old_state)
+		nf_conntrack_event_cache(IPCT_PROTOINFO, ct);
+
 	dn = dccp_pernet(net);
 	nf_ct_refresh_acct(ct, ctinfo, skb, dn->dccp_timeout[new_state]);
 
