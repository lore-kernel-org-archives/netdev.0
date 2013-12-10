From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2] packet: Deliver VLAN TPID to userspace
Date: Tue, 10 Dec 2013 12:59:15 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7476@saturn3.aculab.com>
References: <8738m0q3nq.wl%atzm@stratosphere.co.jp>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Stephen Hemminger" <stephen@networkplumber.org>,
	"Ben Hutchings" <bhutchings@solarflare.com>,
	"David Miller" <davem@davemloft.net>,
	"Daniel Borkmann" <dborkman@redhat.com>
To: "Atzm Watanabe" <atzm@stratosphere.co.jp>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:37983 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751908Ab3LJNAO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 08:00:14 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 21528-08 for <netdev@vger.kernel.org>;
 Tue, 10 Dec 2013 13:00:12 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <8738m0q3nq.wl%atzm@stratosphere.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Atzm Watanabe
> Sent: 10 December 2013 12:41
> After the 802.1AD support, userspace packet receivers (packet dumper,
> software switch, and the like) need how to know VLAN TPID in order to
> reconstruct original tagged frame.
...
> -#define TP_STATUS_VLAN_VALID	(1 << 4) /* auxdata has valid tp_vlan_tci */
> +#define TP_STATUS_VLAN_VALID	(1 << 4) /* auxdata has valid tp_vlan_tci and tp_vlan_tpid */

How can userland (I presume) determine whether tp_vlan_tpid is valid?

...
> +struct tpacket_hdr_variant2 {
> +	__u32	tp_rxhash;
> +	__u32	tp_vlan_tci;
> +	__u32	tp_vlan_tpid;
> +};
> +
>  struct tpacket3_hdr {
>  	__u32		tp_next_offset;
>  	__u32		tp_sec;
> @@ -153,6 +159,7 @@ struct tpacket3_hdr {
>  	/* pkt_hdr variants */
>  	union {
>  		struct tpacket_hdr_variant1 hv1;
> +		struct tpacket_hdr_variant2 hv2;
>  	};
>  };

You've defined a new header variant, but all the code seems to rely
on the fact that the 'new' variant is identical to the old one
with the addition of an extra field at the end.

In which case it ought to be valid to just extend the old header variant.
If the header really can change format there ought to be a discriminating
member somewhere - which you don't seem to have changed.
 
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 9d70f13..3c75878 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -975,11 +975,15 @@ static void prb_clear_rxhash(struct tpacket_kbdq_core *pkc,
>  static void prb_fill_vlan_info(struct tpacket_kbdq_core *pkc,
>  			struct tpacket3_hdr *ppd)
>  {
> +	BUILD_BUG_ON(TPACKET_ALIGN(sizeof(*ppd)) != 48);

I'd add a comment about why check matters.
(ie the fact that it can safely grow until that is no longer true.)

	David
