From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [Xen-devel] compound skb frag pages appearing in start_xmit
Date: Wed, 10 Oct 2012 13:29:09 +0100
Message-ID: <1349872149.10070.31.camel@zakaz.uk.xensource.com>
References: <1349790467.21847.185.camel@zakaz.uk.xensource.com>
	 <1349790863.21172.4406.camel@edumazet-glaptop>
	 <1349792241.21847.199.camel@zakaz.uk.xensource.com>
	 <1349792847.21172.4479.camel@edumazet-glaptop>
	 <1349793630.21847.208.camel@zakaz.uk.xensource.com>
	 <1349863984.10070.26.camel@zakaz.uk.xensource.com>
	 <1622789731.20121010142428@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	"Konrad Rzeszutek Wilk" <konrad@kernel.org>,
	xen-devel <xen-devel@lists.xen.org>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:14847 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754940Ab2JJM3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2012 08:29:42 -0400
In-Reply-To: <1622789731.20121010142428@eikelenboom.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-10-10 at 13:24 +0100, Sander Eikelenboom wrote:
> Wednesday, October 10, 2012, 12:13:04 PM, you wrote:
> 
> > On Tue, 2012-10-09 at 15:40 +0100, Ian Campbell wrote:
> >> On Tue, 2012-10-09 at 15:27 +0100, Eric Dumazet wrote:
> >> > On Tue, 2012-10-09 at 15:17 +0100, Ian Campbell wrote:
> >> > 
> >> > > Does the higher order pages effectively reduce the number of frags which
> >> > > are in use? e.g if MAX_SKB_FRAGS is 16, then for order-0 pages you could
> >> > > have 64K worth of frag data.
> >> > > 
> >> > > If we switch to order-3 pages everywhere then can the skb contain 512K
> >> > > of data, or does the effective maximum number of frags in an skb reduce
> >> > > to 2?
> >> > 
> >> > effective number of frags reduce to 2 or 3
> >> > 
> >> > (We still limit GSO packets to ~63536 bytes)
> >> 
> >> Great! Then I think the fix is more/less trivial...
> 
> > The following seems to work for me.
> 
> But it doesn't seem to work for me ... dmesg attached.

> [  191.777994] ------------[ cut here ]------------
> [  191.784245] kernel BUG at drivers/net/xen-netback/netback.c:481!

Looks like that BUG_ON is a little aggressive. It'll trigger if the data
happens to end on a frame boundary. Hopefully this will fix it for you:

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index d747e30..f2d6b78 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -477,7 +477,7 @@ static void netbk_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
 		size -= bytes;
 
 		/* Next frame */
-		if (offset == PAGE_SIZE) {
+		if (offset == PAGE_SIZE && size) {
 			BUG_ON(!PageCompound(page));
 			page++;
 			offset = 0;
