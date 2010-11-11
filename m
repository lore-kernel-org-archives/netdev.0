From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next-2.6] vlan: lockless transmit path
Date: Thu, 11 Nov 2010 09:40:29 -0800
Message-ID: <AANLkTikBkUNfrfSZkoVd1xzisD3jgg5kVUUZC45gNpde@mail.gmail.com>
References: <1289468520.17691.1018.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:43959 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753242Ab0KKRrV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 12:47:21 -0500
Received: by yxn22 with SMTP id 22so25135yxn.19
        for <netdev@vger.kernel.org>; Thu, 11 Nov 2010 09:47:20 -0800 (PST)
In-Reply-To: <1289468520.17691.1018.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 11, 2010 at 1:42 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> vlan is a stacked device, like tunnels. We should use the lockless
> mechanism we are using in tunnels and loopback.
>
> This patch completely removes locking in TX path.
>
> tx stat counters are added into existing percpu stat structure, renam=
ed
> from vlan_rx_stats to vlan_pcpu_stats.
>
> Note : this partially reverts commit 2e59af3dcbdf (vlan: multiqueue v=
lan
> device)
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Patrick McHardy <kaber@trash.net>
> ---
> =A0net/8021q/vlan.c =A0 =A0 =A0 =A0 | =A0 =A04 -
> =A0net/8021q/vlan.h =A0 =A0 =A0 =A0 | =A0 16 +++++--
> =A0net/8021q/vlan_core.c =A0 =A0| =A0 =A04 -
> =A0net/8021q/vlan_dev.c =A0 =A0 | =A0 78 +++++++++++++++++++++-------=
---------
> =A0net/8021q/vlan_netlink.c | =A0 20 ---------
> =A05 files changed, 59 insertions(+), 63 deletions(-)
>
> diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
> index 52077ca..2f54ce8 100644
> --- a/net/8021q/vlan.c
> +++ b/net/8021q/vlan.c
> @@ -272,13 +272,11 @@ static int register_vlan_device(struct net_devi=
ce *real_dev, u16 vlan_id)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0snprintf(name, IFNAMSIZ, "vlan%.4i", v=
lan_id);
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 new_dev =3D alloc_netdev_mq(sizeof(struct vlan_dev_info=
), name,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vla=
n_setup, real_dev->num_tx_queues);
> + =A0 =A0 =A0 new_dev =3D alloc_netdev(sizeof(struct vlan_dev_info), =
name, vlan_setup);

If we're only allocating a single queue then we should also drop
vlan_dev_select_queue() and the netdev_ops that call it.  If the
underlying device is multiqueue and has its own select_queue function
then it can pick a queue number that is larger than what the vlan
device has.  The problem will be caught by dev_cap_txqueue() but it's
not right and it would also be nice to get rid of half of those
netdev_ops.
