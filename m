From: Alexandru Copot <alex.mihai.c@gmail.com>
Subject: Re: [RFC PATCH 4/4] inet: use second hash in inet_csk_get_port
Date: Wed, 30 May 2012 22:11:02 +0300
Message-ID: <CAHG7+CD6Ug24jUCO5cR5t3gsS1z3bRj-OqMiskJZxe_DTf+gYQ@mail.gmail.com>
References: <1338363410-6562-1-git-send-email-alex.mihai.c@gmail.com>
	<1338363410-6562-5-git-send-email-alex.mihai.c@gmail.com>
	<1338398456.2760.338.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, gerrit@erg.abdn.ac.uk, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, Daniel Baluta <dbaluta@ixiacom.com>,
	Lucian Grijincu <lucian.grijincu@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:47641 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751122Ab2E3TLE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 15:11:04 -0400
Received: by yenm10 with SMTP id m10so154721yen.19
        for <netdev@vger.kernel.org>; Wed, 30 May 2012 12:11:03 -0700 (PDT)
In-Reply-To: <1338398456.2760.338.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 30, 2012 at 8:20 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> On Wed, 2012-05-30 at 10:36 +0300, Alexandru Copot wrote:
>
>> +struct inet_bind_bucket *
>> +inet4_find_bind_buckets(struct sock *sk,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned short port,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct inet_bind_hashbucke=
t **p_bhead,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct inet_bind_hashbucke=
t **p_portaddr_bhead)
>> +{
>> + =A0 =A0 struct net *net =3D sock_net(sk);
>> + =A0 =A0 struct inet_hashinfo *hinfo =3D sk->sk_prot->h.hashinfo;
>> + =A0 =A0 struct inet_bind_bucket *tb =3D NULL;
>> + =A0 =A0 struct hlist_node *node;
>> +
>> + =A0 =A0 struct inet_bind_hashbucket *bhead, *portaddr_bhead, *port=
addrany_bhead;
>> + =A0 =A0 bhead =3D &hinfo->bhash[inet_bhashfn(net, port, hinfo->bha=
sh_size)];
>> + =A0 =A0 portaddr_bhead =3D inet4_portaddr_hashbucket(hinfo, net,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sk_rcv_sad=
dr(sk), port);
>> + =A0 =A0 portaddrany_bhead =3D inet4_portaddr_hashbucket(hinfo, net=
,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 INADDR_ANY, port);
>> +
>> + =A0 =A0 *p_portaddr_bhead =3D portaddr_bhead;
>> + =A0 =A0 *p_bhead =3D bhead;
>> +
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* prevent dead locks by always taking locks in a fixed =
order:
>> + =A0 =A0 =A0* - always take the port-only lock first. This is done =
because in some
>> + =A0 =A0 =A0* =A0 other places this is the lock taken, being folllo=
wed in only some
>> + =A0 =A0 =A0* =A0 cases by the portaddr lock.
>> + =A0 =A0 =A0* - between portaddr and portaddrany always choose the =
one with the
>> + =A0 =A0 =A0* =A0 lower address. Unlock ordering is not important, =
as long as the
>> + =A0 =A0 =A0* =A0 locking order is consistent.
>> + =A0 =A0 =A0* - make sure to not take the same lock twice
>> + =A0 =A0 =A0*/
>> + =A0 =A0 spin_lock(&bhead->lock);
>> + =A0 =A0 if (portaddr_bhead > portaddrany_bhead) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&portaddrany_bhead->lock);
>> + =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&portaddr_bhead->lock);
>> + =A0 =A0 } else if (portaddr_bhead < portaddrany_bhead) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&portaddr_bhead->lock);
>> + =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&portaddrany_bhead->lock);
>> + =A0 =A0 } else {
>> + =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&portaddr_bhead->lock);
>> + =A0 =A0 }
>> +
>> + =A0 =A0 if (sk_rcv_saddr(sk) !=3D INADDR_ANY) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct inet_bind_hashbucket *_head;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 _head =3D portaddr_bhead;
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (bhead->count < portaddr_bhead->count) =
{
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 _head =3D bhead;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 inet_bind_bucket_for_each(=
tb, node, &_head->chain)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((net_e=
q(ib_net(tb), net)) &&
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (t=
b->port =3D=3D port) &&
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (t=
b->ib_addr_ipv4 =3D=3D sk_rcv_saddr(sk)))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 goto found;
>> + =A0 =A0 =A0 =A0 =A0 =A0 } else {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 inet_portaddr_bind_bucket_=
for_each(tb, node, &_head->chain)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((net_e=
q(ib_net(tb), net)) &&
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (t=
b->port =3D=3D port) &&
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (t=
b->ib_addr_ipv4 =3D=3D sk_rcv_saddr(sk)))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 goto found;
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 _head =3D portaddrany_bhead;
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (bhead->count < portaddrany_bhead->coun=
t) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 _head =3D bhead;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 inet_bind_bucket_for_each(=
tb, node, &_head->chain)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((ib_ne=
t(tb) =3D=3D net) &&
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (t=
b->port =3D=3D port) &&
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (t=
b->ib_addr_ipv4 =3D=3D INADDR_ANY))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 goto found;
>> + =A0 =A0 =A0 =A0 =A0 =A0 } else {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 inet_portaddr_bind_bucket_=
for_each(tb, node, &_head->chain)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((ib_ne=
t(tb) =3D=3D net) &&
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (t=
b->port =3D=3D port) &&
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (t=
b->ib_addr_ipv4 =3D=3D INADDR_ANY))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 goto found;
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 } else {
>> + =A0 =A0 =A0 =A0 =A0 =A0 inet_bind_bucket_for_each(tb, node, &bhead=
->chain)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((ib_net(tb) =3D=3D net=
) && (tb->port =3D=3D port))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto found=
;
>> + =A0 =A0 }
>> +
>> + =A0 =A0 tb =3D NULL;
>> +found:
>> + =A0 =A0 if (portaddr_bhead !=3D portaddrany_bhead)
>> + =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&portaddrany_bhead->lock);
>> +
>> + =A0 =A0 /* the other locks remain taken, as the caller
>> + =A0 =A0 =A0* may want to change the hash tabels */
>> + =A0 =A0 return tb;
>> +}
>> +
>> +
>
> How this is going to work with IPv6 sockets in the middle of the
> chains ?

Now I see it might not work that well. I think I should just skip them
here and only check the IPv4 sockets.

> Also, comments are not properly formatted, they should all look like =
:
>
> =A0 =A0 =A0 =A0/* the other locks remain taken, as the caller
> =A0 =A0 =A0 =A0 * may want to change the hash tables
> =A0 =A0 =A0 =A0 */
>
> And finally, make sure LOCKDEP is happy with your locking code.
>
I will check that too.
