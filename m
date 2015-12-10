From: Jarno Rajahalme <jarno@ovn.org>
Subject: Re: [PATCH net-next v4 2/8] netfilter: Factor out nf_ct_get_info().
Date: Thu, 10 Dec 2015 13:51:40 -0800
Message-ID: <EDA41B9E-0F1E-4ACB-A4AA-28188E8436C8@ovn.org>
References: <1449622870-48944-1-git-send-email-jarno@ovn.org> <1449622870-48944-3-git-send-email-jarno@ovn.org> <20151210191441.GA20536@salvia>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org, dev@openvswitch.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:58635 "EHLO
	relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751929AbbLJVvr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 16:51:47 -0500
In-Reply-To: <20151210191441.GA20536@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Dec 10, 2015, at 11:14 AM, Pablo Neira Ayuso <pablo@netfilter.org>=
 wrote:
>=20
> On Tue, Dec 08, 2015 at 05:01:04PM -0800, Jarno Rajahalme wrote:
>> Define a new inline function to map conntrack status to enum
>> ip_conntrack_info.  This removes the need to otherwise duplicate thi=
s
>> code in a later patch ("openvswitch: Find existing conntrack entry
>> after upcall.").
>>=20
>> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
>> ---
>> include/net/netfilter/nf_conntrack.h | 15 +++++++++++++++
>> net/netfilter/nf_conntrack_core.c    | 22 +++-------------------
>> 2 files changed, 18 insertions(+), 19 deletions(-)
>>=20
>> diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netf=
ilter/nf_conntrack.h
>> index fde4068..b3de10e 100644
>> --- a/include/net/netfilter/nf_conntrack.h
>> +++ b/include/net/netfilter/nf_conntrack.h
>> @@ -125,6 +125,21 @@ nf_ct_tuplehash_to_ctrack(const struct nf_connt=
rack_tuple_hash *hash)
>> 			    tuplehash[hash->tuple.dst.dir]);
>> }
>>=20
>> +static inline enum ip_conntrack_info
>> +nf_ct_get_info(const struct nf_conntrack_tuple_hash *h)
>> +{
>> +	const struct nf_conn *ct =3D nf_ct_tuplehash_to_ctrack(h);
>> +
>> +	if (NF_CT_DIRECTION(h) =3D=3D IP_CT_DIR_REPLY)
>> +		return IP_CT_ESTABLISHED_REPLY;
>> +	/* Once we've had two way comms, always ESTABLISHED. */
>> +	if (test_bit(IPS_SEEN_REPLY_BIT, &ct->status))
>> +		return IP_CT_ESTABLISHED;
>> +	if (test_bit(IPS_EXPECTED_BIT, &ct->status))
>> +		return IP_CT_RELATED;
>> +	return IP_CT_NEW;
>> +}
>> +
>> static inline u_int16_t nf_ct_l3num(const struct nf_conn *ct)
>> {
>> 	return ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.l3num;
>> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_co=
nntrack_core.c
>> index 3cb3cb8..70ddbd8 100644
>> --- a/net/netfilter/nf_conntrack_core.c
>> +++ b/net/netfilter/nf_conntrack_core.c
>> @@ -1056,25 +1056,9 @@ resolve_normal_ct(struct net *net, struct nf_=
conn *tmpl,
>> 	ct =3D nf_ct_tuplehash_to_ctrack(h);
>>=20
>> 	/* It exists; we have (non-exclusive) reference. */
>> -	if (NF_CT_DIRECTION(h) =3D=3D IP_CT_DIR_REPLY) {
>> -		*ctinfo =3D IP_CT_ESTABLISHED_REPLY;
>> -		/* Please set reply bit if this packet OK */
>> -		*set_reply =3D 1;
>> -	} else {
>> -		/* Once we've had two way comms, always ESTABLISHED. */
>> -		if (test_bit(IPS_SEEN_REPLY_BIT, &ct->status)) {
>> -			pr_debug("nf_conntrack_in: normal packet for %p\n", ct);
>=20
> This implicitly assumes we don't want pr_debug for nf_conntrack
> anymore. Not telling this is wrong, but we have more pr_debug() calls
> in nf_conntrack that will remain there.

Dropping pr_debug was unintentional. Unless I hear otherwise, I=E2=80=99=
ll add the pr_debug() back for the next version.

Thanks,

  Jarno
