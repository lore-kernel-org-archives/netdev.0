From: Plamen Petrov <pvp-lsts@fs.uni-ruse.bg>
Subject: Re: [Bugme-new] [Bug 16626] New: Machine hangs with EIP at
  skb_copy_and_csum_dev
Date: Tue, 24 Aug 2010 20:25:16 +0300
Message-ID: <courier.4C74007C.00000EE4@fs.ru.acad.bg>
References: <20100820193835.GA6025@del.dom.local>
            <20100821074742.GA2367@del.dom.local>
            <1282377058.2636.12.camel@edumazet-laptop>
            <20100821080735.GA2409@del.dom.local>
            <4C725FCB.2000304@fs.uni-ruse.bg>
            <20100823124736.GA16966@ff.dom.local>
            <1282568443.2486.34.camel@edumazet-laptop>
            <20100823131056.GA19160@ff.dom.local>
            <4C727B06.2060002@fs.uni-ruse.bg>
            <4C72802D.8090405@fs.uni-ruse.bg>
            <20100823141437.GA2282@del.dom.local>
            <4C734FB5.1090702@fs.uni-ruse.bg>
            <1282626102.2378.1351.camel@edumazet-laptop>
            <4C738636.4000107@fs.uni-ruse.bg>
            <4C73C8DF.4060601@fs.uni-ruse.bg>
            <1282662532.2477.248.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Plamen Petrov <pvp-lsts@fs.uni-ruse.bg>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [83.228.35.12] ([83.228.35.12]:38772 "EHLO fs.ru.acad.bg"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932131Ab0HXRa4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 13:30:56 -0400
In-Reply-To: <1282662532.2477.248.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet =D0=BD=D0=B0=D0=BF=D0=B8=D1=81=D0=B0:=20

> Le mardi 24 ao=C3=BBt 2010 =C3=A0 16:27 +0300, Plamen Petrov a =C3=A9=
crit :=20
>=20
>> The current status: if I enable GRO on the tg3 - the kernel oopses.
>> It just takes a different amount of time to trigger: somewhere from
>> 30 seconds to 30 minutes.=20
>>=20
>> The oopses looks the same, and here are the latest:=20
>>=20
>> [picture 13]
>> http://picpaste.com/c8dbda8f5c15d9ce3e050dd7f245f5d0.jpg=20
>>=20
>> [picture 14]
>> http://picpaste.com/646cca586b704c5b72d3cf9fa54c7344.jpg=20
>>=20
>> I was wondering which debug options could help us track this down?=20
>>=20
>=20
> Thanks, here is an updated patch (against linux-2.6)=20
>=20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 3721fbb..77c8eb7 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1935,6 +1935,32 @@ static inline int skb_needs_linearize(struct s=
k_buff *skb,
>  					      illegal_highdma(dev, skb))));
>  }
> =20
> +int skb_csum_start_bug(const struct sk_buff *skb, int pos)
> +{
> +
> +	if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL) {
> +		long csstart;
> +
> +		csstart =3D skb->csum_start - skb_headroom(skb);
> +		if (WARN_ON(csstart > skb_headlen(skb))) {
> +			int i;
> +
> +			pr_err("%d: csum_start %u, offset %u, headroom %d, headlen %d, le=
n %d\n",
> +				   pos, skb->csum_start, skb->csum_offset, skb_headroom(skb),
> +				   skb_headlen(skb), skb->len);
> +			pr_err("nr_frags=3D%u gso_size=3D%u ",
> +					skb_shinfo(skb)->nr_frags,
> +					skb_shinfo(skb)->gso_size);
> +			for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
> +				pr_err("frag_size=3D%u ", skb_shinfo(skb)->frags[i].size);
> +			}
> +			pr_err("\n");
> +			return 1;
> +		}
> +	}
> +	return 0;
> +}
> +
>  int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
>  			struct netdev_queue *txq)
>  {
> @@ -1959,11 +1985,15 @@ int dev_hard_start_xmit(struct sk_buff *skb, =
struct net_device *dev,
>  				goto out_kfree_skb;
>  			if (skb->next)
>  				goto gso;
> +			if (skb_csum_start_bug(skb, 10))
> +				goto out_kfree_skb;
>  		} else {
>  			if (skb_needs_linearize(skb, dev) &&
>  			    __skb_linearize(skb))
>  				goto out_kfree_skb;
> =20
> +			if (skb_csum_start_bug(skb, 20))
> +				goto out_kfree_skb;
>  			/* If packet is not checksummed and device does not
>  			 * support checksumming for this protocol, complete
>  			 * checksumming here.
> @@ -1974,10 +2004,16 @@ int dev_hard_start_xmit(struct sk_buff *skb, =
struct net_device *dev,
>  				if (!dev_can_checksum(dev, skb) &&
>  				     skb_checksum_help(skb))
>  					goto out_kfree_skb;
> +				if (skb_csum_start_bug(skb, 30))
> +					goto out_kfree_skb;
>  			}
>  		}
> =20
> -		rc =3D ops->ndo_start_xmit(skb, dev);
> +		if (skb_csum_start_bug(skb, 40)) {
> +			kfree_skb(skb);
> +			rc =3D NETDEV_TX_OK;
> +		} else
> +			rc =3D ops->ndo_start_xmit(skb, dev);
>  		if (rc =3D=3D NETDEV_TX_OK)
>  			txq_trans_update(txq);
>  		return rc;
> @@ -1997,7 +2033,12 @@ gso:
>  		if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
>  			skb_dst_drop(nskb);
> =20
> -		rc =3D ops->ndo_start_xmit(nskb, dev);
> +		if (skb_csum_start_bug(skb, 50)) {
> +			kfree_skb(skb);
> +			rc =3D NETDEV_TX_OK;
> +		} else
> +			rc =3D ops->ndo_start_xmit(nskb, dev);
> +
>  		if (unlikely(rc !=3D NETDEV_TX_OK)) {
>  			if (rc & ~NETDEV_TX_MASK)
>  				goto out_kfree_gso_skb;
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 3a2513f..3d54a1b 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -1824,13 +1824,15 @@ void skb_copy_and_csum_dev(const struct sk_bu=
ff *skb, u8 *to)
>  {
>  	__wsum csum;
>  	long csstart;
> +	extern int skb_csum_start_bug(const struct sk_buff *skb, int pos);
> =20
>  	if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL)
>  		csstart =3D skb->csum_start - skb_headroom(skb);
>  	else
>  		csstart =3D skb_headlen(skb);
> =20
> -	BUG_ON(csstart > skb_headlen(skb));
> +	if (skb_csum_start_bug(skb, 100))
> +		return;
> =20
>  	skb_copy_from_linear_data(skb, to, csstart);
>  =20
>=20
>=20

Above patch applied, and happy to report the machine now spits data
in the logs instead of oopsing. Here is what we have now:=20

[   10.721802] Ending clean XFS mount for filesystem: md12
[   11.669013] IPv4 FIB: Using LC-trie version 0.409
[   11.669101] eth2: link up, 100Mbps, full-duplex, lpa 0x45E1
[   11.746792] eth0: link up, 100Mbps, full-duplex, lpa 0x41E1
[   11.757230] tg3 0000:04:00.0: irq 44 for MSI/MSI-X
[   11.810133] ADDRCONF(NETDEV_UP): eth1: link is not ready
[   11.957523] sixxs_t: Disabled Privacy Extensions
[   14.843711] tg3 0000:04:00.0: eth1: Link is up at 1000 Mbps, full du=
plex
[   14.843717] tg3 0000:04:00.0: eth1: Flow control is on for TX and on=
 for=20
RX
[   14.843753] ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
[   15.854861] tun0: Disabled Privacy Extensions
[  699.375620] ------------[ cut here ]------------
[  699.475648] WARNING: at net/core/dev.c:1945=20
skb_csum_start_bug+0x46/0xf2()
[  699.575667] Hardware name: PowerEdge SC440
[  699.675688] Pid: 2963, comm: FahCore_78.exe Not tainted=20
2.6.36-rc2-FS-00103-g2d6fa25 #1
[  699.775706] Call Trace:
[  699.975744]  [<c102d86c>] ? warn_slowpath_common+0x67/0x8c
[  700.175779]  [<c12abc76>] ? skb_csum_start_bug+0x46/0xf2
[  700.375813]  [<c12abc76>] ? skb_csum_start_bug+0x46/0xf2
[  700.575848]  [<c102d8ac>] ? warn_slowpath_null+0x1b/0x1f
[  700.775882]  [<c12abc76>] ? skb_csum_start_bug+0x46/0xf2
[  700.975918]  [<c1024569>] ? __wake_up_sync_key+0x3c/0x52
[  701.175953]  [<c12a7bab>] ? skb_copy_and_csum_dev+0x2a/0xaf
[  701.375989]  [<c122483b>] ? rtl8139_start_xmit+0x4a/0x13a
[  701.576026]  [<c12ae29e>] ? dev_hard_start_xmit+0x220/0x4cc
[  701.776062]  [<c12bfbed>] ? sch_direct_xmit+0xac/0x174
[  701.976096]  [<c12c3f69>] ? nf_iterate+0x69/0x7c
[  702.176131]  [<c12e8976>] ? ip_finish_output+0x0/0x2b6
[  702.376165]  [<c12b00eb>] ? dev_queue_xmit+0xc7/0x355
[  702.576198]  [<c12e8976>] ? ip_finish_output+0x0/0x2b6
[  702.776232]  [<c12e8a92>] ? ip_finish_output+0x11c/0x2b6
[  702.976266]  [<c12e8f11>] ? ip_output+0xa4/0xc3
[  703.176299]  [<c12e8976>] ? ip_finish_output+0x0/0x2b6
[  703.376332]  [<c12e4ff9>] ? ip_forward_finish+0x39/0x44
[  703.576365]  [<c12e3a38>] ? ip_rcv_finish+0xe8/0x39f
[  703.776398]  [<c12ad0fd>] ? __netif_receive_skb+0x237/0x2b3
[  703.976431]  [<c12ad70b>] ? netif_receive_skb+0x5f/0x64
[  704.176464]  [<c12ad75e>] ? napi_gro_complete+0x4e/0x94
[  704.376497]  [<c12ada9a>] ? dev_gro_receive+0x158/0x1f5
[  704.576530]  [<c12adc84>] ? napi_gro_receive+0x16/0x1f
[  704.776563]  [<c1217efb>] ? tg3_poll_work+0x5bc/0xbfb
[  704.976597]  [<c1006e50>] ? nommu_sync_single_for_device+0x0/0x1
[  705.176631]  [<c121ce68>] ? tg3_poll+0x43/0x194
[  705.376665]  [<c12ad8b3>] ? net_rx_action+0xcc/0x15b
[  705.576699]  [<c1031cad>] ? __do_softirq+0x7f/0xfa
[  705.776733]  [<c1053dc9>] ? handle_IRQ_event+0x48/0xa6
[  705.976767]  [<c105689b>] ? move_native_irq+0x9/0x3e
[  706.176799]  [<c1031d4f>] ? do_softirq+0x27/0x2a
[  706.376832]  [<c1031e9d>] ? irq_exit+0x63/0x68
[  706.576864]  [<c1003dda>] ? do_IRQ+0x44/0xa1
[  706.776897]  [<c1031e6b>] ? irq_exit+0x31/0x68
[  706.976930]  [<c101654e>] ? smp_apic_timer_interrupt+0x53/0x83
[  707.176963]  [<c1002d29>] ? common_interrupt+0x29/0x30
[  707.276981] ---[ end trace 75e4f8534893c910 ]---
[  707.376998] 100: csum_start 306, offset 16, headroom 390, headlen 70=
,=20
len 70
[  707.477015] nr_frags=3D0 gso_size=3D0
[  707.577031]
[ 1012.931455] ------------[ cut here ]------------
[ 1013.031482] WARNING: at net/core/dev.c:1945=20
skb_csum_start_bug+0x46/0xf2()
[ 1013.131501] Hardware name: PowerEdge SC440
[ 1013.231521] Pid: 2963, comm: FahCore_78.exe Tainted: G        W  =20
2.6.36-rc2-FS-00103-g2d6fa25 #1
[ 1013.331538] Call Trace:
[ 1013.531575]  [<c102d86c>] ? warn_slowpath_common+0x67/0x8c
[ 1013.731608]  [<c12abc76>] ? skb_csum_start_bug+0x46/0xf2
[ 1013.931641]  [<c12abc76>] ? skb_csum_start_bug+0x46/0xf2
[ 1014.131675]  [<c102d8ac>] ? warn_slowpath_null+0x1b/0x1f
[ 1014.331708]  [<c12abc76>] ? skb_csum_start_bug+0x46/0xf2
[ 1014.531742]  [<c1024569>] ? __wake_up_sync_key+0x3c/0x52
[ 1014.731775]  [<c12a7bab>] ? skb_copy_and_csum_dev+0x2a/0xaf
[ 1014.931809]  [<c122483b>] ? rtl8139_start_xmit+0x4a/0x13a
[ 1015.131841]  [<c12ae29e>] ? dev_hard_start_xmit+0x220/0x4cc
[ 1015.331875]  [<c12bfbed>] ? sch_direct_xmit+0xac/0x174
[ 1015.531908]  [<c12c3f69>] ? nf_iterate+0x69/0x7c
[ 1015.731941]  [<c12e8976>] ? ip_finish_output+0x0/0x2b6
[ 1015.931973]  [<c12b00eb>] ? dev_queue_xmit+0xc7/0x355
[ 1016.132007]  [<c12e8976>] ? ip_finish_output+0x0/0x2b6
[ 1016.332039]  [<c12e8a92>] ? ip_finish_output+0x11c/0x2b6
[ 1016.532071]  [<c12e8f11>] ? ip_output+0xa4/0xc3
[ 1016.732103]  [<c12e8976>] ? ip_finish_output+0x0/0x2b6
[ 1016.932135]  [<c12e4ff9>] ? ip_forward_finish+0x39/0x44
[ 1017.132166]  [<c12e3a38>] ? ip_rcv_finish+0xe8/0x39f
[ 1017.332198]  [<c12ad0fd>] ? __netif_receive_skb+0x237/0x2b3
[ 1017.532230]  [<c12ad70b>] ? netif_receive_skb+0x5f/0x64
[ 1017.732262]  [<c12ad75e>] ? napi_gro_complete+0x4e/0x94
[ 1017.932294]  [<c12ada9a>] ? dev_gro_receive+0x158/0x1f5
[ 1018.132326]  [<c12adc84>] ? napi_gro_receive+0x16/0x1f
[ 1018.332358]  [<c1217efb>] ? tg3_poll_work+0x5bc/0xbfb
[ 1018.532392]  [<c1006e50>] ? nommu_sync_single_for_device+0x0/0x1
[ 1018.732424]  [<c121ce68>] ? tg3_poll+0x43/0x194
[ 1018.932456]  [<c12ad8b3>] ? net_rx_action+0xcc/0x15b
[ 1019.132489]  [<c1031cad>] ? __do_softirq+0x7f/0xfa
[ 1019.332522]  [<c1053dc9>] ? handle_IRQ_event+0x48/0xa6
[ 1019.532554]  [<c105689b>] ? move_native_irq+0x9/0x3e
[ 1019.732586]  [<c1031d4f>] ? do_softirq+0x27/0x2a
[ 1019.932617]  [<c1031e9d>] ? irq_exit+0x63/0x68
[ 1020.132648]  [<c1003dda>] ? do_IRQ+0x44/0xa1
[ 1020.332680]  [<c1031e6b>] ? irq_exit+0x31/0x68
[ 1020.532713]  [<c101654e>] ? smp_apic_timer_interrupt+0x53/0x83
[ 1020.732745]  [<c1002d29>] ? common_interrupt+0x29/0x30
[ 1020.932777]  [<c1390000>] ? quirk_io_region+0x1c/0x91
[ 1021.032794] ---[ end trace 75e4f8534893c911 ]---
[ 1021.132812] 100: csum_start 306, offset 16, headroom 390, headlen 15=
3,=20
len 153
[ 1021.232828] nr_frags=3D0 gso_size=3D0
[ 1021.332844]=20

Now what?=20

Thanks a lot, Eric and Jarek!=20

Plamen=20

_
___
_____
 ------------------------------------------
This message was sent by the mail server
at fs.ru.acad.bg using the web interface:
    https://fs.ru.acad.bg/s/m/webmail
E-mail postmaster@fs.ru.acad.bg with anything,
regarding the server itself
