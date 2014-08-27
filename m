From: Julian Anastasov <ja-FgGsKACvmQM@public.gmane.org>
Subject: Re: [RFC] net: ipv4: drop unicast encapsulated in L2 multicast
Date: Wed, 27 Aug 2014 13:23:17 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1408271255230.2348@ja.home.ssi.bg>
References: <1408641747-22199-1-git-send-email-johannes@sipsolutions.net>  <alpine.LFD.2.11.1408212119510.1896@ja.home.ssi.bg>  <20140822.105405.1982870131653082781.davem@davemloft.net> <1409130792.2505.5.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1409130792.2505.5.camel-8Nb76shvtaUJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


	Hello,

On Wed, 27 Aug 2014, Johannes Berg wrote:

> On Fri, 2014-08-22 at 10:54 -0700, David Miller wrote:
> 
> > > 	Is this place better, after checking for RTN_BROADCAST?
> > > 
> > > 	/* ARP link-layer broadcasts are acceptable here */
> > > 	if ((skb->pkt_type == PACKET_BROADCAST ||
> > > 	     skb->pkt_type == PACKET_MULTICAST) &&
> > > 	    skb->protocol == htons(ETH_P_IP))
> > > 		goto e_inval;
> > 
> > Indeed, this would make ARP happier, but that still leaves open the
> > issue of CLUSTERIP.
> 
> Unfortunately, I have no idea how to determine that CLUSTERIP is active
> here? Do we need to tag frames, or would a sysctl work?
> 
> Or should we go back to the drawing board and not make this change in
> the IP stack at all? But parsing all the IP layer in the wireless stack
> is really quite ugly as well.

	CLUSTERIP works in LOCAL_IN. My preference is to
add checks in every protocol where it is missing but if
you prefer a global check, ip_local_deliver_finish() is
a good place: CLUSTERIP already changed pkt_type to
PACKET_HOST. For example:

	if (!(skb_rtable(skb)->rt_flags &
	      (RTCF_BROADCAST | RTCF_MULTICAST)) &&
	    (skb->pkt_type == PACKET_BROADCAST ||
	     skb->pkt_type == PACKET_MULTICAST)) {
		kfree_skb(skb);
		return;
	}

	By this way we protect the local stack globally.
BTW, what kind of packets (protocol) we want to drop? UDP?

	As for ip_forward(), there is already check for
PACKET_HOST.

	Not sure, may be a MIB counter for such drops
would be useful.

Regards

--
Julian Anastasov <ja-FgGsKACvmQM@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
