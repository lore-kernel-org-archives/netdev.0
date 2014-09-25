From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 1/1 V4] qdisc: bulk dequeue support for qdiscs
 with TCQ_F_ONETXQUEUE
Date: Thu, 25 Sep 2014 16:40:09 -0700
Message-ID: <1411688409.16953.64.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140924160932.9721.56450.stgit@localhost>
	 <20140924161047.9721.43080.stgit@localhost>
	 <1411579395.15395.41.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140924195831.6fb91051@redhat.com>
	 <CA+mtBx8s63TDe1XS7TzfscwhiRCgyeLkKLz2p-4et1erX0-dUQ@mail.gmail.com>
	 <1411586550.15395.46.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411611140.16953.1.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Toke =?ISO-8859-1?Q?H=F8iland-J=F8rgensen?= <toke@toke.dk>,
	Florian Westphal <fw@strlen.de>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Dave Taht <dave.taht@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36626 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752243AbaIYXkL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 19:40:11 -0400
Received: by mail-pa0-f43.google.com with SMTP id kx10so11853056pab.16
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2014 16:40:10 -0700 (PDT)
In-Reply-To: <1411611140.16953.1.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-09-24 at 19:12 -0700, Eric Dumazet wrote:
> On Wed, 2014-09-24 at 12:22 -0700, Eric Dumazet wrote:
> > On Wed, 2014-09-24 at 11:34 -0700, Tom Herbert wrote:
> > > >
> > > I believe drivers typically use skb->len for BQL tracking. Since
> > > bytelimit is based on BQL here, it might be more correct to use
> > > skb->len.
>=20
> Speaking of BQL, I wonder if we now should try to not wakeup queues a=
s
> soon some room was made, and instead have a 50% threshold ?
>=20
> This would probably increase probability to have bulk dequeues ;)

It turned out the problem I noticed was caused by compiler trying to be
smart, but involving a bad MESI transaction.

  0.05 =E2=94=82  mov    0xc0(%rax),%edi    // LOAD dql->num_queued
  0.48 =E2=94=82  mov    %edx,0xc8(%rax)    // STORE dql->last_obj_cnt =
=3D count
 58.23 =E2=94=82  add    %edx,%edi
  0.58 =E2=94=82  cmp    %edi,0xc4(%rax)
  0.76 =E2=94=82  mov    %edi,0xc0(%rax)    // STORE dql->num_queued +=3D=
 count
  0.72 =E2=94=82  js     bd8


I get an incredible 10 % gain by making sure cpu wont get the cache lin=
e
in Shared mode.

(I also tried a barrier() in netdev_tx_sent_queue() between the

	dql_queued(&dev_queue->dql, bytes);
-
+	barrier();
 	if (likely(dql_avail(&dev_queue->dql) >=3D 0))

But following patch seems cleaner

diff --git a/include/linux/dynamic_queue_limits.h b/include/linux/dynam=
ic_queue_limits.h
index 5621547d631b..978fbe332090 100644
--- a/include/linux/dynamic_queue_limits.h
+++ b/include/linux/dynamic_queue_limits.h
@@ -80,7 +80,7 @@ static inline void dql_queued(struct dql *dql, unsign=
ed int count)
 /* Returns how many objects can be queued, < 0 indicates over limit. *=
/
 static inline int dql_avail(const struct dql *dql)
 {
-	return dql->adj_limit - dql->num_queued;
+	return ACCESS_ONCE(dql->adj_limit) - ACCESS_ONCE(dql->num_queued);
 }
=20
