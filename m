From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/3] macvlan: Reflect macvlan packets meant for other macvlan devices
Date: Wed, 18 Nov 2009 10:47:07 +0100
Message-ID: <200911181047.07974.arnd@arndb.de>
References: <1258497551-25959-1-git-send-email-arnd@arndb.de> <1258497551-25959-2-git-send-email-arnd@arndb.de> <4B03949D.4000908@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick McHardy <kaber@trash.net>,
	Patrick Mullaney <pmullaney@novell.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Edge Virtual Bridging <evb@yahoogroups.com>,
	Anna Fischer <anna.fischer@hp.com>,
	bridge@lists.linux-foundation.org,
	virtualization@linux-foundation.com,
	Jens Osterkamp <jens@linux.vnet.ibm.com>,
	Gerhard Stenzel <gerhard.stenzel@de.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756584AbZKRJst@vger.kernel.org>
In-Reply-To: <4B03949D.4000908@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 18 November 2009, Eric Dumazet wrote:
> > -     skb->dev = dev;
> > -     skb->pkt_type = PACKET_HOST;
> > +     skb->protocol = eth_type_trans(skb, dev);
> > +     eth = eth_hdr(skb);
> >  
> > -     netif_rx(skb);
> > -     return NULL;
> > +     skb_dst_drop(skb);
> 
> Why do you drop dst here ?
> 
> It seems strange, since this driver specifically masks out IFF_XMIT_DST_RELEASE
> in its macvlan_setup() :
> 
> dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;
> 
> If we really want to drop dst, it could be done by caller, if IFF_XMIT_DST_RELEASE
> was not masked in macvlan_setup().
> 

That must be my fault, it is the only change I did to Eric B's patch when
forward-porting to 2.6.32. The original patch did

	skb->protocol = eth_type_trans(skb, dev);
	eth = eth_hdr(skb);
	dst_release(skb->dst);
	skb->dst = NULL;
	skb->mark = 0;

and I tried to convert that in the same way that other drivers did, but I
have to admit that I did not understand the mechanics of IFF_XMIT_DST_RELEASE.

	Arnd <><
