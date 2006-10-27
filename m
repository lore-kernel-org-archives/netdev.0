From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 7421] New: Oops, EIP is at atalk_sendmsg
Date: Thu, 26 Oct 2006 17:26:20 -0700 (PDT)
Message-ID: <20061026.172620.02298797.davem@davemloft.net>
References: <200610261108.k9QB8a2Q009544@fire-2.osdl.org>
	<20061026094438.48c57c48.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	rose@sj.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:25831
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1946058AbWJ0A0n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Oct 2006 20:26:43 -0400
To: akpm@osdl.org
In-Reply-To: <20061026094438.48c57c48.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>
Date: Thu, 26 Oct 2006 09:44:38 -0700

> > Oct 26 10:01:07 localhost kernel: EIP is at atalk_sendmsg+0x15b/0x4e4 [appletalk]
> > Oct 26 10:01:07 localhost kernel: eax: 00000000   ebx: 0000002f   ecx: 00000000   \
> >                 edx: 00000000
> > Oct 26 10:01:07 localhost kernel: esi: cadcb600   edi: 00000000   ebp: cc9d7eec   \
> >                 esp: cc9d7d6c

Does this make the bug go away?

This code has been like this for a long time, I'm surprised
it never triggered before.  We properly set "dev = rt->dev"
right after the "if (!rt)" check, so the two settings removed
by this patch were not only OOPS-prone, they were also
superfluous.

diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 708e2e0..485e35c 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1584,7 +1584,6 @@ #endif
 
 	if (usat->sat_addr.s_net || usat->sat_addr.s_node == ATADDR_ANYNODE) {
 		rt = atrtr_find(&usat->sat_addr);
-		dev = rt->dev;
 	} else {
 		struct atalk_addr at_hint;
 
@@ -1592,7 +1591,6 @@ #endif
 		at_hint.s_net  = at->src_net;
 
 		rt = atrtr_find(&at_hint);
-		dev = rt->dev;
 	}
 	if (!rt)
 		return -ENETUNREACH;
