From: Jiri Olsa <jolsa@redhat.com>
Subject: Re: no reassembly for outgoing packets on RAW socket
Date: Thu, 10 Jun 2010 11:53:12 +0200
Message-ID: <20100610095312.GC1915@jolsa.lab.eng.brq.redhat.com>
References: <20100604112708.GA1958@jolsa.lab.eng.brq.redhat.com>
 <4C08EB85.3050900@trash.net>
 <20100607145558.GA1939@jolsa.lab.eng.brq.redhat.com>
 <4C0FA24A.7060907@trash.net>
 <20100610065631.GA1915@jolsa.lab.eng.brq.redhat.com>
 <4C10ACDC.6010108@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4C10ACDC.6010108@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 10, 2010 at 11:14:04AM +0200, Patrick McHardy wrote:
> Jiri Olsa wrote:
> > On Wed, Jun 09, 2010 at 04:16:42PM +0200, Patrick McHardy wrote:
> >   
> >>> If this is not the way, I'd appreciatte any hint..  my goal is
> >>> to put malformed packet on the wire (more frags bit set for a
> >>> non fragmented packet)
> >>>       
> >> I don't have any good suggestions besides adding a flag to the IPCB
> >> and skipping defragmentation based on that.
> >>     
> > ok,
> >
> > I can see a way when I set this via setsockopt to the socket,
> > and check the value before the defragmentation..  would such a new
> > setsock option be acceptable?
> >
> > I'm not sure I can see a way via IPCB, AFAICS it's for skb bound flags
> > which arise during the skb processing.
> >   
> 
> Yes, a socket option is basically what I was suggesting, using the
> IPCB to mark the packet. But just marking the socket is fine of
> course.
> 
> 

one last thought before the socket option.. :)

there's IP_HDRINCL option which is enabled for RAW sockets
(can be disabled later by setsockopt)

The 'man 7 ip' says:
	"the user supplies an IP header in front of the user data"

but does not mention the outgoing defragmentation.

It kind of looks to me more appropriate to preserve the user suplied
IP header.. moreover if there's a way to switch this off and have
netfilter defragmentation + connection tracking for RAW socket.

please check the following patch..
(there's no special need for the IPSKB_NODEFRAG, it could check the
socket->hdrincl flag directly..)

thoughts?

thanks,
jirka

---
diff --git a/include/net/ip.h b/include/net/ip.h
index 452f229..201a17e 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -42,6 +42,7 @@ struct inet_skb_parm {
 #define IPSKB_XFRM_TRANSFORMED	4
 #define IPSKB_FRAG_COMPLETE	8
 #define IPSKB_REROUTED		16
+#define IPSKB_NODEFRAG		32
 };
 
 static inline unsigned int ip_hdrlen(const struct sk_buff *skb)
diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index cb763ae..0355bea 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -74,6 +74,9 @@ static unsigned int ipv4_conntrack_defrag(unsigned int hooknum,
 		return NF_ACCEPT;
 #endif
 #endif
+	if (IPCB(skb)->flags & IPSKB_NODEFRAG)
+		return NF_ACCEPT;
+
 	/* Gather fragments. */
 	if (ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)) {
 		enum ip_defrag_users user = nf_ct_defrag_user(hooknum, skb);
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 2c7a163..978e813 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -354,6 +354,13 @@ static int raw_send_hdrinc(struct sock *sk, void *from, size_t length,
 	if (memcpy_fromiovecend((void *)iph, from, 0, length))
 		goto error_free;
 
+	/*
+	 * The header is created by user, preserve the fragments
+	 * settings throught the defragmentation unit.
+	 */
+	if (iph->frag_off & htons(IP_MF|IP_OFFSET))
+		IPCB(skb)->flags |= IPSKB_NODEFRAG;
+
 	iphlen = iph->ihl * 4;
 
 	/*
