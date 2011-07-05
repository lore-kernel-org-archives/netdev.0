From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] non-preemptible kernel socket for RAMster
Date: Tue, 05 Jul 2011 18:30:30 +0200
Message-ID: <1309883430.2271.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4232c4b6-15be-42d8-be42-6e27f9188ce2@default>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, Konrad Wilk <konrad.wilk@oracle.com>, linux-mm
 <linux-mm@kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <4232c4b6-15be-42d8-be42-6e27f9188ce2@default>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Le mardi 05 juillet 2011 =C3=A0 08:54 -0700, Dan Magenheimer a =C3=A9crit=
 :
> In working on a kernel project called RAMster* (where RAM on a
> remote system may be used for clean page cache pages and for swap
> pages), I found I have need for a kernel socket to be used when
> in non-preemptible state.  I admit to being a networking idiot,
> but I have been successfully using the following small patch.
> I'm not sure whether I am lucky so far... perhaps more
> sockets or larger/different loads will require a lot more
> changes (or maybe even make my objective impossible).
> So I thought I'd post it for comment.  I'd appreciate
> any thoughts or suggestions.
>=20
> Thanks,
> Dan
>=20
> * http://events.linuxfoundation.org/events/linuxcon/magenheimer=20
>=20
> diff -Napur linux-2.6.37/net/core/sock.c linux-2.6.37-ramster/net/core/=
sock.c
> --- linux-2.6.37/net/core/sock.c	2011-07-03 19:14:52.267853088 -0600
> +++ linux-2.6.37-ramster/net/core/sock.c	2011-07-03 19:10:04.340980799 =
-0600
> @@ -1587,6 +1587,14 @@ static void __lock_sock(struct sock *sk)
>  	__acquires(&sk->sk_lock.slock)
>  {
>  	DEFINE_WAIT(wait);
> +	if (!preemptible()) {
> +		while (sock_owned_by_user(sk)) {
> +			spin_unlock_bh(&sk->sk_lock.slock);
> +			cpu_relax();
> +			spin_lock_bh(&sk->sk_lock.slock);
> +		}
> +		return;
> +	}

Hmm, was this tested on UP machine ?

> =20
>  	for (;;) {
>  		prepare_to_wait_exclusive(&sk->sk_lock.wq, &wait,
> @@ -1623,7 +1631,8 @@ static void __release_sock(struct sock *
>  			 * This is safe to do because we've taken the backlog
>  			 * queue private:
>  			 */
> -			cond_resched_softirq();
> +			if (preemptible())
> +				cond_resched_softirq();
>  			skb =3D next;
>  		} while (skb !=3D NULL);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
