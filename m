From: Nikolay Aleksandrov via Bridge <bridge@lists.linux-foundation.org>
Subject: Re: [PATCH] net: bridge: allow IPv6 when multicast flood
	is disabled
Date: Tue, 28 Feb 2017 11:20:53 +0200
Message-ID: <E4A652DE-AC03-4E8D-B50E-8BE92DCA31C5@cumulusnetworks.com>
References: <1488215489-26372-1-git-send-email-mmanning@brocade.com>
Reply-To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org
To: Mike Manning <mmanning@brocade.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1488215489-26372-1-git-send-email-mmanning@brocade.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org


> On Feb 27, 2017, at 7:11 PM, Mike Manning <mmanning@brocade.com> =
wrote:
>=20

+CC bridge maintainers

> Even with multicast flooding turned off, IPv6 ND should still work so
> that IPv6 connectivity is provided. Allow this by continuing to flood
> multicast traffic originated by us. And similar to the unicast case,
> set auto-mask if the multicast flood flag is set.
>=20
> Fixes: b6cb5ac8331b ("net: bridge: add per-port multicast flood flag")
> Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Signed-off-by: Mike Manning <mmanning@brocade.com>
> ---
> include/linux/if_bridge.h | 2 +-
> net/bridge/br_forward.c   | 3 ++-
> 2 files changed, 3 insertions(+), 2 deletions(-)
>=20
> diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
> index c5847dc..7731808 100644
> --- a/include/linux/if_bridge.h
> +++ b/include/linux/if_bridge.h
> @@ -40,12 +40,12 @@ struct br_ip_list {
> #define BR_ADMIN_COST		BIT(4)
> #define BR_LEARNING		BIT(5)
> #define BR_FLOOD		BIT(6)
> -#define BR_AUTO_MASK		(BR_FLOOD | BR_LEARNING)
> #define BR_PROMISC		BIT(7)
> #define BR_PROXYARP		BIT(8)
> #define BR_LEARNING_SYNC	BIT(9)
> #define BR_PROXYARP_WIFI	BIT(10)
> #define BR_MCAST_FLOOD		BIT(11)
> +#define BR_AUTO_MASK		(BR_FLOOD | BR_LEARNING | =
BR_MCAST_FLOOD)

Quoting myself from v2 of the patch-set that introduced the mcast flood =
flag:
=E2=80=9C
Actually there is one potential issue with br_auto_mask. I shouldn't =
change it=20
because that
changes the requirement for a br_auto_port and it may change =
user-visible=20
behaviour (e.g.
having to disable both unicast flood and multicast flood to get the same =
config=20
for
auto ports).=E2=80=9D

Source: =
http://www.mail-archive.com/netdev@vger.kernel.org/msg125724.html

> #define BR_MULTICAST_TO_UNICAST	BIT(12)
> #define BR_VLAN_TUNNEL		BIT(13)
>=20
> diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
> index 6bfac29..7fe7d58 100644
> --- a/net/bridge/br_forward.c
> +++ b/net/bridge/br_forward.c
> @@ -186,8 +186,9 @@ void br_flood(struct net_bridge *br, struct =
sk_buff *skb,
> 		/* Do not flood unicast traffic to ports that turn it =
off */
> 		if (pkt_type =3D=3D BR_PKT_UNICAST && !(p->flags & =
BR_FLOOD))
> 			continue;
> +		/* Do not flood if mc off, except for traffic we =
originate */
> 		if (pkt_type =3D=3D BR_PKT_MULTICAST &&
> -		    !(p->flags & BR_MCAST_FLOOD))
> +		    !(p->flags & BR_MCAST_FLOOD) && (skb->dev !=3D =
br->dev))

Please drop the extra () around the device check

> 			continue;
>=20
> 		/* Do not flood to ports that enable proxy ARP */

We are aware of this and have discussed it, but I=E2=80=99m not sure =
this is the best way to fix it,
it will still allow local IPv4 mcast to be flooded on all ports even =
with that flag removed and
that definitely changes user-visible behaviour (even if it is okay) and =
will not be appropriate
for -net.

Let me get back to you on this one.

Thanks,
 Nik
