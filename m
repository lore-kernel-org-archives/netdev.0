From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] netfilter: xtables: userspace notification target
Date: Tue, 13 Jul 2010 14:18:26 +0800
Message-ID: <AANLkTil2EgQbzUqYNHAYpIWJvyyE6AWq1TpvxrqVsD7k@mail.gmail.com>
References: <20100713001115.GA3751@sortiz-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Luciano Coelho <luciano.coelho@nokia.com>
To: Samuel Ortiz <sameo@linux.intel.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100713001115.GA3751@sortiz-mobl>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 13, 2010 at 8:11 AM, Samuel Ortiz <sameo@linux.intel.com> w=
rote:
>
> The userspace notification Xtables target sends a netlink notificatio=
n
> whenever a packet hits the target. Notifications have a label attribu=
te
> for userspace to match it against a previously set rule. The rules al=
so
> take a --all option to switch between sending a notification for all
> packets or for the first one only.
> Userspace can also send a netlink message to toggle this switch while=
 the
> target is in place. This target uses the nefilter netlink framework.
>
> This target combined with various matches (quota, rateest, etc..) all=
ows
> userspace to make decisions on interfaces handling. One could for exa=
mple
> decide to switch between power saving modes depending on estimated ra=
te
> thresholds.
>

It much like the following iptables rules.

iptables -N log_and_drop
iptables -A log_and_drop -j NFLOG --nflog-group 1 --nflog-prefix "log_a=
nd_drop"
iptables -A log_and_drop -j DROP

=2E..
iptables ... -m quota --quota-bytes 20000 -j log_and_drop
=2E..

> =A0include/linux/netfilter/Kbuild =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A01 =
+
> =A0include/linux/netfilter/nfnetlink.h =A0 =A0 =A0 =A0| =A0 =A05 +-
> =A0include/linux/netfilter/nfnetlink_compat.h | =A0 =A01 +
> =A0include/linux/netfilter/xt_NFNOTIF.h =A0 =A0 =A0 | =A0 55 +++++
> =A0net/netfilter/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0|=
 =A0 17 ++
> =A0net/netfilter/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0=
 =A01 +
> =A0net/netfilter/xt_NFNOTIF.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A030=
0 ++++++++++++++++++++++++++++
> =A07 files changed, 379 insertions(+), 1 deletions(-)
> =A0create mode 100644 include/linux/netfilter/xt_NFNOTIF.h
> =A0create mode 100644 net/netfilter/xt_NFNOTIF.c
>
> diff --git a/include/linux/netfilter/Kbuild b/include/linux/netfilter=
/Kbuild
> index bb103f4..1b80b27 100644
> --- a/include/linux/netfilter/Kbuild
> +++ b/include/linux/netfilter/Kbuild
> @@ -12,6 +12,7 @@ header-y +=3D xt_IDLETIMER.h
> =A0header-y +=3D xt_LED.h
> =A0header-y +=3D xt_MARK.h
> =A0header-y +=3D xt_NFLOG.h
> +header-y +=3D xt_NFNOTIF.h
> =A0header-y +=3D xt_NFQUEUE.h
> =A0header-y +=3D xt_RATEEST.h
> =A0header-y +=3D xt_SECMARK.h
> diff --git a/include/linux/netfilter/nfnetlink.h b/include/linux/netf=
ilter/nfnetlink.h
> index 361d6b5..e336f03 100644
> --- a/include/linux/netfilter/nfnetlink.h
> +++ b/include/linux/netfilter/nfnetlink.h
> @@ -18,6 +18,8 @@ enum nfnetlink_groups {
> =A0#define NFNLGRP_CONNTRACK_EXP_UPDATE =A0 NFNLGRP_CONNTRACK_EXP_UPD=
ATE
> =A0 =A0 =A0 =A0NFNLGRP_CONNTRACK_EXP_DESTROY,
> =A0#define NFNLGRP_CONNTRACK_EXP_DESTROY =A0NFNLGRP_CONNTRACK_EXP_DES=
TROY
> + =A0 =A0 =A0 NFNLGRP_NFNOTIF,
> +#define NFNLGRP_NFNOTIF =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0NFNLGRP_NFNOTIF
> =A0 =A0 =A0 =A0__NFNLGRP_MAX,
> =A0};
> =A0#define NFNLGRP_MAX =A0 =A0(__NFNLGRP_MAX - 1)
> @@ -47,7 +49,8 @@ struct nfgenmsg {
> =A0#define NFNL_SUBSYS_QUEUE =A0 =A0 =A0 =A0 =A0 =A0 =A03
> =A0#define NFNL_SUBSYS_ULOG =A0 =A0 =A0 =A0 =A0 =A0 =A0 4
> =A0#define NFNL_SUBSYS_OSF =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A05
> -#define NFNL_SUBSYS_COUNT =A0 =A0 =A0 =A0 =A0 =A0 =A06
> +#define NFNL_SUBSYS_NFNOTIF =A0 =A0 =A0 =A0 =A0 =A06
> +#define NFNL_SUBSYS_COUNT =A0 =A0 =A0 =A0 =A0 =A0 =A07
>
> =A0#ifdef __KERNEL__
>
> diff --git a/include/linux/netfilter/nfnetlink_compat.h b/include/lin=
ux/netfilter/nfnetlink_compat.h
> index ffb9503..dca8ab2 100644
> --- a/include/linux/netfilter/nfnetlink_compat.h
> +++ b/include/linux/netfilter/nfnetlink_compat.h
> @@ -13,6 +13,7 @@
> =A0#define NF_NETLINK_CONNTRACK_EXP_NEW =A0 =A0 =A0 =A0 =A0 0x0000000=
8
> =A0#define NF_NETLINK_CONNTRACK_EXP_UPDATE =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A00x00000010
> =A0#define NF_NETLINK_CONNTRACK_EXP_DESTROY =A0 =A0 =A0 0x00000020
> +#define NF_NETLINK_NFNOTIF =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0=
x00000040
>
> =A0/* Generic structure for encapsulation optional netfilter informat=
ion.
> =A0* It is reminiscent of sockaddr, but with sa_family replaced
> diff --git a/include/linux/netfilter/xt_NFNOTIF.h b/include/linux/net=
filter/xt_NFNOTIF.h
> new file mode 100644
> index 0000000..8fae827
> --- /dev/null
> +++ b/include/linux/netfilter/xt_NFNOTIF.h
> @@ -0,0 +1,55 @@
> +/*
> + * linux/include/linux/netfilter/xt_NFNOTIF.h
> + *
> + * Header file for Xtables notification target module.
> + *
> + * Copyright (C) 2010 Intel Corporation
> + * Samuel Ortiz <samuel.ortiz@intel.com>
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License versi=
on
> + * 2 as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. =A0See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
> + * 02110-1301, USA.
> + */
> +
> +#ifndef _XT_NFNOTIF_H
> +#define _XT_NFNOTIF_H
> +
> +#include <linux/types.h>
> +
> +enum nfnotif_msg_type {
> + =A0 =A0 =A0 NFNOTIF_TG_MSG_PACKETS,
> +
> + =A0 =A0 =A0 NFNOTIF_TG_MSG_MAX
> +};
> +
> +enum nfnotif_attr_type {
> + =A0 =A0 =A0 NFNOTIF_TG_ATTR_UNSPEC,
> + =A0 =A0 =A0 NFNOTIF_TG_ATTR_LABEL,
> + =A0 =A0 =A0 NFNOTIF_TG_ATTR_SEND_NOTIF,
> +
> + =A0 =A0 =A0 __NFNOTIF_TG_ATTR_AFTER_LAST
> +};
> +#define NFNOTIF_TG_ATTR_MAX (__NFNOTIF_TG_ATTR_AFTER_LAST - 1)
> +
> +#define MAX_NFNOTIF_LABEL_SIZE 31
> +
> +struct nfnotif_tg_info {
> + =A0 =A0 =A0 __u8 all_packets;
> +
> + =A0 =A0 =A0 char label[MAX_NFNOTIF_LABEL_SIZE];
> +
> + =A0 =A0 =A0 /* for kernel module internal use only */
> + =A0 =A0 =A0 struct nfnotif_tg *notif __attribute((aligned(8)));
> +};
> +
> +#endif
> diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
> index aa2f106..0e2de36 100644
> --- a/net/netfilter/Kconfig
> +++ b/net/netfilter/Kconfig
> @@ -469,6 +469,23 @@ config NETFILTER_XT_TARGET_NFQUEUE
>
> =A0 =A0 =A0 =A0 =A0To compile it as a module, choose M here. =A0If un=
sure, say N.
>
> +config NETFILTER_XT_TARGET_NFNOTIF
> + =A0 =A0 =A0 tristate '"NFNOTIF" target Support'
> + =A0 =A0 =A0 depends on NETFILTER_ADVANCED
> + =A0 =A0 =A0 select NETFILTER_NETLINK
> + =A0 =A0 =A0 help
> +
> + =A0 =A0 =A0 =A0 This option adds the `NFNOTIF' target, which allows=
 to send
> + =A0 =A0 =A0 =A0 netfilter netlink messages when packets hit the tar=
get.
> +
> + =A0 =A0 =A0 =A0 This target comes with an option to specify if one =
wants all
> + =A0 =A0 =A0 =A0 packets hitting the target to trigger the netlink m=
essage
> + =A0 =A0 =A0 =A0 transmission, or only the first one.
> + =A0 =A0 =A0 =A0 It also listen on its netfilter netlink subsystem f=
or messages
> + =A0 =A0 =A0 =A0 allowing to reset the above option.
> +
> + =A0 =A0 =A0 =A0 To compile it as a module, choose M here. =A0If uns=
ure, say N.
> +
> =A0config NETFILTER_XT_TARGET_NOTRACK
> =A0 =A0 =A0 =A0tristate =A0'"NOTRACK" target support'
> =A0 =A0 =A0 =A0depends on IP_NF_RAW || IP6_NF_RAW
> diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
> index e28420a..5d9c9e9 100644
> --- a/net/netfilter/Makefile
> +++ b/net/netfilter/Makefile
> @@ -62,6 +62,7 @@ obj-$(CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP) +=3D =
xt_TCPOPTSTRIP.o
> =A0obj-$(CONFIG_NETFILTER_XT_TARGET_TEE) +=3D xt_TEE.o
> =A0obj-$(CONFIG_NETFILTER_XT_TARGET_TRACE) +=3D xt_TRACE.o
> =A0obj-$(CONFIG_NETFILTER_XT_TARGET_IDLETIMER) +=3D xt_IDLETIMER.o
> +obj-$(CONFIG_NETFILTER_XT_TARGET_NFNOTIF) +=3D xt_NFNOTIF.o
>
> =A0# matches
> =A0obj-$(CONFIG_NETFILTER_XT_MATCH_CLUSTER) +=3D xt_cluster.o
> diff --git a/net/netfilter/xt_NFNOTIF.c b/net/netfilter/xt_NFNOTIF.c
> new file mode 100644
> index 0000000..e6e906b
> --- /dev/null
> +++ b/net/netfilter/xt_NFNOTIF.c
> @@ -0,0 +1,300 @@
> +/*
> + * linux/net/netfilter/xt_NFNOTIF.c
> + *
> + * Copyright (C) 2010 Intel Corporation
> + * Samuel Ortiz <samuel.ortiz@intel.com>
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License versi=
on
> + * 2 as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. =A0See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
> + * 02110-1301, USA.
> + *
> + */
> +
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> +
> +#include <linux/module.h>
> +#include <linux/list.h>
> +#include <linux/mutex.h>
> +#include <linux/netfilter.h>
> +#include <linux/netfilter/x_tables.h>
> +#include <linux/netfilter/nfnetlink.h>
> +#include <linux/netfilter/xt_NFNOTIF.h>
> +
> +struct nfnotif_tg {
> + =A0 =A0 =A0 struct list_head entry;
> + =A0 =A0 =A0 struct work_struct work;
> +
> + =A0 =A0 =A0 char *label;
> + =A0 =A0 =A0 __u8 all_packets;
> + =A0 =A0 =A0 struct net *net;
> +
> + =A0 =A0 =A0 __u8 send_notif;
> +
> + =A0 =A0 =A0 unsigned int refcnt;
> +};
> +
> +static LIST_HEAD(nfnotif_tg_list);
> +static DEFINE_MUTEX(list_mutex);
> +
> +static int __nfnotif_tg_netlink_send(struct nfnotif_tg *nfnotif)
> +{
> + =A0 =A0 =A0 struct nlmsghdr *nlh;
> + =A0 =A0 =A0 struct nfgenmsg *nfmsg;
> + =A0 =A0 =A0 struct sk_buff *skb;
> + =A0 =A0 =A0 struct net *net =3D nfnotif->net;
> + =A0 =A0 =A0 unsigned int type;
> + =A0 =A0 =A0 int flags;
> +
> + =A0 =A0 =A0 type =3D NFNL_SUBSYS_NFNOTIF << 8;
> + =A0 =A0 =A0 flags =3D NLM_F_CREATE;
> +
> + =A0 =A0 =A0 skb =3D nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> + =A0 =A0 =A0 if (skb =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto error_out;
> +
> + =A0 =A0 =A0 nlh =3D nlmsg_put(skb, 0, 0, type, sizeof(*nfmsg), flag=
s);
> + =A0 =A0 =A0 if (nlh =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto nlmsg_put_failure;
> +
> + =A0 =A0 =A0 nfmsg =3D nlmsg_data(nlh);
> + =A0 =A0 =A0 nfmsg->version =A0 =A0 =A0=3D NFNETLINK_V0;
> + =A0 =A0 =A0 nfmsg->res_id =A0 =A0 =A0 =3D 0;
> +
> + =A0 =A0 =A0 NLA_PUT_STRING(skb, NFNOTIF_TG_ATTR_LABEL, nfnotif->lab=
el);
> +
> + =A0 =A0 =A0 nlmsg_end(skb, nlh);
> +
> + =A0 =A0 =A0 return nfnetlink_send(skb, net, 0, NFNLGRP_NFNOTIF, 0, =
GFP_KERNEL);
> +
> +nla_put_failure:
> + =A0 =A0 =A0 nlmsg_cancel(skb, nlh);
> +
> +nlmsg_put_failure:
> + =A0 =A0 =A0 kfree_skb(skb);
> +
> +error_out:
> + =A0 =A0 =A0 return nfnetlink_set_err(net, 0, 0, -ENOBUFS);
> +}
> +
> +static void nfnotif_tg_work(struct work_struct *work)
> +{
> + =A0 =A0 =A0 struct nfnotif_tg *notif =3D container_of(work, struct =
nfnotif_tg, work);
> +
> +
> + =A0 =A0 =A0 if (__nfnotif_tg_netlink_send(notif) < 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_debug("Could not send notification")=
;
> +
> + =A0 =A0 =A0 if (!notif->all_packets)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 notif->send_notif =3D 0;
> +}
> +
> +static struct nfnotif_tg *__nfnotif_tg_find_by_label(const char *lab=
el)
> +{
> + =A0 =A0 =A0 struct nfnotif_tg *entry;
> +
> + =A0 =A0 =A0 BUG_ON(!label);
> +
> + =A0 =A0 =A0 list_for_each_entry(entry, &nfnotif_tg_list, entry) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!strcmp(label, entry->label))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return entry;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return NULL;
> +}
> +
> +static int nfnotif_tg_create(struct nfnotif_tg_info *info)
> +{
> + =A0 =A0 =A0 info->notif =3D kmalloc(sizeof(*info->notif), GFP_KERNE=
L);
> + =A0 =A0 =A0 if (!info->notif) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_debug("Couldn't allocate notificatio=
n\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 info->notif->label =3D kstrdup(info->label, GFP_KERNEL)=
;
> + =A0 =A0 =A0 if (!info->notif->label) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_debug("Couldn't allocate label\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(info->notif);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 info->notif->all_packets =3D info->all_packets;
> + =A0 =A0 =A0 info->notif->send_notif =3D 1;
> +
> + =A0 =A0 =A0 list_add(&info->notif->entry, &nfnotif_tg_list);
> +
> + =A0 =A0 =A0 info->notif->refcnt =3D 1;
> +
> + =A0 =A0 =A0 INIT_WORK(&info->notif->work, nfnotif_tg_work);
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static unsigned int nfnotif_tg_target(struct sk_buff *skb,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 const struct xt_action_param *par)
> +{
> + =A0 =A0 =A0 const struct nfnotif_tg_info *info =3D par->targinfo;
> +
> + =A0 =A0 =A0 BUG_ON(!info->notif);
> +
> + =A0 =A0 =A0 if (!info->notif->send_notif)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return XT_CONTINUE;
> +
> + =A0 =A0 =A0 pr_debug("Sending notification for %s\n", info->label);
> +
> + =A0 =A0 =A0 schedule_work(&info->notif->work);
> +

Why do you use another kernel activity: kernel thread? netlink
messages can be sent in atomic context.

> + =A0 =A0 =A0 return XT_CONTINUE;
> +}
> +
> +static int nfnotif_tg_checkentry(const struct xt_tgchk_param *par)
> +{
> + =A0 =A0 =A0 struct nfnotif_tg_info *info =3D par->targinfo;
> + =A0 =A0 =A0 int ret;
> +
> + =A0 =A0 =A0 pr_debug("Checkentry targinfo %s\n", info->label);
> +
> + =A0 =A0 =A0 if (info->label[0] =3D=3D '\0' ||
> + =A0 =A0 =A0 =A0 =A0 strnlen(info->label,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 MAX_NFNOTIF_LABEL_SIZE) =3D=3D =
MAX_NFNOTIF_LABEL_SIZE) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_debug("Label is empty or not nul-ter=
minated\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 mutex_lock(&list_mutex);
> +
> + =A0 =A0 =A0 info->notif =3D __nfnotif_tg_find_by_label(info->label)=
;
> + =A0 =A0 =A0 if (info->notif) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 info->notif->refcnt++;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_debug("Increased refcnt for %s to %u=
\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0info->label, info->n=
otif->refcnt);
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D nfnotif_tg_create(info);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret < 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_debug("Failed to cre=
ate notification\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_unlock(&list_mute=
x);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 info->notif->net =3D par->net;
> +
> + =A0 =A0 =A0 mutex_unlock(&list_mutex);
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static void nfnotif_tg_destroy(const struct xt_tgdtor_param *par)
> +{
> + =A0 =A0 =A0 const struct nfnotif_tg_info *info =3D par->targinfo;
> +
> + =A0 =A0 =A0 pr_debug("Destroy targinfo %s\n", info->label);
> +
> + =A0 =A0 =A0 mutex_lock(&list_mutex);
> +
> + =A0 =A0 =A0 if (--info->notif->refcnt =3D=3D 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_debug("Deleting notification %s\n", =
info->label);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del(&info->notif->entry);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(info->notif->label);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(info->notif);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 mutex_unlock(&list_mutex);
> +}
> +
> +static struct xt_target nfnotif_tg __read_mostly =3D {
> + =A0 =A0 =A0 .name =A0 =A0 =A0 =A0 =A0 =3D "NFNOTIF",
> + =A0 =A0 =A0 .family =A0 =A0 =A0 =A0 =3D NFPROTO_UNSPEC,
> + =A0 =A0 =A0 .target =A0 =A0 =A0 =A0 =3D nfnotif_tg_target,
> + =A0 =A0 =A0 .targetsize =A0 =A0 =3D sizeof(struct nfnotif_tg_info),
> + =A0 =A0 =A0 .checkentry =A0 =A0 =3D nfnotif_tg_checkentry,
> + =A0 =A0 =A0 .destroy =A0 =A0 =A0 =A0=3D nfnotif_tg_destroy,
> + =A0 =A0 =A0 .me =A0 =A0 =A0 =A0 =A0 =A0 =3D THIS_MODULE,
> +};
> +
> +static int nfnotif_msg_send_notif(struct sock *nfnl, struct sk_buff =
*skb,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 con=
st struct nlmsghdr *nlh,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 con=
st struct nlattr * const attrs[])
> +{
> + =A0 =A0 =A0 struct nfnotif_tg *notif;
> + =A0 =A0 =A0 char *label;
> + =A0 =A0 =A0 u8 send_notif;
> +
> + =A0 =A0 =A0 if (attrs[NFNOTIF_TG_ATTR_LABEL] =3D=3D NULL ||
> + =A0 =A0 =A0 =A0 =A0 attrs[NFNOTIF_TG_ATTR_SEND_NOTIF] =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> +
> + =A0 =A0 =A0 label =3D nla_data(attrs[NFNOTIF_TG_ATTR_LABEL]);
> + =A0 =A0 =A0 send_notif =3D nla_get_u8(attrs[NFNOTIF_TG_ATTR_SEND_NO=
TIF]);
> +
> + =A0 =A0 =A0 pr_debug("Label %s send %d\n", label, send_notif);
> +
> + =A0 =A0 =A0 notif =3D __nfnotif_tg_find_by_label(label);
> + =A0 =A0 =A0 if (notif =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> +
> + =A0 =A0 =A0 notif->send_notif =3D send_notif;
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +
> +static const struct nla_policy nfnotif_nla_policy[NFNOTIF_TG_ATTR_MA=
X + 1] =3D {
> + =A0 =A0 =A0 [NFNOTIF_TG_ATTR_LABEL] =A0 =A0 =A0 =A0 =A0 =A0=3D { .t=
ype =3D NLA_NUL_STRING },
> + =A0 =A0 =A0 [NFNOTIF_TG_ATTR_SEND_NOTIF] =A0 =A0 =A0 =3D { .type =3D=
 NLA_U8 },
> +};
> +
> +static const struct nfnl_callback nfnotif_cb[NFNOTIF_TG_MSG_MAX] =3D=
 {
> + =A0 =A0 =A0 [NFNOTIF_TG_MSG_PACKETS] =A0 =3D { .call =3D nfnotif_ms=
g_send_notif,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0.attr_count =3D NFNOTIF_TG_ATTR_MAX,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0.policy =3D nfnotif_nla_policy },
> +};
> +
> +static const struct nfnetlink_subsystem nfnotif_subsys =3D {
> + =A0 =A0 =A0 .name =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =3D "nfnotif",
> + =A0 =A0 =A0 .subsys_id =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D=
 NFNL_SUBSYS_NFNOTIF,
> + =A0 =A0 =A0 .cb_count =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D=
 NFNOTIF_TG_MSG_MAX,
> + =A0 =A0 =A0 .cb =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =3D nfnotif_cb,
> +};
> +
> +static int __init nfnotif_tg_init(void)
> +{
> + =A0 =A0 =A0 int ret;
> +
> + =A0 =A0 =A0 ret =3D nfnetlink_subsys_register(&nfnotif_subsys);
> + =A0 =A0 =A0 if (ret < 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_err("%s: Cannot register with nfnetl=
ink\n", __func__);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 ret =3D xt_register_target(&nfnotif_tg);
> + =A0 =A0 =A0 if (ret < 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_err("%s: Cannot register target\n", =
__func__);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nfnetlink_subsys_unregister(&nfnotif_su=
bsys);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return ret;
> +}
> +
> +static void __exit nfnotif_tg_exit(void)
> +{
> + =A0 =A0 =A0 nfnetlink_subsys_unregister(&nfnotif_subsys);
> + =A0 =A0 =A0 xt_unregister_target(&nfnotif_tg);
> +}
> +
> +module_init(nfnotif_tg_init);
> +module_exit(nfnotif_tg_exit);
> +
> +MODULE_AUTHOR("Samuel Ortiz <samuel.ortiz@intel.com>");
> +MODULE_DESCRIPTION("Xtables: userspace notification");
> +MODULE_LICENSE("GPL v2");
> --
> 1.7.1
>
> --
> Intel Open Source Technology Centre
> http://oss.intel.com/
> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-d=
evel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>



--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
