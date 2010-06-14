From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] fragment: add fast path
Date: Mon, 14 Jun 2010 13:59:11 +0800
Message-ID: <AANLkTimN1-uyAvpxgpno55XoyPzBptdZimz-MA-0MCWZ@mail.gmail.com>
References: <1276470995-21713-1-git-send-email-xiaosuo@gmail.com>
	<1276493743.2448.41.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:64775 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751644Ab0FNF7c convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jun 2010 01:59:32 -0400
Received: by vws14 with SMTP id 14so193425vws.19
        for <netdev@vger.kernel.org>; Sun, 13 Jun 2010 22:59:31 -0700 (PDT)
In-Reply-To: <1276493743.2448.41.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 14, 2010 at 1:35 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le lundi 14 juin 2010 =E0 07:16 +0800, Changli Gao a =E9crit :
>> add fast path
>>
>> As the fragments are usually in order, it is likely the new fragment=
s are
>> at the end of the inet_frag_queue. In the fast path, we check if the=
 skb at the
>> end of the inet_frag_queue is the prev we expect.
>>
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>> ----
>> =A0include/net/inet_frag.h | =A0 =A01 +
>> =A0net/ipv4/ip_fragment.c =A0| =A0 17 +++++++++++++++++
>> =A0net/ipv6/reassembly.c =A0 | =A0 16 ++++++++++++++++
>> =A03 files changed, 34 insertions(+)
>> diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
>> index 39f2dc9..16ff29a 100644
>> --- a/include/net/inet_frag.h
>> +++ b/include/net/inet_frag.h
>> @@ -20,6 +20,7 @@ struct inet_frag_queue {
>> =A0 =A0 =A0 atomic_t =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0refcnt;
>> =A0 =A0 =A0 struct timer_list =A0 =A0 =A0 timer; =A0 =A0 =A0/* when =
will this queue expire? */
>> =A0 =A0 =A0 struct sk_buff =A0 =A0 =A0 =A0 =A0*fragments; /* list of=
 received fragments */
>> + =A0 =A0 struct sk_buff =A0 =A0 =A0 =A0 =A0*fragments_tail;
>> =A0 =A0 =A0 ktime_t =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 stamp;
>> =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 len; =A0 =A0=
 =A0 =A0/* total length of orig datagram */
>> =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 meat;
>> diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
>> index 75347ea..d8c36d4 100644
>> --- a/net/ipv4/ip_fragment.c
>> +++ b/net/ipv4/ip_fragment.c
>> @@ -317,6 +317,7 @@ static int ip_frag_reinit(struct ipq *qp)
>> =A0 =A0 =A0 qp->q.len =3D 0;
>> =A0 =A0 =A0 qp->q.meat =3D 0;
>> =A0 =A0 =A0 qp->q.fragments =3D NULL;
>> + =A0 =A0 qp->q.fragments_tail =3D NULL;
>> =A0 =A0 =A0 qp->iif =3D 0;
>>
>> =A0 =A0 =A0 return 0;
>> @@ -389,6 +390,16 @@ static int ip_frag_queue(struct ipq *qp, struct=
 sk_buff *skb)
>> =A0 =A0 =A0 =A0* in the chain of fragments so far. =A0We must know w=
here to put
>> =A0 =A0 =A0 =A0* this fragment, right?
>> =A0 =A0 =A0 =A0*/
>> + =A0 =A0 prev =3D qp->q.fragments_tail;
>> + =A0 =A0 if (prev) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (FRAG_CB(prev)->offset < offset) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 next =3D NULL;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto found;
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 } else {
>> + =A0 =A0 =A0 =A0 =A0 =A0 next =3D NULL;
>
> How can this chunk be a win ? queue is empty anyway.
> You add tests and slow the 'other path'
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto found;
>> + =A0 =A0 }

Without this branch. prev needs to be initialized to zero again(of
course, we can avoid this by moving prev =3D NULL in the previous
branch). next needs an assignment, and a duplicate check if the the
queue is empty, which is already known in the above branch. Sorry, but
I can't see which path I slow.

        prev =3D NULL;
        for (next =3D qp->q.fragments; next !=3D NULL; next =3D next->n=
ext) {
                if (FRAG_CB(next)->offset >=3D offset)
                        break;  /* bingo! */
                prev =3D next;
        }

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
