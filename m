From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: assertion (!atomic_read(&sk->sk_rmem_alloc)) failed at net/netlink/af_netlink.c (122)
Date: Wed, 11 May 2005 10:58:36 +1000
Message-ID: <20050511005836.GA1674@gondor.apana.org.au>
References: <20050510.214332.-1300551106.chamas@h4.dion.ne.jp> <20050510220751.GA459@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="uAKRQypu60I7Lcqm"
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
Content-Disposition: inline
In-Reply-To: <20050510220751.GA459@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--uAKRQypu60I7Lcqm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, May 11, 2005 at 08:07:51AM +1000, herbert wrote:
> On Tue, May 10, 2005 at 12:43:32PM +0000, Ken-ichirou MATSUZAWA wrote:
> > 
> > Everytime on shutting down, the subject message is logged.  
> > It seems that the reason is do_one_broadcast may preempt
> > netlink_recvmsg. Added patch to 2.6.12-rc4 seems resolving this
> > problem.
> 
> Thanks for the patch.  To help me understand the problem better,
> could you please tell me:

I think I understand your patch now.  What's happening is that

1) The skb is sent to socket 1.
2) Someone does a recvmsg on socket 1 and drops the ref on the skb.
   Note that the rmalloc is not returned at this point since the
   skb is still referenced.
3) The same skb is now sent to socket 2.

I agree with your solution except that we should still do the skb_get
if we can.  Here is my version where we only do the skb_get at the
start.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Please let me know whether this works for you or not.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--uAKRQypu60I7Lcqm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -735,12 +735,7 @@ static inline int do_one_broadcast(struc
 
 	sock_hold(sk);
 	if (p->skb2 == NULL) {
-		if (atomic_read(&p->skb->users) != 1) {
-			p->skb2 = skb_clone(p->skb, p->allocation);
-		} else {
-			p->skb2 = p->skb;
-			atomic_inc(&p->skb->users);
-		}
+		p->skb2 = skb_clone(p->skb, p->allocation);
 	}
 	if (p->skb2 == NULL) {
 		netlink_overrun(sk);
@@ -776,7 +771,8 @@ int netlink_broadcast(struct sock *ssk, 
 	info.delivered = 0;
 	info.allocation = allocation;
 	info.skb = skb;
-	info.skb2 = NULL;
+	info.skb2 = skb;
+	skb_get(skb);
 
 	/* While we sleep in clone, do not allow to change socket list */
 

--uAKRQypu60I7Lcqm--
