From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Bug#243084: net-tools: netstat do not display some ipv6 listening sockets
Date: Sat, 1 May 2004 16:50:11 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040501065011.GA25540@gondor.apana.org.au>
References: <E1BCQ8h-0005bb-8s@thorr.asgardr.info> <20040411211116.GA32025@lina.inka.de> <87smfagpxf.fsf@thorr.asgardr.info> <20040412001011.GB3310@lina.inka.de> <20040412080013.GA24732@gondor.apana.org.au> <87fzb9z8zp.fsf@thorr.asgardr.info>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="sm4nu43k4a2Rpi4c"
Cc: Bernd Eckenfels <be-mail2004@lina.inka.de>,
        "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Daniel 'NebuchadnezzaR' Dehennin" <nebuchadnezzar@nerim.net>,
        243084@bugs.debian.org
Content-Disposition: inline
In-Reply-To: <87fzb9z8zp.fsf@thorr.asgardr.info>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--sm4nu43k4a2Rpi4c
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tags 243084 pending
quit

On Mon, Apr 12, 2004 at 02:16:58PM +0200, Daniel 'NebuchadnezzaR' Dehennin wrote:
> 
> I made a little piece of code inspired by my patch to mailutils, it's
> dirty code I prefere prevent you ;-)

Thanks for the test case.

Hi Dave:

There is a bug in listening_get_first() which used by /proc/net/tcp*
where it wasn't looping through all the sockets in each hash chain.
This problem doesn't show up unless the first socket in a chain doesn't
match the family that is being looked up.

The following patch fixes this by getting rid of listening_get_first()
altogether.

Cheers,
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--sm4nu43k4a2Rpi4c
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

Index: net/ipv4/tcp_ipv4.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/net/ipv4/tcp_ipv4.c,v
retrieving revision 1.4
diff -u -r1.4 tcp_ipv4.c
--- a/net/ipv4/tcp_ipv4.c	5 Apr 2004 10:54:54 -0000	1.4
+++ b/net/ipv4/tcp_ipv4.c	1 May 2004 06:22:20 -0000
@@ -2137,46 +2137,6 @@
 		hlist_entry(tw->tw_node.next, typeof(*tw), tw_node) : NULL;
 }
 
-static void *listening_get_first(struct seq_file *seq)
-{
-	struct tcp_iter_state* st = seq->private;
-	void *rc = NULL;
-
-	for (st->bucket = 0; st->bucket < TCP_LHTABLE_SIZE; ++st->bucket) {
-		struct open_request *req;
-		struct tcp_opt *tp;
-		struct sock *sk = sk_head(&tcp_listening_hash[st->bucket]);
-
-		if (!sk)
-			continue;
-		if (sk->sk_family == st->family) {
-			rc = sk;
-			goto out;
-		}
-	       	tp = tcp_sk(sk);
-		read_lock_bh(&tp->syn_wait_lock);
-		if (tp->listen_opt && tp->listen_opt->qlen) {
-			st->uid		= sock_i_uid(sk);
-			st->syn_wait_sk = sk;
-			st->state	= TCP_SEQ_STATE_OPENREQ;
-			for (st->sbucket = 0; st->sbucket < TCP_SYNQ_HSIZE;
-			     ++st->sbucket) {
-				for (req = tp->listen_opt->syn_table[st->sbucket];
-				     req; req = req->dl_next) {
-					if (req->class->family != st->family)
-						continue;
-					rc = req;
-					goto out;
-				}
-			}
-			st->state = TCP_SEQ_STATE_LISTENING;
-		}
-		read_unlock_bh(&tp->syn_wait_lock);
-	}
-out:
-	return rc;
-}
-
 static void *listening_get_next(struct seq_file *seq, void *cur)
 {
 	struct tcp_opt *tp;
@@ -2184,6 +2144,12 @@
 	struct sock *sk = cur;
 	struct tcp_iter_state* st = seq->private;
 
+	if (!sk) {
+		st->bucket = 0;
+		sk = sk_head(&tcp_listening_hash[0]);
+		goto get_sk;
+	}
+
 	++st->num;
 
 	if (st->state == TCP_SEQ_STATE_OPENREQ) {
@@ -2237,7 +2203,7 @@
 
 static void *listening_get_idx(struct seq_file *seq, loff_t *pos)
 {
-	void *rc = listening_get_first(seq);
+	void *rc = listening_get_next(seq, NULL);
 
 	while (rc && *pos) {
 		rc = listening_get_next(seq, rc);

--sm4nu43k4a2Rpi4c--
