From: Ben Greear <greearb@candelatech.com>
Subject: =?UTF-8?Q?Re:_[PATCH_3.2_085/115]_veth:_don=e2=80=99t_modify_ip=5fs?=
 =?UTF-8?Q?ummed;_doing_so_treats_packets_with_bad_checksums_as_good.?=
Date: Wed, 27 Apr 2016 08:59:44 -0700
Message-ID: <5720E1F0.9010203@candelatech.com>
References: <lsq.1461711744.699003961@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, "David S. Miller" <davem@davemloft.net>,
	Vijay Pandurangan <vijayp@vijayp.ca>,
	Cong Wang <cwang@twopensource.com>, netdev@vger.kernel.org,
	Evan Jones <ej@evanjones.ca>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Phil Sutter <phil@nwl.cc>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: Ben Hutchings <ben@decadent.org.uk>, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <lsq.1461711744.699003961@decadent.org.uk>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/26/2016 04:02 PM, Ben Hutchings wrote:
> 3.2.80-rc1 review patch.  If anyone has any objections, please let me=
 know.

I would be careful about this.  It causes regressions when sending
PACKET_SOCKET buffers from user-space to veth devices.

There was a proposed upstream fix for the regression, but it has not go=
ne
into the tree as far as I know.

http://www.spinics.net/lists/netdev/msg370436.html

Thanks,
Ben

>
> ------------------
>
> From: Vijay Pandurangan <vijayp@vijayp.ca>
>
> [ Upstream commit ce8c839b74e3017996fad4e1b7ba2e2625ede82f ]
>
> Packets that arrive from real hardware devices have ip_summed =3D=3D
> CHECKSUM_UNNECESSARY if the hardware verified the checksums, or
> CHECKSUM_NONE if the packet is bad or it was unable to verify it. The
> current version of veth will replace CHECKSUM_NONE with
> CHECKSUM_UNNECESSARY, which causes corrupt packets routed from hardwa=
re to
> a veth device to be delivered to the application. This caused applica=
tions
> at Twitter to receive corrupt data when network hardware was corrupti=
ng
> packets.
>
> We believe this was added as an optimization to skip computing and
> verifying checksums for communication between containers. However, lo=
cally
> generated packets have ip_summed =3D=3D CHECKSUM_PARTIAL, so the code=
 as
> written does nothing for them. As far as we can tell, after removing =
this
> code, these packets are transmitted from one stack to another unmodif=
ied
> (tcpdump shows invalid checksums on both sides, as expected), and the=
y are
> delivered correctly to applications. We didn=E2=80=99t test every pos=
sible network
> configuration, but we tried a few common ones such as bridging contai=
ners,
> using NAT between the host and a container, and routing from hardware
> devices to containers. We have effectively deployed this in productio=
n at
> Twitter (by disabling RX checksum offloading on veth devices).
>
> This code dates back to the first version of the driver, commit
> <e314dbdc1c0dc6a548ecf> ("[NET]: Virtual ethernet device driver"), so=
 I
> suspect this bug occurred mostly because the driver API has evolved
> significantly since then. Commit <0b7967503dc97864f283a> ("net/veth: =
=46ix
> packet checksumming") (in December 2010) fixed this for packets that =
get
> created locally and sent to hardware devices, by not changing
> CHECKSUM_PARTIAL. However, the same issue still occurs for packets co=
ming
> in from hardware devices.
>
> Co-authored-by: Evan Jones <ej@evanjones.ca>
> Signed-off-by: Evan Jones <ej@evanjones.ca>
> Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Cc: Phil Sutter <phil@nwl.cc>
> Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> Cc: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Signed-off-by: Vijay Pandurangan <vijayp@vijayp.ca>
> Acked-by: Cong Wang <cwang@twopensource.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> [bwh: Backported to 3.2: adjust context]
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> ---
>   drivers/net/veth.c | 6 ------
>   1 file changed, 6 deletions(-)
>
> --- a/drivers/net/veth.c
> +++ b/drivers/net/veth.c
> @@ -126,11 +126,6 @@ static netdev_tx_t veth_xmit(struct sk_b
>   	stats =3D this_cpu_ptr(priv->stats);
>   	rcv_stats =3D this_cpu_ptr(rcv_priv->stats);
>
> -	/* don't change ip_summed =3D=3D CHECKSUM_PARTIAL, as that
> -	   will cause bad checksum on forwarded packets */
> -	if (skb->ip_summed =3D=3D CHECKSUM_NONE &&
> -	    rcv->features & NETIF_F_RXCSUM)
> -		skb->ip_summed =3D CHECKSUM_UNNECESSARY;
>
>   	length =3D skb->len;
>   	if (dev_forward_skb(rcv, skb) !=3D NET_RX_SUCCESS)
>


--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
