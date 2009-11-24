From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/4] veth: move loopback logic to common location
Date: Tue, 24 Nov 2009 10:02:20 +0000
Message-ID: <200911241002.20904.arnd@arndb.de>
References: <1259024166-28158-1-git-send-email-arnd@arndb.de> <1259024166-28158-2-git-send-email-arnd@arndb.de> <4B0BAC97.6010000@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick Mullaney <pmullaney@novell.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Edge Virtual Bridging <evb@yahoogroups.com>,
	Anna Fischer <anna.fischer@hp.com>,
	bridge@lists.linux-foundation.org,
	virtualization@lists.linux-foundation.org,
	Jens Osterkamp <jens@linux.vnet.ibm.com>,
	Gerhard Stenzel <gerhard.stenzel@de.ibm.com>,
	Mark Smith <lk-netdev@lk-netdev.nosense.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932556AbZKXKDu@vger.kernel.org>
In-Reply-To: <4B0BAC97.6010000@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 24 November 2009 09:51:19 Patrick McHardy wrote:
> > +     skb_dst_drop(skb);
> > +     skb->tstamp.tv64 = 0;
> > +     skb->pkt_type = PACKET_HOST;
> > +     skb->protocol = eth_type_trans(skb, dev);
> > +     skb->mark = 0;
> 
> skb->mark clearing should stay private to veth since its usually
> supposed to stay intact. The only exception is packets crossing
> namespaces, where they should appear like a freshly received skbs.

But isn't that what we want in macvlan as well when we're
forwarding from one downstream interface to another?

I did all my testing with macvlan interfaces in separate namespaces
communicating with each other, so I'd assume that we should always
clear skb->mark and skb->dst in this function. Maybe I should make
the documentation clearer?

---
net: clarify documentation of dev_forward_skb

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1433,6 +1433,10 @@ static inline void net_timestamp(struct sk_buff *skb)
  * dev_forward_skb can be used for injecting an skb from the
  * start_xmit function of one device into the receive queue
  * of another device.
+ *
+ * The receiving device may be in another namespace, so
+ * we have to clear all information in the skb that could
+ * impact namespace isolation.
  */
 int dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
 {
