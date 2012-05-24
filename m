From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [RFC PATCH] tcp: Fast/early SYN handling to mitigate SYN floods
Date: Thu, 24 May 2012 15:26:33 +0200
Message-ID: <4FBE3709.6070806@uclouvain.be>
References: <1337864467.13491.15.camel@localhost>
Reply-To: christoph.paasch@uclouvain.be
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Martin Topholm <mph@hoth.dk>, netdev <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:46464 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751156Ab2EXNcb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2012 09:32:31 -0400
In-Reply-To: <1337864467.13491.15.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On 05/24/2012 03:01 PM, Jesper Dangaard Brouer wrote:
> I have been doing some TCP performance measurements with SYN flooding=
,
> and have found that, we don't handle this case well.
>=20
> I have made a patch for fast/early SYN handling in tcp_v4_rcv() in
> net/ipv4/tcp_ipv4.c.  This increases SYN performance from 130 kpps to
> 750 kpps (max of the generator), with idle CPU cycles.
>=20
> Current locking:
>  During a SYN flood (against a single port) all CPUs are spinning on
> the same spinlock, namely bh_lock_sock_nested(sk), in tcp_ipv4.c.  Th=
e
> lock dates back to a commit by DaveM in May 1999, see historic
> commit[1].  It seem that TCP runs fully locked, per sock.
>=20
> I need some help with locking, as the patch seems to work fine, with
> NO-PREEMPT, but with PREEMPT enabled I start to see warnings (in
> reqsk_queue_destroy) and oopses (in inet_csk_reqsk_queue_prune).
>=20
> What am I missing?

=46or each retransmission of a SYN you will add a request-sock to the
syn_table, because you do not pass by tcp_v4_hnd_req(), which checks
this by calling inet_csk_search_req().

And your warning in reqsk_queue_destroy is because the access to the th=
e
request_sock_queue is no more protected by a lock.


The request_sock_queue is a shared resource, which must be protect by a
lock. As you allow "parallel" SYN-processing, the queue will get corrup=
ted.


Cheers,
Christoph


--=20
Christoph Paasch
PhD Student

IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://mptcp.info.ucl.ac.be
Universit=C3=A9 Catholique de Louvain
--=20
