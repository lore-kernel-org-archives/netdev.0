From: Krzysztof Oledzki <ole@ans.pl>
Subject: Re: Oops in nf_nat_core.c:find_appropriate_src(), kernel 2.6.25.4
Date: Tue, 10 Jun 2008 15:56:04 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0806101545460.12641@bizon.gios.gov.pl>
References: <484A9E75.8000601@redhat.com> <484AA276.9090407@trash.net>
 <484AA5D5.10404@trash.net> <Pine.LNX.4.64.0806071742180.13503@bizon.gios.gov.pl>
 <484E4343.5090606@trash.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-524042434-1213106164=:12641"
Cc: Chuck Ebbert <cebbert@redhat.com>, Netdev <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <484E4343.5090606@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-524042434-1213106164=:12641
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Tue, 10 Jun 2008, Patrick McHardy wrote:

> Krzysztof Oledzki wrote:
>> On Sat, 7 Jun 2008, Patrick McHardy wrote:
>>=20
>>> Patrick McHardy wrote:
>>>> Chuck Ebbert wrote:
>>>>> Reported at https://bugzilla.redhat.com/show_bug.cgi?id=3D449315
>>>>>=20
>>>>> In find_appropriate_src():
>>>>>
>>>>>         hlist_for_each_entry_rcu(nat, n, &bysource[h], bysource) {
>>>>>                 ct =3D nat->ct;
>>>>>                 if (same_src(ct, tuple)) {
>>>>>=20
>>>>> Dereference of ct in same_src() causes the oops. This only seems to
>>>>> happen on heavily loaded firewall machines. Kernel 2.6.24.7 works.
>>>>>=20
>>>>> The reporter identifies commit 4d354c5782dc352cec187845d17eedc2c2bfcf=
67
>>>>> ("[NETFILTER]: nf_nat: use RCU for bysource hash") as a possible caus=
e
>>>>> of the problem.
>>>>=20
>>>> We have a similar looking report, but that one also affects 2.6.24:
>>>>=20
>>>> http://bugzilla.kernel.org/show_bug.cgi?id=3D10875
>
>
> We found the reason for that crash and I've queued these two
> patches. Please let me know whether they also fix the problem
> from the redhat bugzilla.

There is a one thing that still bugs me. This patch removes setting the=20
nat->ct pointer to NULL:

--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -556,7 +556,6 @@ static void nf_nat_cleanup_conntrack(struct nf_conn=20
*ct)

         spin_lock_bh(&nf_nat_lock);
         hlist_del_rcu(&nat->bysource);
-       nat->ct =3D NULL;
         spin_unlock_bh(&nf_nat_lock);
  }

After this patch the whole function looks like this:

/* Noone using conntrack by the time this called. */
static void nf_nat_cleanup_conntrack(struct nf_conn *ct)
{
         struct nf_conn_nat *nat =3D nf_ct_ext_find(ct, NF_CT_EXT_NAT);

         if (nat =3D=3D NULL || nat->ct =3D=3D NULL)
                 return;

         NF_CT_ASSERT(nat->ct->status & IPS_NAT_DONE_MASK);

         spin_lock_bh(&nf_nat_lock);
         hlist_del_rcu(&nat->bysource);
         spin_unlock_bh(&nf_nat_lock);
}

As you can see we still check if nat->ct is NULL here. So, or the check is=
=20
now unnecessary, or it is still possible that nat->ct may become NULL. If=
=20
the second statement is true than we may need to check ct before calling=20
same_src in the find_appropriate_src function.

Best regards,

 =09=09=09Krzysztof Ol=EAdzki
---187430788-524042434-1213106164=:12641--
