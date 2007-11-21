From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC][PATCH 1/3] NET_SCHED: PSPacer qdisc module
Date: Wed, 21 Nov 2007 16:58:47 +0100
Message-ID: <474455B7.3080005@cosmosbay.com>
References: <20071121.191840.07671434.takano@axe-inc.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	t.kudoh@aist.go.jp
To: Ryousei Takano <takano-ryousei@aist.go.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:55122 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755496AbXKUP7K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 10:59:10 -0500
In-Reply-To: <20071121.191840.07671434.takano@axe-inc.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ryousei Takano a =E9crit :
> This patch includes the PSPacer (Precise Software Pacer) qdisc
> module, which achieves precise transmission bandwidth control.
> You can find more information at the project web page
> (http://www.gridmpi.org/gridtcp.jsp).
>=20
> Signed-off-by: Ryousei Takano <takano-ryousei@aist.go.jp>


> +static struct sk_buff *alloc_gap_packet(struct Qdisc* sch, int size)
> +{
> +	struct sk_buff *skb;
> +	struct net_device *dev =3D sch->dev;
> +	unsigned char *pkt;
> +	int pause_time =3D 0;
> +	int pktsize =3D size + 2;
> +
> +	skb =3D alloc_skb(pktsize, GFP_ATOMIC);
> +	if (!skb)
> +		return NULL;
> +
> +	skb_reserve(skb, 2);

minor nit, but skb_reserve is not *needed* here.

skb_reserve() is used to align IP header on a 16 bytes boundary, and
we do it on rx side to speedup IP stack, at the cost of a possibly more
expensive DMA transfert.

Here you dont send an IP packet, do you ?

> +
> +	pkt =3D skb->data;
> +	memset(pkt, 0xff, pktsize);
> +	pkt[0] =3D 0x01; /* dst address: 01:80:c2:00:00:01 */
> +	pkt[1] =3D 0x80;
> +	pkt[2] =3D 0xc2;
> +	pkt[3] =3D 0x00;
> +	pkt[4] =3D 0x00;
> +	pkt[5] =3D 0x01;
> +	memcpy(pkt + 6, dev->dev_addr, ETH_ALEN /* dev->addr_len */);
> +
> +	pkt[12] =3D 0x88; /* MAC control:        88 08 */
> +	pkt[13] =3D 0x08;
> +	pkt[14] =3D 0;    /* MAC control opcode: 00 01 */
> +	pkt[15] =3D 1;
> +	pkt[16] =3D pause_time >> 8;
> +	pkt[17] =3D pause_time;
> +
> +	skb_put(skb, size);
> +
> +	skb->dev =3D sch->dev;

