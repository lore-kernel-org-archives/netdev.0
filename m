From: Nick Carter <ncarter100@gmail.com>
Subject: Re: [PATCH] bridge: mask forwarding of IEEE 802 local multicast groups
Date: Sun, 10 Jul 2011 17:04:30 +0100
Message-ID: <CAEJpZP1cr4B9qX6gH9O4iXwWvEdxs2aebL21FnX1BE0dJPHrEw@mail.gmail.com>
References: <BANLkTi=jnxBu6WzAOTxHD+e_O1qYKE2m=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net
To: netdev@vger.kernel.org,
	=?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>,
	David Lamparter <equinox@diac24.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:45604 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753492Ab1GJQEc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jul 2011 12:04:32 -0400
Received: by pvg12 with SMTP id 12so2167653pvg.19
        for <netdev@vger.kernel.org>; Sun, 10 Jul 2011 09:04:31 -0700 (PDT)
In-Reply-To: <BANLkTi=jnxBu6WzAOTxHD+e_O1qYKE2m=g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Updated diffs so they apply to net-next (Original diffs were based off =
2.6.38).

Any chance of getting these diffs applied?  The default behaviour of
the bridge code is unchanged.  They solve the problem of
authenticating a virtual 802.1x supplicant machine against an external
802.1X authenticator.  It is also a general solution that allows the
forwarding of any combination of the IEEE 802 local multicast groups.

Signed-off-by: Nick Carter <ncarter100@gmail.com>
Reviewed-by: David Lamparter <equinox@diac24.net>

 net/bridge/br_device.c   |    1 +
 net/bridge/br_input.c    |    3 +++
 net/bridge/br_private.h  |    8 ++++++++
 net/bridge/br_sysfs_br.c |   23 +++++++++++++++++++++++
 4 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 32b8f9f..573ed8c 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -366,6 +366,7 @@ void br_dev_setup(struct net_device *dev)
 	br->bridge_hello_time =3D br->hello_time =3D 2 * HZ;
 	br->bridge_forward_delay =3D br->forward_delay =3D 15 * HZ;
 	br->ageing_time =3D 300 * HZ;
+	br->group_fwd_mask =3D 0;

 	br_netfilter_rtable_init(br);
 	br_stp_timer_init(br);
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index f06ee39..3bee262 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -170,6 +170,9 @@ rx_handler_result_t br_handle_frame(struct sk_buff =
**pskb)
 		if (p->br->stp_enabled =3D=3D BR_NO_STP && dest[5] =3D=3D 0)
 			goto forward;

+		if (p->br->group_fwd_mask & (1 << dest[5]))
+			goto forward;
+
 		if (NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
 			    NULL, br_handle_local_finish)) {
 			return RX_HANDLER_CONSUMED; /* consumed by filter */
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 54578f2..413fcec 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -244,6 +244,14 @@ struct net_bridge
 	struct timer_list		multicast_query_timer;
 #endif

+	/* Each bit used to match the least significant nibble of the
+	 * IEEE 802.1D group address.
+	 * 01-80-C2-00-00-00 bit 0
+	 * ..
+	 * 01-80-C2-00-00-0F bit 15
+	 */
+	u16				group_fwd_mask;
+
 	struct timer_list		hello_timer;
 	struct timer_list		tcn_timer;
 	struct timer_list		topology_change_timer;
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 68b893e..d77f681 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -646,6 +646,28 @@ static DEVICE_ATTR(nf_call_arptables, S_IRUGO | S_=
IWUSR,
 		   show_nf_call_arptables, store_nf_call_arptables);
 #endif

+static ssize_t show_group_fwd_mask(struct device *d,
+				   struct device_attribute *attr, char *buf)
+{
+	struct net_bridge *br =3D to_bridge(d);
+	return sprintf(buf, "%d\n", br->group_fwd_mask);
+}
+
+static int set_group_fwd_mask(struct net_bridge *br, unsigned long val=
)
+{
+	br->group_fwd_mask =3D (u16)val;
+	return 0;
+}
+
+static ssize_t store_group_fwd_mask(struct device *d,
+				    struct device_attribute *attr,
+				    const char *buf, size_t len)
+{
+	return store_bridge_parm(d, buf, len, set_group_fwd_mask);
+}
+static DEVICE_ATTR(group_fwd_mask, S_IRUGO | S_IWUSR, show_group_fwd_m=
ask,
+		   store_group_fwd_mask);
+
 static struct attribute *bridge_attrs[] =3D {
 	&dev_attr_forward_delay.attr,
 	&dev_attr_hello_time.attr,
@@ -665,6 +687,7 @@ static struct attribute *bridge_attrs[] =3D {
 	&dev_attr_gc_timer.attr,
 	&dev_attr_group_addr.attr,
 	&dev_attr_flush.attr,
+	&dev_attr_group_fwd_mask.attr,
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	&dev_attr_multicast_router.attr,
 	&dev_attr_multicast_snooping.attr,

On 1 July 2011 22:21, Nick Carter <ncarter100@gmail.com> wrote:
> Introduce sysfs ../bridge/group_fwd_mask attribute so users can
> configure which group mac addresses are forwarded.
>
> These diffs do not change the default behaviour of bridge.ko. =A0By
> changing the group_fwd_mask value users can select any combination of
> the 01-80-C2-00-00-00 - 01-80-C2-00-00-0F addresses to be forwarded.
>
> Signed-off-by: Nick Carter <ncarter100@gmail.com>
>
> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> index d9d1e2b..bb25e49 100644
> --- a/net/bridge/br_if.c
> +++ b/net/bridge/br_if.c
> @@ -214,6 +214,7 @@ static struct net_device *new_bridge_dev(struct
> net *net, const char *name)
> =A0 =A0 =A0 =A0br->topology_change =3D 0;
> =A0 =A0 =A0 =A0br->topology_change_detected =3D 0;
> =A0 =A0 =A0 =A0br->ageing_time =3D 300 * HZ;
> + =A0 =A0 =A0 br->group_fwd_mask =3D 0;
>
> =A0 =A0 =A0 =A0br_netfilter_rtable_init(br);
>
> diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
> index 90e985b..80b94f4 100644
> --- a/net/bridge/br_input.c
> +++ b/net/bridge/br_input.c
> @@ -166,6 +166,9 @@ struct sk_buff *br_handle_frame(struct sk_buff *s=
kb)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (p->br->stp_enabled =3D=3D BR_NO_ST=
P && dest[5] =3D=3D 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto forward;
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (p->br->group_fwd_mask & (1 << dest[=
5]))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto forward;
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCA=
L_IN, skb, skb->dev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0NULL, br_handl=
e_local_finish))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NULL; =A0 =A0/*=
 frame consumed by filter */
> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> index 4e1b620..d5aa164 100644
> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -244,6 +244,13 @@ struct net_bridge
> =A0 =A0 =A0 =A0struct timer_list =A0 =A0 =A0 =A0 =A0 =A0 =A0 multicas=
t_query_timer;
> =A0#endif
>
> + =A0 =A0 =A0 /* Each bit used to match the LSB of the IEEE 802.1D gr=
oup address
> + =A0 =A0 =A0 =A0* 01-80-C2-00-00-00 bit 0
> + =A0 =A0 =A0 =A0* ..
> + =A0 =A0 =A0 =A0* 01-80-C2-00-00-0F bit 15
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 u16 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 group_fwd_mask;
> +
> =A0 =A0 =A0 =A0struct timer_list =A0 =A0 =A0 =A0 =A0 =A0 =A0 hello_ti=
mer;
> =A0 =A0 =A0 =A0struct timer_list =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcn_time=
r;
> =A0 =A0 =A0 =A0struct timer_list =A0 =A0 =A0 =A0 =A0 =A0 =A0 topology=
_change_timer;
> diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
> index 5c1e555..f3cced5 100644
> --- a/net/bridge/br_sysfs_br.c
> +++ b/net/bridge/br_sysfs_br.c
> @@ -679,6 +679,28 @@ static DEVICE_ATTR(nf_call_arptables, S_IRUGO | =
S_IWUSR,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 show_nf_call_arptables, store_nf_=
call_arptables);
> =A0#endif
>
> +static ssize_t show_group_fwd_mask(struct device *d, struct
> device_attribute *attr,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 char *b=
uf)
> +{
> + =A0 =A0 =A0 struct net_bridge *br =3D to_bridge(d);
> + =A0 =A0 =A0 return sprintf(buf, "%d\n", br->group_fwd_mask);
> +}
> +
> +static int set_group_fwd_mask(struct net_bridge *br, unsigned long v=
al)
> +{
> + =A0 =A0 =A0 br->group_fwd_mask =3D (u16)val;
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static ssize_t store_group_fwd_mask(struct device *d,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stru=
ct device_attribute *attr, const char *buf,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0size=
_t len)
> +{
> + =A0 =A0 =A0 return store_bridge_parm(d, buf, len, set_group_fwd_mas=
k);
> +}
> +static DEVICE_ATTR(group_fwd_mask, S_IRUGO | S_IWUSR, show_group_fwd=
_mask,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0store_group_fwd_mask);
> +
> =A0static struct attribute *bridge_attrs[] =3D {
> =A0 =A0 =A0 =A0&dev_attr_forward_delay.attr,
> =A0 =A0 =A0 =A0&dev_attr_hello_time.attr,
> @@ -698,6 +720,7 @@ static struct attribute *bridge_attrs[] =3D {
> =A0 =A0 =A0 =A0&dev_attr_gc_timer.attr,
> =A0 =A0 =A0 =A0&dev_attr_group_addr.attr,
> =A0 =A0 =A0 =A0&dev_attr_flush.attr,
> + =A0 =A0 =A0 &dev_attr_group_fwd_mask.attr,
> =A0#ifdef CONFIG_BRIDGE_IGMP_SNOOPING
> =A0 =A0 =A0 =A0&dev_attr_multicast_router.attr,
> =A0 =A0 =A0 =A0&dev_attr_multicast_snooping.attr,
>
