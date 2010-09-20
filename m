From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v5 2/2] netfilter: save the hash of the tuple in the
 original direction for latter use
Date: Mon, 20 Sep 2010 23:04:33 +0800
Message-ID: <AANLkTikZeFrS9pj6jxmOxqY6dsaAf1U+FAXe5jNwQ-nV@mail.gmail.com>
References: <1282344540-5306-1-git-send-email-xiaosuo@gmail.com> <4C91B6BE.8020300@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	akpm@linux-foundation.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C91B6BE.8020300@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 16, 2010 at 2:18 PM, Patrick McHardy <kaber@trash.net> wrot=
e:
> On 21.08.2010 00:49, Changli Gao wrote:
>> Since we don't change the tuple in the original direction, we can sa=
ve it
>> in ct->tuplehash[IP_CT_DIR_REPLY].hnode.pprev for __nf_conntrack_con=
firm()
>> use.
>
> I like this idea. We could actually do the same for the reply tuple
> and invalidate the saved hash in case the reply tuple is changed
> (nf_conntrack_alter_reply()), which only happens when NAT is used.
>

We can't do that, as the unconfirmed ct owned maybe dropped, and
pre-computing will wast CPU cycles in this case.

>> __hash_conntrack() is split into two steps: ____hash_conntrack() is =
used
>> to get the raw hash, and __hash_bucket() is used to get the bucket i=
d.
>
> This patch uses underscores a bit excessively, how about renaming:
>
> - ____hash_conntrack() =3D> hash_conntrack_raw()
> - __hash variables =3D> hash
> - hash variables =3D> bucket

OK. Thanks.

>
>> @@ -408,7 +438,8 @@ __nf_conntrack_confirm(struct sk_buff *skb)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NF_ACCEPT;
>>
>> =A0 =A0 =A0 zone =3D nf_ct_zone(ct);
>> - =A0 =A0 hash =3D hash_conntrack(net, zone, &ct->tuplehash[IP_CT_DI=
R_ORIGINAL].tuple);
>> + =A0 =A0 /* reuse the __hash saved before */
>> + =A0 =A0 hash =3D hash_bucket(*(unsigned long *)&ct->tuplehash[IP_C=
T_DIR_REPLY].hnnode.pprev, net);
>
> Please try to stay at least close to the 80 characters limit.
>

OK. Thanks.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
