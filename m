From: Jarno Rajahalme <jarno@ovn.org>
Subject: Re: [PATCH nf-next v9 8/8] openvswitch: Interface with NAT.
Date: Thu, 10 Mar 2016 10:55:53 -0800
Message-ID: <D23E44DD-FA6D-4095-ABC8-CAE8E032BE7A@ovn.org>
References: <1457565024-27300-1-git-send-email-jarno@ovn.org> <1457565024-27300-8-git-send-email-jarno@ovn.org> <CAPWQB7GkhrfZaaT-LkTP7Esfj4tzU=Fgto2ZaSq4YkurhOf8bw@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Graf <tgraf@suug.ch>, netfilter-devel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>, ovs dev <dev@openvswitch.org>
To: Joe Stringer <joe@ovn.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CAPWQB7GkhrfZaaT-LkTP7Esfj4tzU=Fgto2ZaSq4YkurhOf8bw@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks for the reviews Joe! Comments below.

> On Mar 9, 2016, at 7:47 PM, Joe Stringer <joe@ovn.org> wrote:
>=20
> Hi Jarno,
>=20
> Thanks for working on this. Mostly just a few style things around #if=
defs below.
>=20
> On 9 March 2016 at 15:10, Jarno Rajahalme <jarno@ovn.org> wrote:
>> Extend OVS conntrack interface to cover NAT.  New nested
>> OVS_CT_ATTR_NAT attribute may be used to include NAT with a CT actio=
n.
>> A bare OVS_CT_ATTR_NAT only mangles existing and expected connection=
s.
>> If OVS_NAT_ATTR_SRC or OVS_NAT_ATTR_DST is included within the neste=
d
>> attributes, new (non-committed/non-confirmed) connections are mangle=
d
>> according to the rest of the nested attributes.
>>=20
>> The corresponding OVS userspace patch series includes test cases (in
>> tests/system-traffic.at) that also serve as example uses.
>>=20
>> This work extends on a branch by Thomas Graf at
>> https://github.com/tgraf/ovs/tree/nat.
>=20
> Thomas, I guess there was not signoff in these patches so Jarno does
> not have your signoff in this patch.
>=20
>> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
>> ---
>> v9: Fixed module dependencies.
>>=20
>> include/uapi/linux/openvswitch.h |  49 ++++
>> net/openvswitch/Kconfig          |   3 +-
>> net/openvswitch/conntrack.c      | 523 +++++++++++++++++++++++++++++=
++++++++--
>> net/openvswitch/conntrack.h      |   3 +-
>> 4 files changed, 551 insertions(+), 27 deletions(-)
>=20
> <snip>
>=20
>> diff --git a/net/openvswitch/Kconfig b/net/openvswitch/Kconfig
>> index cd5fd9d..23471a4 100644
>> --- a/net/openvswitch/Kconfig
>> +++ b/net/openvswitch/Kconfig
>> @@ -6,7 +6,8 @@ config OPENVSWITCH
>>        tristate "Open vSwitch"
>>        depends on INET
>>        depends on !NF_CONNTRACK || \
>> -                  (NF_CONNTRACK && (!NF_DEFRAG_IPV6 || NF_DEFRAG_IP=
V6))
>> +                  (NF_CONNTRACK && ((!NF_DEFRAG_IPV6 || NF_DEFRAG_I=
PV6) && \
>> +                                (!NF_NAT || NF_NAT)))
>=20
> Whitespace.
>=20

=46ixed.

>>        select LIBCRC32C
>>        select MPLS
>>        select NET_MPLS_GSO
>> diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack=
=2Ec
>> index 5711f80..6455237 100644
>> --- a/net/openvswitch/conntrack.c
>> +++ b/net/openvswitch/conntrack.c
>=20
> <snip>
>=20
>> struct ovs_ct_len_tbl {
>> -       size_t maxlen;
>> -       size_t minlen;
>> +       int maxlen;
>> +       int minlen;
>> };
>=20
> Are these changed for a specific reason, or just to use INT_MAX rathe=
r
> than SIZE_MAX in ovs_ct_len_tbl?
>=20

=E2=80=98maxlen=E2=80=99 and =E2=80=98minlen=E2=80=99 are compared agai=
nst the values returned by nla_len(), which returns an int:

net/netlink.h:static inline int nla_len(const struct nlattr *nla)

so I figured it is better to have these as ints, too.

>> /* Metadata mark for masked write to conntrack mark */
>> @@ -42,15 +52,29 @@ struct md_labels {
>>        struct ovs_key_ct_labels mask;
>> };
>>=20
>> +#ifdef CONFIG_NF_NAT_NEEDED
>> +enum ovs_ct_nat {
>> +       OVS_CT_NAT =3D 1 << 0,     /* NAT for committed connections =
only. */
>> +       OVS_CT_SRC_NAT =3D 1 << 1, /* Source NAT for NEW connections=
=2E */
>> +       OVS_CT_DST_NAT =3D 1 << 2, /* Destination NAT for NEW connec=
tions. */
>> +};
>> +#endif
>=20
> Here...
>=20
>> /* Conntrack action context for execution. */
>> struct ovs_conntrack_info {
>>        struct nf_conntrack_helper *helper;
>>        struct nf_conntrack_zone zone;
>>        struct nf_conn *ct;
>>        u8 commit : 1;
>> +#ifdef CONFIG_NF_NAT_NEEDED
>> +       u8 nat : 3;                 /* enum ovs_ct_nat */
>> +#endif
>=20
> and here.. I wonder if we can trim more of these #ifdefs, for
> readability and more compiler coverage if the feature is disabled.
>=20

Trimmed this and other #ifdefs as you suggested, and it still compiles =
when NAT is disabled.

Just posted the v10, which I hope will be the final version :-)

  Jarno

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
