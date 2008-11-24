From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: af_packet should disable preempt around	sock_prot_inuse_add()
Date: Mon, 24 Nov 2008 14:08:27 +0100
Message-ID: <492AA74B.2030108@cosmosbay.com>
References: <20081124130240.GB6255@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Alexander Beregalov <a.beregalov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:43110 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752999AbYKXNIj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 08:08:39 -0500
In-Reply-To: <20081124130240.GB6255@orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexander Beregalov a =E9crit :
> BUG: using smp_processor_id() in preemptible [00000000] code: dhc
>=20
> caller is sock_prot_inuse_add+0x24/0x42
> Pid: 1776, comm: dhcpcd Tainted: G        W  2.6.28-rc6-next-2008
>=20
> Call Trace:
>  [<ffffffff8037fb72>] debug_smp_processor_id+0xca/0xe0
>  [<ffffffff8046afc9>] sock_prot_inuse_add+0x24/0x42
>  [<ffffffff804bd0a7>] packet_release+0x178/0x198
>  [<ffffffff804695c6>] sock_release+0x20/0xc0
>  [<ffffffff80469688>] sock_close+0x22/0x26
>  [<ffffffff8029fa30>] __fput+0xeb/0x18a
>  [<ffffffff8029fae4>] fput+0x15/0x17
>  [<ffffffff8029cfac>] filp_close+0x67/0x72
>  [<ffffffff8029d05c>] sys_close+0xa5/0xe4
>  [<ffffffff8020b75b>] system_call_fastpath+0x16/0x1b
>=20
> Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
> ---
>=20
>  net/packet/af_packet.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index b4870a3..8b7ddf7 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -910,7 +910,9 @@ static int packet_release(struct socket *sock)
>  	skb_queue_purge(&sk->sk_receive_queue);
>  	sk_refcnt_debug_release(sk);
> =20
> +	preempt_disable();
>  	sock_prot_inuse_add(net, sk->sk_prot, -1);
> +	preempt_enable();
>  	sock_put(sk);
>  	return 0;
>  }
> @@ -1085,8 +1087,8 @@ static int packet_create(struct net *net, struc=
t socket *sock, int protocol)
> =20
>  	write_lock_bh(&net->packet.sklist_lock);
>  	sk_add_node(sk, &net->packet.sklist);
> -	write_unlock_bh(&net->packet.sklist_lock);
>  	sock_prot_inuse_add(net, &packet_proto, 1);
> +	write_unlock_bh(&net->packet.sklist_lock);
>  	return(0);
>  out:
>  	return err;
> --

Thanks Alexander, but same answer than previous mail.

Problem already fixed in net-next-2.6


