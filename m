From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [RFC PATCH 0/2] Faster/parallel SYN handling to mitigate SYN
 floods
Date: Tue, 29 May 2012 22:36:35 +0200
Message-ID: <4FC53353.2050801@uclouvain.be>
References: <20120528115102.12068.79994.stgit@localhost.localdomain> <4FC3A465.4030203@uclouvain.be> <1338322661.7747.17.camel@localhost>
Reply-To: christoph.paasch@uclouvain.be
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Topholm <mph@hoth.dk>, Florian Westphal <fw@strlen.de>,
	opurdila@ixiacom.com,
	Hans Schillstrom <hans.schillstrom@ericsson.com>,
	Andi Kleen <andi@firstfloor.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:47888 "EHLO
	smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753719Ab2E2Ugm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 May 2012 16:36:42 -0400
In-Reply-To: <1338322661.7747.17.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On 05/29/2012 10:17 PM, Jesper Dangaard Brouer wrote:
> On Mon, 2012-05-28 at 18:14 +0200, Christoph Paasch wrote:
>=20
>> On 05/28/2012 01:52 PM, Jesper Dangaard Brouer wrote:
>>> The following series is a RFC (Request For Comments) for implementi=
ng
>>> a faster and parallel handling of TCP SYN connections, to mitigate =
SYN
>>> flood attacks.  This is against DaveM's net (f0d1b3c2bc), as net-ne=
xt
>>> is closed, as DaveM has mentioned numerous times ;-)
>>>
>>> Only IPv4 TCP is handled here. The IPv6 TCP code also need to be
>>> updated, but I'll deal with that part after we have agreed on a
>>> solution for IPv4 TCP.
>>>
>>>  Patch 1/2: Is a cleanup, where I split out the SYN cookie handling
>>>   from tcp_v4_conn_request() into tcp_v4_syn_conn_limit().
>>>
>>>  Patch 2/2: Move tcp_v4_syn_conn_limit() outside bh_lock_sock() in
>>>   tcp_v4_rcv().  I would like some input on, (1) if this safe witho=
ut
>>>   the lock, (2) if we need to do some sock lookup, before calling
>>>   tcp_v4_syn_conn_limit() (Christoph Paasch
>>>   <christoph.paasch@uclouvain.be> mentioned something about SYN
>>>   retransmissions)
>>
>> Concerning (1):
>> I think, there are places where you may have troube because you don'=
t
>> hold the lock.
>> E.g., in tcp_make_synack (called by tcp_v4_send_synack from your
>> tcp_v4_syn_conn_limit) there is:
>>
>> if (sk->sk_userlocks & SOCK_RCVBUF_LOCK &&
>> 	(req->window_clamp > tcp_full_space(sk) ||
>> 	 req->window_clamp =3D=3D 0))
>> 	req->window_clamp =3D tcp_full_space(sk);
>>
>> Thus, tcp_full_space(sk) may have different values between the check=
 and
>> setting req->window_clamp.
>=20
> This should be simply solved by using a local stack variable, for
> storing the result from tcp_full_space(sk).  Its likely that GCC alre=
ady
> does this behind our back.

The place in tcp_make_synack is not the only one where we may have a ra=
ce.

E.g., tcp_syn_flood_action or inet_csk_reqsk_queue_is_full.

And you never know which module is loaded behind
security_inet_conn_request and what it will do.

It must be carefully checked if the race really isn't an issue.

>> Concerning (2):
>>
>> Imagine, a SYN coming in, when the reqsk-queue is not yet full. A
>> request-sock will be added to the reqsk-queue. Then, a retransmissio=
n of
>> this SYN comes in and the queue got full by the time. This time
>> tcp_v4_syn_conn_limit will do syn-cookies and thus generate a differ=
ent
>> seq-number for the SYN/ACK.
>=20
> I have addressed your issue, by checking the reqsk_queue in
> tcp_v4_syn_conn_limit() before allocating a new req via
> inet_reqsk_alloc().
> If I find an existing reqsk, I choose to drop it, so the SYN cookie
> SYN-ACK takes precedence, as the path/handling of the last ACK doesn'=
t
> find this reqsk. This is done under the lock.

Then the receiver will receive two SYN/ACK's for the same SYN with
different sequence-numbers. As the "SYN cookie SYN-ACK" will arrive
second, it will be discarded and seq-numbers from the first one will be
taken on the client-side.

Then, the connection will never establish, as both sides "agreed" on
different sequence numbers.

I would say, you have to handle the retransmitted SYN as in
tcp_v4_hnd_req by calling tcp_check_req.


Cheers,
Christoph


> Test results show that I can provoke the SYN retransmit situation, an=
d
> that performance is still very good. Func call inet_csk_search_req()
> only sneaks up to a top 20 on perf report.
>=20
> Patch on top of this patch:
>=20
> [RFC PATCH 3/2] tcp: Detect SYN retransmits during SYN flood
>=20
>  Check for existing connection request (reqsk) as this might
>  be a retransmitted SYN which have gotten into the
>  reqsk_queue.  If so, we choose to drop the reqsk, and use
>  SYN cookies to restore the state later.
>=20
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 7480fc2..e0c9ba3 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -1274,8 +1274,10 @@ static const struct tcp_request_sock_ops tcp_r=
equest_sock_ipv4_ops =3D {
>   */
>  int tcp_v4_syn_conn_limit(struct sock *sk, struct sk_buff *skb)
>  {
> -       struct request_sock *req;
> +       struct request_sock *req =3D NULL;
>         struct inet_request_sock *ireq;
> +       struct request_sock *exist_req;
> +       struct request_sock **prev;
>         struct tcp_options_received tmp_opt;
>         __be32 saddr =3D ip_hdr(skb)->saddr;
>         __be32 daddr =3D ip_hdr(skb)->daddr;
> @@ -1303,6 +1305,22 @@ int tcp_v4_syn_conn_limit(struct sock *sk, str=
uct sk_buff *skb)
>         if (!tcp_syn_flood_action(sk, skb, "TCP"))
>                 goto drop; /* Not enabled, indicate drop, due to queu=
e full */
> =20
> +       /* Check for existing connection request (reqsk) as this migh=
t
> +        *   be a retransmitted SYN which have gotten into the
> +        *   reqsk_queue.  If so, we choose to drop the reqsk, and us=
e
> +        *   SYN cookies to restore the state later.
> +        */
> +       bh_lock_sock(sk);
> +       exist_req =3D inet_csk_search_req(sk, &prev, tcp_hdr(skb)->so=
urce, saddr, daddr);
> +       if (exist_req) { /* Drop existing reqsk */
> +               if (TCP_SKB_CB(skb)->seq =3D=3D tcp_rsk(exist_req)->r=
cv_isn)
> +                       net_warn_ratelimited("Retransmitted SYN from =
%pI4"
> +                                            " (orig reqsk dropped)",=
 &saddr);
> +
> +               inet_csk_reqsk_queue_drop(sk, exist_req, prev);
> +       }
> +       bh_unlock_sock(sk);
> +
>         /* Allocate a request_sock */
>         req =3D inet_reqsk_alloc(&tcp_request_sock_ops);
>         if (!req) {
>=20
>=20
>=20
> I'll post some V2 patches tomorrow, which integrates this changes in
> patch 2/2.
>=20
>=20


--=20
Christoph Paasch
PhD Student

IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://mptcp.info.ucl.ac.be
Universit=C3=A9 Catholique de Louvain
--=20
