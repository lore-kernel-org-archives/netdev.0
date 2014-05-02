From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Xen-devel] [3.15-rc3] Bisected: xen-netback mangles packets
 between two guests on a bridge since merge of "TX grant mapping with
 SKBTX_DEV_ZEROCOPY instead of copy" series.
Date: Fri, 02 May 2014 08:21:13 -0700
Message-ID: <1399044073.29914.237.camel@edumazet-glaptop2.roam.corp.google.com>
References: <395225650.20140430124506@eikelenboom.it>
	 <536162D3.5080307@citrix.com> <94755525.20140501002553@eikelenboom.it>
	 <53624E25.8040404@citrix.com> <1810270947.20140501155911@eikelenboom.it>
	 <53626C39.3030304@citrix.com> <928229683.20140501193936@eikelenboom.it>
	 <198418193.20140501213951@eikelenboom.it> <5363A508.1000602@citrix.com>
	 <653156457.20140502160632@eikelenboom.it> <5363AFED.5080601@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sander Eikelenboom <linux@eikelenboom.it>, netdev@vger.kernel.org,
	xen-devel@lists.xen.org, Ian Campbell <Ian.Campbell@citrix.com>,
	"David S. Miller" <davem@davemloft.net>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:52670 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752457AbaEBPVV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2014 11:21:21 -0400
Received: by mail-pd0-f172.google.com with SMTP id g10so4807384pdj.31
        for <netdev@vger.kernel.org>; Fri, 02 May 2014 08:21:20 -0700 (PDT)
In-Reply-To: <5363AFED.5080601@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-05-02 at 15:47 +0100, Zoltan Kiss wrote:

> Sorry, I was misleading and wrong. Can you try out this scenario with 
> the attached patch?

Guys, I already told you skb->truesize 'mismatch' could not explain
packet corruptions. This comes from an expert in this matter, you can
trust me.

What could happens here is that TCP stack merges skbs (TCP coalescing)

Problem is that SKBTX_DEV_ZEROCOPY addition did not take care of this.

We have to forbid these merges from happening, because one skb has a
single destructor_arg.

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 1b62343f5837..85995a14aafc 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3838,7 +3839,10 @@ bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
 		return true;
 	}
 
-	if (skb_has_frag_list(to) || skb_has_frag_list(from))
+	if (skb_has_frag_list(to) ||
+	    skb_has_frag_list(from) ||
+	    (skb_shinfo(to)->tx_flags & SKBTX_DEV_ZEROCOPY) ||
+	    (skb_shinfo(from)->tx_flags & SKBTX_DEV_ZEROCOPY))
 		return false;
 
 	if (skb_headlen(from) != 0) {
