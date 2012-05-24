From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH 01/17] netfilter: add struct nf_proto_net for register
 l4proto sysctl
Date: Thu, 24 May 2012 18:54:42 +0800
Message-ID: <4FBE1372.60206@cn.fujitsu.com>
References: <1336985547-31960-1-git-send-email-gaofeng@cn.fujitsu.com> <1336985547-31960-2-git-send-email-gaofeng@cn.fujitsu.com> <20120523101200.GA2836@1984> <4FBD9076.6060309@cn.fujitsu.com> <20120524095859.GC13091@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitus.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:39273 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756481Ab2EXLhV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2012 07:37:21 -0400
In-Reply-To: <20120524095859.GC13091@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B405=E6=9C=8824=E6=97=A5 17:58, Pablo Neira Ayuso =
=E5=86=99=E9=81=93:
> On Thu, May 24, 2012 at 09:35:50AM +0800, Gao feng wrote:
>> Hi pablo:
>>
>> =E4=BA=8E 2012=E5=B9=B405=E6=9C=8823=E6=97=A5 18:12, Pablo Neira Ayu=
so =E5=86=99=E9=81=93:
>>> On Mon, May 14, 2012 at 04:52:11PM +0800, Gao feng wrote:
>>>> From: Gao feng <gaofeng@cn.fujitus.com>
>>>>
>>>> the struct nf_proto_net stroes proto's ctl_table_header and ctl_ta=
ble,
>>>> nf_ct_l4proto_(un)register_sysctl use it to register sysctl.
>>>>
>>>> there are some changes for struct nf_conntrack_l4proto:
>>>> - add field compat to identify if this proto should do compat.
>>>> - the net_id field is used to store the pernet_operations id
>>>>   that belones to l4proto.
>>>> - init_net will be used to initial the proto's pernet data
>>>>
>>>> and add init_net for struct nf_conntrack_l3proto too.
>>>
>>> This patchset looks bette but there are still things that we have t=
o
>>> resolve.
>>>
>>> The first one (regarding this patch 1/17) changes in:
>>> * include/net/netfilter/nf_conntrack_l4proto.h
>>> * include/net/netns/conntrack.h
>>>
>>> should be included in:
>>> [PATCH] netfilter: add namespace support for l4proto
>>>
>>> And changes in:
>>> * include/net/netfilter/nf_conntrack_l3proto.h
>>>
>>> should be included in:
>>> [PATCH] netfilter: add namespace support for l3proto
>>>
>>> I already told you. A patch that adds a structure without using it,
>>> is not good. The structure has to go together with the code uses it=
=2E
>>>
>>
>> It seams this patch should be merged to "netfilter: add namespace su=
pport for l4proto"
>> the struct nf_proto_net is first used there.
>>
>>> More comments below.
>>>
>>>> Acked-by: Eric W. Biederman <ebiederm@xmission.com>
>>>> Signed-off-by: Gao feng <gaofeng@cn.fujitus.com>
>>>> ---
>>>>  include/net/netfilter/nf_conntrack_l3proto.h |    3 +++
>>>>  include/net/netfilter/nf_conntrack_l4proto.h |    6 ++++++
>>>>  include/net/netns/conntrack.h                |   12 ++++++++++++
>>>>  3 files changed, 21 insertions(+), 0 deletions(-)
>>>>
>>>> diff --git a/include/net/netfilter/nf_conntrack_l3proto.h b/includ=
e/net/netfilter/nf_conntrack_l3proto.h
>>>> index 9699c02..9766005 100644
>>>> --- a/include/net/netfilter/nf_conntrack_l3proto.h
>>>> +++ b/include/net/netfilter/nf_conntrack_l3proto.h
>>>> @@ -69,6 +69,9 @@ struct nf_conntrack_l3proto {
>>>>  	struct ctl_table	*ctl_table;
>>>>  #endif /* CONFIG_SYSCTL */
>>>> =20
>>>> +	/* Init l3proto pernet data */
>>>> +	int (*init_net)(struct net *net);
>>>> +
>>>>  	/* Module (if any) which this is connected to. */
>>>>  	struct module *me;
>>>>  };
>>>> diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/includ=
e/net/netfilter/nf_conntrack_l4proto.h
>>>> index 3b572bb..a90eab5 100644
>>>> --- a/include/net/netfilter/nf_conntrack_l4proto.h
>>>> +++ b/include/net/netfilter/nf_conntrack_l4proto.h
>>>> @@ -22,6 +22,8 @@ struct nf_conntrack_l4proto {
>>>>  	/* L4 Protocol number. */
>>>>  	u_int8_t l4proto;
>>>> =20
>>>> +	u_int8_t compat;
>>>
>>> I don't see why we need this new field.
>>>
>>> It seems to be set to 1 in each structure that has set:
>>>
>>> .ctl_compat_table
>>>
>>> to non-NULL. So, it's redundant.
>>>
>>> Moreover, you already know from the protocol tracker itself if you
>>> have to allocate the compat ctl table or not.
>>>
>>> In other words: You set compat to 1 for nf_conntrack_l4proto_generi=
c.
>>> Then, you pass that compat value to generic_init_net via ->inet_net
>>> again, but this information (that determines if the compat has to b=
e
>>> done or not) is already in the scope of the protocol tracker.
>>>
>>
>> because some protocols such l4proto_tcp6 and l4proto_tcp use the sam=
e init_net
>> function. the l4proto_tcp6 doesn't need compat sysctl, so we should =
use this new
>> field to identify if we should kmemdup compat_sysctl_table.
>=20
> Then, could you use two init_net functions? one for TCP for IPv4 and =
another
> for TCP for IPv6?

Of cause, if you prefer to impletment it in this way.
