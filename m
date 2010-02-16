From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 06/62: nf_nat_ftp: remove (*mangle[]) array and functions, use %pI4
Date: Tue, 16 Feb 2010 15:55:27 +0100 (MET)
Message-ID: <20100216145525.2796.28656.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51955 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755491Ab0BPOz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 09:55:28 -0500
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit c299bd53aa2616e6afc304b4f848186af3b3a881
Author: Joe Perches <joe@perches.com>
Date:   Mon Jan 11 11:49:51 2010 +0100

    netfilter: nf_nat_ftp: remove (*mangle[]) array and functions, use %pI4
    
    These functions merely exist to format a buffer and call
    nf_nat_mangle_tcp_packet.
    
    Format the buffer and perform the call in nf_nat_ftp instead.
    
    Use %pI4 for the IP address.
    
    Saves ~600 bytes of text
    
    old:
    $ size net/ipv4/netfilter/nf_nat_ftp.o
       text	   data	    bss	    dec	    hex	filename
       2187	    160	    408	   2755	    ac3	net/ipv4/netfilter/nf_nat_ftp.o
    new:
    $ size net/ipv4/netfilter/nf_nat_ftp.o
       text    data     bss     dec     hex filename
       1532     112     288    1932     78c net/ipv4/netfilter/nf_nat_ftp.o
    
    Signed-off-by: Joe Perches <joe@perches.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/netfilter/nf_nat_ftp.c b/net/ipv4/netfilter/nf_nat_ftp.c
index a1d5d58..86e0e84 100644
--- a/net/ipv4/netfilter/nf_nat_ftp.c
+++ b/net/ipv4/netfilter/nf_nat_ftp.c
@@ -27,76 +27,29 @@ MODULE_ALIAS("ip_nat_ftp");
 
 /* FIXME: Time out? --RR */
 
-static int
-mangle_rfc959_packet(struct sk_buff *skb,
-		     __be32 newip,
-		     u_int16_t port,
-		     unsigned int matchoff,
-		     unsigned int matchlen,
-		     struct nf_conn *ct,
-		     enum ip_conntrack_info ctinfo)
+static int nf_nat_ftp_fmt_cmd(enum nf_ct_ftp_type type,
+			      char *buffer, size_t buflen,
+			      __be32 addr, u16 port)
 {
-	char buffer[sizeof("nnn,nnn,nnn,nnn,nnn,nnn")];
-
-	sprintf(buffer, "%u,%u,%u,%u,%u,%u",
-		NIPQUAD(newip), port>>8, port&0xFF);
-
-	pr_debug("calling nf_nat_mangle_tcp_packet\n");
-
-	return nf_nat_mangle_tcp_packet(skb, ct, ctinfo, matchoff,
-					matchlen, buffer, strlen(buffer));
-}
-
-/* |1|132.235.1.2|6275| */
-static int
-mangle_eprt_packet(struct sk_buff *skb,
-		   __be32 newip,
-		   u_int16_t port,
-		   unsigned int matchoff,
-		   unsigned int matchlen,
-		   struct nf_conn *ct,
-		   enum ip_conntrack_info ctinfo)
-{
-	char buffer[sizeof("|1|255.255.255.255|65535|")];
-
-	sprintf(buffer, "|1|%u.%u.%u.%u|%u|", NIPQUAD(newip), port);
-
-	pr_debug("calling nf_nat_mangle_tcp_packet\n");
-
-	return nf_nat_mangle_tcp_packet(skb, ct, ctinfo, matchoff,
-					matchlen, buffer, strlen(buffer));
-}
-
-/* |1|132.235.1.2|6275| */
-static int
-mangle_epsv_packet(struct sk_buff *skb,
-		   __be32 newip,
-		   u_int16_t port,
-		   unsigned int matchoff,
-		   unsigned int matchlen,
-		   struct nf_conn *ct,
-		   enum ip_conntrack_info ctinfo)
-{
-	char buffer[sizeof("|||65535|")];
-
-	sprintf(buffer, "|||%u|", port);
-
-	pr_debug("calling nf_nat_mangle_tcp_packet\n");
+	switch (type) {
+	case NF_CT_FTP_PORT:
+	case NF_CT_FTP_PASV:
+		return snprintf(buffer, buflen, "%u,%u,%u,%u,%u,%u",
+				((unsigned char *)&addr)[0],
+				((unsigned char *)&addr)[1],
+				((unsigned char *)&addr)[2],
+				((unsigned char *)&addr)[3],
+				port >> 8,
+				port & 0xFF);
+	case NF_CT_FTP_EPRT:
+		return snprintf(buffer, buflen, "|1|%pI4|%u|", &addr, port);
+	case NF_CT_FTP_EPSV:
+		return snprintf(buffer, buflen, "|||%u|", port);
+	}
 
-	return nf_nat_mangle_tcp_packet(skb, ct, ctinfo, matchoff,
-					matchlen, buffer, strlen(buffer));
+	return 0;
 }
 
-static int (*mangle[])(struct sk_buff *, __be32, u_int16_t,
-		       unsigned int, unsigned int, struct nf_conn *,
-		       enum ip_conntrack_info)
-= {
-	[NF_CT_FTP_PORT] = mangle_rfc959_packet,
-	[NF_CT_FTP_PASV] = mangle_rfc959_packet,
-	[NF_CT_FTP_EPRT] = mangle_eprt_packet,
-	[NF_CT_FTP_EPSV] = mangle_epsv_packet
-};
-
 /* So, this packet has hit the connection tracking matching code.
    Mangle it, and change the expectation to match the new version. */
 static unsigned int nf_nat_ftp(struct sk_buff *skb,
@@ -110,6 +63,8 @@ static unsigned int nf_nat_ftp(struct sk_buff *skb,
 	u_int16_t port;
 	int dir = CTINFO2DIR(ctinfo);
 	struct nf_conn *ct = exp->master;
+	char buffer[sizeof("|1|255.255.255.255|65535|")];
+	unsigned int buflen;
 
 	pr_debug("FTP_NAT: type %i, off %u len %u\n", type, matchoff, matchlen);
 
@@ -132,11 +87,21 @@ static unsigned int nf_nat_ftp(struct sk_buff *skb,
 	if (port == 0)
 		return NF_DROP;
 
-	if (!mangle[type](skb, newip, port, matchoff, matchlen, ct, ctinfo)) {
-		nf_ct_unexpect_related(exp);
-		return NF_DROP;
-	}
+	buflen = nf_nat_ftp_fmt_cmd(type, buffer, sizeof(buffer), newip, port);
+	if (!buflen)
+		goto out;
+
+	pr_debug("calling nf_nat_mangle_tcp_packet\n");
+
+	if (!nf_nat_mangle_tcp_packet(skb, ct, ctinfo, matchoff,
+				      matchlen, buffer, buflen))
+		goto out;
+
 	return NF_ACCEPT;
+
+out:
+	nf_ct_unexpect_related(exp);
+	return NF_DROP;
 }
 
 static void __exit nf_nat_ftp_fini(void)
