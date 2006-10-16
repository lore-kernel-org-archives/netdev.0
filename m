From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] NET : Suspicious locking in reqsk_queue_hash_req()
Date: Mon, 16 Oct 2006 19:39:32 +0200
Message-ID: <200610161939.32769.dada1@cosmosbay.com>
References: <20061010.191547.83619974.davem@davemloft.net> <39e6f6c70610160916x36c86453pa128950896cfc17d@mail.gmail.com> <200610161856.03334.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_UP8MF2ng6NxlixI"
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:64677 "EHLO pfx2.jmh.fr")
	by vger.kernel.org with ESMTP id S1161012AbWJPRjh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2006 13:39:37 -0400
To: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
In-Reply-To: <200610161856.03334.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_UP8MF2ng6NxlixI
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Monday 16 October 2006 18:56, Eric Dumazet wrote:
> On Monday 16 October 2006 18:16, Arnaldo Carvalho de Melo wrote:
> > On 10/16/06, Eric Dumazet <dada1@cosmosbay.com> wrote:
> > > (Sorry, patch inlined this time)
> > >
> > > Hi David
> > >
> > > While browsing include/net/request_sock.h I found this suspicious
> > > locking protecting the SYN table hash table. I think this patch is
> > > necessary.
> > >
> > > Thank you
> >
> > Interesting, just checked and it was there before I moved this out of tcp
> > land:
>
> Well, the bug was there before you put your hands on the code (I checked
> linux-2.4.33 & linux-2.4.1 , bug present on both versions)

Well, 'bug' is not appropriate in fact. Overkill maybe ? 

The comment from include/net/request_sock.h explain the thing...

 * %syn_wait_lock is necessary only to avoid proc interface having to grab the 
main
 * lock sock while browsing the listening hash (otherwise it's deadlock 
prone).
 *
 * This lock is acquired in read mode only from listening_get_next() seq_file
 * op and it's acquired in write mode _only_ from code that is actively
 * changing rskq_accept_head. All readers that are holding the master sock 
lock
 * don't need to grab this lock in read mode too as rskq_accept_head. writes
 * are always protected from the main sock lock.

I bet a more appropriate code (and less prone to reading errors for kernel 
gurus/newbies) would be :

What do you think ?

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--Boundary-00=_UP8MF2ng6NxlixI
Content-Type: text/plain;
  charset="iso-8859-1";
  name="reqsk_queue_hash_req.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="reqsk_queue_hash_req.patch"

--- linux-2.6.19-rc2/include/net/request_sock.h	2006-10-13 18:25:04.000000000 +0200
+++ linux-2.6.19-rc2-ed/include/net/request_sock.h	2006-10-16 19:34:19.000000000 +0200
@@ -254,9 +254,13 @@
 	req->sk = NULL;
 	req->dl_next = lopt->syn_table[hash];
 
-	write_lock(&queue->syn_wait_lock);
+	/*
+	 * We want previous writes being commited before doing this change,
+	 * so that readers of the chain are not confused.
+	 */
+	smp_mb();
+
 	lopt->syn_table[hash] = req;
-	write_unlock(&queue->syn_wait_lock);
 }
 
 #endif /* _REQUEST_SOCK_H */

--Boundary-00=_UP8MF2ng6NxlixI--
