From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [v3 PATCH 2/2] netpoll: remove IFF_IN_NETPOLL flag
Date: Wed, 8 Dec 2010 16:16:22 +0800
Message-ID: <AANLkTindQMNKhC2aowUyjm=uO8gFKqOOPa9HXSU1q7Gh@mail.gmail.com>
References: <20101208075208.5792.45247.sendpatchset@localhost.localdomain> <20101208075218.5792.64791.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, Jiri Pirko <jpirko@redhat.com>,
	Neil Horman <nhorman@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Amerigo Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101208075218.5792.64791.sendpatchset@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 8, 2010 at 3:52 PM, Amerigo Wang <amwang@redhat.com> wrote:
> From: Amerigo Wang <amwang@redhat.com>
> Date: Thu, 2 Dec 2010 21:34:44 +0800
> Subject: [v3 PATCH 2/2] netpoll: remove IFF_IN_NETPOLL flag
>
> This patch removes the flag IFF_IN_NETPOLL, we don't need it any more=
 since
> we have netpoll_tx_running() now.
>
> Signed-off-by: WANG Cong <amwang@redhat.com>
> Cc: Neil Horman <nhorman@redhat.com>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Jay Vosburgh <fubar@us.ibm.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Stephen Hemminger <shemminger@vyatta.com>
> Cc: Jiri Pirko <jpirko@redhat.com>
> Cc: "Eric W. Biederman" <ebiederm@xmission.com>
>
> ---
>
> =A0drivers/net/bonding/bond_main.c | =A0 =A06 ++----
> =A0drivers/net/bonding/bonding.h =A0 | =A0 =A02 +-
> =A0include/linux/if.h =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A09 ++++-----
> =A0net/core/netpoll.c =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 --
> =A04 files changed, 7 insertions(+), 12 deletions(-)
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
> index 7fafe06..21ac08b 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -448,11 +448,9 @@ int bond_dev_queue_xmit(struct bonding *bond, st=
ruct sk_buff *skb,
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0skb->priority =3D 1;
> - =A0 =A0 =A0 if (unlikely(netpoll_tx_running(slave_dev))) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 slave_dev->priv_flags |=3D IFF_IN_NETPO=
LL;
> + =A0 =A0 =A0 if (unlikely(netpoll_tx_running(slave_dev)))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bond_netpoll_send_skb(bond_get_slave_b=
y_dev(bond, slave_dev), skb);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 slave_dev->priv_flags &=3D ~IFF_IN_NETP=
OLL;
> - =A0 =A0 =A0 } else
> + =A0 =A0 =A0 else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_queue_xmit(skb);
>
> =A0 =A0 =A0 =A0return 0;
> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bond=
ing.h
> index c4f6a94..493e645 100644
> --- a/drivers/net/bonding/bonding.h
> +++ b/drivers/net/bonding/bonding.h
> @@ -138,7 +138,7 @@ static inline void unblock_netpoll_tx(void)
>
> =A0static inline int is_netpoll_tx_blocked(struct net_device *dev)
> =A0{
> - =A0 =A0 =A0 if (unlikely(dev->priv_flags & IFF_IN_NETPOLL))
> + =A0 =A0 =A0 if (unlikely(netpoll_tx_running(dev)))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return cpumask_test_cpu(smp_processor_=
id(), netpoll_block_tx);
> =A0 =A0 =A0 =A0return 0;
> =A0}
> diff --git a/include/linux/if.h b/include/linux/if.h
> index 1239599..3bc63e6 100644
> --- a/include/linux/if.h
> +++ b/include/linux/if.h
> @@ -71,11 +71,10 @@
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 * release skb->dst
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 */
> =A0#define IFF_DONT_BRIDGE 0x800 =A0 =A0 =A0 =A0 =A0/* disallow bridg=
ing this ether dev */
> -#define IFF_IN_NETPOLL 0x1000 =A0 =A0 =A0 =A0 =A0/* whether we are p=
rocessing netpoll */
> -#define IFF_DISABLE_NETPOLL =A0 =A00x2000 =A0/* disable netpoll at r=
un-time */
> -#define IFF_MACVLAN_PORT =A0 =A0 =A0 0x4000 =A0/* device used as mac=
vlan port */
> -#define IFF_BRIDGE_PORT =A0 =A0 =A0 =A00x8000 =A0 =A0 =A0 =A0 =A0/* =
device used as bridge port */
> -#define IFF_OVS_DATAPATH =A0 =A0 =A0 0x10000 /* device used as Open =
vSwitch
> +#define IFF_DISABLE_NETPOLL =A0 =A00x1000 =A0/* disable netpoll at r=
un-time */
> +#define IFF_MACVLAN_PORT =A0 =A0 =A0 0x2000 =A0/* device used as mac=
vlan port */
> +#define IFF_BRIDGE_PORT =A0 =A0 =A0 =A00x4000 =A0 =A0 =A0 =A0 =A0/* =
device used as bridge port */
> +#define IFF_OVS_DATAPATH =A0 =A0 =A0 0x8000 =A0/* device used as Ope=
n vSwitch
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 * datapath port */
>

You can't change the values of these macros or delete some of them,
because they are exported to user space and are parts of ABI.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
