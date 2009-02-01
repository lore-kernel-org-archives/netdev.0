From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: Re: virt-manager broken by bind(0) in net-next.
Date: Sat, 31 Jan 2009 21:58:50 -0800
Message-ID: <20090131215850.3dfc29fb@extreme>
References: <20090130112125.GA9908@ioremap.net>
	<20090130125337.GA7155@gondor.apana.org.au>
	<20090130095737.103edbff@extreme> <498349F7.4050300@cosmosbay.com>
	<20090130215008.GB12210@ioremap.net>
Reply-To: Fedora/Linux Management Tools <et-mgmt-tools-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>, et-mgmt-tools-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>
Return-path: <et-mgmt-tools-bounces-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <20090130215008.GB12210-i6C2adt8DTjR7s880joybQ@public.gmane.org>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/et-mgmt-tools>,
	<mailto:et-mgmt-tools-request-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/et-mgmt-tools>
List-Post: <mailto:et-mgmt-tools-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Help: <mailto:et-mgmt-tools-request-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/et-mgmt-tools>,
	<mailto:et-mgmt-tools-request-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org?subject=subscribe>
Sender: et-mgmt-tools-bounces-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Errors-To: et-mgmt-tools-bounces-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 31 Jan 2009 00:50:08 +0300
Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org> wrote:

> On Fri, Jan 30, 2009 at 07:41:59PM +0100, Eric Dumazet (dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org) wrote:
> > Reviewing commit a9d8f9110d7e953c2f2b521087a4179677843c2a
> > 
> > I see use of a hashinfo->bsockets field that :
> > 
> > - lacks proper lock/synchronization
> 
> It should contain rough number of sockets, there is no need to be very
> precise because of this hueristic.
> 
> > - suffers from cache line ping pongs on SMP
> 
> I used free alignment slot so that socket structure would not be
> icreased.
> 
> > Also there might be a problem at line 175
> > 
> > if (sk->sk_reuse && sk->sk_state != TCP_LISTEN && --attempts >= 0) { 
> > 	spin_unlock(&head->lock);
> > 	goto again;
> > 
> > If we entered inet_csk_get_port() with a non null snum, we can "goto again"
> > while it was not expected.
> > 
> > diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
> > index df8e72f..752c6b2 100644
> > --- a/net/ipv4/inet_connection_sock.c
> > +++ b/net/ipv4/inet_connection_sock.c
> > @@ -172,7 +172,8 @@ tb_found:
> >  		} else {
> >  			ret = 1;
> >  			if (inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb)) {
> > -				if (sk->sk_reuse && sk->sk_state != TCP_LISTEN && --attempts >= 0) {
> > +				if (sk->sk_reuse && sk->sk_state != TCP_LISTEN &&
> > +					smallest_size == -1 &&  --attempts >= 0) {
> 
> I think it should be smallest_size != -1, since we really want to goto
> to the again label when hueristic is used, which in turn changes
> smallest_size.
> 

Yes, this fixes the problem, not sure who wants the honors for sending a signed off
version.




--- a/net/ipv4/inet_connection_sock.c	2009-01-31 21:18:45.433239861 -0800
+++ b/net/ipv4/inet_connection_sock.c	2009-01-31 21:30:14.720825414 -0800
@@ -172,7 +172,8 @@ tb_found:
 		} else {
 			ret = 1;
 			if (inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb)) {
-				if (sk->sk_reuse && sk->sk_state != TCP_LISTEN && --attempts >= 0) {
+				if (sk->sk_reuse && sk->sk_state != TCP_LISTEN &&
+				    smallest_size != -1 && --attempts >= 0) {
 					spin_unlock(&head->lock);
 					goto again;
 				}
