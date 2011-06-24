From: Nick Carter <ncarter100@gmail.com>
Subject: Re: [PATCH] bridge: Forward EAPOL Kconfig option BRIDGE_PAE_FORWARD
Date: Fri, 24 Jun 2011 19:29:41 +0100
Message-ID: <BANLkTi==Ho+6nCX=0hFEQgNAoNE34g35UA@mail.gmail.com>
References: <BANLkTim2G7_pnv5W10Q7kHHCnc2v126fZw@mail.gmail.com>
	<20110623152929.3f94b3e7@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:42019 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751134Ab1FXS3m convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 14:29:42 -0400
Received: by pzk9 with SMTP id 9so1932824pzk.19
        for <netdev@vger.kernel.org>; Fri, 24 Jun 2011 11:29:41 -0700 (PDT)
In-Reply-To: <20110623152929.3f94b3e7@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New diffs below with the Kconfig option removed as requested.

Now all users and distro's will get the correct 802.1x bridge
behaviour by default.  That is EAPOL frames attempting to traverse the
bridge will be dropped (IEEE Std 802.1X-2001 C.3.3).

Users or distro's who want the non-standard behaviour of forwarding
EAPOL frames, can use a simple runtime configuration change to the
sysfs bridge/pae_forward attribute.

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index d9d1e2b..91c1b71 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -214,6 +214,7 @@ static struct net_device *new_bridge_dev(struct
net *net, const char *name)
 	br->topology_change =3D 0;
 	br->topology_change_detected =3D 0;
 	br->ageing_time =3D 300 * HZ;
+	br->pae_forward =3D BR_PAE_DEFAULT;

 	br_netfilter_rtable_init(br);

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 90e985b..edeb92d 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -43,6 +43,16 @@ static int br_pass_frame_up(struct sk_buff *skb)
 		       netif_receive_skb);
 }

+static inline bool br_pae_forward(struct net_bridge *br, __be16 proto)
+{
+	return br->pae_forward =3D=3D BR_PAE_FORWARD && proto =3D=3D htons(ET=
H_P_PAE);
+}
+
+static inline bool br_pae_drop(struct net_bridge *br, __be16 proto)
+{
+	return br->pae_forward =3D=3D BR_PAE_DEFAULT && proto =3D=3D htons(ET=
H_P_PAE);
+}
+
 /* note: already called with rcu_read_lock */
 int br_handle_frame_finish(struct sk_buff *skb)
 {
@@ -98,6 +108,10 @@ int br_handle_frame_finish(struct sk_buff *skb)
 	}

 	if (skb) {
+		/* Prevent Crosstalk (IEEE Std 802.1X-2001 C.3.3) */
+		if (unlikely(br_pae_drop(br, skb->protocol)))
+			goto drop;
+
 		if (dst)
 			br_forward(dst->dst, skb, skb2);
 		else
@@ -166,6 +180,10 @@ struct sk_buff *br_handle_frame(struct sk_buff *sk=
b)
 		if (p->br->stp_enabled =3D=3D BR_NO_STP && dest[5] =3D=3D 0)
 			goto forward;

+		/* Check if PAE frame should be forwarded */
+		if (br_pae_forward(p->br, skb->protocol))
+			goto forward;
+
 		if (NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
 			    NULL, br_handle_local_finish))
 			return NULL;	/* frame consumed by filter */
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 4e1b620..683c057 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -244,6 +244,11 @@ struct net_bridge
 	struct timer_list		multicast_query_timer;
 #endif

+	enum {
+		BR_PAE_DEFAULT,		/* 802.1x frames consumed by bridge */
+		BR_PAE_FORWARD,		/* 802.1x frames forwarded by bridge */
+	} pae_forward;
+
 	struct timer_list		hello_timer;
 	struct timer_list		tcn_timer;
 	struct timer_list		topology_change_timer;
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 5c1e555..9bdbc84 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -679,6 +679,31 @@ static DEVICE_ATTR(nf_call_arptables, S_IRUGO | S_=
IWUSR,
 		   show_nf_call_arptables, store_nf_call_arptables);
 #endif

+static ssize_t show_pae_forward(struct device *d, struct
device_attribute *attr,
+				char *buf)
+{
+	struct net_bridge *br =3D to_bridge(d);
+	return sprintf(buf, "%d\n", br->pae_forward);
+}
+
+static int set_pae_forward(struct net_bridge *br, unsigned long val)
+{
+	if (val > BR_PAE_FORWARD)
+		return -EINVAL;
+
+	br->pae_forward =3D val;
+	return 0;
+}
+
+static ssize_t store_pae_forward(struct device *d,
+				 struct device_attribute *attr, const char *buf,
+				 size_t len)
+{
+	return store_bridge_parm(d, buf, len, set_pae_forward);
+}
+static DEVICE_ATTR(pae_forward, S_IRUGO | S_IWUSR, show_pae_forward,
+		   store_pae_forward);
+
 static struct attribute *bridge_attrs[] =3D {
 	&dev_attr_forward_delay.attr,
 	&dev_attr_hello_time.attr,
@@ -698,6 +723,7 @@ static struct attribute *bridge_attrs[] =3D {
 	&dev_attr_gc_timer.attr,
 	&dev_attr_group_addr.attr,
 	&dev_attr_flush.attr,
+	&dev_attr_pae_forward.attr,
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	&dev_attr_multicast_router.attr,
 	&dev_attr_multicast_snooping.attr,

On 23 June 2011 23:29, Stephen Hemminger
<shemminger@linux-foundation.org> wrote:
> On Thu, 23 Jun 2011 22:39:52 +0100
> Nick Carter <ncarter100@gmail.com> wrote:
>
>> Signed-off-by: Nick Carter <ncarter100@gmail.com>
>>
>> This Kconfig option is used to enable a bridge to forward 802.1x
>> (EAPOL) Port Access Entity (PAE) frames. =A0One use of this would be=
 to
>> enable 802.1x authentication between a PAE supplicant running inside=
 a
>> virtual machine, with the EAPOL frames bridged out to an external PA=
E
>> authenticator.
>>
>> If BRIDGE_PAE_FORWARD is not set the behaviour of bridge.ko is uncha=
nged.
>>
>> If BRIDGE_PAE_FORWARD is set then by default the only new behaviour =
is
>> that unicast EAPOL frames attempting to traverse the bridge will be
>> dropped. =A0This makes the bridge standards compliant by preventing
>> crosstalk (IEEE Std 802.1X-2001 C.3.3).
>>
>> Writing a 1 to the new sysfs attribute ../bridge/pae_forward will
>> enable the forwarding of EAPOL frames, both unicast and link local
>> multicast (01-80-C2-00-00-03).
>>
>> diff --git a/net/bridge/Kconfig b/net/bridge/Kconfig
>> index 6dee7bf..c47a49e 100644
>> --- a/net/bridge/Kconfig
>> +++ b/net/bridge/Kconfig
>> @@ -46,3 +46,22 @@ config BRIDGE_IGMP_SNOOPING
>> =A0 =A0 =A0 =A0 Say N to exclude this support and reduce the binary =
size.
>>
>> =A0 =A0 =A0 =A0 If unsure, say Y.
>> +
>> +config BRIDGE_PAE_FORWARD
>> + =A0 =A0 bool "PAE Forwarding"
>> + =A0 =A0 depends on BRIDGE
>> + =A0 =A0 default n
>> + =A0 =A0 ---help---
>> + =A0 =A0 =A0 If you say Y here, then the Ethernet bridge will be ab=
le to forward
>> + =A0 =A0 =A0 802.1x (EAPOL) Port Access Entity (PAE) frames. =A0One=
 use of this would
>> + =A0 =A0 =A0 be to enable 802.1x authentication between a PAE suppl=
icant running
>> + =A0 =A0 =A0 inside a virtual machine, with the EAPOL frames bridge=
d out to an
>> + =A0 =A0 =A0 external PAE authenticator.
>> +
>> + =A0 =A0 =A0 On a running kernel with this support, enable PAE forw=
arding by
>> + =A0 =A0 =A0 writing a '1' to the bridge devices pae_forward attrib=
ute.
>> + =A0 =A0 =A0 e.g. echo 1 > /sys/devices/virtual/net/br73/bridge/pae=
_forward
>> +
>> + =A0 =A0 =A0 Say N to exclude this support.
>> +
>> + =A0 =A0 =A0 If unsure, say N.
>> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
>> index d9d1e2b..b493474 100644
>> --- a/net/bridge/br_if.c
>> +++ b/net/bridge/br_if.c
>> @@ -214,6 +214,9 @@ static struct net_device *new_bridge_dev(struct
>> net *net, const char *name)
>> =A0 =A0 =A0 br->topology_change =3D 0;
>> =A0 =A0 =A0 br->topology_change_detected =3D 0;
>> =A0 =A0 =A0 br->ageing_time =3D 300 * HZ;
>> +#ifdef CONFIG_BRIDGE_PAE_FORWARD
>> + =A0 =A0 br->pae_forward =3D BR_PAE_DEFAULT;
>> +#endif
>>
>> =A0 =A0 =A0 br_netfilter_rtable_init(br);
>>
>> diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
>> index 90e985b..183c40f 100644
>> --- a/net/bridge/br_input.c
>> +++ b/net/bridge/br_input.c
>> @@ -43,6 +43,24 @@ static int br_pass_frame_up(struct sk_buff *skb)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0netif_receive_skb);
>> =A0}
>>
>> +static inline bool br_pae_forward(struct net_bridge *br, __be16 pro=
to)
>> +{
>> +#ifdef CONFIG_BRIDGE_PAE_FORWARD
>> + =A0 =A0 return br->pae_forward =3D=3D BR_PAE_FORWARD && proto =3D=3D=
 htons(ETH_P_PAE);
>> +#else
>> + =A0 =A0 return false;
>> +#endif
>> +}
>> +
>> +static inline bool br_pae_drop(struct net_bridge *br, __be16 proto)
>> +{
>> +#ifdef CONFIG_BRIDGE_PAE_FORWARD
>> + =A0 =A0 return br->pae_forward =3D=3D BR_PAE_DEFAULT && proto =3D=3D=
 htons(ETH_P_PAE);
>> +#else
>> + =A0 =A0 return false;
>> +#endif
>> +}
>> +
>> =A0/* note: already called with rcu_read_lock */
>> =A0int br_handle_frame_finish(struct sk_buff *skb)
>> =A0{
>> @@ -98,6 +116,10 @@ int br_handle_frame_finish(struct sk_buff *skb)
>> =A0 =A0 =A0 }
>>
>> =A0 =A0 =A0 if (skb) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* Prevent Crosstalk (IEEE Std 802.1X-2001=
 C.3.3) */
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(br_pae_drop(br, skb->protocol=
)))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto drop;
>> +
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (dst)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 br_forward(dst->dst, skb=
, skb2);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
>> @@ -166,6 +188,10 @@ struct sk_buff *br_handle_frame(struct sk_buff =
*skb)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (p->br->stp_enabled =3D=3D BR_NO_STP =
&& dest[5] =3D=3D 0)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto forward;
>>
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* Check if PAE frame should be forwarded =
*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (br_pae_forward(p->br, skb->protocol))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto forward;
>> +
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_=
IN, skb, skb->dev,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NULL, br_handle_=
local_finish))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL; =A0 =A0/* f=
rame consumed by filter */
>> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
>> index 4e1b620..a523032 100644
>> --- a/net/bridge/br_private.h
>> +++ b/net/bridge/br_private.h
>> @@ -244,6 +244,13 @@ struct net_bridge
>> =A0 =A0 =A0 struct timer_list =A0 =A0 =A0 =A0 =A0 =A0 =A0 multicast_=
query_timer;
>> =A0#endif
>>
>> +#ifdef CONFIG_BRIDGE_PAE_FORWARD
>> + =A0 =A0 enum {
>> + =A0 =A0 =A0 =A0 =A0 =A0 BR_PAE_DEFAULT, =A0 =A0 =A0 =A0 /* 802.1x =
frames consumed by bridge */
>> + =A0 =A0 =A0 =A0 =A0 =A0 BR_PAE_FORWARD, =A0 =A0 =A0 =A0 /* 802.1x =
frames forwarded by bridge */
>> + =A0 =A0 } pae_forward;
>> +#endif
>> +
>> =A0 =A0 =A0 struct timer_list =A0 =A0 =A0 =A0 =A0 =A0 =A0 hello_time=
r;
>> =A0 =A0 =A0 struct timer_list =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcn_timer;
>> =A0 =A0 =A0 struct timer_list =A0 =A0 =A0 =A0 =A0 =A0 =A0 topology_c=
hange_timer;
>> diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
>> index 5c1e555..c5ffd97 100644
>> --- a/net/bridge/br_sysfs_br.c
>> +++ b/net/bridge/br_sysfs_br.c
>> @@ -679,6 +679,33 @@ static DEVICE_ATTR(nf_call_arptables, S_IRUGO |=
 S_IWUSR,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0show_nf_call_arptables, store_nf_=
call_arptables);
>> =A0#endif
>>
>> +#ifdef CONFIG_BRIDGE_PAE_FORWARD
>> +static ssize_t show_pae_forward(struct device *d, struct
>> device_attribute *attr,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 char *buf)
>> +{
>> + =A0 =A0 struct net_bridge *br =3D to_bridge(d);
>> + =A0 =A0 return sprintf(buf, "%d\n", br->pae_forward);
>> +}
>> +
>> +static int set_pae_forward(struct net_bridge *br, unsigned long val=
)
>> +{
>> + =A0 =A0 if (val > BR_PAE_FORWARD)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
>> +
>> + =A0 =A0 br->pae_forward =3D val;
>> + =A0 =A0 return 0;
>> +}
>> +
>> +static ssize_t store_pae_forward(struct device *d,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct =
device_attribute *attr, const char *buf,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0size_t =
len)
>> +{
>> + =A0 =A0 return store_bridge_parm(d, buf, len, set_pae_forward);
>> +}
>> +static DEVICE_ATTR(pae_forward, S_IRUGO | S_IWUSR, show_pae_forward=
,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0store_pae_forward);
>> +#endif
>> +
>> =A0static struct attribute *bridge_attrs[] =3D {
>> =A0 =A0 =A0 &dev_attr_forward_delay.attr,
>> =A0 =A0 =A0 &dev_attr_hello_time.attr,
>> @@ -717,6 +744,9 @@ static struct attribute *bridge_attrs[] =3D {
>> =A0 =A0 =A0 &dev_attr_nf_call_ip6tables.attr,
>> =A0 =A0 =A0 &dev_attr_nf_call_arptables.attr,
>> =A0#endif
>> +#ifdef CONFIG_BRIDGE_PAE_FORWARD
>> + =A0 =A0 &dev_attr_pae_forward.attr,
>> +#endif
>> =A0 =A0 =A0 NULL
>> =A0};
>
> Don't make it a config option, users and distros won't get it right.
> The bridge already makes special case for multicast, why not add
> some smarts and always do it.
>
