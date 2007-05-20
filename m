From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] libertas: skb dereferenced after netif_rx
Date: Sat, 19 May 2007 20:56:41 -0400
Message-ID: <1179622601.9453.4.camel@xo-28-0B-88.localdomain>
References: <464B7127.5080502@gmail.com>
	 <20070518180903.GC3492@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Florin Malita <fmalita@gmail.com>, marcelo@kvack.org,
	linville@redhat.com, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:40031 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756099AbXETAyO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 May 2007 20:54:14 -0400
In-Reply-To: <20070518180903.GC3492@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-05-18 at 14:09 -0400, John W. Linville wrote:
> On Wed, May 16, 2007 at 05:01:27PM -0400, Florin Malita wrote:
> > In libertas_process_rxed_packet() and process_rxed_802_11_packet() the 
> > skb is dereferenced after being passed to netif_rx (called from 
> > libertas_upload_rx_packet). Spotted by Coverity (1658, 1659).
>  
> Relocating the libertas_upload_rx_packet call is fine, but...
> 
> > Also, libertas_upload_rx_packet() unconditionally returns 0 so the error 
> > check is dead code - might as well take it out.
> 
> Is this merely an implementation detail?  Or an absolute fact?
> If the former is true, then we should preserve the error
> checking.  If the latter, then we should change the signature of
> libertas_upload_rx_packet to return void.

According to the comments, netif_rx always succeeds.  I think we should
just change the return type to void since there's nothing else in that
function that can fail.

Dan


> > Signed-off-by: Florin Malita <fmalita@gmail.com>
> 
> > 	lbs_pr_debug(1, "RX Data: size of actual packet = %d\n", skb->len);
> > -	if (libertas_upload_rx_packet(priv, skb)) {
> > -		lbs_pr_debug(1, "RX error: libertas_upload_rx_packet"
> > -		       " returns failure\n");
> > -		ret = -1;
> > -		goto done;
> > -	}
> > 	priv->stats.rx_bytes += skb->len;
> > 	priv->stats.rx_packets++;
> > 
> > +	libertas_upload_rx_packet(priv, skb);
> > +
> > 	ret = 0;
> > done:
> > 	LEAVE();
> 
> Another potential patch is to remove the "ret = 0" line before the
> "done" label, since ret is initialized at the head of the function.
> Come to think of it, you can probably remove the "= 0" part of ret's
> declaration as well (in both functions).
> 
> Hth!
> 
> John
> 
> P.S.  Also, please make sure to send wireless patches to
> linux-wireless@vger.kernel.org and CC me.

