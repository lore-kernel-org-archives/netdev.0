From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: vxlan/veth performance issues on net.git + latest kernels
Date: Sun, 08 Dec 2013 13:36:41 -0800
Message-ID: <1386538601.30495.305.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.LFD.2.03.1312031500020.570@intel.com>
	 <CAJZOPZLT_3msfz_XY45GOBMWK_y8WEYBTq3rGRUijpYyXE1ddg@mail.gmail.com>
	 <alpine.LFD.2.03.1312031626400.7539@intel.com>
	 <CAJZOPZJKsrj2+SQJsgq-w7BrNwDR0OsYWiF+1CcRQ3-KhejZhQ@mail.gmail.com>
	 <alpine.LFD.2.03.1312040113290.14367@intel.com>
	 <CAJZOPZJVBpqm-OduV4K2YwbXESP7awhsk0HbjuHazAiQJZTLWQ@mail.gmail.com>
	 <52A197DF.5010806@mellanox.com>
	 <CAJZOPZJ20j9KaaMkyQmhYDkimzAM5tvxJLDzmpiAcvG0Bcky6w@mail.gmail.com>
	 <20131208124352.GA7935@zed.ravello.local> <52A46F2A.40101@mellanox.com>
	 <20131208143054.GA6984@zed.ravello.local>
	 <1386535824.30495.301.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jerry Chu <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	John Fastabend <john.fastabend@gmail.com>
To: Mike Rapoport <mike.rapoport@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:60995 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755384Ab3LHVgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 16:36:46 -0500
Received: by mail-pb0-f54.google.com with SMTP id un15so4122672pbc.41
        for <netdev@vger.kernel.org>; Sun, 08 Dec 2013 13:36:45 -0800 (PST)
In-Reply-To: <1386535824.30495.301.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-12-08 at 12:50 -0800, Eric Dumazet wrote:
> On Sun, 2013-12-08 at 16:30 +0200, Mike Rapoport wrote:
> >  
> > It was something *very* hacky:
> 
> > 		if (skb->len < 64000)
> > 			skb_shinfo(skb)->gso_size = skb->len;
> > 		else
> > 			skb_shinfo(skb)->gso_size = 64000;
> 
> This sounds like an 16bit overflow somewhere.
> 
> This reminds the issue we fix in commit 50bceae9bd356
> ("tcp: Reallocate headroom if it would overflow csum_start")
> 
> You might try to reduce the 0xFFFF to something smaller.

Also try following debugging patch :

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 2718fed53d8c..d6fcb6272d37 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -913,8 +913,12 @@ EXPORT_SYMBOL(skb_clone);
 static void skb_headers_offset_update(struct sk_buff *skb, int off)
 {
 	/* Only adjust this if it actually is csum_start rather than csum */
-	if (skb->ip_summed == CHECKSUM_PARTIAL)
-		skb->csum_start += off;
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		u32 val = (u32)skb->csum_start + off;
+
+		WARN_ON_ONCE(val > 0xFFFF);
+		skb->csum_start = val;
+	}
 	/* {transport,network,mac}_header and tail are relative to skb->head
*/
 	skb->transport_header += off;
 	skb->network_header   += off;
