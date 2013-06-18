From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 4/5] net: sctp: decouple cleaning socket data
 from endpoint
Date: Tue, 18 Jun 2013 18:02:26 +0200
Message-ID: <51C08492.7040602@redhat.com>
References: <1371545720-22950-1-git-send-email-dborkman@redhat.com> <1371545720-22950-5-git-send-email-dborkman@redhat.com> <20130618142240.GA27099@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26630 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754648Ab3FRQCf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jun 2013 12:02:35 -0400
In-Reply-To: <20130618142240.GA27099@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/18/2013 04:22 PM, Neil Horman wrote:
> I like this idea, but I think I'm maybe missing something from it - we reference
> the socket in both the receive and send paths (sctp_unpack_cookie, is
> specifically called from the rx path, which makes use of sp->hmac).  a socket
> destructor can be called from __sk_free when sk_wmem_alloc reaches zero, but we
> use sk_refcnt in the rx path to prevent premature socket cleanup.  If we drain
> our send queeue while wer'e still processing rx messages, what prevents us from
> freeing the socket in the tx path, via sk_free while we're still using the
> socket in the rx path.  Note I don't think this patch is wrong per-se, but it
> seems to me there is more work to do to properly interlock the use of sk_refcnt
> and sk_wmem_alloc here (unless I'm just missing something obvious, which is
> entirely possible, I've been in the sun alot lately :) ).

Hm, __sk_free() calls sk_prot_free() which frees our socket structure and in
sctp_wfree() we do a sctp_association_put(asoc) after sock_wfree(skb).

So no matter if having this patch or not, couldn't this use-after-free like
scenario already happen with the current code?

F.e. through a given call graph like that:

sctp_wfree(skb):
  1) sock_wfree(skb)
     -> __sk_free()
      -> sk_prot_free(.., sk)
       -> kmem_cache_free(.., sk) or kfree(sk)
  2) __sctp_write_space(asoc)
  3) sctp_association_put(asoc)
     -> sctp_association_destroy(asoc)
      -> sctp_endpoint_put(asoc->ep)
       -> sctp_endpoint_destroy(ep)
        -> crypto_free_hash(sctp_sk(ep->base.sk)->hmac)
           (etc, all unconditionally accessed while sk is
            already dead/freed)

Then, this might need a fix in general. :-)

Assuming you would reduce the buffer space via setsockopt(.., SO_SNDBUF, ..),
you might end up with a minimum buffer space of SOCK_MIN_SNDBUF [*] and a call to
sk->sk_write_space(sk), which is sctp_write_space() and calls __sctp_write_space()
on all asocs belonging to the socket, but it seems not to alter the current
sk->sk_wmem_alloc I think, but rather sk->sk_sndbuf.

[*] Btw, shouldn't this rather be (2048 + sizeof(struct sk_buff)) or
     SKB_TRUESIZE(2048), at least like in SOCK_MIN_RCVBUF since we operate
     on skb->truesize as well?
