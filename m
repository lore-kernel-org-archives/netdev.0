From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [6/6]: jenkins hash for neigh
Date: Mon, 27 Sep 2004 12:14:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927121403.767e2308.davem@davemloft.net>
References: <20040925005623.2faf8faf.davem@davemloft.net>
	<E1CBu70-00010X-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: laforge@gnumonks.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1CBu70-00010X-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 27 Sep 2004 21:56:10 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> David S. Miller <davem@davemloft.net> wrote:
> > 
> > 4) The controversial/RFC patch, dorking with neigh_forced_gc()
> >
> > +			if (n->nud_state -= NUD_INCOMPLETE &&
> > +			    reap_incomplete == 0 &&
> > +			    time_after(jiffies,
> > +				       n->used + n->parms->retrans_time)) {
> > +				num_incomplete++;
> > +				goto next_ent;
> 
> That should either be time_before, or you need to swap the arguments.

Good catch, and it means that the code basically behaved
as if the NUD_INCOMPLETE tests weren't even there.

So, as mentioned in another email, this is what I'm using
in the end:

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/27 11:46:12-07:00 davem@nuts.davemloft.net 
#   [NET]: Remove INCOMPLETE checks from neigh_forced_gc().
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/core/neighbour.c
#   2004/09/27 11:45:40-07:00 davem@nuts.davemloft.net +3 -11
#   [NET]: Remove INCOMPLETE checks from neigh_forced_gc().
# 
diff -Nru a/net/core/neighbour.c b/net/core/neighbour.c
--- a/net/core/neighbour.c	2004-09-27 11:55:57 -07:00
+++ b/net/core/neighbour.c	2004-09-27 11:55:57 -07:00
@@ -123,20 +123,12 @@
 		np = &tbl->hash_buckets[i];
 		while ((n = *np) != NULL) {
 			/* Neighbour record may be discarded if:
-			   - nobody refers to it.
-			   - it is not permanent
-			   - (NEW and probably wrong)
-			     INCOMPLETE entries are kept at least for
-			     n->parms->retrans_time, otherwise we could
-			     flood network with resolution requests.
-			     It is not clear, what is better table overflow
-			     or flooding.
+			 * - nobody refers to it.
+			 * - it is not permanent
 			 */
 			write_lock(&n->lock);
 			if (atomic_read(&n->refcnt) == 1 &&
-			    !(n->nud_state & NUD_PERMANENT) &&
-			    (n->nud_state != NUD_INCOMPLETE ||
-			     time_after(jiffies, n->used + n->parms->retrans_time))) {
+			    !(n->nud_state & NUD_PERMANENT)) {
 				*np	= n->next;
 				n->dead = 1;
 				shrunk	= 1;
