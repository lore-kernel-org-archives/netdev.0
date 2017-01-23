From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: wrong smp_mb__after_atomic() in tcp_check_space() ?
Date: Mon, 23 Jan 2017 10:04:31 -0800
Message-ID: <1485194671.16328.195.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170123143025.GA31676@redhat.com>
         <f5f9c542-2b23-9df9-098c-ad4007bf7e78@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Oleg Nesterov <oleg@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert.xu@redhat.com>,
        Yauheni Kaliuta <yauheni.kaliuta@redhat.com>,
        netdev@vger.kernel.org
To: Jason Baron <jbaron@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35231 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750705AbdAWSEd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 13:04:33 -0500
Received: by mail-pf0-f195.google.com with SMTP id f144so10446657pfa.2
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 10:04:33 -0800 (PST)
In-Reply-To: <f5f9c542-2b23-9df9-098c-ad4007bf7e78@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-01-23 at 11:56 -0500, Jason Baron wrote:
> On 01/23/2017 09:30 AM, Oleg Nesterov wrote:
> > Hello,
> >
> > smp_mb__after_atomic() looks wrong and misleading, sock_reset_flag() does the
> > non-atomic __clear_bit() and thus it can not guarantee test_bit(SOCK_NOSPACE)
> > (non-atomic too) won't be reordered.
> >
> 
> Indeed. Here's a bit of discussion on it:
> http://marc.info/?l=linux-netdev&m=146662325920596&w=2
> 
> > It was added by 3c7151275c0c9a "tcp: add memory barriers to write space paths"
> > and the patch looks correct in that we need the barriers in tcp_check_space()
> > and tcp_poll() in theory, so it seems tcp_check_space() needs smp_mb() ?
> >
> 
> Yes, I think it should be upgraded to an smp_mb() there. If you agree 
> with this analysis, I will send a patch to upgrade it. Note, I did not 
> actually run into this race in practice.

SOCK_QUEUE_SHRUNK is used locally in TCP, it is not used by tcp_poll().

(Otherwise it would be using atomic set/clear operations)

I do not see obvious reason why we have this smp_mb__after_atomic() in
tcp_check_space().


But looking at this code, it seems we lack one barrier if sk_sndbuf is
ever increased. Fortunately this almost never happen during TCP session
lifetime...

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index bfa165cc455ad0a9aea44964aa663dbe6085aebd..3692e9f4c852cebf8c4d46c141f112e75e4ae66d 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -331,8 +331,13 @@ static void tcp_sndbuf_expand(struct sock *sk)
 	sndmem = ca_ops->sndbuf_expand ? ca_ops->sndbuf_expand(sk) : 2;
 	sndmem *= nr_segs * per_mss;
 
-	if (sk->sk_sndbuf < sndmem)
+	if (sk->sk_sndbuf < sndmem) {
 		sk->sk_sndbuf = min(sndmem, sysctl_tcp_wmem[2]);
+		/* Paired with second sk_stream_is_writeable(sk)
+		 * test from tcp_poll()
+		 */
+		smp_wmb();
+	}
 }
 
 /* 2. Tuning advertised window (window_clamp, rcv_ssthresh)
