From: Nick Carter <ncarter100@gmail.com>
Subject: Re: [RFC] bridge: allow passing link-local multicast
Date: Thu, 18 Aug 2011 16:06:19 +0100
Message-ID: <CAEJpZP0fOydMMbgquAud7dfwcO28BXAMzAwnMjSZO6TvEjxgpQ@mail.gmail.com>
References: <CAF5U64C+WgQhfJL3zfVnvzE7p=G61humQCObHGUxAvY2-MGAFQ@mail.gmail.com>
	<CAF5U64CJTWDn8E9+XVLFsdaSbiu-4Rd9XmxZq7ReziRNZviO6Q@mail.gmail.com>
	<20110812154545.79d8313f@nehalam.ftrdhcpuser.net>
	<CAF5U64B_fb2tFMLHmK+zw3n6gmq+bYDyFnXhLE0ayssK5m+THA@mail.gmail.com>
	<20110815150501.3a6cc432@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ed Swierk <eswierk@bigswitch.com>, netdev@vger.kernel.org,
	David Lamparter <equinox@diac24.net>,
	bridge@linux-foundation.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:61354 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751319Ab1HRPGU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2011 11:06:20 -0400
Received: by gwaa12 with SMTP id a12so967142gwa.19
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2011 08:06:20 -0700 (PDT)
In-Reply-To: <20110815150501.3a6cc432@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15 August 2011 23:05, Stephen Hemminger <shemminger@vyatta.com> wrot=
e:
> Several users have wanted to forward 802.1x EAP multicast
> packets through a bridge. And there has been a couple of
> attempts at allowing some form of this in the past.
>
> If a bridge does not have spanning tree turned on, then it should
> act like a pure hub and forward all traffic. This makes it fully
> transparent, and if there is another bridge using spanning tree
> the STP packets will still work for detecting loops in the network.
>
> If bridge has STP enabled, then the default behavior is to
> process all link-local multicasts locally. The expectation is
> that if 802.1x or other protocol using link-local multicasts
> that a service (or proxy) for that protocol will be used.
>
> Optionally, a sysctl value can be set to allow non STP packets
> to still be forwarded. =A0I chose sysctl for this because it is
> where such modifications exist when doing IP or netfilter.
> There are other filtering/configuration options that are needed
> and this is a better way to enable them.
>
> Thanks to David Lamparter, and others for bringing this up.
> Users who need this facility should provide feedback, is this
> a usable solution?
>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>
> ---
> Patch against net-next
>
> =A0Documentation/networking/ip-sysctl.txt | =A0 =A04 ++
> =A0net/bridge/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A0=
2 -
> =A0net/bridge/br.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0=
 12 ++++++
> =A0net/bridge/br_input.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 30 =
++++++++++++++++-
> =A0net/bridge/br_private.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A05 =
++
> =A0net/bridge/br_sysctl.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 57 ++=
+++++++++++++++++++++++++++++++
> =A06 files changed, 107 insertions(+), 3 deletions(-)
>
> --- a/Documentation/networking/ip-sysctl.txt =A0 =A02011-08-15 10:58:=
36.451532115 -0700
> +++ b/Documentation/networking/ip-sysctl.txt =A0 =A02011-08-15 11:39:=
57.719438766 -0700
> @@ -1289,6 +1289,10 @@ bridge-nf-filter-pppoe-tagged - BOOLEAN
> =A0 =A0 =A0 =A00 : disable this.
> =A0 =A0 =A0 =A0Default: 1
>
> +bridge-forward-link-local - BOOLEAN
> + =A0 =A0 =A0 1 : pass link-local multicasts through bridge in STP mo=
de
> + =A0 =A0 =A0 0 : disable this.
> + =A0 =A0 =A0 Default: 0
>
> =A0proc/sys/net/sctp/* Variables:
>
> --- a/net/bridge/Makefile =A0 =A0 =A0 2011-08-15 10:30:25.203595742 -=
0700
> +++ b/net/bridge/Makefile =A0 =A0 =A0 2011-08-15 11:22:38.139477877 -=
0700
> @@ -9,7 +9,7 @@ bridge-y =A0 =A0 =A0 =A0:=3D br.o br_device.o br_fdb.=
o br
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0br_stp_if.o br_stp_tim=
er.o br_netlink.o
>
> =A0bridge-$(CONFIG_SYSFS) +=3D br_sysfs_if.o br_sysfs_br.o
> -
> +bridge-$(CONFIG_SYSCTL) +=3D br_sysctl.o
> =A0bridge-$(CONFIG_BRIDGE_NETFILTER) +=3D br_netfilter.o
>
> =A0bridge-$(CONFIG_BRIDGE_IGMP_SNOOPING) +=3D br_multicast.o
> --- a/net/bridge/br.c =A0 2011-08-15 10:30:48.755594855 -0700
> +++ b/net/bridge/br.c =A0 2011-08-15 10:33:07.215589647 -0700
> @@ -60,6 +60,12 @@ static int __init br_init(void)
> =A0 =A0 =A0 =A0if (err)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto err_out4;
>
> +#ifdef CONFIG_SYSCTL
> + =A0 =A0 =A0 err =3D br_sysctl_init();
> + =A0 =A0 =A0 if (err)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_out5;
> +#endif
> +
> =A0 =A0 =A0 =A0brioctl_set(br_ioctl_deviceless_stub);
>
> =A0#if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
> @@ -67,6 +73,9 @@ static int __init br_init(void)
> =A0#endif
>
> =A0 =A0 =A0 =A0return 0;
> +
> +err_out5:
> + =A0 =A0 =A0 br_netlink_fini();
> =A0err_out4:
> =A0 =A0 =A0 =A0unregister_netdevice_notifier(&br_device_notifier);
> =A0err_out3:
> @@ -84,6 +93,9 @@ static void __exit br_deinit(void)
> =A0{
> =A0 =A0 =A0 =A0stp_proto_unregister(&br_stp_proto);
>
> +#ifdef CONFIG_SYSCTL
> + =A0 =A0 =A0 br_sysctl_fini();
> +#endif
> =A0 =A0 =A0 =A0br_netlink_fini();
> =A0 =A0 =A0 =A0unregister_netdevice_notifier(&br_device_notifier);
> =A0 =A0 =A0 =A0brioctl_set(NULL);
> --- a/net/bridge/br_input.c =A0 =A0 2011-08-15 10:40:21.435573311 -07=
00
> +++ b/net/bridge/br_input.c =A0 =A0 2011-08-15 11:39:57.719438766 -07=
00
> @@ -16,11 +16,18 @@
> =A0#include <linux/netdevice.h>
> =A0#include <linux/etherdevice.h>
> =A0#include <linux/netfilter_bridge.h>
> +#include <linux/llc.h>
> +#include <net/llc.h>
> +#include <net/llc_pdu.h>
> +
> =A0#include "br_private.h"
>
> =A0/* Bridge group multicast address 802.1d (pg 51). */
> =A0const u8 br_group_address[ETH_ALEN] =3D { 0x01, 0x80, 0xc2, 0x00, =
0x00, 0x00 };
>
> +/* Should link-local packets be forwarded (in STP mode) */
> +int br_forward_link_local;
> +
> =A0/* Hook for brouter */
> =A0br_should_route_hook_t __rcu *br_should_route_hook __read_mostly;
> =A0EXPORT_SYMBOL(br_should_route_hook);
> @@ -138,6 +145,17 @@ static inline int is_link_local(const un
> =A0 =A0 =A0 =A0return ((a[0] ^ b[0]) | (a[1] ^ b[1]) | ((a[2] ^ b[2])=
 & m)) =3D=3D 0;
> =A0}
>
> +/* Identify Spanning Tree packets based on header */
Why can't we use the 802.1D specified STP group address to identify ?
The existing code uses that address.
I know you said on another thread that there are people using other add=
resses.
Who are these people ?
Are they following any standard ?
What address / address range are they using ?

Thanks,
Nick
> +static bool is_stp_bpdu(struct sk_buff *skb)
> +{
> + =A0 =A0 =A0 struct llc_pdu_un *pdu =3D llc_pdu_un_hdr(skb);
> +
> + =A0 =A0 =A0 return skb->protocol =3D=3D htons(ETH_P_802_2) &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pdu->ctrl_1 =3D=3D LLC_PDU_TYPE_U &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pdu->dsap =3D=3D LLC_SAP_BSPAN &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pdu->ssap =3D=3D LLC_SAP_BSPAN;
> +}
> +
> =A0/*
> =A0* Return NULL if skb is handled
> =A0* note: already called with rcu_read_lock
> @@ -166,8 +184,16 @@ rx_handler_result_t br_handle_frame(stru
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (skb->protocol =3D=3D htons(ETH_P_P=
AUSE))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto drop;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* If STP is turned off, then forward *=
/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (p->br->stp_enabled =3D=3D BR_NO_STP=
 && dest[5] =3D=3D 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* If STP is turned off, then in hub mo=
de */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (p->br->stp_enabled =3D=3D BR_NO_STP=
)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto forward;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If STP is on
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* then Always handle STP packets loc=
ally,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* =A0 =A0 =A0other packets can be fo=
rwarded if sysctl is enabled.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!is_stp_bpdu(skb) && br_forward_lin=
k_local)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto forward;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCA=
L_IN, skb, skb->dev,
> --- a/net/bridge/br_private.h =A0 2011-08-15 10:38:35.587577293 -0700
> +++ b/net/bridge/br_private.h =A0 2011-08-15 10:57:36.983534352 -0700
> @@ -284,6 +284,7 @@ struct br_input_skb_cb {
> =A0 =A0 =A0 =A0pr_debug("%s: " format, =A0(br)->dev->name, ##args)
>
> =A0extern struct notifier_block br_device_notifier;
> +extern int br_forward_link_local;
> =A0extern const u8 br_group_address[ETH_ALEN];
>
> =A0/* called under bridge lock */
> @@ -546,6 +547,10 @@ extern int br_sysfs_renameif(struct net_
> =A0extern int br_sysfs_addbr(struct net_device *dev);
> =A0extern void br_sysfs_delbr(struct net_device *dev);
>
> +/* br_sysctl.c */
> +extern int br_sysctl_init(void);
> +extern void br_sysctl_fini(void);
> +
> =A0#else
>
> =A0#define br_sysfs_addif(p) =A0 =A0 =A0(0)
> --- /dev/null =A0 1970-01-01 00:00:00.000000000 +0000
> +++ b/net/bridge/br_sysctl.c =A0 =A02011-08-15 11:41:00.819436393 -07=
00
> @@ -0,0 +1,57 @@
> +/*
> + * =A0 =A0 Sysctl settings for bridge
> + *
> + * =A0 =A0 Authors:
> + * =A0 =A0 Stephen Hemminger =A0 =A0 =A0 =A0 =A0 =A0 =A0 <shemminger=
@osdl.org>
> + *
> + * =A0 =A0 This program is free software; you can redistribute it an=
d/or
> + * =A0 =A0 modify it under the terms of the GNU General Public Licen=
se
> + * =A0 =A0 as published by the Free Software Foundation; either vers=
ion
> + * =A0 =A0 2 of the License, or (at your option) any later version.
> + */
> +
> +#include <linux/module.h>
> +#include <linux/kernel.h>
> +#include <linux/slab.h>
> +#include <linux/ip.h>
> +#include <linux/netdevice.h>
> +#include <linux/skbuff.h>
> +#include <linux/if_arp.h>
> +#include <linux/if_ether.h>
> +#include <linux/if_vlan.h>
> +#include <linux/if_pppox.h>
> +#include <linux/sysctl.h>
> +
> +#include "br_private.h"
> +
> +static struct ctl_table bridge_table[] =3D {
> + =A0 =A0 =A0 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .procname =A0 =A0 =A0 =3D "bridge-forwa=
rd-link-local",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .data =A0 =A0 =A0 =A0 =A0 =3D &br_forwa=
rd_link_local,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .maxlen =A0 =A0 =A0 =A0 =3D sizeof(int)=
,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .mode =A0 =A0 =A0 =A0 =A0 =3D 0644,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .proc_handler =A0 =3D proc_dointvec
> + =A0 =A0 =A0 },
> +};
> +
> +static struct ctl_path bridge_ctl_path[] =3D {
> + =A0 =A0 =A0 { .procname =3D "net", },
> + =A0 =A0 =A0 { .procname =3D "bridge", },
> + =A0 =A0 =A0 { },
> +};
> +
> +static struct ctl_table_header *br_sysctl;
> +
> +int __init br_sysctl_init(void)
> +{
> + =A0 =A0 =A0 br_sysctl =3D register_sysctl_paths(bridge_ctl_path, br=
idge_table);
> + =A0 =A0 =A0 if (br_sysctl =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +void __exit br_sysctl_fini(void)
> +{
> + =A0 =A0 =A0 unregister_net_sysctl_table(br_sysctl);
> +}
>
