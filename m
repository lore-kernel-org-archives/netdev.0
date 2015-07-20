From: Florian Westphal <fw@strlen.de>
Subject: Re: reproducable panic eviction work queue
Date: Mon, 20 Jul 2015 16:30:23 +0200
Message-ID: <20150720143023.GC11985@breakpoint.cc>
References: <F8D94413-90A2-4F80-AAA2-7A6AB57DF314@transip.nl>
 <1437209795.1026.31.camel@edumazet-glaptop2.roam.corp.google.com>
 <5FD5C17E-B321-404E-80A2-EE46BB8AA746@transip.nl>
 <55AA243D.5020306@cumulusnetworks.com>
 <22C5EB62-8974-432D-9C3B-45F4E4067A45@transip.nl>
 <55AA717D.8080800@cumulusnetworks.com>
 <55ACEDE9.3090205@transip.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Johan Schuijt <johan@transip.nl>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"nikolay@redhat.com" <nikolay@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"fw@strlen.de" <fw@strlen.de>,
	"chutzpah@gentoo.org" <chutzpah@gentoo.org>,
	Robin Geuze <robing@transip.nl>,
	netdev <netdev@vger.kernel.org>
To: Frank Schreuder <fschreuder@transip.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:34656 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932590AbbGTOad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 10:30:33 -0400
Content-Disposition: inline
In-Reply-To: <55ACEDE9.3090205@transip.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rank Schreuder <fschreuder@transip.nl> wrote:
>=20
> On 7/18/2015  05:32 PM, Nikolay Aleksandrov wrote:
> >On 07/18/2015 05:28 PM, Johan Schuijt wrote:
> >>Thx for your looking into this!
> >>
> >>>Thank you for the report, I will try to reproduce this locally
> >>>Could you please post the full crash log ?
> >>Of course, please see attached file.
> >>
> >>>Also could you test
> >>>with a clean current kernel from Linus' tree or Dave's -net ?
> >>Will do.
> >>
> >>>These are available at:
> >>>git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
> >>>git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
> >>>respectively.
> >>>
> >>>One last question how many IRQs do you pin i.e. how many cores
> >>>do you actively use for receive ?
> >>This varies a bit across our systems, but we=E2=80=99ve managed to =
reproduce this with IRQs pinned on as many as 2,4,8 or 20 cores.
> >>
> >>I won=E2=80=99t have access to our test-setup till Monday again, so=
 I=E2=80=99ll be testing 3 scenario=E2=80=99s then:
> >>- Your patch
> >-----
> >>- Linux tree
> >>- Dave=E2=80=99s -net tree
> >Just one of these two would be enough. I couldn't reproduce it here =
but
> >I don't have as many machines to test right now and had to improvise=
 with VMs. :-)
> >
> >>I=E2=80=99ll make sure to keep you posted on all the results then. =
We have a kernel dump of the panic, so if you need me to extract any da=
ta from there just let me know! (Some instructions might be needed)
> >>
> >>- Johan
> >>
> >Great, thank you!
> >
> I'm able to reproduce this panic on the following kernel builds:
> - 3.18.7
> - 3.18.18
> - 3.18.18 + patch from Nikolay Aleksandrov
> - 4.1.0
>=20
> Would you happen to have any more suggestions we can try?

Yes, although I admit its clutching at straws.

Problem is that I don't see how we can race with timer, but OTOH
I don't see why this needs to play refcnt tricks if we can just skip
the entry completely ...

The other issue is parallel completion on other cpu, but don't
see how we could trip there either.

Do you always get this one crash backtrace from evictor wq?

I'll set up a bigger test machine soon and will also try to reproduce
this.

Thanks for reporting!

diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -131,24 +131,14 @@ inet_evict_bucket(struct inet_frags *f, struct in=
et_frag_bucket *hb)
 	unsigned int evicted =3D 0;
 	HLIST_HEAD(expired);
=20
-evict_again:
 	spin_lock(&hb->chain_lock);
=20
 	hlist_for_each_entry_safe(fq, n, &hb->chain, list) {
 		if (!inet_fragq_should_evict(fq))
 			continue;
=20
-		if (!del_timer(&fq->timer)) {
-			/* q expiring right now thus increment its refcount so
-			 * it won't be freed under us and wait until the timer
-			 * has finished executing then destroy it
-			 */
-			atomic_inc(&fq->refcnt);
-			spin_unlock(&hb->chain_lock);
-			del_timer_sync(&fq->timer);
-			inet_frag_put(fq, f);
-			goto evict_again;
-		}
+		if (!del_timer(&fq->timer))
+			continue;
=20
 		fq->flags |=3D INET_FRAG_EVICTED;
 		hlist_del(&fq->list);
@@ -240,18 +230,20 @@ void inet_frags_exit_net(struct netns_frags *nf, =
struct inet_frags *f)
 	int i;
=20
 	nf->low_thresh =3D 0;
-	local_bh_disable();
=20
 evict_again:
+	local_bh_disable();
 	seq =3D read_seqbegin(&f->rnd_seqlock);
=20
 	for (i =3D 0; i < INETFRAGS_HASHSZ ; i++)
 		inet_evict_bucket(f, &f->hash[i]);
=20
-	if (read_seqretry(&f->rnd_seqlock, seq))
-		goto evict_again;
-
 	local_bh_enable();
+	cond_resched();
+
+	if (read_seqretry(&f->rnd_seqlock, seq) ||
+	    percpu_counter_sum(&nf->mem))
+		goto evict_again;
=20
 	percpu_counter_destroy(&nf->mem);
 }
@@ -286,6 +278,8 @@ static inline void fq_unlink(struct inet_frag_queue=
 *fq, struct inet_frags *f)
 	hb =3D get_frag_bucket_locked(fq, f);
 	if (!(fq->flags & INET_FRAG_EVICTED))
 		hlist_del(&fq->list);
+
+	fq->flags |=3D INET_FRAG_COMPLETE;
 	spin_unlock(&hb->chain_lock);
 }
=20
@@ -297,7 +291,6 @@ void inet_frag_kill(struct inet_frag_queue *fq, str=
uct inet_frags *f)
 	if (!(fq->flags & INET_FRAG_COMPLETE)) {
 		fq_unlink(fq, f);
 		atomic_dec(&fq->refcnt);
-		fq->flags |=3D INET_FRAG_COMPLETE;
 	}
 }
 EXPORT_SYMBOL(inet_frag_kill);
