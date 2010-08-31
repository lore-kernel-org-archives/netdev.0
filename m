From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Gigabit Ethernet driver of Topcliff PCH
Date: Tue, 31 Aug 2010 16:51:03 +0200
Message-ID: <1283266263.2550.106.camel@edumazet-laptop>
References: <4C763A67.5040107@dsn.okisemi.com>
	 <4C7D0E7A.5060309@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Sam Ravnborg <sam@ravnborg.org>, Joe Perches <joe@perches.com>,
	LKML <linux-kernel@vger.kernel.org>,
	ML netdev <netdev@vger.kernel.org>,
	Greg Rose <gregory.v.rose@intel.com>,
	Maxime Bizon <mbizon@freebox.fr>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	John Linn <john.linn@xilinx.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	MeeGo <meego-dev@meego.com>, "Wang, Qi" <qi.wang@intel.com>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	Andrew <andrew.chih.howe.khor@intel.com>,
	Intel OTC <joel.clark@intel.com>,
	"Foster, Margie" <margie.foster@intel.com>,
	Toshiharu Okada <okada533@dsn.okisemi.com>,
	Tomoya Morinaga <morinaga526@dsn.okisemi.com>,
	Takahiro Shimizu <shimizu394@dsn.okisemi.com>
To: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C7D0E7A.5060309@dsn.okisemi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 31 ao=C3=BBt 2010 =C3=A0 23:15 +0900, Masayuki Ohtake a =C3=A9=
crit :
> Hi Sam, Joe and Stephen
>=20
> Thank you for your comments.
> We have modified this driver for your comment.
>=20
> ---
> Gigabit Ethernet driver of Topcliff PCH

> +			skb->protocol =3D eth_type_trans(skb, netdev);
> +			if ((tcp_ip_status & PCH_GBE_RXD_ACC_STAT_TCPIPOK) =3D=3D
> +			    PCH_GBE_RXD_ACC_STAT_TCPIPOK) {
> +				skb->ip_summed =3D CHECKSUM_UNNECESSARY;
> +			} else {
> +				skb->ip_summed =3D CHECKSUM_NONE;
> +			}
> +
> +			if (netif_receive_skb(skb) =3D=3D NET_RX_DROP) {
> +				adapter->stats.rx_dropped++;

dont use pr_err() here, dropping a frame is a normal condition.

> +				pr_err("Receive Netif Receive Dropped Error\n");
> +			}
> +			(*work_done)++;
> +			netdev->last_rx =3D jiffies;

really ? last_rx is a thing of the past.

> +			pr_debug
> +			    ("Receive skb->ip_summed: %d length: %d\n",
> +			     skb->ip_summed, length);
> +		}
> +dorrop:
> +		/* return some buffers to hardware, one at a time is too slow */
> +		if (unlikely(cleaned_count >=3D PCH_GBE_RX_BUFFER_WRITE)) {
> +			pch_gbe_alloc_rx_buffers(adapter, rx_ring,
> +						 cleaned_count);
> +			cleaned_count =3D 0;
> +		}
> +		if (++i =3D=3D rx_ring->count)
> +			i =3D 0;
> +	}
> +	rx_ring->next_to_clean =3D i;
> +	if (cleaned_count)
> +		pch_gbe_alloc_rx_buffers(adapter, rx_ring, cleaned_count);
> +	return cleaned;
> +}
> +



I find hard to believe this driver needs to copy all outgoing frames on
pre-allocated skbs.

+       /* [Header:14][payload] ---> [Header:14][paddong:2][payload]   =
 */
+       memcpy(tmp_skb->data, skb->data, ETH_HLEN);
+       tmp_skb->data[ETH_HLEN] =3D 0x00;
+       tmp_skb->data[ETH_HLEN + 1] =3D 0x00;
+       tmp_skb->len =3D skb->len;
+       memcpy(&tmp_skb->data[ETH_HLEN + 2], &skb->data[ETH_HLEN],
+              (skb->len - ETH_HLEN));
+       buffer_info->kernel_skb =3D skb;
+       skb =3D tmp_skb;

Whats the deal here please ?
