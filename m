From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [Qemu-devel] [PATCH] net: add raw backend  - some performance
	measurements
Date: Tue, 21 Jul 2009 15:01:42 +0300
Message-ID: <20090721120142.GA23439@redhat.com>
References: <4A534EC4.5030209@voltaire.com> <20090707145739.GB14392@shareable.org> <4A54B0F1.3070201@voltaire.com> <20090715203806.GF3056@shareable.org> <4A647B72.5090404@Voltaire.com> <20090720155308.GA9327@gondor.apana.org.au> <4A656824.7070100@Voltaire.com> <20090721072546.GA16131@gondor.apana.org.au> <20090721102733.GB22155@redhat.com> <4A65A0FC.6090204@Voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Jamie Lokier <jamie@shareable.org>,
	Anthony Liguori <anthony@codemonkey.ws>, qemu-devel@nongnu.org,
	Jan Kiszka <jan.kiszka@web.de>,
	Mark McLoughlin <markmc@redhat.com>,
	Dor Laor <dlaor@redhat.com>, netdev@vger.kernel.org
To: Or Gerlitz <ogerlitz@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:48127 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753459AbZGUMC6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jul 2009 08:02:58 -0400
Content-Disposition: inline
In-Reply-To: <4A65A0FC.6090204@Voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 21, 2009 at 02:05:32PM +0300, Or Gerlitz wrote:
> Michael S. Tsirkin wrote:
> > With raw sockets, send will block or fail if the TX queue for device is
> > full. With tap+bridge, the buffer in tap has to fill up instead, which
> > is not the same. I'm not sure this is the issue here, but could be: the
> > benchmark is UDP, isn't it?
> 
> Michael, 
> 
> What/where is this tap buffer?
> we're talking on VM TX, so looking on tun_get_user I see a call to 
> skb_copy_datagram_from_iovec() to copy from the user buffer to an skb, then a call to netif_rx_ni() and that's it... As for your question, indeed udp, the VM runs netperf/UDP_STREAM
> 
> Or.

Queue is not the right word, sorry.

I was referring to the fact that, when bridge floods a packet to
multiple interfaces, it clones the skb and frees the original, which
breaks the send buffer accounting in tun and might let you overrun the
tx queue in one of the devices.  This does not usually happen with raw
sockets.  This is the code in question:

                        if (prev != NULL) {
                                struct sk_buff *skb2;

                                if ((skb2 = skb_clone(skb, GFP_ATOMIC)) == NULL) {
                                        br->dev->stats.tx_dropped++;
                                        kfree_skb(skb);
                                        return;
                                }

                                __packet_hook(prev, skb2);
                        }

the thing to check then would be that some kind of misconfiguration
does not cause the bridge to flood your packets to multiple interfaces.

-- 
MST
