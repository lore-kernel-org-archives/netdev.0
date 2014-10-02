From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCHv9 net-next 2/4] sunvnet: make transmit path zero-copy in
 the kernel
Date: Thu, 2 Oct 2014 09:06:44 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D174A2CD2@AcuExch.aculab.com>
References: <5429EFBB.2090909@oracle.com>
 <77E6695E-58F8-4D10-8ED7-EEC4A487339E@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: 'Raghuram Kothakota' <Raghuram.Kothakota@oracle.com>,
	David L Stevens <david.stevens@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:42625 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751282AbaJBJIl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 05:08:41 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 20508-04 for <netdev@vger.kernel.org>;
 Thu,  2 Oct 2014 10:08:30 +0100 (BST)
In-Reply-To: <77E6695E-58F8-4D10-8ED7-EEC4A487339E@oracle.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raghuram Kothakota
> Sorry I am late in providing my comments, but I feel it is important
> to share this comment.

A comment on the original patch...

...
> > @@ -811,14 +930,27 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
> >
> > 	d = vio_dring_cur(dr);
> >
> > -	tx_buf = port->tx_bufs[dr->prod].buf;
> > -	skb_copy_from_linear_data(skb, tx_buf + VNET_PACKET_SKIP, skb->len);
> > +	txi = dr->prod;
> > +
> > +	freeskbs = vnet_clean_tx_ring(port, &pending);
> > +
> > +	BUG_ON(port->tx_bufs[txi].skb);
> >
> > 	len = skb->len;
> > -	if (len < ETH_ZLEN) {
> > +	if (len < ETH_ZLEN)
> > 		len = ETH_ZLEN;
> > -		memset(tx_buf+VNET_PACKET_SKIP+skb->len, 0, len - skb->len);
> > +

Aren't you transmitting 'random' bytes from the end of the data?
Plausibly they might not even be mapped.

Also, for short frames the copy could well be faster - especially on systems
with non-trivial iommu.
It is also worth checking whether the original copy was aligned.

	David
