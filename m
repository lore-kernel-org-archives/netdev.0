From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Re: WARNING: at kernel/softirq.c:159
 _local_bh_enable_ip+0x35/0x71()
Date: Thu, 23 Feb 2012 12:53:48 +0100
Message-ID: <1329998028.15610.14.camel@edumazet-laptop>
References: <1422860.157191329872584374.JavaMail.weblogic@epml01>
	 <20120223104237.GA2127@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shreyas Bhatewara <sbhatewara@vmware.com>,
	Jongman Heo <jongman.heo@samsung.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Scott J. Goldman" <scottjg@vmware.com>,
	VMware PV-Drivers <pv-drivers@vmware.com>,
	Peter Zijlstra <peterz@infradead.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:62487 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751785Ab2BWLyC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 06:54:02 -0500
Received: by wgbgn7 with SMTP id gn7so5766385wgb.1
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2012 03:54:00 -0800 (PST)
In-Reply-To: <20120223104237.GA2127@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 23 f=C3=A9vrier 2012 =C3=A0 11:42 +0100, Francois Romieu a =C3=
=A9crit :
> (Heo, your mua broke threading)
>=20
> Jongman Heo <jongman.heo@samsung.com> :
> > Francois Romieu<romieu@fr.zoreil.com>
> > > > Jongman Heo <jongman.heo@samsung.com> :
> > > > Following warning triggered with my VMware Linux guest, when NF=
S connection is requested from outside.
> > >=20
> > > I'd try reverting 39d4a96fd7d2926e46151adbd18b810aeeea8ec0.
> [...]
> > I confirm that reverting the commit fixes the warning.
>=20
> Shreyas, can you provide a proper fix for this bug (see
> http://www.spinics.net/lists/netdev/msg189554.html for details).
>=20
> As far as I understand it you can not claim a fake transport layer he=
ader
> size for udp and blindly check the available buffer size through
> pskb_may_pull later. With a 32 bits HIGHMEM guest config (yuck...) it=
 ends
> up enabling bh within a network device start_xmit context.
>=20

Hmm, I am not sure we still need local_bh_disable()/local_bh_enable() i=
n
kmap_skb_frag()/ kunmap_skb_frag() anymore after commit 3e4d3af501ccc
(mm: stack based kmap_atomic() )

diff --git a/net/core/kmap_skb.h b/net/core/kmap_skb.h
index 81e1ed7..06be5ee 100644
--- a/net/core/kmap_skb.h
+++ b/net/core/kmap_skb.h
@@ -2,18 +2,10 @@
=20
 static inline void *kmap_skb_frag(const skb_frag_t *frag)
 {
-#ifdef CONFIG_HIGHMEM
-	BUG_ON(in_irq());
-
-	local_bh_disable();
-#endif
 	return kmap_atomic(skb_frag_page(frag), KM_SKB_DATA_SOFTIRQ);
 }
=20
 static inline void kunmap_skb_frag(void *vaddr)
 {
 	kunmap_atomic(vaddr, KM_SKB_DATA_SOFTIRQ);
-#ifdef CONFIG_HIGHMEM
-	local_bh_enable();
-#endif
 }
