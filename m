From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [Xen-devel] compound skb frag pages appearing in start_xmit
Date: Wed, 10 Oct 2012 14:09:58 +0100
Message-ID: <1349874598.10070.39.camel@zakaz.uk.xensource.com>
References: <1349790467.21847.185.camel@zakaz.uk.xensource.com>
	 <1349790863.21172.4406.camel@edumazet-glaptop>
	 <1349792241.21847.199.camel@zakaz.uk.xensource.com>
	 <1349792847.21172.4479.camel@edumazet-glaptop>
	 <1349793630.21847.208.camel@zakaz.uk.xensource.com>
	 <1349863984.10070.26.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	xen-devel <xen-devel@lists.xen.org>,
	"Konrad Rzeszutek Wilk" <konrad@kernel.org>,
	Sander Eikelenboom <linux@eikelenboom.it>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:16114 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755832Ab2JJNKD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2012 09:10:03 -0400
In-Reply-To: <1349863984.10070.26.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-10-10 at 11:13 +0100, Ian Campbell wrote:
> I haven't tackled netfront yet. 

I seem to be totally unable to reproduce the equivalent issue on the
netfront xmit side, even though it seems like the loop in
xennet_make_frags ought to be obviously susceptible to it.

Konrad, Sander, are either of you able to repro, e.g. with:

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index b06ef81..8a3f770 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -462,6 +462,8 @@ static void xennet_make_frags(struct sk_buff *skb, struct net_device *dev,
 		ref = gnttab_claim_grant_reference(&np->gref_tx_head);
 		BUG_ON((signed short)ref < 0);
 
+		BUG_ON(PageCompound(skb_frag_page(frag)));
+
 		mfn = pfn_to_mfn(page_to_pfn(skb_frag_page(frag)));
 		gnttab_grant_foreign_access_ref(ref, np->xbdev->otherend_id,
 						mfn, GNTMAP_readonly);

My repro for netback was just to netcat a wodge of data from dom0->domU
but going the other way doesn't seem to trigger.
