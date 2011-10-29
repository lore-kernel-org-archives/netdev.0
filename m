From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [net-next PATCH] net: allow vlan traffic to be received under
 bond
Date: Sat, 29 Oct 2011 18:16:41 +0200
Message-ID: <20111029161640.GB2053@minipsycho.orion>
References: <C8A6796DE7C66C4ABCBC18106CB6C1CC106D903179@ESESSCMS0356.eemea.ericsson.se>
 <4E972301.4030004@intel.com>
 <CAEP_g=9dk_ERdnw4Hw_8RO8Z23E1g2Q9G=AxPkiaVhwbHvo47A@mail.gmail.com>
 <20111018.234723.1235424375699917420.davem@davemloft.net>
 <1319796053.23112.92.camel@edumazet-laptop>
 <1319799986.23112.101.camel@edumazet-laptop>
 <4EAB62F0.2040101@intel.com>
 <1319883746.2586.33.camel@edumazet-laptop>
 <20111029145900.GA2053@minipsycho.orion>
 <1319904026.2586.42.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Fastabend <john.r.fastabend@intel.com>,
	David Miller <davem@davemloft.net>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"hans.schillstrom@ericsson.com" <hans.schillstrom@ericsson.com>,
	"mbizon@freebox.fr" <mbizon@freebox.fr>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"fubar@us.ibm.com" <fubar@us.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25631 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933419Ab1J2QQ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Oct 2011 12:16:57 -0400
Content-Disposition: inline
In-Reply-To: <1319904026.2586.42.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Oct 29, 2011 at 06:00:26PM CEST, eric.dumazet@gmail.com wrote:
>Le samedi 29 octobre 2011 =E0 16:59 +0200, Jiri Pirko a =E9crit :
>> Sat, Oct 29, 2011 at 12:22:26PM CEST, eric.dumazet@gmail.com wrote:
>> >Le vendredi 28 octobre 2011 =E0 19:20 -0700, John Fastabend a =E9cr=
it :
>> >
>> >> Thanks Eric! Thought about this some and I haven't come up
>> >> with anything better yet. Even though this might be a slight
>> >> hack I would prefer this to reverting the patch.
>> >>=20
>> >> I'll think about this more tomorrow. Would you be against
>> >> submitting this patch?
>> >
>> >I cant submit this patch, because its a hack and partial fix.
>> >
>> >For Unicast packets, we still do the wrong thing : setting their
>> >pkt_type to PACKET_OTHERHOST before the call to rx_handler :
>> >
>> >In this case, bond_handle_frame() wont handle this packet correctly=
 in
>> >some cases (BOND_MODE_ALB ...). I suppose bridge might be confused =
as
>> >well. So other problems remain.
>> >
>> >We should delay the PACKET_OTHERHOST setting to the last moment, th=
at is
>> >the last time vlan_do_receive() is called.
>> >
>> >What about following patch instead ?
>> >
>> >[PATCH] vlan: allow nested vlan_do_receive()
>> >
>> >commit 2425717b27eb (net: allow vlan traffic to be received under b=
ond)
>> >broke ARP processing on vlan on top of bonding.
>> >
>> >       +-------+
>> >eth0 --| bond0 |---bond0.103
>> >eth1 --|       |
>> >       +-------+
>> >
>> >52870.115435: skb_gro_reset_offset <-napi_gro_receive
>> >52870.115435: dev_gro_receive <-napi_gro_receive
>> >52870.115435: napi_skb_finish <-napi_gro_receive
>> >52870.115435: netif_receive_skb <-napi_skb_finish
>> >52870.115435: get_rps_cpu <-netif_receive_skb
>> >52870.115435: __netif_receive_skb <-netif_receive_skb
>> >52870.115436: vlan_do_receive <-__netif_receive_skb
>> >52870.115436: bond_handle_frame <-__netif_receive_skb
>> >52870.115436: vlan_do_receive <-__netif_receive_skb
>> >52870.115436: arp_rcv <-__netif_receive_skb
>> >52870.115436: kfree_skb <-arp_rcv
>> >
>> >Packet is dropped in arp_rcv() because its pkt_type was set to
>> >PACKET_OTHERHOST in the first vlan_do_receive() call, since no eth0=
=2E103
>> >exists.
>> >
>> >We really need to change pkt_type only if no more rx_handler is abo=
ut to
>> >be called for the packet.
>> >
>> >Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> >---
>> > include/linux/if_vlan.h |    8 +++++---
>> > net/8021q/vlan_core.c   |    7 +++++--
>> > net/core/dev.c          |    4 ++--
>> > 3 files changed, 12 insertions(+), 7 deletions(-)
>> >
>> >diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
>> >index 44da482..95874ff 100644
>> >--- a/include/linux/if_vlan.h
>> >+++ b/include/linux/if_vlan.h
>> >@@ -106,7 +106,8 @@ extern struct net_device *__vlan_find_dev_deep(=
struct net_device *real_dev,
>> > extern struct net_device *vlan_dev_real_dev(const struct net_devic=
e *dev);
>> > extern u16 vlan_dev_vlan_id(const struct net_device *dev);
>> >=20
>> >-extern bool vlan_do_receive(struct sk_buff **skb);
>> >+extern bool vlan_do_receive(struct sk_buff **skb,
>> >+			    rx_handler_func_t *rx_handler);
>> > extern struct sk_buff *vlan_untag(struct sk_buff *skb);
>> >=20
>> > #else
>> >@@ -128,9 +129,10 @@ static inline u16 vlan_dev_vlan_id(const struc=
t net_device *dev)
>> > 	return 0;
>> > }
>> >=20
>> >-static inline bool vlan_do_receive(struct sk_buff **skb)
>> >+static inline bool vlan_do_receive(struct sk_buff **skb,
>> >+				   rx_handler_func_t *rx_handler)
>> > {
>> >-	if ((*skb)->vlan_tci & VLAN_VID_MASK)
>> >+	if (((*skb)->vlan_tci & VLAN_VID_MASK) && !rx_handler)
>> > 		(*skb)->pkt_type =3D PACKET_OTHERHOST;
>> > 	return false;
>> > }
>> >diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
>> >index f1f2f7b..3ec1ada 100644
>> >--- a/net/8021q/vlan_core.c
>> >+++ b/net/8021q/vlan_core.c
>> >@@ -4,7 +4,7 @@
>> > #include <linux/netpoll.h>
>> > #include "vlan.h"
>> >=20
>> >-bool vlan_do_receive(struct sk_buff **skbp)
>> >+bool vlan_do_receive(struct sk_buff **skbp, rx_handler_func_t *rx_=
handler)
>> > {
>> > 	struct sk_buff *skb =3D *skbp;
>> > 	u16 vlan_id =3D skb->vlan_tci & VLAN_VID_MASK;
>> >@@ -13,7 +13,10 @@ bool vlan_do_receive(struct sk_buff **skbp)
>> >=20
>> > 	vlan_dev =3D vlan_find_dev(skb->dev, vlan_id);
>> > 	if (!vlan_dev) {
>> >-		if (vlan_id)
>> >+		/* Only the last call to vlan_do_receive() should change
>> >+		 * pkt_type to PACKET_OTHERHOST
>> >+		 */
>> >+		if (vlan_id && !rx_handler)
>> > 			skb->pkt_type =3D PACKET_OTHERHOST;
>> > 		return false;
>> > 	}
>> >diff --git a/net/core/dev.c b/net/core/dev.c
>> >index edcf019..40976b4 100644
>> >--- a/net/core/dev.c
>> >+++ b/net/core/dev.c
>> >@@ -3283,18 +3283,18 @@ another_round:
>> > ncls:
>> > #endif
>> >=20
>> >+	rx_handler =3D rcu_dereference(skb->dev->rx_handler);
>> > 	if (vlan_tx_tag_present(skb)) {
>> > 		if (pt_prev) {
>> > 			ret =3D deliver_skb(skb, pt_prev, orig_dev);
>> > 			pt_prev =3D NULL;
>> > 		}
>> >-		if (vlan_do_receive(&skb))
>> >+		if (vlan_do_receive(&skb, rx_handler))
>>=20
>> I must say I do not like passing rx_handler out like this. Apart it'=
s
>> not nice, it might be misleading....
>>=20
>> How about something like following instead? I must test it but I bel=
ieve
>> it should resolve the problem.
>>=20
>>=20
>> diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
>> index 44da482..165a487 100644
>> --- a/include/linux/if_vlan.h
>> +++ b/include/linux/if_vlan.h
>> @@ -130,8 +130,6 @@ static inline u16 vlan_dev_vlan_id(const struct =
net_device *dev)
>> =20
>>  static inline bool vlan_do_receive(struct sk_buff **skb)
>>  {
>> -	if ((*skb)->vlan_tci & VLAN_VID_MASK)
>> -		(*skb)->pkt_type =3D PACKET_OTHERHOST;
>>  	return false;
>>  }
>> =20
>> @@ -141,6 +139,14 @@ static inline struct sk_buff *vlan_untag(struct=
 sk_buff *skb)
>>  }
>>  #endif
>> =20
>> +static inline void vlan_handle_leftover(struct sk_buff *skb)
>> +{
>> +	u16 vlan_id =3D skb->vlan_tci & VLAN_VID_MASK;
>> +
>> +	if (vlan_id)
>> +		skb->pkt_type =3D PACKET_OTHERHOST;
>> +}
>> +
>>  /**
>>   * vlan_insert_tag - regular VLAN tag inserting
>>   * @skb: skbuff to tag
>> diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
>> index f1f2f7b..540da12 100644
>> --- a/net/8021q/vlan_core.c
>> +++ b/net/8021q/vlan_core.c
>> @@ -12,11 +12,8 @@ bool vlan_do_receive(struct sk_buff **skbp)
>>  	struct vlan_pcpu_stats *rx_stats;
>> =20
>>  	vlan_dev =3D vlan_find_dev(skb->dev, vlan_id);
>> -	if (!vlan_dev) {
>> -		if (vlan_id)
>> -			skb->pkt_type =3D PACKET_OTHERHOST;
>> +	if (!vlan_dev)
>>  		return false;
>> -	}
>> =20
>>  	skb =3D *skbp =3D skb_share_check(skb, GFP_ATOMIC);
>>  	if (unlikely(!skb))
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index b7ba81a..6fdfcc9 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -3314,6 +3314,14 @@ ncls:
>>  		}
>>  	}
>> =20
>> +	if (vlan_tx_tag_present(skb)) {
>> +		/*
>> +		 * Tag is still present here. That means there's no device
>> +		 * set up for this vlan id. So handle these leftovers here.
>> +		 */
>> +		vlan_handle_leftover(skb);
>> +	}
>> +
>>  	/* deliver only exact match when indicated */
>>  	null_or_dev =3D deliver_exact ? skb->dev : NULL;
>> =20
>
>Hmm, is it really working ? where vlan_tci is cleared ?

Near the end of vlan_do_receive.

>
>This is indeed nice but adds another test in fast path, while in my
>patch, additional tests are done in slow path only.

Oh, vlan_tx_tag_present() check adds overhead that can be waived upon I
suppose. I think it's better to be nice here...

>
>I see nothing wrong with passing rx_handler : Its probably cleaner tha=
n
>adding rcu_dereference_raw(skb->dev->rx_handler) in the two
>vlan_do_receive() implementations...

Cleaner for sure.

>
>For reference, this was the first patch I had in mind, before I decide=
d
>that caller had to pass the rx_handler instead. (It could be a boolean
>instead)
>
> include/linux/if_vlan.h |    3 ++-
> net/8021q/vlan_core.c   |    5 ++++-
> 2 files changed, 6 insertions(+), 2 deletions(-)
>
>diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
>index 44da482..c6c00b4 100644
>--- a/include/linux/if_vlan.h
>+++ b/include/linux/if_vlan.h
>@@ -130,7 +130,8 @@ static inline u16 vlan_dev_vlan_id(const struct ne=
t_device *dev)
>=20
> static inline bool vlan_do_receive(struct sk_buff **skb)
> {
>-	if ((*skb)->vlan_tci & VLAN_VID_MASK)
>+	if (((*skb)->vlan_tci & VLAN_VID_MASK) &&
>+	    !rcu_dereference_raw((*skb)->dev->rx_handler))
> 		(*skb)->pkt_type =3D PACKET_OTHERHOST;
> 	return false;
> }
>diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
>index f1f2f7b..245efb8 100644
>--- a/net/8021q/vlan_core.c
>+++ b/net/8021q/vlan_core.c
>@@ -13,7 +13,10 @@ bool vlan_do_receive(struct sk_buff **skbp)
>=20
> 	vlan_dev =3D vlan_find_dev(skb->dev, vlan_id);
> 	if (!vlan_dev) {
>-		if (vlan_id)
>+		/* Only the last call to vlan_do_receive() should change
>+		 * pkt_type to PACKET_OTHERHOST
>+		 */
>+		if (vlan_id && !rcu_dereference_raw(skb->dev->rx_handler))
> 			skb->pkt_type =3D PACKET_OTHERHOST;
> 		return false;
> 	}
>
>
