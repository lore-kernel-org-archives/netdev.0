From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 4/5] netfilter: use sequence number synchronization for
 counters
Date: Thu, 29 Jan 2009 09:47:53 +0100
Message-ID: <49816D39.9030705@cosmosbay.com>
References: <20090129062521.092861272@vyatta.com> <20090129062549.234454895@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:33126 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752431AbZA2Ir6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 03:47:58 -0500
In-Reply-To: <20090129062549.234454895@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> Change how synchronization is done on the iptables counters. Use seqc=
ount
> wrapper instead of depending on reader/writer lock.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
>=20
> ---
>  include/linux/netfilter/x_tables.h |    3 +++
>  net/ipv4/netfilter/arp_tables.c    |   24 +++++++++++++++++++-----
>  net/ipv4/netfilter/ip_tables.c     |   24 +++++++++++++++++++-----
>  net/ipv6/netfilter/ip6_tables.c    |   32 +++++++++++++++++++++++---=
------
>  net/netfilter/x_tables.c           |   11 +++++++++++
>  5 files changed, 75 insertions(+), 19 deletions(-)
> 4
> --- a/net/ipv4/netfilter/arp_tables.c	2009-01-28 21:24:39.223991934 -=
0800
> +++ b/net/ipv4/netfilter/arp_tables.c	2009-01-28 22:13:16.423490077 -=
0800
> @@ -230,6 +230,7 @@ unsigned int arpt_do_table(struct sk_buf
>  	void *table_base;
>  	const struct xt_table_info *private;
>  	struct xt_target_param tgpar;
> +	seqcount_t *seq;
> =20
>  	if (!pskb_may_pull(skb, arp_hdr_len(skb->dev)))
>  		return NF_DROP;
> @@ -240,6 +241,7 @@ unsigned int arpt_do_table(struct sk_buf
>  	read_lock_bh(&table->lock);
>  	private =3D table->private;
>  	table_base =3D (void *)private->entries[smp_processor_id()];
> +	seq =3D per_cpu_ptr(private->seq, smp_processor_id());

But, why not using a global seqcount_t, shared by all tables, no matter=
 they
are arp_tables, ip_tables, ip6_tables ?

A global PER_CPU variable, not dynamically allocated, so that its
access can be faster (no indirection), and uses exactly 4 bytes per
possible cpu.

DEFINE_PER_CPU(seqcount_t,  nf_seqcount);


