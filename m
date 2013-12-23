From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v2 2/2] netlink: specify netlink packet direction
 for nlmon
Date: Mon, 23 Dec 2013 11:43:52 +0100
Message-ID: <52B813E8.8010508@6wind.com>
References: <1387788519-17722-1-git-send-email-dborkman@redhat.com> <1387788519-17722-3-git-send-email-dborkman@redhat.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jakub Zawadzki <darkjames-ws@darkjames.pl>
To: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:56462 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757186Ab3LWKnz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 05:43:55 -0500
Received: by mail-wg0-f49.google.com with SMTP id x12so4826137wgg.16
        for <netdev@vger.kernel.org>; Mon, 23 Dec 2013 02:43:54 -0800 (PST)
In-Reply-To: <1387788519-17722-3-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 23/12/2013 09:48, Daniel Borkmann a =C3=A9crit :
> In order to facilitate development for netlink protocol dissector,
> fill the unused field skb->pkt_type of the cloned skb with a hint
> of the address space of the new owner (receiver) socket in the
> notion of "to kernel" resp. "to user".
>
> At the time we invoke __netlink_deliver_tap_skb(), we already have
> set the new skb owner via netlink_skb_set_owner_r(), so we can use
> that for netlink_is_kernel() probing.
>
> In normal PF_PACKET network traffic, this field denotes if the
> packet is destined for us (PACKET_HOST), if it's broadcast
> (PACKET_BROADCAST), etc.
>
> As we only have 3 bit reserved, we can use the value (=3D 6) of
> PACKET_FASTROUTE as it's _not used_ anywhere in the whole kernel
> and packets of such type were never exposed to user space, so
> there are no overlapping users of such kind. Thus, as wished,
> that seems the only way to make both PACKET_* values non-overlapping
> and therefore device agnostic.
>
> By using those two flags for netlink skbs on nlmon devices, they
> can be made available and picked up via sll_pkttype (previously
> unused in netlink context) in struct sockaddr_ll. We now have
> these two directions:
>
>   - PACKET_USER (=3D 6)    ->  to user space
>   - PACKET_KERNEL (=3D 7)  ->  to kernel space
>
> Partial `ip a` example strace for sa_family=3DAF_NETLINK with
> detected nl msg direction:
>
> syscall:                     direction:
> sendto(3,  ...) =3D 40         /* to kernel */
> recvmsg(3, ...) =3D 3404       /* to user */
> recvmsg(3, ...) =3D 1120       /* to user */
> recvmsg(3, ...) =3D 20         /* to user */
> sendto(3,  ...) =3D 40         /* to kernel */
> recvmsg(3, ...) =3D 168        /* to user */
> recvmsg(3, ...) =3D 144        /* to user */
> recvmsg(3, ...) =3D 20         /* to user */
>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Jakub Zawadzki <darkjames-ws@darkjames.pl>
> ---
>   v1->v2:
>    - let PACKET_* values not overlap as wished by Dave
>
>   include/uapi/linux/if_packet.h | 4 +++-
>   net/netlink/af_netlink.c       | 2 ++
>   2 files changed, 5 insertions(+), 1 deletion(-)
>
> diff --git a/include/uapi/linux/if_packet.h b/include/uapi/linux/if_p=
acket.h
> index e9d844c..06e2a28 100644
> --- a/include/uapi/linux/if_packet.h
> +++ b/include/uapi/linux/if_packet.h
> @@ -26,8 +26,10 @@ struct sockaddr_ll {
>   #define PACKET_MULTICAST	2		/* To group		*/
>   #define PACKET_OTHERHOST	3		/* To someone else 	*/
>   #define PACKET_OUTGOING		4		/* Outgoing of any type */
> -/* These ones are invisible by user level */
>   #define PACKET_LOOPBACK		5		/* MC/BRD frame looped back */
> +#define PACKET_USER		6		/* To user space	*/
Reusing this value is like changing the API. If some userland apps and =
external
modules rely on it, this patch may break them.

> +#define PACKET_KERNEL		7		/* To kernel space	*/
> +/* Unused, PACKET_FASTROUTE and PACKET_LOOPBACK are invisble to user=
 space */
nitpicking: s/invisble/invisible

>   #define PACKET_FASTROUTE	6		/* Fastrouted frame	*/
>
>   /* Packet socket options */
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index 56e09d8..3f75f1c 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -204,6 +204,8 @@ static int __netlink_deliver_tap_skb(struct sk_bu=
ff *skb,
>   	if (nskb) {
>   		nskb->dev =3D dev;
>   		nskb->protocol =3D htons((u16) sk->sk_protocol);
> +		nskb->pkt_type =3D netlink_is_kernel(sk) ?
> +				 PACKET_KERNEL : PACKET_USER;
>
>   		ret =3D dev_queue_xmit(nskb);
>   		if (unlikely(ret > 0))
>
