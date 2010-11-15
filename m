From: sergey belov <gexlie@gmail.com>
Subject: Re: NETPOLL on bond interfaces
Date: Mon, 15 Nov 2010 18:35:35 +0300
Message-ID: <AANLkTinKK16z1ROf-gjZz9p1jOO3We42F9PX9kqFTuXL@mail.gmail.com>
References: <AANLkTingysT7=+AiGCh4kiY27RK9jz40ci1y_of4o-FC@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:35394 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755066Ab0KOPgG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 10:36:06 -0500
Received: by yxn35 with SMTP id 35so1143791yxn.19
        for <netdev@vger.kernel.org>; Mon, 15 Nov 2010 07:36:06 -0800 (PST)
In-Reply-To: <AANLkTingysT7=+AiGCh4kiY27RK9jz40ci1y_of4o-FC@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

found this thread:
http://amailbox.org/mailarchive/linux-netdev/2010/6/25/6280002

and this:

static int disable_netpoll =3D 1; in drivers/net/bonding/bond_main.c

have switched value to 0, so nevermind now :)



On Mon, Nov 15, 2010 at 4:49 PM, sergey belov <gexlie@gmail.com> wrote:
> Before 2.6.36 came out I was using this patch to enable netpoll on bo=
nd
> interfaces (see below)
>
> When I tried to apply this patch to 2.6.36 sources some chunks was fa=
iled.
>
> [root@kernel-x32 experimental]# patch -p0 < netpoll.patch
> patching file a/drivers/net/bonding/bond_main.c
> Hunk #1 FAILED at 75.
> Hunk #2 FAILED at 416.
> Hunk #3 succeeded at 1334 with fuzz 2 (offset 23 lines).
> Hunk #4 succeeded at 1729 with fuzz 1 (offset 15 lines).
> Hunk #5 succeeded at 1837 (offset 42 lines).
> Hunk #6 succeeded at 2026 (offset 19 lines).
> Hunk #7 succeeded at 4490 with fuzz 1 (offset 11 lines).
> Hunk #8 succeeded at 4674 (offset 68 lines).
> 2 out of 8 hunks FAILED -- saving rejects to file
> a/drivers/net/bonding/bond_main.c.rej
> patching file a/drivers/net/bonding/bonding.h
> Hunk #2 succeeded at 227 (offset 4 lines).
> patching file a/include/linux/netdevice.h
> Hunk #1 FAILED at 52.
> Hunk #2 FAILED at 625.
> 2 out of 2 hunks FAILED -- saving rejects to file
> a/include/linux/netdevice.h.rej
> patching file a/include/linux/netpoll.h
> Hunk #1 succeeded at 43 with fuzz 2 (offset 9 lines).
> patching file a/net/core/netpoll.c
> Reversed (or previously applied) patch detected! =A0Assume -R? [n]
>
>
> Inspecting changelog at
> http://www.kernel.org/pub/linux/kernel/v2.6/ChangeLog-2.6.36 I found =
there
> are a lot of changes was done inside of the bonding and netpoll subsy=
stem.
>
> Could please someone provide me new patch to enable netpoll on bond i=
faces
> or send me a workaround how to enable it in any other way.
>
> We need to use it only to enable netconsole on our servers with bond.
>
>
> =A0 1. diff --git a/drivers/net/bonding/bond_main.c
> =A0 b/drivers/net/bonding/bond_main.c
> =A0 2. index d927f71..6304720 100644
> =A0 3. --- a/drivers/net/bonding/bond_main.c
> =A0 4. +++ b/drivers/net/bonding/bond_main.c
> =A0 5. @@ -75,6 +75,7 @@
> =A0 6. =A0#include <linux/jiffies.h>
> =A0 7. =A0#include <net/route.h>
> =A0 8. =A0#include <net/net_namespace.h>
> =A0 9. +#include <linux/netpoll.h>
> =A0 10. =A0#include "bonding.h"
> =A0 11. =A0#include "bond_3ad.h"
> =A0 12. =A0#include "bond_alb.h"
> =A0 13. @@ -415,7 +416,12 @@ int bond_dev_queue_xmit(struct bonding *=
bond,
> =A0 struct sk_buff *skb,
> =A0 14. =A0 =A0 =A0 =A0 }
> =A0 15.
> =A0 16. =A0 =A0 =A0 =A0 skb->priority =3D 1;
> =A0 17. - =A0 =A0 =A0 dev_queue_xmit(skb);
> =A0 18. +#ifdef CONFIG_NET_POLL_CONTROLLER
> =A0 19. + =A0 =A0 =A0 if (bond->netpoll)
> =A0 20. + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netpoll_send_skb(bond->netpoll,=
 skb);
> =A0 21. + =A0 =A0 =A0 else
> =A0 22. +#endif
> =A0 23. + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_queue_xmit(skb);
> =A0 24.
> =A0 25. =A0 =A0 =A0 =A0 return 0;
> =A0 26. =A0}
> =A0 27. @@ -1305,6 +1311,44 @@ static void bond_detach_slave(struct b=
onding
> =A0 *bond, struct slave *slave)
> =A0 28. =A0 =A0 =A0 =A0 bond->slave_cnt--;
> =A0 29. =A0}
> =A0 30.
> =A0 31. +#ifdef CONFIG_NET_POLL_CONTROLLER
> =A0 32. +static int slaves_support_netpoll(struct net_device *bond_de=
v)
> =A0 33. +{
> =A0 34. + =A0 =A0 =A0 struct bonding *bond =3D netdev_priv(bond_dev);
> =A0 35. + =A0 =A0 =A0 struct slave *slave;
> =A0 36. + =A0 =A0 =A0 int i;
> =A0 37. +
> =A0 38. + =A0 =A0 =A0 bond_for_each_slave(bond, slave, i)
> =A0 39. + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!slave->dev->netdev_ops->nd=
o_poll_controller)
> =A0 40. + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> =A0 41. + =A0 =A0 =A0 return 1;
> =A0 42. +}
> =A0 43. +
> =A0 44. +static void bond_poll_controller(struct net_device *bond_dev=
)
> =A0 45. +{
> =A0 46. + =A0 =A0 =A0 struct bonding *bond =3D netdev_priv(bond_dev);
> =A0 47. + =A0 =A0 =A0 struct slave *slave;
> =A0 48. + =A0 =A0 =A0 int i;
> =A0 49. +
> =A0 50. + =A0 =A0 =A0 if (slaves_support_netpoll(bond_dev))
> =A0 51. + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bond_for_each_slave(bond, slave=
, i)
> =A0 52. + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netpoll_poll_de=
v(slave->dev);
> =A0 53. +}
> =A0 54. +
> =A0 55. +static int bond_netpoll_setup(struct net_device *bond_dev,
> =A0 56. + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 str=
uct netpoll_info *npinfo)
> =A0 57. +{
> =A0 58. + =A0 =A0 =A0 struct bonding *bond =3D netdev_priv(bond_dev);
> =A0 59. + =A0 =A0 =A0 struct slave *slave;
> =A0 60. + =A0 =A0 =A0 int i;
> =A0 61. +
> =A0 62. + =A0 =A0 =A0 bond_for_each_slave(bond, slave, i)
> =A0 63. + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (slave->dev)
> =A0 64. + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 slave->dev->npi=
nfo =3D npinfo;
> =A0 65. + =A0 =A0 =A0 return 0;
> =A0 66. +}
> =A0 67. +#endif
> =A0 68. +
> =A0 69. =A0/*---------------------------------- IOCTL
> =A0 ----------------------------------*/
> =A0 70.
> =A0 71. =A0static int bond_sethwaddr(struct net_device *bond_dev,
> =A0 72. @@ -1670,6 +1714,16 @@ int bond_enslave(struct net_device *bo=
nd_dev,
> =A0 struct net_device *slave_dev)
> =A0 73. =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bond->primary=
_slave =3D new_slave;
> =A0 74. =A0 =A0 =A0 =A0 }
> =A0 75.
> =A0 76. +#ifdef CONFIG_NET_POLL_CONTROLLER
> =A0 77. + =A0 =A0 =A0 if (slaves_support_netpoll(bond_dev))
> =A0 78. + =A0 =A0 =A0 =A0 =A0 =A0 =A0 slave_dev->npinfo =3D bond_dev-=
>npinfo;
> =A0 79. + =A0 =A0 =A0 else {
> =A0 80. + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_err(DRV_NAME "New slave devi=
ce %s does not support
> =A0 netpoll.\n",
> =A0 81. + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0slave_dev->name)=
;
> =A0 82. + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_err(DRV_NAME "netpoll disabl=
ed for %s.\n",
> =A0 bond_dev->name);
> =A0 83. + =A0 =A0 =A0 }
> =A0 84. +#endif
> =A0 85. +
> =A0 86. =A0 =A0 =A0 =A0 write_lock_bh(&bond->curr_slave_lock);
> =A0 87.
> =A0 88. =A0 =A0 =A0 =A0 switch (bond->params.mode) {
> =A0 89. @@ -1741,6 +1795,10 @@ int bond_enslave(struct net_device *bo=
nd_dev,
> =A0 struct net_device *slave_dev)
> =A0 90.
> =A0 91. =A0/* Undo stages on error */
> =A0 92. =A0err_close:
> =A0 93. +#ifdef CONFIG_NET_POLL_CONTROLLER
> =A0 94. + =A0 =A0 =A0 if (slave_dev->npinfo)
> =A0 95. + =A0 =A0 =A0 =A0 =A0 =A0 =A0 slave_dev->npinfo =3D NULL;
> =A0 96. +#endif
> =A0 97. =A0 =A0 =A0 =A0 dev_close(slave_dev);
> =A0 98.
> =A0 99. =A0err_unset_master:
> =A0 100. @@ -1949,6 +2007,10 @@ int bond_release(struct net_device *b=
ond_dev,
> =A0 struct net_device *slave_dev)
> =A0 101. =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0IFF_SLAVE_INACTIVE | IFF_BONDING
> =A0 |
> =A0 102. =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0IFF_SLAVE_NEEDARP);
> =A0 103.
> =A0 104. +#ifdef CONFIG_NET_POLL_CONTROLLER
> =A0 105. + =A0 =A0 =A0 if (slave_dev->npinfo)
> =A0 106. + =A0 =A0 =A0 =A0 =A0 =A0 =A0 slave_dev->npinfo =3D NULL;
> =A0 107. +#endif
> =A0 108. =A0 =A0 =A0 =A0 kfree(slave);
> =A0 109.
> =A0 110. =A0 =A0 =A0 =A0 return 0; =A0/* deletion OK */
> =A0 111. @@ -4417,6 +4479,20 @@ out:
> =A0 112. =A0 =A0 =A0 =A0 return 0;
> =A0 113. =A0}
> =A0 114.
> =A0 115. +#ifdef CONFIG_NET_POLL_CONTROLLER
> =A0 116. +int bond_netpoll_start_xmit(struct netpoll *np, struct sk_b=
uff *skb
> =A0 )
> =A0 117. +{
> =A0 118. + =A0 =A0 =A0 struct bonding *bond =3D netdev_priv(skb->dev)=
;
> =A0 119. + =A0 =A0 =A0 int ret;
> =A0 120. +
> =A0 121. + =A0 =A0 =A0 bond->netpoll =3D np;
> =A0 122. + =A0 =A0 =A0 ret =3D bond->dev->netdev_ops->ndo_start_xmit(=
skb, bond->dev);
> =A0 123. + =A0 =A0 =A0 bond->netpoll =3D NULL;
> =A0 124. +
> =A0 125. + =A0 =A0 =A0 return ret;
> =A0 126. +}
> =A0 127. +#endif
> =A0 128. +
> =A0 129. =A0/*------------------------- Device initialization
> =A0 ---------------------------*/
> =A0 130.
> =A0 131. =A0static void bond_set_xmit_hash_policy(struct bonding *bon=
d)
> =A0 132. @@ -4530,6 +4606,9 @@ static const struct net_device_ops
> =A0 bond_netdev_ops =3D {
> =A0 133. =A0 =A0 =A0 =A0 .ndo_change_mtu =A0 =A0 =A0 =A0 =3D bond_cha=
nge_mtu,
> =A0 134. =A0 =A0 =A0 =A0 .ndo_set_mac_address =A0 =A0=3D bond_set_mac=
_address,
> =A0 135. =A0 =A0 =A0 =A0 .ndo_neigh_setup =A0 =A0 =A0 =A0=3D bond_nei=
gh_setup,
> =A0 136. + =A0 =A0 =A0 .ndo_netpoll_setup =A0 =A0 =A0=3D bond_netpoll=
_setup,
> =A0 137. + =A0 =A0 =A0 .ndo_netpoll_start_xmit =3D bond_netpoll_start=
_xmit,
> =A0 138. + =A0 =A0 =A0 .ndo_poll_controller =A0 =A0=3D bond_poll_cont=
roller,
> =A0 139. =A0 =A0 =A0 =A0 .ndo_vlan_rx_register =A0 =3D bond_vlan_rx_r=
egister,
> =A0 140. =A0 =A0 =A0 =A0 .ndo_vlan_rx_add_vid =A0 =A0=3D bond_vlan_rx=
_add_vid,
> =A0 141. =A0 =A0 =A0 =A0 .ndo_vlan_rx_kill_vid =A0 =3D bond_vlan_rx_k=
ill_vid,
> =A0 142. diff --git a/drivers/net/bonding/bonding.h
> =A0 b/drivers/net/bonding/bonding.h
> =A0 143. index 6290a50..563d28c 100644
> =A0 144. --- a/drivers/net/bonding/bonding.h
> =A0 145. +++ b/drivers/net/bonding/bonding.h
> =A0 146. @@ -18,6 +18,7 @@
> =A0 147. =A0#include <linux/timer.h>
> =A0 148. =A0#include <linux/proc_fs.h>
> =A0 149. =A0#include <linux/if_bonding.h>
> =A0 150. +#include <linux/netpoll.h>
> =A0 151. =A0#include <linux/kobject.h>
> =A0 152. =A0#include <linux/in6.h>
> =A0 153. =A0#include "bond_3ad.h"
> =A0 154. @@ -222,6 +223,10 @@ struct bonding {
> =A0 155. =A0#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
> =A0 156. =A0 =A0 =A0 =A0 struct =A0 in6_addr master_ipv6;
> =A0 157. =A0#endif
> =A0 158. +#ifdef CONFIG_NET_POLL_CONTROLLER
> =A0 159. + =A0 =A0 =A0 struct =A0 netpoll *netpoll;
> =A0 160. +#endif
> =A0 161. +
> =A0 162. =A0};
> =A0 163.
> =A0 164. =A0/**
> =A0 165. diff --git a/include/linux/netdevice.h b/include/linux/netde=
vice.h
> =A0 166. index d4a4d98..e1724b2 100644
> =A0 167. --- a/include/linux/netdevice.h
> =A0 168. +++ b/include/linux/netdevice.h
> =A0 169. @@ -52,6 +52,7 @@
> =A0 170.
> =A0 171. =A0struct vlan_group;
> =A0 172. =A0struct netpoll_info;
> =A0 173. +struct netpoll;
> =A0 174. =A0/* 802.11 specific */
> =A0 175. =A0struct wireless_dev;
> =A0 176. =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 /* source back-compat hooks
> =A0 */
> =A0 177. @@ -624,6 +625,10 @@ struct net_device_ops {
> =A0 178. =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned
> =A0 short vid);
> =A0 179. =A0#ifdef CONFIG_NET_POLL_CONTROLLER
> =A0 180. =A0#define HAVE_NETDEV_POLL
> =A0 181. + =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (*=
ndo_netpoll_setup)(struct
> =A0 net_device *dev,
> =A0 182. + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct
> =A0 netpoll_info *npinfo);
> =A0 183. + =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (*=
ndo_netpoll_start_xmit)(struct
> =A0 netpoll *np,
> =A0 184. + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct
> =A0 sk_buff *skb);
> =A0 185. =A0 =A0 =A0 =A0 void =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
(*ndo_poll_controller)(struct
> =A0 net_device *dev);
> =A0 186. =A0#endif
> =A0 187. =A0#if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
> =A0 188. diff --git a/include/linux/netpoll.h b/include/linux/netpoll=
=2Eh
> =A0 189. index 2524267..39d42e4 100644
> =A0 190. --- a/include/linux/netpoll.h
> =A0 191. +++ b/include/linux/netpoll.h
> =A0 192. @@ -34,7 +34,9 @@ struct netpoll_info {
> =A0 193. =A0};
> =A0 194.
> =A0 195. =A0void netpoll_poll(struct netpoll *np);
> =A0 196. +void netpoll_poll_dev(struct net_device *dev);
> =A0 197. =A0void netpoll_send_udp(struct netpoll *np, const char *msg=
, int len)
> =A0 ;
> =A0 198. +void netpoll_send_skb(struct netpoll *np, struct sk_buff *s=
kb);
> =A0 199. =A0void netpoll_print_options(struct netpoll *np);
> =A0 200. =A0int netpoll_parse_options(struct netpoll *np, char *opt);
> =A0 201. =A0int netpoll_setup(struct netpoll *np);
> =A0 202. diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> =A0 203. index 9675f31..3776b26 100644
> =A0 204. --- a/net/core/netpoll.c
> =A0 205. +++ b/net/core/netpoll.c
> =A0 206. @@ -174,9 +174,8 @@ static void service_arp_queue(struct
> =A0 netpoll_info *npi)
> =A0 207. =A0 =A0 =A0 =A0 }
> =A0 208. =A0}
> =A0 209.
> =A0 210. -void netpoll_poll(struct netpoll *np)
> =A0 211. +void netpoll_poll_dev(struct net_device *dev)
> =A0 212. =A0{
> =A0 213. - =A0 =A0 =A0 struct net_device *dev =3D np->dev;
> =A0 214. =A0 =A0 =A0 =A0 const struct net_device_ops *ops;
> =A0 215.
> =A0 216. =A0 =A0 =A0 =A0 if (!dev || !netif_running(dev))
> =A0 217. @@ -196,6 +195,11 @@ void netpoll_poll(struct netpoll *np)
> =A0 218. =A0 =A0 =A0 =A0 zap_completion_queue();
> =A0 219. =A0}
> =A0 220.
> =A0 221. +void netpoll_poll(struct netpoll *np)
> =A0 222. +{
> =A0 223. + =A0 =A0 =A0 netpoll_poll_dev(np->dev);
> =A0 224. +}
> =A0 225. +
> =A0 226. =A0static void refill_skbs(void)
> =A0 227. =A0{
> =A0 228. =A0 =A0 =A0 =A0 struct sk_buff *skb;
> =A0 229. @@ -277,11 +281,11 @@ static int netpoll_owner_active(struct
> =A0 net_device *dev)
> =A0 230. =A0 =A0 =A0 =A0 return 0;
> =A0 231. =A0}
> =A0 232.
> =A0 233. -static void netpoll_send_skb(struct netpoll *np, struct sk_=
buff
> =A0 *skb)
> =A0 234. +void netpoll_send_skb(struct netpoll *np, struct sk_buff *s=
kb)
> =A0 235. =A0{
> =A0 236. =A0 =A0 =A0 =A0 int status =3D NETDEV_TX_BUSY;
> =A0 237. =A0 =A0 =A0 =A0 unsigned long tries;
> =A0 238. - =A0 =A0 =A0 struct net_device *dev =3D np->dev;
> =A0 239. + =A0 =A0 =A0 struct net_device *dev =3D skb->dev;
> =A0 240. =A0 =A0 =A0 =A0 const struct net_device_ops *ops =3D dev->ne=
tdev_ops;
> =A0 241. =A0 =A0 =A0 =A0 struct netpoll_info *npinfo =3D np->dev->npi=
nfo;
> =A0 242.
> =A0 243. @@ -303,7 +307,10 @@ static void netpoll_send_skb(struct net=
poll
> =A0 *np, struct sk_buff *skb)
> =A0 244. =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tries > 0; --trie=
s) {
> =A0 245. =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (__netif_=
tx_trylock(txq)) {
> =A0 246. =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 if (!netif_tx_queue_stopped(txq)) {
> =A0 247. - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 status =3D ops->ndo_start_xmit
> =A0 (skb, dev);
> =A0 248. + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 if (
> =A0 ops->ndo_netpoll_start_xmit)
> =A0 249. + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D
> =A0 ops->ndo_netpoll_start_xmit(np,skb);
> =A0 250. + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 else
> =A0 251. + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D
> =A0 ops->ndo_start_xmit(skb, dev);
> =A0 252. =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 if (status =3D=3D NETDEV_TX_OK)
> =A0 253. =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 txq_trans_update(txq
> =A0 );
> =A0 254. =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 }
> =A0 255. @@ -789,6 +796,9 @@ int netpoll_setup(struct netpoll *np)
> =A0 256. =A0 =A0 =A0 =A0 /* avoid racing with NAPI reading npinfo */
> =A0 257. =A0 =A0 =A0 =A0 synchronize_rcu();
> =A0 258.
> =A0 259. + =A0 =A0 =A0 if (ndev->netdev_ops->ndo_netpoll_setup)
> =A0 260. + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ndev->netdev_ops->ndo_netpoll_=
setup(ndev, npinfo);
> =A0 261. +
> =A0 262. =A0 =A0 =A0 =A0 return 0;
> =A0 263.
> =A0 264. =A0 release:
> =A0 265. @@ -859,4 +869,6 @@ EXPORT_SYMBOL(netpoll_parse_options);
> =A0 266. =A0EXPORT_SYMBOL(netpoll_setup);
> =A0 267. =A0EXPORT_SYMBOL(netpoll_cleanup);
> =A0 268. =A0EXPORT_SYMBOL(netpoll_send_udp);
> =A0 269. +EXPORT_SYMBOL(netpoll_send_skb);
> =A0 270. =A0EXPORT_SYMBOL(netpoll_poll);
> =A0 271. +EXPORT_SYMBOL(netpoll_poll_dev);
>
