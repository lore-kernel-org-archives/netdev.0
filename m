From: "David S. Miller" <davem@davemloft.net>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Mon, 27 Sep 2004 22:58:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927225819.5cf9ade9.davem@davemloft.net>
References: <20040923161141.4ea9be4c.davem@davemloft.net>
	<Pine.NEB.4.33.0409271416360.14606-100000@dexter.psc.edu>
	<20040927160411.22b44f48.davem@davemloft.net>
	<20040927233639.GA8333@gondor.apana.org.au>
	<20040927171356.6a59d039.davem@davemloft.net>
	<20040928003412.GA8755@gondor.apana.org.au>
	<20040927215901.6f65dc15.davem@davemloft.net>
	<20040928051539.GA11354@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jheffner@psc.edu, ak@suse.de, niv@us.ibm.com, andy.grover@gmail.com,
        anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040928051539.GA11354@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 28 Sep 2004 15:15:39 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> > +	if (skb->len != (data_end_seq - data_seq)) {
> 
> Please make that > so that I can sleep at night :)
> 
> > +		if (__tcp_trim_head(sk, skb, data_end_seq - data_seq))
> 
> The argument to __tcp_trim_head should be
> 
> skb->len - (data_end_seq - data_seq)

Good catch, fixed as follows:

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/27 22:37:27-07:00 davem@nuts.davemloft.net 
#   [TCP]: Fix third arg to __tcp_trim_head().
#   
#   Noted by Herbert Xu <herbert@gondor.apana.org.au>
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/ipv4/tcp_output.c
#   2004/09/27 22:36:41-07:00 davem@nuts.davemloft.net +4 -2
#   [TCP]: Fix third arg to __tcp_trim_head().
# 
diff -Nru a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
--- a/net/ipv4/tcp_output.c	2004-09-27 22:37:55 -07:00
+++ b/net/ipv4/tcp_output.c	2004-09-27 22:37:55 -07:00
@@ -980,8 +980,10 @@
 	if (TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN)
 		data_end_seq--;
 
-	if (skb->len != (data_end_seq - data_seq)) {
-		if (__tcp_trim_head(sk, skb, data_end_seq - data_seq))
+	if (skb->len > (data_end_seq - data_seq)) {
+		u32 to_trim = skb->len - (data_end_seq - data_seq);
+
+		if (__tcp_trim_head(sk, skb, to_trim))
 			return -ENOMEM;
 	}		
 
