From: Jiri Olsa <jolsa@redhat.com>
Subject: Re: no reassembly for outgoing packets on RAW socket
Date: Mon, 7 Jun 2010 16:55:58 +0200
Message-ID: <20100607145558.GA1939@jolsa.lab.eng.brq.redhat.com>
References: <20100604112708.GA1958@jolsa.lab.eng.brq.redhat.com>
 <4C08EB85.3050900@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:65116 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751858Ab0FGO4D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jun 2010 10:56:03 -0400
Content-Disposition: inline
In-Reply-To: <4C08EB85.3050900@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 04, 2010 at 02:03:17PM +0200, Patrick McHardy wrote:
> Jiri Olsa wrote:
> > hi,
> > 
> > I'd like to be able to sendout a single IP packet with MF flag set.
> > 
> > When using RAW sockets the packet will get stuck in the
> > netfilter (NF_INET_LOCAL_OUT nf_defrag_ipv4 reassembly unit)
> > and wont ever make it out..
> > 
> > I made a change which bypass the outgoing reassembly for
> > RAW sockets, but I'm not sure wether it's too invasive..
> 
> That would break reassembly (and thus connection tracking) for cases
> where its really intended.
> 
> > Is there any standard for RAW sockets behaviour?
> > Or another way around? :)
> 
> You could use the NOTRACK target to bypass connection tracking.

ok,

I tried the NOTRACK target, but the packet is still going
throught reassembly, because the RAW filter has lower priority
then the connection track defragmentation..

I was able to get it bypassed by attached patch and following
command:

	iptables -v -t raw -A OUTPUT -p icmp -j NOTRACK

again, not sure if this is too invasive ;)

If this is not the way, I'd appreciatte any hint..  my goal is
to put malformed packet on the wire (more frags bit set for a
non fragmented packet)


thanks for help,
jirka

---
diff --git a/include/linux/netfilter_ipv4.h b/include/linux/netfilter_ipv4.h
index 29c7727..d249b6a 100644
--- a/include/linux/netfilter_ipv4.h
+++ b/include/linux/netfilter_ipv4.h
@@ -53,8 +53,8 @@
 
 enum nf_ip_hook_priorities {
 	NF_IP_PRI_FIRST = INT_MIN,
-	NF_IP_PRI_CONNTRACK_DEFRAG = -400,
-	NF_IP_PRI_RAW = -300,
+	NF_IP_PRI_RAW = -400,
+	NF_IP_PRI_CONNTRACK_DEFRAG = -300,
 	NF_IP_PRI_SELINUX_FIRST = -225,
 	NF_IP_PRI_CONNTRACK = -200,
 	NF_IP_PRI_MANGLE = -150,
diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index cb763ae..cb865d1 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -74,6 +74,9 @@ static unsigned int ipv4_conntrack_defrag(unsigned int hooknum,
 		return NF_ACCEPT;
 #endif
 #endif
+	if (nf_ct_is_untracked(skb))
+		return NF_ACCEPT;
+
 	/* Gather fragments. */
 	if (ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)) {
 		enum ip_defrag_users user = nf_ct_defrag_user(hooknum, skb);
