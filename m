From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH RFC 8/9] vti: Update the ipv4 side to use it's own
 receive hook.
Date: Fri, 13 Dec 2013 10:56:48 +0100
Message-ID: <20131213095648.GN31491@secunet.com>
References: <20131205120028.GW31491@secunet.com>
 <20131205120504.GE31491@secunet.com>
 <52A9E3CF.7040204@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Christophe Gouault <christophe.gouault@6wind.com>,
	Saurabh Mohan <saurabh.mohan@vyatta.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:46677 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752288Ab3LMJ4y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Dec 2013 04:56:54 -0500
Content-Disposition: inline
In-Reply-To: <52A9E3CF.7040204@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 12, 2013 at 05:26:55PM +0100, Nicolas Dichtel wrote:
> Le 05/12/2013 13:05, Steffen Klassert a =E9crit :
> >
> >-/* We dont digest the packet therefore let the packet pass */
> >  static int vti_rcv(struct sk_buff *skb)
> >  {
> >  	struct ip_tunnel *tunnel;
> >@@ -60,48 +61,72 @@ static int vti_rcv(struct sk_buff *skb)
> >  	tunnel =3D ip_tunnel_lookup(itn, skb->dev->ifindex, TUNNEL_NO_KEY=
,
> >  				  iph->saddr, iph->daddr, 0);
> >  	if (tunnel !=3D NULL) {
> >-		struct pcpu_tstats *tstats;
> >-		u32 oldmark =3D skb->mark;
> >-		int ret;
> >+		if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
> >+			goto drop;
> >+
> >+		XFRM_TUNNEL_SKB_CB(skb)->tunnel =3D tunnel;
> >+
> >+		/* Partially clear the buffer, the rest is done by xfrm_input. */
> >+		if (!net_eq(tunnel->net, dev_net(tunnel->dev)))
> >+			skb_orphan(skb);
> >+		skb->tstamp.tv64 =3D 0;
> >+		skb->pkt_type =3D PACKET_HOST;
> >+		skb->skb_iif =3D 0;
> >+		nf_reset_trace(skb);
> >+		secpath_reset(skb);
> Is it not better to call skb_scrub_packet() (if necessary adding a ne=
w
> argument to skip some operations)?

Yes, looks like we can simply use skb_scrub_packet(). xfrm_input()
will do nf_reset() and skb_dst_drop() again, but this should not
harm too much.

I'll incorporate this into the v2 patchest.

Thanks!
