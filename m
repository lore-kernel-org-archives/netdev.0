From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP-MD5 checksum failure on x86_64 SMP
Date: Fri, 07 May 2010 10:00:22 +0200
Message-ID: <1273219222.2261.11.camel@edumazet-laptop>
References: <i2h571fb4001005031027y4a58c4dtfd28ddcdc08d8401@mail.gmail.com>
	 <o2h571fb4001005032030tdf02a4fag520ec4e56ebdb8df@mail.gmail.com>
	 <1272972722.2097.1.camel@achroite.uk.solarflarecom.com>
	 <l2s571fb4001005040728t91979906ofa10cf0714c305b2@mail.gmail.com>
	 <20100504091215.5a4a51f4@nehalam>
	 <l2k571fb4001005041008k9b129a06vf5e40db2d119434c@mail.gmail.com>
	 <20100504101301.5f4dd9c2@nehalam>
	 <g2p571fb4001005051103w67e1b9ddn3e8f7feb84d0559@mail.gmail.com>
	 <1273085598.2367.233.camel@edumazet-laptop>
	 <i2y571fb4001005060455m39bed7f7if5fcfc45b12bc4d3@mail.gmail.com>
	 <1273210774.2222.45.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Bhaskar Dutta <bhaskie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:57591 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754134Ab0EGIA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 04:00:28 -0400
Received: by bwz19 with SMTP id 19so415797bwz.21
        for <netdev@vger.kernel.org>; Fri, 07 May 2010 01:00:26 -0700 (PDT)
In-Reply-To: <1273210774.2222.45.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 07 mai 2010 =C3=A0 07:39 +0200, Eric Dumazet a =C3=A9crit :
> Le jeudi 06 mai 2010 =C3=A0 17:25 +0530, Bhaskar Dutta a =C3=A9crit :
> > On Thu, May 6, 2010 at 12:23 AM, Eric Dumazet <eric.dumazet@gmail.c=
om> wrote:
>=20
> > > I am not familiar with this code, but I suspect same per_cpu data=
 can be
> > > used at both time by a sender (process context) and by a receiver
> > > (softirq context).
> > >
> > > To trigger this, you need at least two active md5 sockets.
> > >
> > > tcp_get_md5sig_pool() should probably disable bh to make sure cur=
rent
> > > cpu wont be preempted by softirq processing
> > >
> > >
> > > Something like :
> > >
> > > diff --git a/include/net/tcp.h b/include/net/tcp.h
> > > index fb5c66b..e232123 100644
> > > --- a/include/net/tcp.h
> > > +++ b/include/net/tcp.h
> > > @@ -1221,12 +1221,15 @@ struct tcp_md5sig_pool          *tcp_get_=
md5sig_pool(void)
> > >        struct tcp_md5sig_pool *ret =3D __tcp_get_md5sig_pool(cpu)=
;
> > >        if (!ret)
> > >                put_cpu();
> > > +       else
> > > +               local_bh_disable();
> > >        return ret;
> > >  }
> > >
> > >  static inline void             tcp_put_md5sig_pool(void)
> > >  {
> > >        __tcp_put_md5sig_pool();
> > > +       local_bh_enable();
> > >        put_cpu();
> > >  }
> > >
> > >
> > >
> >=20
> > I put in the above change and ran some load tests with around 50
> > active TCP connections doing MD5.
> > I could see only 1 bad packet in 30 min (earlier the problem used t=
o
> > occur instantaneously and repeatedly).
> >=20
>=20
>=20
> > I think there is another possibility of being preempted when callin=
g
> > tcp_alloc_md5sig_pool()
> > this function releases the spinlock when calling __tcp_alloc_md5sig=
_pool().
> >=20
> > I will run some more tests after changing the  tcp_alloc_md5sig_poo=
l
> > and see if the problem is completely resolved.

Here is my official patch submission, could you please test it ?

Thanks

[PATCH] tcp: fix MD5 (RFC2385) support

TCP MD5 support uses percpu data for temporary storage. It currently
disables preemption so that same storage cannot be reclaimed by another
thread on same cpu.

We also have to make sure a softirq handler wont try to use also same
context. Various bug reports demonstrated corruptions.

=46ix is to disable preemption and BH.

Reported-by: Bhaskar Dutta <bhaskie@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/tcp.h |   21 +++------------------
 net/ipv4/tcp.c    |   34 ++++++++++++++++++++++++----------
 2 files changed, 27 insertions(+), 28 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 75be5a2..aa04b9a 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1197,30 +1197,15 @@ extern int			tcp_v4_md5_do_del(struct sock *sk,
 extern struct tcp_md5sig_pool * __percpu *tcp_alloc_md5sig_pool(struct=
 sock *);
 extern void			tcp_free_md5sig_pool(void);
=20
-extern struct tcp_md5sig_pool	*__tcp_get_md5sig_pool(int cpu);
-extern void			__tcp_put_md5sig_pool(void);
+extern struct tcp_md5sig_pool	*tcp_get_md5sig_pool(void);
+extern void			tcp_put_md5sig_pool(void);
+
 extern int tcp_md5_hash_header(struct tcp_md5sig_pool *, struct tcphdr=
 *);
 extern int tcp_md5_hash_skb_data(struct tcp_md5sig_pool *, struct sk_b=
uff *,
 				 unsigned header_len);
 extern int tcp_md5_hash_key(struct tcp_md5sig_pool *hp,
 			    struct tcp_md5sig_key *key);
=20
-static inline
-struct tcp_md5sig_pool		*tcp_get_md5sig_pool(void)
-{
-	int cpu =3D get_cpu();
-	struct tcp_md5sig_pool *ret =3D __tcp_get_md5sig_pool(cpu);
-	if (!ret)
-		put_cpu();
-	return ret;
-}
-
-static inline void		tcp_put_md5sig_pool(void)
-{
-	__tcp_put_md5sig_pool();
-	put_cpu();
-}
-
 /* write queue abstraction */
 static inline void tcp_write_queue_purge(struct sock *sk)
 {
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 0f8caf6..296150b 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2839,7 +2839,6 @@ static void __tcp_free_md5sig_pool(struct tcp_md5=
sig_pool * __percpu *pool)
 			if (p->md5_desc.tfm)
 				crypto_free_hash(p->md5_desc.tfm);
 			kfree(p);
-			p =3D NULL;
 		}
 	}
 	free_percpu(pool);
@@ -2937,25 +2936,40 @@ retry:
=20
 EXPORT_SYMBOL(tcp_alloc_md5sig_pool);
=20
-struct tcp_md5sig_pool *__tcp_get_md5sig_pool(int cpu)
+
+/**
+ *	tcp_get_md5sig_pool - get md5sig_pool for this user
+ *
+ *	We use percpu structure, so if we succeed, we exit with preemption
+ *	and BH disabled, to make sure another thread or softirq handling
+ *	wont try to get same context.
+ */
+struct tcp_md5sig_pool *tcp_get_md5sig_pool(void)
 {
 	struct tcp_md5sig_pool * __percpu *p;
-	spin_lock_bh(&tcp_md5sig_pool_lock);
+
+	local_bh_disable();
+
+	spin_lock(&tcp_md5sig_pool_lock);
 	p =3D tcp_md5sig_pool;
 	if (p)
 		tcp_md5sig_users++;
-	spin_unlock_bh(&tcp_md5sig_pool_lock);
-	return (p ? *per_cpu_ptr(p, cpu) : NULL);
-}
+	spin_unlock(&tcp_md5sig_pool_lock);
+
+	if (p)
+		return *per_cpu_ptr(p, smp_processor_id());
=20
-EXPORT_SYMBOL(__tcp_get_md5sig_pool);
+	local_bh_enable();
+	return NULL;
+}
+EXPORT_SYMBOL(tcp_get_md5sig_pool);
=20
-void __tcp_put_md5sig_pool(void)
+void tcp_put_md5sig_pool(void)
 {
+	local_bh_enable();
 	tcp_free_md5sig_pool();
 }
-
-EXPORT_SYMBOL(__tcp_put_md5sig_pool);
+EXPORT_SYMBOL(tcp_put_md5sig_pool);
=20
 int tcp_md5_hash_header(struct tcp_md5sig_pool *hp,
 			struct tcphdr *th)


