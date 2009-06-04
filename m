From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/4] net: skb_orphan on dev_hard_start_xmit
Date: Thu, 04 Jun 2009 06:54:24 +0200
Message-ID: <4A275380.1050601@gmail.com>
References: <200906012157.29465.rusty@rustcorp.com.au>	<4A26E4FD.5010405@gmail.com>	<200906041324.59118.rusty@rustcorp.com.au>
	<20090603.210054.18839960.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: libertas-dev@lists.infradead.org, dcbw@redhat.com, netdev@vger.kernel.org,
        virtualization@lists.linux-foundation.org, rolandd@cisco.com,
        divy@chelsio.com, xemul@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20090603.210054.18839960.davem@davemloft.net>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

David Miller a =E9crit :
> From: Rusty Russell <rusty@rustcorp.com.au>
> Date: Thu, 4 Jun 2009 13:24:57 +0930
> =

>> On Thu, 4 Jun 2009 06:32:53 am Eric Dumazet wrote:
>>> Also, taking a reference on socket for each xmit packet in flight is ve=
ry
>>> expensive, since it slows down receiver in __udp4_lib_lookup(). Several
>>> cpus are fighting for sk->refcnt cache line.
>> Now we have decent dynamic per-cpu, we can finally implement bigrefs.  M=
ore =

>> obvious for device counts than sockets, but perhaps applicable here as w=
ell?
> =

> It might be very beneficial for longer lasting, active, connections, but
> for high connection rates it's going to be a lose in my estimation.

Agreed.

We also can avoid the sock_put()/sock_hold() pair for each tx packet,
to only touch sk_wmem_alloc (with appropriate atomic_sub_return() in sock_w=
free()
and atomic_dec_test in sk_free

We could initialize sk->sk_wmem_alloc to one instead of 0, so that
sock_wfree() could just synchronize itself with sk_free()

void sk_free(struct sock *sk)
{
	if (atomic_dec_test(&sk->sk_wmem_alloc))
		__sk_free(sk)
}

 static inline void skb_set_owner_w(struct sk_buff *skb, struct sock *sk)
 {
-       sock_hold(sk);
        skb->sk =3D sk;
        skb->destructor =3D sock_wfree;
        atomic_add(skb->truesize, &sk->sk_wmem_alloc);
 }

 void sock_wfree(struct sk_buff *skb)
 {
        struct sock *sk =3D skb->sk;
+       int res;

        /* In case it might be waiting for more memory. */
-       atomic_sub(skb->truesize, &sk->sk_wmem_alloc);
+       res =3D atomic_sub_return(skb->truesize, &sk->sk_wmem_alloc);
        if (!sock_flag(sk, SOCK_USE_WRITE_QUEUE))
                sk->sk_write_space(sk);
-       sock_put(sk);
+       if (res =3D=3D 0)
+               __sk_free(sk);
 }

Patch will follow after some testing
