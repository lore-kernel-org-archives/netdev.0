From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] conntrack: use SLAB_DESTROY_BY_RCU for nf_conn structs
Date: Wed, 25 Mar 2009 21:10:19 +0100
Message-ID: <49CA8FAB.8090903@trash.net>
References: <OF1FEA88FD.D6B88765-ONC1257582.003A487F-C1257582.003ACE3A@transmode.se>	 <49C77D71.8090709@trash.net>	 <OF8A05682D.BA831A09-ONC1257582.0043892E-C1257582.004440BD@transmode.se>	 <49C780AD.70704@trash.net>	 <OF20814141.D78C9170-ONC1257582.0060B64A-C1257582.00614FDC@transmode.se>	 <49C7CB9B.1040409@trash.net>	 <OFBD3D31D8.7AD81126-ONC1257583.002C5C2B-C1257583.002DFF13@transmode.se>	 <49C8A415.1090606@cosmosbay.com>	 <OF9168DCC3.5E31F8E4-ONC1257583.003B48CC-C1257583.003C0A5E@transmode.se>	 <49C8CCF4.5050104@cosmosbay.com> <1237907850.12351.80.camel@sakura.staff.proxad.net> <49C8FBCA.40402@cosmosbay.com> <49CA6F9A.9010806@cosmosbay.com> <49CA7255.20807@trash.net> <49CA74CA.1040603@cosmosbay.com> <49CA76C4.2090409@trash.net> <49CA7DAF.9070207@cosmosbay.com> <49CA7F45.5020800@trash.n
 et> <49CA8350.5040407@cosmosbay.com> <49CA88D4.6010808@trash.net> <49CA8CD0.2010907@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mbizon@freebox.fr, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Joakim Tjernlund <Joakim.Tjernlund@transmode.se>,
	avorontsov@ru.mvista.com, netdev@vger.kernel.org,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38873 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750718AbZCYUK1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 16:10:27 -0400
In-Reply-To: <49CA8CD0.2010907@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Patrick McHardy a =E9crit :
>> I think double entries are not a problem, as you say, there
>> are already other cases where this can happen. But I think we
>> should try our best that every entry present at the start and
>> still present at the end of a dump is also contained in the
>> dump, otherwise the guantees seem to weak to still be useful.
>> Your first proposal would do exactly that, right?
>=20
> If your concern is to not forget entries, and we are allowed to print=
 some entries several times,
> then we can just check the final "nulls" value, and if we find a diff=
erent value than expected for
> chain N, go back to begining of chain N.
>=20
> No need to check hash value (this could help not print several time s=
ame entry, we dont care that much)
>=20
> +       while (is_a_nulls(head)) {
> +               if (likely(get_nulls_value(head) =3D=3D st->bucket)) =
{
> +                       if (++st->bucket >=3D nf_conntrack_htable_siz=
e)
> +                               return NULL;
> +               }

Looks perfect :)

> [PATCH] conntrack: use SLAB_DESTROY_BY_RCU and get rid of call_rcu()
>=20
> Use "hlist_nulls" infrastructure we added in 2.6.29 for RCUification =
of UDP & TCP.
>=20
> This permits an easy conversion from call_rcu() based hash lists to a
> SLAB_DESTROY_BY_RCU one.
>=20
> Avoiding call_rcu() delay at nf_conn freeing time has numerous gains.
>=20
> First, it doesnt fill RCU queues (up to 10000 elements per cpu).
> This reduces OOM possibility, if queued elements are not taken into a=
ccount
> This reduces latency problems when RCU queue size hits hilimit and tr=
iggers
> emergency mode.
>=20
> - It allows fast reuse of just freed elements, permitting better use =
of
> CPU cache.
>=20
> - We delete rcu_head from "struct nf_conn", shrinking size of this st=
ructure
> by 8 or 16 bytes.
>=20
> This patch only takes care of "struct nf_conn".
> call_rcu() is still used for less critical conntrack parts, that may
> be converted later if necessary.

Applied, thanks a lot.
