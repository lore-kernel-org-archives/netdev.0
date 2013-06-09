From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 1/3] net: sctp: let sctp_destroy_sock destroy
 related members
Date: Sat, 8 Jun 2013 20:20:54 -0400
Message-ID: <20130609002054.GA5386@neilslaptop.think-freely.org>
References: <1370594106-25745-1-git-send-email-dborkman@redhat.com>
 <1370594106-25745-2-git-send-email-dborkman@redhat.com>
 <20130607105419.GA3249@hmsreliant.think-freely.org>
 <51B1C5A4.7080906@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50189 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752983Ab3FIAVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Jun 2013 20:21:07 -0400
Content-Disposition: inline
In-Reply-To: <51B1C5A4.7080906@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 07, 2013 at 01:36:04PM +0200, Daniel Borkmann wrote:
> On 06/07/2013 12:54 PM, Neil Horman wrote:
> >I'm not sure this is safe.  Comment in sk_common_release indicates that the
> >network can still find the socket in the receive path.  What if we receive a
> >cookie chunk while the socket is being torn down?  We would wind up using the
> >hmac to unpack it potentially after you just freed it.  I think you need to wait
> >until you drop the last reference to the endpoint, not whenever you destroy the
> >local socket.  Note that sctp_endpoint_free doesn't actually free anything, it
> >just removes it from the hash list so it can't be found again, and drops a
> >refcount.  If a parallel recieve op has already found it, hmac may still be
> >used.
> 
> Agreed, you're right, thanks for pointing this out Neil! Is it *always* guaranteed
> that at the time the endpoint is destroyed in a deferred way (e.g. exactly in such
> a scenario you describe), the socket structure is still alive and not yet freed?
> Either the ep->base.sk test in sctp_endpoint_destroy() would then be unnecessary
> or, if necessary, we should move crypto_free_hash() and sctp_put_port() within this
> body since they deref. socket members (but then that memory would be leaked in case
> ep->base.sk is NULL). Probably, it might be best to add sth like this to explicitly
> decouple it from the endpoint, which is then called when all refs are released from
> the socket; then we could call this from __sk_free() via sk->sk_destruct():
> 
Thats a good question, I'm on vacation right now, so I'm not looking to closely
at much (I've spent all day in a pool).  I think what you're proposing below
probably makes sense.  Since the hmac crypo instance is allocated when the
socket transitions to the listening state in sctp_listen, it makes sense to
destroy it in sctp_sock_destroy.  If we need to we can protect it as an rcu
variable to protect it against parallel reads from cookie processing.  If it
fails in that case, its irrelevant, as the local socket is shutting down anyway.

Best
Neil

> static void sctp_sock_destruct(struct sock *sk)
> {
> 	struct sctp_sock *sp = sctp_sk(sk);
> 
> 	inet_sock_destruct(sk);
> 
> 	/* Free up the HMAC transform. */
> 	crypto_free_hash(sp->hmac);
> 
> 	/* Remove and free the port */
> 	if (sp->bind_hash)
> 		sctp_put_port(sk);
> }
> 
