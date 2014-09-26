From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] dql: dql_queued() should write first to reduce bus
 transactions
Date: Thu, 25 Sep 2014 23:04:56 -0700
Message-ID: <1411711496.16953.92.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140924160932.9721.56450.stgit@localhost>
	 <20140924161047.9721.43080.stgit@localhost>
	 <1411579395.15395.41.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140924195831.6fb91051@redhat.com>
	 <CA+mtBx8s63TDe1XS7TzfscwhiRCgyeLkKLz2p-4et1erX0-dUQ@mail.gmail.com>
	 <1411586550.15395.46.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411611140.16953.1.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411688409.16953.64.camel@edumazet-glaptop2.roam.corp.google.com>
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
Received: from mail-pa0-f53.google.com ([209.85.220.53]:52354 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753266AbaIZGE6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 02:04:58 -0400
Received: by mail-pa0-f53.google.com with SMTP id kq14so367376pab.26
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2014 23:04:57 -0700 (PDT)
In-Reply-To: <1411688409.16953.64.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

While doing high throughput test on a BQL enabled NIC,
I found a very high cost in ndo_start_xmit() when accessing BQL data.

It turned out the problem was caused by compiler trying to be
smart, but involving a bad MESI transaction :

  0.05 =E2=94=82  mov    0xc0(%rax),%edi    // LOAD dql->num_queued
  0.48 =E2=94=82  mov    %edx,0xc8(%rax)    // STORE dql->last_obj_cnt =
=3D count
 58.23 =E2=94=82  add    %edx,%edi
  0.58 =E2=94=82  cmp    %edi,0xc4(%rax)
  0.76 =E2=94=82  mov    %edi,0xc0(%rax)    // STORE dql->num_queued +=3D=
 count
  0.72 =E2=94=82  js     bd8


I got an incredible 10 % gain [1] by making sure cpu do not attempt
to get the cache line in Shared mode, but directly requests for
ownership.

New code :
	mov    %edx,0xc8(%rax)  // STORE dql->last_obj_cnt =3D count
	add    %edx,0xc0(%rax)  // RMW   dql->num_queued +=3D count
	mov    0xc4(%rax),%ecx  // LOAD dql->adj_limit
	mov    0xc0(%rax),%edx  // LOAD dql->num_queued
	cmp    %edx,%ecx

The TX completion was running from another cpu, with high interrupts
rate.

Note that I am using barrier() as a soft hint, as mb() here could be
too heavy cost.

[1] This was a netperf TCP_STREAM with TSO disabled, but GSO enabled.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/dynamic_queue_limits.h |   12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/include/linux/dynamic_queue_limits.h b/include/linux/dynam=
ic_queue_limits.h
index 5621547d631b..a4be70398ce1 100644
--- a/include/linux/dynamic_queue_limits.h
+++ b/include/linux/dynamic_queue_limits.h
@@ -73,14 +73,22 @@ static inline void dql_queued(struct dql *dql, unsi=
gned int count)
 {
 	BUG_ON(count > DQL_MAX_OBJECT);
=20
-	dql->num_queued +=3D count;
 	dql->last_obj_cnt =3D count;
+
+	/* We want to force a write first, so that cpu do not attempt
+	 * to get cache line containing last_obj_cnt, num_queued, adj_limit
+	 * in Shared state, but directly does a Request For Ownership
+	 * It is only a hint, we use barrier() only.
+	 */
+	barrier();
+
+	dql->num_queued +=3D count;
 }
=20
 /* Returns how many objects can be queued, < 0 indicates over limit. *=
/
 static inline int dql_avail(const struct dql *dql)
 {
-	return dql->adj_limit - dql->num_queued;
+	return ACCESS_ONCE(dql->adj_limit) - ACCESS_ONCE(dql->num_queued);
 }
=20
 /* Record number of completed objects and recalculate the limit. */
