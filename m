From: David Miller <davem@davemloft.net>
Subject: Re: Another 2.6.25rc7 lockdep trace
Date: Fri, 28 Mar 2008 17:30:58 -0700 (PDT)
Message-ID: <20080328.173058.55643081.davem@davemloft.net>
References: <20080328015416.GB4695@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@codemonkey.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53700
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753999AbYC2Aa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 20:30:58 -0400
In-Reply-To: <20080328015416.GB4695@codemonkey.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@codemonkey.org.uk>
Date: Thu, 27 Mar 2008 21:54:16 -0400

>  stack backtrace:
>  Pid: 7285, comm: modprobe Not tainted 2.6.25-0.161.rc7.fc9.i686 #1
>   [print_usage_bug+266/279] print_usage_bug+0x10a/0x117
>   [mark_lock+822/1009] mark_lock+0x336/0x3f1
>   [__lock_acquire+1349/3089] __lock_acquire+0x545/0xc11
>   [_spin_unlock_irq+34/47] ? _spin_unlock_irq+0x22/0x2f
>   [lock_acquire+106/144] lock_acquire+0x6a/0x90
>   [inet_frag_evictor+60/175] ? inet_frag_evictor+0x3c/0xaf
>   [_read_lock+28/73] _read_lock+0x1c/0x49
>   [inet_frag_evictor+60/175] ? inet_frag_evictor+0x3c/0xaf
>   [inet_frag_evictor+60/175] inet_frag_evictor+0x3c/0xaf
>   [<d0e299f2>] nf_ct_frag6_cleanup+0x26/0x28 [nf_conntrack_ipv6]
>   [<d0e2a3f4>] nf_conntrack_l3proto_ipv6_fini+0x44/0x46 [nf_conntrack_ipv6]

Thanks for the report.

This should fix it:

commit e8e16b706e8406f1ab3bccab16932ebc513896d8
Author: David S. Miller <davem@davemloft.net>
Date:   Fri Mar 28 17:30:18 2008 -0700

    [INET]: inet_frag_evictor() must run with BH disabled
    
    Based upon a lockdep trace from Dave Jones.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 724d69a..a0a3c78 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -86,7 +86,10 @@ EXPORT_SYMBOL(inet_frags_fini);
 void inet_frags_exit_net(struct netns_frags *nf, struct inet_frags *f)
 {
 	nf->low_thresh = 0;
+
+	local_bh_disable();
 	inet_frag_evictor(nf, f);
+	local_bh_enable();
 }
 EXPORT_SYMBOL(inet_frags_exit_net);
 
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 2a0d698..24c0d03 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -171,7 +171,9 @@ static __inline__ void fq_kill(struct nf_ct_frag6_queue *fq)
 
 static void nf_ct_frag6_evictor(void)
 {
+	local_bh_disable();
 	inet_frag_evictor(&nf_init_frags, &nf_frags);
+	local_bh_enable();
 }
 
 static void nf_ct_frag6_expire(unsigned long data)
