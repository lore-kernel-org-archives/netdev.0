From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 7621] New: 2.6.19 breaks IPv6
Date: Sat, 02 Dec 2006 21:02:12 -0800 (PST)
Message-ID: <20061202.210212.104031085.davem@davemloft.net>
References: <200612021923.kB2JNsLw018910@fire-2.osdl.org>
	<20061202192009.05277ebf.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	jasmin-bugs@pacifica.ch, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1424952AbWLCFCJ@vger.kernel.org>
To: akpm@osdl.org
In-Reply-To: <20061202192009.05277ebf.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>
Date: Sat, 2 Dec 2006 19:20:09 -0800

> > On Sat, 2 Dec 2006 11:23:54 -0800 bugme-daemon@bugzilla.kernel.org wrote:
> > http://bugzilla.kernel.org/show_bug.cgi?id=7621
> > 
> >            Summary: 2.6.19 breaks IPv6
> >     Kernel Version: 2.6.19
> >             Status: NEW
> >           Severity: high
> >              Owner: yoshfuji@linux-ipv6.org
> >          Submitter: jasmin-bugs@pacifica.ch
> > 
> > 
> > Vanille 2.6.19 oops'es at boot. With the patch from 
> > http://marc.theaimsgroup.com/?l=linux-kernel&m=116485303623545&w=2 it boots 
> > but IPv6 stopps working. I can't ping/traceroute any host. Network setup has 
> > not changed.
> > 
> > ------- You are receiving this mail because: -------
> > You are on the CC list for the bug, or are watching someone who is.

As YOSHIFUJI Hideaki noticed, changing 'len' influences the
argument to ip6_nd_hdr(), which is not a side effect we wanted.

We only wanted the allocation length to be increased by
sizeof(struct ipv6hdr).

This is the correct version of the fix.

commit 6e38433357e2381bb278a418fb7e2fd201475101
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Sat Dec 2 21:00:06 2006 -0800

    [IPV6] NDISC: Calculate packet length correctly for allocation.
    
    MAX_HEADER does not include the ipv6 header length in it,
    so we need to add it in explicitly.
    
    With help from YOSHIFUJI Hideaki.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 73eb8c3..89d527e 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -472,7 +472,9 @@ static void ndisc_send_na(struct net_dev
 			inc_opt = 0;
 	}
 
-	skb = sock_alloc_send_skb(sk, MAX_HEADER + len + LL_RESERVED_SPACE(dev),
+	skb = sock_alloc_send_skb(sk,
+				  (MAX_HEADER + sizeof(struct ipv6hdr) +
+				   len + LL_RESERVED_SPACE(dev)),
 				  1, &err);
 
 	if (skb == NULL) {
@@ -561,7 +563,9 @@ void ndisc_send_ns(struct net_device *de
 	if (send_llinfo)
 		len += ndisc_opt_addr_space(dev);
 
-	skb = sock_alloc_send_skb(sk, MAX_HEADER + len + LL_RESERVED_SPACE(dev),
+	skb = sock_alloc_send_skb(sk,
+				  (MAX_HEADER + sizeof(struct ipv6hdr) +
+				   len + LL_RESERVED_SPACE(dev)),
 				  1, &err);
 	if (skb == NULL) {
 		ND_PRINTK0(KERN_ERR
@@ -636,7 +640,9 @@ void ndisc_send_rs(struct net_device *de
 	if (dev->addr_len)
 		len += ndisc_opt_addr_space(dev);
 
-        skb = sock_alloc_send_skb(sk, MAX_HEADER + len + LL_RESERVED_SPACE(dev),
+        skb = sock_alloc_send_skb(sk,
+				  (MAX_HEADER + sizeof(struct ipv6hdr) +
+				   len + LL_RESERVED_SPACE(dev)),
 				  1, &err);
 	if (skb == NULL) {
 		ND_PRINTK0(KERN_ERR
@@ -1446,7 +1452,9 @@ void ndisc_send_redirect(struct sk_buff 
 	rd_len &= ~0x7;
 	len += rd_len;
 
-	buff = sock_alloc_send_skb(sk, MAX_HEADER + len + LL_RESERVED_SPACE(dev),
+	buff = sock_alloc_send_skb(sk,
+				   (MAX_HEADER + sizeof(struct ipv6hdr) +
+				    len + LL_RESERVED_SPACE(dev)),
 				   1, &err);
 	if (buff == NULL) {
 		ND_PRINTK0(KERN_ERR
