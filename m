From: Nick Carter <ncarter100@gmail.com>
Subject: Re: [PATCH] bridge: Forward EAPOL Kconfig option BRIDGE_PAE_FORWARD
Date: Fri, 24 Jun 2011 22:29:00 +0100
Message-ID: <BANLkTin4XOCmpFaETsjkYb2kk+psZUBKcA@mail.gmail.com>
References: <BANLkTim2G7_pnv5W10Q7kHHCnc2v126fZw@mail.gmail.com>
	<20110623152929.3f94b3e7@nehalam.ftrdhcpuser.net>
	<BANLkTi==Ho+6nCX=0hFEQgNAoNE34g35UA@mail.gmail.com>
	<20110624120859.3c43bbcb@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f51.google.com ([209.85.210.51]:54923 "EHLO
	mail-pz0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752945Ab1FXV3B convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 17:29:01 -0400
Received: by mail-pz0-f51.google.com with SMTP id 26so2088128pzk.10
        for <netdev@vger.kernel.org>; Fri, 24 Jun 2011 14:29:01 -0700 (PDT)
In-Reply-To: <20110624120859.3c43bbcb@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24 June 2011 20:08, Stephen Hemminger
<shemminger@linux-foundation.org> wrote:
> On Fri, 24 Jun 2011 19:29:41 +0100
> Nick Carter <ncarter100@gmail.com> wrote:
>
>> New diffs below with the Kconfig option removed as requested.
>>
>> Now all users and distro's will get the correct 802.1x bridge
>> behaviour by default. =A0That is EAPOL frames attempting to traverse=
 the
>> bridge will be dropped (IEEE Std 802.1X-2001 C.3.3).
>>
>> Users or distro's who want the non-standard behaviour of forwarding
>> EAPOL frames, can use a simple runtime configuration change to the
>> sysfs bridge/pae_forward attribute.
>
> This is much better, thanks.
> See the comments for how to make the code more compact and tighter.
>
>> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
>> index d9d1e2b..91c1b71 100644
>> --- a/net/bridge/br_if.c
>> +++ b/net/bridge/br_if.c
>> @@ -214,6 +214,7 @@ static struct net_device *new_bridge_dev(struct
>> net *net, const char *name)
>> =A0 =A0 =A0 br->topology_change =3D 0;
>> =A0 =A0 =A0 br->topology_change_detected =3D 0;
>> =A0 =A0 =A0 br->ageing_time =3D 300 * HZ;
>> + =A0 =A0 br->pae_forward =3D BR_PAE_DEFAULT;
>
> It is just a boolean, why the verbose enum values?
In case we want BR_PAE_<foo> in the future, not that I can think of a
3rd option now.  So happy to change to a boolean.
>
>> =A0 =A0 =A0 br_netfilter_rtable_init(br);
>>
>> diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
>> index 90e985b..edeb92d 100644
>> --- a/net/bridge/br_input.c
>> +++ b/net/bridge/br_input.c
>> @@ -43,6 +43,16 @@ static int br_pass_frame_up(struct sk_buff *skb)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0netif_receive_skb);
>> =A0}
>>
>> +static inline bool br_pae_forward(struct net_bridge *br, __be16 pro=
to)
>> +{
>> + =A0 =A0 return br->pae_forward =3D=3D BR_PAE_FORWARD && proto =3D=3D=
 htons(ETH_P_PAE);
>> +}
>> +
>> +static inline bool br_pae_drop(struct net_bridge *br, __be16 proto)
>> +{
>> + =A0 =A0 return br->pae_forward =3D=3D BR_PAE_DEFAULT && proto =3D=3D=
 htons(ETH_P_PAE);
>> +}
>
> Since only used one place, the extra wrappers aren't helping.
I thought they helped readability, but certainly for performance we
should only be doing each check once in a single place.  Again happy
to change.
>
>> =A0/* note: already called with rcu_read_lock */
>> =A0int br_handle_frame_finish(struct sk_buff *skb)
>> =A0{
>> @@ -98,6 +108,10 @@ int br_handle_frame_finish(struct sk_buff *skb)
>> =A0 =A0 =A0 }
>>
>> =A0 =A0 =A0 if (skb) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* Prevent Crosstalk (IEEE Std 802.1X-2001=
 C.3.3) */
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(br_pae_drop(br, skb->protocol=
)))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto drop;
>> +
>
> Referencing standard is good, but perhaps explaining what that means.
ok

> Since these are multicast frames, will it ever reach this point.
> This point is reached for unicast frames that are not local.
yes, think of it as a bug fix rather than part of new functionality

> And won't this change existing behavior since before this 802.1x unic=
ast
> frames would be forwarded.
Yes, that was my original motivation for making it a Kconfig setting,
so there would be no chance of regressions.  But keep in mind that
802.1x handshake must start with a multicast.  Its only if that
multicast is delivered that the reply can be unicast.  So any one
relying on the existing behaviour of forwarding unicast 802.1x must be
doing something very strange and non-standard.  I can't imagine what.
If there is a valid use case then they now have the simple workaround
of enabling pae forwarding.

>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (dst)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 br_forward(dst->dst, skb=
, skb2);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
>> @@ -166,6 +180,10 @@ struct sk_buff *br_handle_frame(struct sk_buff =
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
>> index 4e1b620..683c057 100644
>> --- a/net/bridge/br_private.h
>> +++ b/net/bridge/br_private.h
>> @@ -244,6 +244,11 @@ struct net_bridge
>> =A0 =A0 =A0 struct timer_list =A0 =A0 =A0 =A0 =A0 =A0 =A0 multicast_=
query_timer;
>> =A0#endif
>>
>> + =A0 =A0 enum {
>> + =A0 =A0 =A0 =A0 =A0 =A0 BR_PAE_DEFAULT, =A0 =A0 =A0 =A0 /* 802.1x =
frames consumed by bridge */
>> + =A0 =A0 =A0 =A0 =A0 =A0 BR_PAE_FORWARD, =A0 =A0 =A0 =A0 /* 802.1x =
frames forwarded by bridge */
>> + =A0 =A0 } pae_forward;
>> +
>> =A0 =A0 =A0 struct timer_list =A0 =A0 =A0 =A0 =A0 =A0 =A0 hello_time=
r;
>> =A0 =A0 =A0 struct timer_list =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcn_timer;
>> =A0 =A0 =A0 struct timer_list =A0 =A0 =A0 =A0 =A0 =A0 =A0 topology_c=
hange_timer;
>> diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
>> index 5c1e555..9bdbc84 100644
>> --- a/net/bridge/br_sysfs_br.c
>> +++ b/net/bridge/br_sysfs_br.c
>> @@ -679,6 +679,31 @@ static DEVICE_ATTR(nf_call_arptables, S_IRUGO |=
 S_IWUSR,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0show_nf_call_arptables, store_nf_=
call_arptables);
>> =A0#endif
>>
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
>> +
>> =A0static struct attribute *bridge_attrs[] =3D {
>> =A0 =A0 =A0 &dev_attr_forward_delay.attr,
>> =A0 =A0 =A0 &dev_attr_hello_time.attr,
>> @@ -698,6 +723,7 @@ static struct attribute *bridge_attrs[] =3D {
>> =A0 =A0 =A0 &dev_attr_gc_timer.attr,
>> =A0 =A0 =A0 &dev_attr_group_addr.attr,
>> =A0 =A0 =A0 &dev_attr_flush.attr,
>> + =A0 =A0 &dev_attr_pae_forward.attr,
>> =A0#ifdef CONFIG_BRIDGE_IGMP_SNOOPING
>> =A0 =A0 =A0 &dev_attr_multicast_router.attr,
>> =A0 =A0 =A0 &dev_attr_multicast_snooping.attr,
>
>
