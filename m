From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net/ipv4: push IP options to CB in
 ip_fragment
Date: Mon, 30 Aug 2010 23:35:18 +0200
Message-ID: <1283204118.2405.32.camel@edumazet-laptop>
References: <20100830200917.GA10754@stratus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Bandan Das <bandan.das@stratus.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100830200917.GA10754@stratus.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 30 ao=C3=BBt 2010 =C3=A0 16:09 -0400, Bandan Das a =C3=A9crit =
:
> The bridge layer can overwrite the IPCB using the
> BR_INPUT_SKB_CB macro. In br_nf_dev_queue_xmit,=20
> if we recieve a packet greater in size than the bridge=20
> device MTU, we call ip_fragment which in turn will lead to=20
> icmp_send calling ip_options_echo if the DF flag is set.=20
> ip_options_echo will then incorrectly try to parse the IPCB as=20
> IP options resulting in a buffer overflow.=20
> This change refills the CB area back with IP=20
> options before ip_fragment calls icmp_send. If we fail parsing,=20
> we zero out the IPCB area to guarantee that the stack does=20
> not get corrupted.
>=20
> Test setup that can exhibit this behavior:
> <Remote Machine>--<Host Machine>--<Bridge>--<Tun/Tap>--<KVM Guest>
>   1500 mtu          576 mtu        576 mtu   576 mtu    1500 mtu
>=20
> Example of crash :
> Kernel panic - not syncing: stack-protector: Kernel stack is corrupte=
d in: ffffffff8146dff3
> Pid: 3173, comm: qemu-kvm Not tainted 2.6.32-63.el6.x86_64 #1
> Call Trace:
> Message from <IRQ>  syslogd@kvm at  [<ffffffff814c8285>] panic+0x78/0=
x137
> Aug 30 14:09:50  [<ffffffff8146dff3>] ? icmp_send+0x743/0x780
>=20
> Signed-off-by: Bandan Das <bandan.das@stratus.com>
> ---
>  net/ipv4/ip_output.c |   11 +++++++++++
>  1 files changed, 11 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index e427620..5fef4a9 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -445,6 +445,7 @@ int ip_fragment(struct sk_buff *skb, int (*output=
)(struct sk_buff *))
>  	struct iphdr *iph;
>  	int ptr;
>  	struct net_device *dev;
> +	struct ip_options *opt;
>  	struct sk_buff *skb2;
>  	unsigned int mtu, hlen, left, len, ll_rs;
>  	int offset;
> @@ -462,6 +463,16 @@ int ip_fragment(struct sk_buff *skb, int (*outpu=
t)(struct sk_buff *))
> =20
>  	if (unlikely((iph->frag_off & htons(IP_DF)) && !skb->local_df)) {
>  		IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGFAILS);
> +
> +		/* Refill CB with IP options */
> +		opt =3D &(IPCB(skb)->opt);
> +		opt->optlen =3D iph->ihl*4 - sizeof(struct iphdr);
> +		if (ip_options_compile(dev_net(dev), opt, skb)) {
> +			IP_INC_STATS(dev_net(dev), IPSTATS_MIB_INHDRERRORS);
> +			/* If we fail, zero out IPCB and continue */
> +			memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
> +		}
> +
>  		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
>  			  htonl(ip_skb_dst_mtu(skb)));
>  		kfree_skb(skb);


I wonder if we want this.

Maybe setting skb->local_df =3D 1 in bridge should be enough ?
