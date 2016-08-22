From: Thomas Winter <Thomas.Winter@alliedtelesis.co.nz>
Subject: Patch to netfilter conntrack for secondary connection logging
Date: Mon, 22 Aug 2016 02:11:42 +0000
Message-ID: <1471831902045.98124@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:36468 "EHLO
        gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753769AbcHVCLr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 Aug 2016 22:11:47 -0400
Received: from mmarshal3.atlnz.lc (mmarshal3.atlnz.lc [10.32.18.43])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (Client did not present a certificate)
        by gate2.alliedtelesis.co.nz (Postfix) with ESMTPS id 4657E80673
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 14:11:43 +1200 (NZST)
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,=0A=
=0A=
We are using netfilter to implement a firewall for a router and we had the =
problem that the ftp data connections were not being logged.=0A=
I did some investigating and found that it is conntrack that is allowing th=
e secondary connection by the ftp helper module.=0A=
I created a patch to enable such logging for any conntrack helper.=0A=
Is this a good change? Or did I miss something really obvious?=0A=
=0A=
Regards,=0A=
Thomas Winter=0A=
=0A=
=0A=
example iptables rules:=0A=
=0A=
Chain FIREWALL_RULE_12 (1 references)=0A=
target     prot opt source               destination         =0A=
LOG        tcp  --  anywhere             anywhere             multiport spo=
rts 1024:65535 multiport dports ftp match-set private src,src match-set pub=
lic dst,dst ctsta=0A=
te NEW,RELATED,ESTABLISHED LOG level info prefix "Firewall rule 12: PERMIT =
"=0A=
CONNMARK   tcp  --  anywhere             anywhere             multiport spo=
rts 1024:65535 multiport dports ftp match-set private src,src match-set pub=
lic dst,dst ctsta=0A=
te NEW,RELATED,ESTABLISHED CONNMARK xset 0x1/0x7=0A=
LOG        tcp  --  anywhere             anywhere             multiport dpo=
rts 1024:65535 multiport sports ftp match-set public src,src match-set priv=
ate dst,dst ctsta=0A=
te RELATED,ESTABLISHED LOG level info prefix "Firewall rule 12: PERMIT "=0A=
CONNMARK   tcp  --  anywhere             anywhere             multiport dpo=
rts 1024:65535 multiport sports ftp match-set public src,src match-set priv=
ate dst,dst ctsta=0A=
te RELATED,ESTABLISHED CONNMARK xset 0x1/0x7=0A=
=0A=
=0A=
patch:=0A=
=0A=
[PATCH] ICSAFW-9: Added expected connection logging in netfilter=0A=
=0A=
For ICSA firewall requirements, FTP data connections=0A=
must be able to be logged.=0A=
=0A=
Our iptables rules for FTP are not able to log the=0A=
data connections because they only take effect on=0A=
the control connection. The FTP conntrack helper=0A=
module inspects FTP control packets and allows the=0A=
data connections when it sees one about to start.=0A=
=0A=
Added a log function for conntrack to be called=0A=
when allowing expected connections.=0A=
=0A=
---=0A=
 include/net/netfilter/nf_conntrack_expect.h |  5 +++++=0A=
 net/netfilter/nf_conntrack_core.c           |  4 ++++=0A=
 net/netfilter/nf_conntrack_ftp.c            | 21 +++++++++++++++++++++=0A=
 3 files changed, 30 insertions(+)=0A=
=0A=
diff --git a/include/net/netfilter/nf_conntrack_expect.h b/include/net/netf=
ilter/nf_conntrack_expect.h=0A=
index dce56f0..c13a457 100644=0A=
--- a/include/net/netfilter/nf_conntrack_expect.h=0A=
+++ b/include/net/netfilter/nf_conntrack_expect.h=0A=
@@ -26,6 +26,11 @@ struct nf_conntrack_expect {=0A=
 	void (*expectfn)(struct nf_conn *new,=0A=
 			 struct nf_conntrack_expect *this);=0A=
 =0A=
+#ifdef ATL_CHANGE=0A=
+	/* Logging function to call when seeing an expected connection */=0A=
+	void (*logfn)(const struct nf_conntrack_tuple *tuple);=0A=
+#endif=0A=
+=0A=
 	/* Helper to assign to new connection */=0A=
 	struct nf_conntrack_helper *helper;=0A=
 =0A=
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack=
_core.c=0A=
index 37d8c06..8f4e15c 100644=0A=
--- a/net/netfilter/nf_conntrack_core.c=0A=
+++ b/net/netfilter/nf_conntrack_core.c=0A=
@@ -984,6 +984,10 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,=
=0A=
 				if (help)=0A=
 					rcu_assign_pointer(help->helper, exp->helper);=0A=
 			}=0A=
+#ifdef ATL_CHANGE=0A=
+			if (exp->logfn)=0A=
+				exp->logfn(tuple);=0A=
+#endif=0A=
 =0A=
 #ifdef CONFIG_NF_CONNTRACK_MARK=0A=
 			ct->mark =3D exp->master->mark;=0A=
diff --git a/net/netfilter/nf_conntrack_ftp.c b/net/netfilter/nf_conntrack_=
ftp.c=0A=
index b666959..3dd1900 100644=0A=
--- a/net/netfilter/nf_conntrack_ftp.c=0A=
+++ b/net/netfilter/nf_conntrack_ftp.c=0A=
@@ -382,6 +382,23 @@ static void update_nl_seq(struct nf_conn *ct, u32 nl_s=
eq,=0A=
 	}=0A=
 }=0A=
 =0A=
+#ifdef ATL_CHANGE=0A=
+void log_ftp_data_connection(const struct nf_conntrack_tuple *tuple)=0A=
+{=0A=
+	if (tuple) {=0A=
+		if (tuple->src.l3num =3D=3D PF_INET) {=0A=
+			pr_info("FTP data connection initiated by %pI4:%d to %pI4:%d\n",=0A=
+				&tuple->src.u3.ip, tuple->src.u.tcp.port,=0A=
+				&tuple->dst.u3.ip, tuple->dst.u.tcp.port);=0A=
+		} else {=0A=
+			pr_info("FTP data connection initiated by %pI6:%d to %pI6:%d\n",=0A=
+				&tuple->src.u3.ip, tuple->src.u.tcp.port,=0A=
+				&tuple->dst.u3.ip, tuple->dst.u.tcp.port);=0A=
+		}=0A=
+	}=0A=
+}=0A=
+#endif=0A=
+=0A=
 static int help(struct sk_buff *skb,=0A=
 		unsigned int protoff,=0A=
 		struct nf_conn *ct,=0A=
@@ -529,6 +546,10 @@ skip_nl_seq:=0A=
 			  &ct->tuplehash[!dir].tuple.src.u3, daddr,=0A=
 			  IPPROTO_TCP, NULL, &cmd.u.tcp.port);=0A=
 =0A=
+#ifdef ATL_CHANGE=0A=
+	exp->logfn =3D log_ftp_data_connection;=0A=
+#endif=0A=
+=0A=
 	/* Now, NAT might want to mangle the packet, and register the=0A=
 	 * (possibly changed) expectation itself. */=0A=
 	nf_nat_ftp =3D rcu_dereference(nf_nat_ftp_hook);=0A=
-- =0A=
2.9.3=0A=
