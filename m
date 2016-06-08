From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: Re: [PATCH net-next] net: ipv4: Add ability to have GRE ignore DF bit in IPv4 payloads
Date: Tue, 7 Jun 2016 21:28:42 -0600
Message-ID: <C4BC2AFC-E0C4-4E6D-959F-B482D8935020@redfish-solutions.com>
References: <20160607194846.11494-1-philipp@redfish-solutions.com> <CAKgT0UdCVQ3fQZk8s2f+guSypKYZrHaR6t+Vh0jvx6pQj41yEw@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:58190 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161119AbcFHD2o convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2016 23:28:44 -0400
In-Reply-To: <CAKgT0UdCVQ3fQZk8s2f+guSypKYZrHaR6t+Vh0jvx6pQj41yEw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Jun 7, 2016, at 9:22 PM, Alexander Duyck <alexander.duyck@gmail.co=
m> wrote:
>=20
> On Tue, Jun 7, 2016 at 12:48 PM, Philip Prindeville
> <philipp@redfish-solutions.com> wrote:
>> From: Philip Prindeville <philipp@redfish-solutions.com>
>>=20
>> In the presence of firewalls which improperly block ICMP Unreachable
>> (including Fragmentation Required) messages, Path MTU Discovery is
>> prevented from working.
>>=20
>> A workaround is to handle IPv4 payloads opaquely, ignoring the DF bi=
t--as
>> is done for other payloads like AppleTalk--and doing transparent
>> fragmentation and reassembly.
>>=20
>> Reviewed-by: Stephen Hemminger <stephen@networkplumber.org>
>> Signed-off-by: Philip Prindeville <philipp@redfish-solutions.com>
>> ---
>> include/net/ip_tunnels.h       |    1 +
>> include/uapi/linux/if_tunnel.h |    1 +
>> net/ipv4/ip_gre.c              |   13 +++++++++++--
>> net/ipv4/ip_tunnel.c           |    2 +-
>> 4 files changed, 14 insertions(+), 3 deletions(-)
>>=20
>> diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
>> index dbf4444..9222678 100644
>> --- a/include/net/ip_tunnels.h
>> +++ b/include/net/ip_tunnels.h
>> @@ -132,6 +132,7 @@ struct ip_tunnel {
>>        int                     ip_tnl_net_id;
>>        struct gro_cells        gro_cells;
>>        bool                    collect_md;
>> +       bool                    ignore_df;
>> };
>>=20
>> #define TUNNEL_CSUM            __cpu_to_be16(0x01)
>> diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_=
tunnel.h
>> index af4de90..1046f55 100644
>> --- a/include/uapi/linux/if_tunnel.h
>> +++ b/include/uapi/linux/if_tunnel.h
>> @@ -113,6 +113,7 @@ enum {
>>        IFLA_GRE_ENCAP_SPORT,
>>        IFLA_GRE_ENCAP_DPORT,
>>        IFLA_GRE_COLLECT_METADATA,
>> +       IFLA_GRE_IGNORE_DF,
>>        __IFLA_GRE_MAX,
>> };
>>=20
>> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
>> index 4d2025f..cbeecfb 100644
>> --- a/net/ipv4/ip_gre.c
>> +++ b/net/ipv4/ip_gre.c
>> @@ -846,6 +846,8 @@ static void ipgre_netlink_parms(struct net_devic=
e *dev,
>>                                struct nlattr *tb[],
>>                                struct ip_tunnel_parm *parms)
>> {
>> +       struct ip_tunnel *t =3D netdev_priv(dev);
>> +
>>        memset(parms, 0, sizeof(*parms));
>>=20
>>        parms->iph.protocol =3D IPPROTO_GRE;
>> @@ -884,12 +886,13 @@ static void ipgre_netlink_parms(struct net_dev=
ice *dev,
>>                parms->iph.frag_off =3D htons(IP_DF);
>>=20
>>        if (data[IFLA_GRE_COLLECT_METADATA]) {
>> -               struct ip_tunnel *t =3D netdev_priv(dev);
>> -
>>                t->collect_md =3D true;
>>                if (dev->type =3D=3D ARPHRD_IPGRE)
>>                        dev->type =3D ARPHRD_NONE;
>>        }
>> +
>> +       if (data[IFLA_GRE_IGNORE_DF])
>> +               t->ignore_df =3D !!nla_get_u8(data[IFLA_GRE_IGNORE_D=
=46]);
>=20
> Why are you passing this as a u8?  Why not just pass it as a flag
> since it defaults to off?
>=20
>> }
>>=20
>> /* This function returns true when ENCAP attributes are present in t=
he nl msg */
>> @@ -1024,6 +1027,8 @@ static size_t ipgre_get_size(const struct net_=
device *dev)
>>                nla_total_size(2) +
>>                /* IFLA_GRE_COLLECT_METADATA */
>>                nla_total_size(0) +
>> +               /* IFLA_GRE_IGNORE_DF */
>> +               nla_total_size(1) +
>>                0;
>> }
>=20
> Switching it to a flag would help reduce the total size.
>=20
>> @@ -1057,6 +1062,9 @@ static int ipgre_fill_info(struct sk_buff *skb=
, const struct net_device *dev)
>>                        t->encap.flags))
>>                goto nla_put_failure;
>>=20
>> +       if (nla_put_u8(skb, IFLA_GRE_IGNORE_DF, t->ignore_df))
>> +               goto nla_put_failure;
>> +
>>        if (t->collect_md) {
>>                if (nla_put_flag(skb, IFLA_GRE_COLLECT_METADATA))
>>                        goto nla_put_failure;
>> @@ -1084,6 +1092,7 @@ static const struct nla_policy ipgre_policy[IF=
LA_GRE_MAX + 1] =3D {
>>        [IFLA_GRE_ENCAP_SPORT]  =3D { .type =3D NLA_U16 },
>>        [IFLA_GRE_ENCAP_DPORT]  =3D { .type =3D NLA_U16 },
>>        [IFLA_GRE_COLLECT_METADATA]     =3D { .type =3D NLA_FLAG },
>> +       [IFLA_GRE_IGNORE_DF]    =3D { .type =3D NLA_U8 },
>> };
>>=20
>=20
> You could just copy the approach used for COLLECT_METADATA and skip
> the need to pass any data and instead just use a flag.


I looked at doing that, but decided not to because there=E2=80=99s no w=
ay to turn it back off once you turn it on that way.

-Philip


>=20
>> static struct rtnl_link_ops ipgre_link_ops __read_mostly =3D {
>> diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
>> index d8f5e0a..95649eb 100644
>> --- a/net/ipv4/ip_tunnel.c
>> +++ b/net/ipv4/ip_tunnel.c
>> @@ -682,7 +682,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct =
net_device *dev,
>>        }
>>=20
>>        df =3D tnl_params->frag_off;
>> -       if (skb->protocol =3D=3D htons(ETH_P_IP))
>> +       if (skb->protocol =3D=3D htons(ETH_P_IP) && !tunnel->ignore_=
df)
>>                df |=3D (inner_iph->frag_off&htons(IP_DF));
>>=20
>>        max_headroom =3D LL_RESERVED_SPACE(rt->dst.dev) + sizeof(stru=
ct iphdr)
>=20
> Looking at this it appears that you should probably make the feature
> mutually exclusive from the pmtudisc feature.  It wouldn't make much
> sense to set the tunnel to ignore the inner DF bit and then turn
> around and set it because you are enforcing path MTU discovery on the
> tunnel itself.
