From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 04/05: nf_ct_dccp: add missing role attributes for DCCP
Date: Fri, 24 Apr 2009 17:44:06 +0200 (MEST)
Message-ID: <20090424154401.28952.91303.sendpatchset@x2.localnet>
References: <20090424154355.28952.21443.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090424154355.28952.21443.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 71951b64a5a87c09eb6fde59ce51aaab2fdaeab2
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Fri Apr 24 16:58:41 2009 +0200

    netfilter: nf_ct_dccp: add missing role attributes for DCCP
    
    This patch adds missing role attribute to the DCCP type, otherwise
    the creation of entries is not of any use.
    
    The attribute added is CTA_PROTOINFO_DCCP_ROLE which contains the
    role of the conntrack original tuple.
    
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netfilter/nfnetlink_conntrack.h b/include/linux/netfilter/nfnetlink_conntrack.h
index 29fe9ea..1a865e4 100644
--- a/include/linux/netfilter/nfnetlink_conntrack.h
+++ b/include/linux/netfilter/nfnetlink_conntrack.h
@@ -100,6 +100,7 @@ enum ctattr_protoinfo_tcp {
 enum ctattr_protoinfo_dccp {
 	CTA_PROTOINFO_DCCP_UNSPEC,
 	CTA_PROTOINFO_DCCP_STATE,
+	CTA_PROTOINFO_DCCP_ROLE,
 	__CTA_PROTOINFO_DCCP_MAX,
 };
 #define CTA_PROTOINFO_DCCP_MAX (__CTA_PROTOINFO_DCCP_MAX - 1)
diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index 5411d63..8e757dd 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -633,6 +633,8 @@ static int dccp_to_nlattr(struct sk_buff *skb, struct nlattr *nla,
 	if (!nest_parms)
 		goto nla_put_failure;
 	NLA_PUT_U8(skb, CTA_PROTOINFO_DCCP_STATE, ct->proto.dccp.state);
+	NLA_PUT_U8(skb, CTA_PROTOINFO_DCCP_ROLE,
+		   ct->proto.dccp.role[IP_CT_DIR_ORIGINAL]);
 	nla_nest_end(skb, nest_parms);
 	read_unlock_bh(&dccp_lock);
 	return 0;
@@ -644,6 +646,7 @@ nla_put_failure:
 
 static const struct nla_policy dccp_nla_policy[CTA_PROTOINFO_DCCP_MAX + 1] = {
 	[CTA_PROTOINFO_DCCP_STATE]	= { .type = NLA_U8 },
+	[CTA_PROTOINFO_DCCP_ROLE]	= { .type = NLA_U8 },
 };
 
 static int nlattr_to_dccp(struct nlattr *cda[], struct nf_conn *ct)
@@ -661,11 +664,21 @@ static int nlattr_to_dccp(struct nlattr *cda[], struct nf_conn *ct)
 		return err;
 
 	if (!tb[CTA_PROTOINFO_DCCP_STATE] ||
-	    nla_get_u8(tb[CTA_PROTOINFO_DCCP_STATE]) >= CT_DCCP_IGNORE)
+	    !tb[CTA_PROTOINFO_DCCP_ROLE] ||
+	    nla_get_u8(tb[CTA_PROTOINFO_DCCP_ROLE]) > CT_DCCP_ROLE_MAX ||
+	    nla_get_u8(tb[CTA_PROTOINFO_DCCP_STATE]) >= CT_DCCP_IGNORE) {
 		return -EINVAL;
+	}
 
 	write_lock_bh(&dccp_lock);
 	ct->proto.dccp.state = nla_get_u8(tb[CTA_PROTOINFO_DCCP_STATE]);
+	if (nla_get_u8(tb[CTA_PROTOINFO_DCCP_ROLE]) == CT_DCCP_ROLE_CLIENT) {
+		ct->proto.dccp.role[IP_CT_DIR_ORIGINAL] = CT_DCCP_ROLE_CLIENT;
+		ct->proto.dccp.role[IP_CT_DIR_REPLY] = CT_DCCP_ROLE_SERVER;
+	} else {
+		ct->proto.dccp.role[IP_CT_DIR_ORIGINAL] = CT_DCCP_ROLE_SERVER;
+		ct->proto.dccp.role[IP_CT_DIR_REPLY] = CT_DCCP_ROLE_CLIENT;
+	}
 	write_unlock_bh(&dccp_lock);
 	return 0;
 }
