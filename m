From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH 01/17] netfilter: add struct nf_proto_net for register
 l4proto sysctl
Date: Thu, 24 May 2012 09:35:50 +0800
Message-ID: <4FBD9076.6060309@cn.fujitsu.com>
References: <1336985547-31960-1-git-send-email-gaofeng@cn.fujitsu.com> <1336985547-31960-2-git-send-email-gaofeng@cn.fujitsu.com> <20120523101200.GA2836@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitus.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120523101200.GA2836@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi pablo:

=E4=BA=8E 2012=E5=B9=B405=E6=9C=8823=E6=97=A5 18:12, Pablo Neira Ayuso =
=E5=86=99=E9=81=93:
> On Mon, May 14, 2012 at 04:52:11PM +0800, Gao feng wrote:
>> From: Gao feng <gaofeng@cn.fujitus.com>
>>
>> the struct nf_proto_net stroes proto's ctl_table_header and ctl_tabl=
e,
>> nf_ct_l4proto_(un)register_sysctl use it to register sysctl.
>>
>> there are some changes for struct nf_conntrack_l4proto:
>> - add field compat to identify if this proto should do compat.
>> - the net_id field is used to store the pernet_operations id
>>   that belones to l4proto.
>> - init_net will be used to initial the proto's pernet data
>>
>> and add init_net for struct nf_conntrack_l3proto too.
>=20
> This patchset looks bette but there are still things that we have to
> resolve.
>=20
> The first one (regarding this patch 1/17) changes in:
> * include/net/netfilter/nf_conntrack_l4proto.h
> * include/net/netns/conntrack.h
>=20
> should be included in:
> [PATCH] netfilter: add namespace support for l4proto
>=20
> And changes in:
> * include/net/netfilter/nf_conntrack_l3proto.h
>=20
> should be included in:
> [PATCH] netfilter: add namespace support for l3proto
>=20
> I already told you. A patch that adds a structure without using it,
> is not good. The structure has to go together with the code uses it.
>=20

It seams this patch should be merged to "netfilter: add namespace suppo=
rt for l4proto"
the struct nf_proto_net is first used there.

> More comments below.
>=20
>> Acked-by: Eric W. Biederman <ebiederm@xmission.com>
>> Signed-off-by: Gao feng <gaofeng@cn.fujitus.com>
>> ---
>>  include/net/netfilter/nf_conntrack_l3proto.h |    3 +++
>>  include/net/netfilter/nf_conntrack_l4proto.h |    6 ++++++
>>  include/net/netns/conntrack.h                |   12 ++++++++++++
>>  3 files changed, 21 insertions(+), 0 deletions(-)
>>
>> diff --git a/include/net/netfilter/nf_conntrack_l3proto.h b/include/=
net/netfilter/nf_conntrack_l3proto.h
>> index 9699c02..9766005 100644
>> --- a/include/net/netfilter/nf_conntrack_l3proto.h
>> +++ b/include/net/netfilter/nf_conntrack_l3proto.h
>> @@ -69,6 +69,9 @@ struct nf_conntrack_l3proto {
>>  	struct ctl_table	*ctl_table;
>>  #endif /* CONFIG_SYSCTL */
>> =20
>> +	/* Init l3proto pernet data */
>> +	int (*init_net)(struct net *net);
>> +
>>  	/* Module (if any) which this is connected to. */
>>  	struct module *me;
>>  };
>> diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/=
net/netfilter/nf_conntrack_l4proto.h
>> index 3b572bb..a90eab5 100644
>> --- a/include/net/netfilter/nf_conntrack_l4proto.h
>> +++ b/include/net/netfilter/nf_conntrack_l4proto.h
>> @@ -22,6 +22,8 @@ struct nf_conntrack_l4proto {
>>  	/* L4 Protocol number. */
>>  	u_int8_t l4proto;
>> =20
>> +	u_int8_t compat;
>=20
> I don't see why we need this new field.
>=20
> It seems to be set to 1 in each structure that has set:
>=20
> .ctl_compat_table
>=20
> to non-NULL. So, it's redundant.
>=20
> Moreover, you already know from the protocol tracker itself if you
> have to allocate the compat ctl table or not.
>=20
> In other words: You set compat to 1 for nf_conntrack_l4proto_generic.
> Then, you pass that compat value to generic_init_net via ->inet_net
> again, but this information (that determines if the compat has to be
> done or not) is already in the scope of the protocol tracker.
>=20

because some protocols such l4proto_tcp6 and l4proto_tcp use the same i=
nit_net
function. the l4proto_tcp6 doesn't need compat sysctl, so we should use=
 this new
field to identify if we should kmemdup compat_sysctl_table.

and beacuse protocols will have pernet ctl_compat_table and ctl_table,t=
he .ctl_compat_table
field will be deleted in patch 15/17. so we should the new field compat=
=2E

actually, we don't need to pass compat value for generic_init_net,beacu=
se
we know l4proto_generic need compat. But consider there are l4proto_tcp=
(6), and in order to keep
code readable,I prefer to add compat field and pass it to init_net.

> You have to fix this.
>=20
>> +
>>  	/* Try to fill in the third arg: dataoff is offset past network pr=
otocol
>>             hdr.  Return true if possible. */
>>  	bool (*pkt_to_tuple)(const struct sk_buff *skb, unsigned int datao=
ff,
>> @@ -103,6 +105,10 @@ struct nf_conntrack_l4proto {
>>  	struct ctl_table	*ctl_compat_table;
>>  #endif
>>  #endif
>> +	int	*net_id;
>> +	/* Init l4proto pernet data */
>> +	int (*init_net)(struct net *net, u_int8_t compat);
>> +
>>  	/* Protocol name */
>>  	const char *name;
>> =20
>> diff --git a/include/net/netns/conntrack.h b/include/net/netns/connt=
rack.h
>> index a053a19..1f53038 100644
>> --- a/include/net/netns/conntrack.h
>> +++ b/include/net/netns/conntrack.h
>> @@ -8,6 +8,18 @@
>>  struct ctl_table_header;
>>  struct nf_conntrack_ecache;
>> =20
>> +struct nf_proto_net {
>> +#ifdef CONFIG_SYSCTL
>> +	struct ctl_table_header *ctl_table_header;
>> +	struct ctl_table        *ctl_table;
>> +#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
>> +	struct ctl_table_header *ctl_compat_header;
>> +	struct ctl_table        *ctl_compat_table;
>> +#endif
>> +#endif
>> +	unsigned int		users;
>> +};
>> +
>>  struct netns_ct {
>>  	atomic_t		count;
>>  	unsigned int		expect_count;
> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-d=
evel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
