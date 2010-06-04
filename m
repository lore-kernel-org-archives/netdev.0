From: Jiri Olsa <jolsa@redhat.com>
Subject: no reassembly for outgoing packets on RAW socket
Date: Fri, 4 Jun 2010 13:27:08 +0200
Message-ID: <20100604112708.GA1958@jolsa.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28961 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751344Ab0FDL1L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jun 2010 07:27:11 -0400
Received: from int-mx05.intmail.prod.int.phx2.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.18])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o54BRAY4009930
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 4 Jun 2010 07:27:10 -0400
Received: from jolsa.lab.eng.brq.redhat.com (dhcp-31-162.brq.redhat.com [10.34.31.162])
	by int-mx05.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with SMTP id o54BR9FI006624
	for <netdev@vger.kernel.org>; Fri, 4 Jun 2010 07:27:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi,

I'd like to be able to sendout a single IP packet with MF flag set.

When using RAW sockets the packet will get stuck in the
netfilter (NF_INET_LOCAL_OUT nf_defrag_ipv4 reassembly unit)
and wont ever make it out..

I made a change which bypass the outgoing reassembly for
RAW sockets, but I'm not sure wether it's too invasive..

Is there any standard for RAW sockets behaviour?
Or another way around? :)

thanks,
jirka


---
diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index cb763ae..5ef8ab2 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -74,6 +74,10 @@ static unsigned int ipv4_conntrack_defrag(unsigned int hooknum,
 		return NF_ACCEPT;
 #endif
 #endif
+	/* Do not reassemble for raw sockets. */
+	if (skb->sk && skb->sk->sk_type == SOCK_RAW)
+		return NF_ACCEPT;
+
 	/* Gather fragments. */
 	if (ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)) {
 		enum ip_defrag_users user = nf_ct_defrag_user(hooknum, skb);
diff --git a/net/ipv4/netfilter/nf_nat_standalone.c b/net/ipv4/netfilter/nf_nat_standalone.c
index beb2581..a9aa19c 100644
--- a/net/ipv4/netfilter/nf_nat_standalone.c
+++ b/net/ipv4/netfilter/nf_nat_standalone.c
@@ -86,8 +86,14 @@ nf_nat_fn(unsigned int hooknum,
 	enum nf_nat_manip_type maniptype = HOOK2MANIP(hooknum);
 
 	/* We never see fragments: conntrack defrags on pre-routing
-	   and local-out, and nf_nat_out protects post-routing. */
-	NF_CT_ASSERT(!(ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)));
+	   and local-out, and nf_nat_out protects post-routing.
+	   With the exception of RAW sockets. */
+#ifdef CONFIG_NETFILTER_DEBUG
+	int raw  = (skb->sk && skb->sk->sk_type == SOCK_RAW);
+	int frag = (ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET));
+
+	NF_CT_ASSERT(!frag || (frag && raw));
+#endif
 
 	ct = nf_ct_get(skb, &ctinfo);
 	/* Can't track?  It's not due to stress, or conntrack would
