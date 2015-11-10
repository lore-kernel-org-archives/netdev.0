From: Jarno Rajahalme <jarno@ovn.org>
Subject: Re: [RFC PATCH net-next v2 7/8] openvswitch: Delay conntrack helper call for new connections.
Date: Tue, 10 Nov 2015 12:58:45 -0800
Message-ID: <CFF40706-E3EE-4DC4-9DFC-EF5A24898284@ovn.org>
References: <1446854768-38299-1-git-send-email-jrajahalme@nicira.com> <1446854768-38299-8-git-send-email-jrajahalme@nicira.com> <20151109132601.GB8098@macbook.localdomain>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	dev@openvswitch.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20151109132601.GB8098@macbook.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> On Nov 9, 2015, at 5:26 AM, Patrick McHardy <kaber@trash.net> wrote:
>=20
> On 06.11, Jarno Rajahalme wrote:
>> There is no need to help connections that are not confirmed, so we c=
an
>> delay helping new connections to the time when they are confirmed.
>> This change is needed for NAT support, and having this as a separate
>> patch will make the following NAT patch a bit easier to review.
>=20
> For the first packet a helper receives the connection is always uncon=
firmed.
> It makes no sense to confirm it if the helper drops the packet.
>=20

Right, the nf_conntrack_confirm() call is still done only if helper acc=
epts the packet.

The issue this patch deals with is that in a fairly typical pattern the=
 packet will be passed through conntrack by a CT action and then recirc=
ulated (for matching on the connection state, using the RECIRC action),=
 and later an another CT action is used to confirm the connection, poss=
ibly with NAT. Before this patch, __ovs_ct_lookup() would have passed t=
he packet through the helper in the first step, while the NAT call woul=
d only happen with the second step, i.e., in the wrong order. With this=
 patch the helper for new connections is called with the second step, a=
fter calling the NAT code (as added by the patch 8/8). For non-new pack=
ets we must call the helper with the first conntrack lookup, as there t=
ypically are no later CT actions for packet belonging to existing conne=
ctions. For new connections we know that if the first CT action does no=
t have the =E2=80=98commit=E2=80=99 flag (which causes nf_conntrack_con=
firm() to be called), we can safely postpone the helper call, as there =
has to be a later CT action for the connection to be confirmed.

  Jarno

>> Signed-off-by: Jarno Rajahalme <jrajahalme@nicira.com>
>> ---
>> net/openvswitch/conntrack.c | 20 +++++++++++++++-----
>> 1 file changed, 15 insertions(+), 5 deletions(-)
>>=20
>> diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack=
=2Ec
>> index 7aa38fa..ba44287 100644
>> --- a/net/openvswitch/conntrack.c
>> +++ b/net/openvswitch/conntrack.c
>> @@ -458,6 +458,7 @@ static bool skb_nfct_cached(struct net *net,
>> /* Pass 'skb' through conntrack in 'net', using zone configured in '=
info', if
>>  * not done already.  Update key with new CT state after passing the=
 packet
>>  * through conntrack.
>> + * Note that invalid packets are accepted while the skb->nfct remai=
ns unset!
>>  */
>> static int __ovs_ct_lookup(struct net *net, struct sw_flow_key *key,
>> 			   const struct ovs_conntrack_info *info,
>> @@ -468,7 +469,11 @@ static int __ovs_ct_lookup(struct net *net, str=
uct sw_flow_key *key,
>> 	 * actually run the packet through conntrack twice unless it's for =
a
>> 	 * different zone.
>> 	 */
>> -	if (!skb_nfct_cached(net, key, info, skb)) {
>> +	bool cached =3D skb_nfct_cached(net, key, info, skb);
>> +	enum ip_conntrack_info ctinfo;
>> +	struct nf_conn *ct;
>> +
>> +	if (!cached) {
>> 		struct nf_conn *tmpl =3D info->ct;
>> 		int err;
>>=20
>> @@ -491,11 +496,16 @@ static int __ovs_ct_lookup(struct net *net, st=
ruct sw_flow_key *key,
>> 			return -ENOENT;
>>=20
>> 		ovs_ct_update_key(skb, key, true);
>> +	}
>>=20
>> -		if (ovs_ct_helper(skb, info->family) !=3D NF_ACCEPT) {
>> -			WARN_ONCE(1, "helper rejected packet");
>> -			return -EINVAL;
>> -		}
>> +	/* Call the helper right after nf_conntrack_in() for confirmed
>> +	 * connections, but only when commiting for unconfirmed connection=
s.
>> +	 */
>> +	ct =3D nf_ct_get(skb, &ctinfo);
>> +	if (ct && (nf_ct_is_confirmed(ct) ? !cached : info->commit)
>> +	    && ovs_ct_helper(skb, info->family) !=3D NF_ACCEPT) {
>> +		WARN_ONCE(1, "helper rejected packet");
>> +		return -EINVAL;
>> 	}
>>=20
>> 	return 0;
>> --=20
>> 2.1.4
>>=20
>> --
>> To unsubscribe from this list: send the line "unsubscribe netfilter-=
devel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>=20

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
