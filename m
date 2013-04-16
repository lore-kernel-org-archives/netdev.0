From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [PATCH v3] vxlan: Allow setting destination to unicast address.
Date: Tue, 16 Apr 2013 17:22:14 +0300
Message-ID: <CAF1J0HMi_FmKtyrO_ruADaJjjc9L_ZuNG741C9o6fFGb4g1TMw@mail.gmail.com>
References: <87hajcm7ym.wl%atzm@stratosphere.co.jp>
	<OF3CF233D4.68C04252-ON85257B4E.006F940A-85257B4E.0072C761@us.ibm.com>
	<87a9oyr65c.wl%atzm@stratosphere.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Stevens <dlstevens@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: Atzm Watanabe <atzm@stratosphere.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog111.obsmtp.com ([74.125.245.90]:47490 "HELO
	na3sys010aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S935477Ab3DPOWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 10:22:17 -0400
Received: by mail-ob0-f199.google.com with SMTP id va7so3145214obc.6
        for <netdev@vger.kernel.org>; Tue, 16 Apr 2013 07:22:16 -0700 (PDT)
In-Reply-To: <87a9oyr65c.wl%atzm@stratosphere.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 16, 2013 at 3:50 PM, Atzm Watanabe <atzm@stratosphere.co.jp> wrote:
> At Mon, 15 Apr 2013 16:53:35 -0400,
> David Stevens wrote:
>>
>> netdev-owner@vger.kernel.org wrote on 04/12/2013 05:09:05 AM:
>>
>> > From: Atzm Watanabe <atzm@stratosphere.co.jp>
>>
>> > Signed-off-by: Atzm Watanabe <atzm@stratosphere.co.jp>
>> > ---
>> >  drivers/net/vxlan.c          | 45 +++++++++++++++++++++++++++++++++
>> > +----------
>> >  include/uapi/linux/if_link.h |  1 +
>> >  2 files changed, 36 insertions(+), 10 deletions(-)
>> >
>> > diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
>> > index 9a64715..e468d5a 100644
>> > --- a/drivers/net/vxlan.c
>> > +++ b/drivers/net/vxlan.c
>> > @@ -106,7 +106,7 @@ struct vxlan_dev {
>> >     struct hlist_node hlist;
>> >     struct net_device *dev;
>> >     __u32        vni;      /* virtual network id */
>> > -   __be32             gaddr;   /* multicast group */
>> > +   __be32             daddr;   /* destination address */
>> >     __be32        saddr;   /* source address */
>> >     unsigned int      link;      /* link to multicast over */
>> >     __u16        port_min;   /* source port range */
>>
>>         This is effectively a default forwarding destination when
>> there is no matching fdb entry. As such, I think a fully general
>> patch would convert this to a "vxlan_rdst" and thereby allow alternate
>> port, vni, specific outgoing interface and multiple remote destinations
>> for copies, as via the fdb. And, in the future, support for this being
>> an IPv6 destination, as well. I think the name here, "daddr", ought to
>> reflect some of this too -- maybe "default_dst" or some such?
>
> Yes, right.  I'll replace "gaddr" with "default_dst" as vxlan_rdst.
>
> But to support multiple default destinations, it will need more fixes
> like Mike Rapoport's patch.  Also it will need careful consideration
> about VNI...  I'll try to fix them to support multiple default
> destinations, after the patch is merged.

I can add multiple destinations myself if you'd prefer it that way :)

>> > @@ -1322,6 +1322,7 @@ static const struct nla_policy vxlan_policy
>> > [IFLA_VXLAN_MAX + 1] = {
>> >     [IFLA_VXLAN_RSC]   = { .type = NLA_U8 },
>> >     [IFLA_VXLAN_L2MISS]   = { .type = NLA_U8 },
>> >     [IFLA_VXLAN_L3MISS]   = { .type = NLA_U8 },
>> > +   [IFLA_VXLAN_REMOTE]   = { .len = FIELD_SIZEOF(struct iphdr, daddr)
>> },
>> >  };
>> >
>> >  static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[])
>>
>> I like the name change from "GROUP". "REMOTE" is ok, but might consider
>> "IFLA_VXLAN_DEFAULT_DST" or some such.
>
> Hmm...  I think that "IFLA_VXLAN_DEFAULT_DST" might be confused with
> vxlan_rdst.  So I'll just replace "GROUP" with "REMOTE".
>
> But in the future, to support multiple default destinations,
> "DEFAULT_DST" attribute might be used to add a destination entry :)
>
>
>> > @@ -1347,6 +1348,9 @@ static int vxlan_validate(struct nlattr *tb[],
>> > struct nlattr *data[])
>> >           return -ERANGE;
>> >     }
>> >
>> > +   if (data[IFLA_VXLAN_GROUP] && data[IFLA_VXLAN_REMOTE])
>> > +      return -EINVAL;
>> > +
>> >     if (data[IFLA_VXLAN_GROUP]) {
>> >        __be32 gaddr = nla_get_be32(data[IFLA_VXLAN_GROUP]);
>> >        if (!IN_MULTICAST(ntohl(gaddr))) {
>> > @@ -1355,6 +1359,14 @@ static int vxlan_validate(struct nlattr *tb
>> > [], struct nlattr *data[])
>> >        }
>> >     }
>> >
>> > +   if (data[IFLA_VXLAN_REMOTE]) {
>> > +      __be32 daddr = nla_get_be32(data[IFLA_VXLAN_REMOTE]);
>> > +      if (IN_MULTICAST(ntohl(daddr))) {
>> > +         pr_debug("remote address is not IPv4 unicast\n");
>> > +         return -EADDRNOTAVAIL;
>> > +      }
>> > +   }
>> > +
>> >     if (data[IFLA_VXLAN_PORT_RANGE]) {
>> >        const struct ifla_vxlan_port_range *p
>> >           = nla_data(data[IFLA_VXLAN_PORT_RANGE]);
>>
>> If this is turned into a vxlan_rdst, it should check for other
>> attributes to fill that-- PORT, VNI, IFINDEX-- with approprate
>> default values if not present.
>>
>> Overall, this patch looks ok to me as far as it goes, but I think
>> it'd be more useful if it were more generic; that is, if it supported
>> everything an fdb can.
>
> Thank you for the reviewing!
> I'll fix that mentioned above and resend patches.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Sincerely yours,
Mike.
