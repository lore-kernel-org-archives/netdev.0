From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] conntrack: use SLAB_DESTROY_BY_RCU for nf_conn structs
Date: Wed, 25 Mar 2009 20:41:08 +0100
Message-ID: <49CA88D4.6010808@trash.net>
References: <OF1FEA88FD.D6B88765-ONC1257582.003A487F-C1257582.003ACE3A@transmode.se>	 <49C77D71.8090709@trash.net>	 <OF8A05682D.BA831A09-ONC1257582.0043892E-C1257582.004440BD@transmode.se>	 <49C780AD.70704@trash.net>	 <OF20814141.D78C9170-ONC1257582.0060B64A-C1257582.00614FDC@transmode.se>	 <49C7CB9B.1040409@trash.net>	 <OFBD3D31D8.7AD81126-ONC1257583.002C5C2B-C1257583.002DFF13@transmode.se>	 <49C8A415.1090606@cosmosbay.com>	 <OF9168DCC3.5E31F8E4-ONC1257583.003B48CC-C1257583.003C0A5E@transmode.se>	 <49C8CCF4.5050104@cosmosbay.com> <1237907850.12351.80.camel@sakura.staff.proxad.net> <49C8FBCA.40402@cosmosbay.com> <49CA6F9A.9010806@cosmosbay.com> <49CA7255.20807@trash.net> <49CA74CA.1040603@cosmosbay.com> <49CA76C4.2090409@trash.net> <49CA7DAF.9070207@cosmosbay.com> <49CA7F45.5020800@trash.n
 et> <49CA8350.5040407@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mbizon@freebox.fr, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Joakim Tjernlund <Joakim.Tjernlund@transmode.se>,
	avorontsov@ru.mvista.com, netdev@vger.kernel.org,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49CA8350.5040407@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Patrick McHardy a =E9crit :
>>>      NF_CT_ASSERT(ct);
>>> +    if (unlikely(!atomic_inc_not_zero(&ct->ct_general.use)))
>>> +        return 0;
>> Can we assume the next pointer still points to the next entry
>> in the same chain after the refcount dropped to zero?
>>
>=20
> We are looking chain N.
> If we cannot atomic_inc() refcount, we got some deleted entry.
> If we could atomic_inc, we can meet an entry that just moved to anoth=
er chain X
>=20
> When hitting its end, we continue the search to the N+1 chain so we o=
nly=20
> skip the end of previous chain (N). We can 'forget' some entries, we =
can print
> several time one given entry.
>=20
>=20
> We could solve this by :
>=20
> 1) Checking hash value : if not one expected ->=20
>    Going back to head of chain N, (potentially re-printing already ha=
ndled entries)
>    So it is not a *perfect* solution.
>=20
> 2) Use a locking to forbid writers (as done in UDP/TCP), but it is ex=
pensive and
> wont solve other problem :
>=20
> We wont avoid emitting same entry several time anyway (this is a flaw=
 of=20
> current seq_file handling, since we 'count' entries to be skiped, and=
 this is
> wrong if some entries were deleted or inserted meanwhile)
>=20
> We have same problem on /proc/net/udp & /proc/net/tcp, I am not sure =
we should care...

I think double entries are not a problem, as you say, there
are already other cases where this can happen. But I think we
should try our best that every entry present at the start and
still present at the end of a dump is also contained in the
dump, otherwise the guantees seem to weak to still be useful.
Your first proposal would do exactly that, right?

> Also, current resizing code can give to a /proc/net/ip_conntrack read=
er a problem, since
> hash table can switch while its doing its dumping : many entries migh=
t be lost or regiven...

Thats true. But its a very rare operation, so I think its mainly
a documentation issue.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
