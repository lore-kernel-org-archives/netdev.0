From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] accounting for socket backlog
Date: Thu, 25 Feb 2010 12:24:40 +0100
Message-ID: <1267097080.2822.14.camel@edumazet-laptop>
References: <1267067593.16986.1583.camel@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Zhu Yi <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:47476 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759252Ab0BYLYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2010 06:24:46 -0500
Received: by bwz1 with SMTP id 1so2709792bwz.21
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2010 03:24:43 -0800 (PST)
In-Reply-To: <1267067593.16986.1583.camel@debian>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 25 f=C3=A9vrier 2010 =C3=A0 11:13 +0800, Zhu Yi a =C3=A9crit :
> Hi,
>=20
> We got system OOM while running some UDP netperf testing on the loopb=
ack
> device. The case is multiple senders sent stream UDP packets to a sin=
gle
> receiver via loopback on local host. Of course, the receiver is not a=
ble
> to handle all the packets in time. But we surprisingly found that the=
se
> packets were not discarded due to the receiver's sk->sk_rcvbuf limit.
> Instead, they are kept queuing to sk->sk_backlog and finally ate up a=
ll
> the memory. We believe this is a secure hole that a none privileged u=
ser
> can crash the system.
>=20
> The root cause for this problem is, when the receiver is doing
> __release_sock() (i.e. after userspace recv, kernel udp_recvmsg ->
> skb_free_datagram_locked -> release_sock), it moves skbs from backlog=
 to
> sk_receive_queue with the softirq enabled. In the above case, multipl=
e
> busy senders will almost make it an endless loop. The skbs in the
> backlog end up eat all the system memory.
>=20
> The patch fixed this problem by adding accounting for the socket
> backlog. So that the backlog size can be restricted by protocol's cho=
ice
> (i.e. UDP).
>=20
> Signed-off-by: Zhu Yi <yi.zhu@intel.com>
> ---
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 3f1a480..2e003b9 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -253,6 +253,7 @@ struct sock {
>  	struct {
>  		struct sk_buff *head;
>  		struct sk_buff *tail;
> +		atomic_t len;

This adds a hole on 32bit arches.

I am pretty sure we dont need an atomic here, since we must own a lock
before manipulating sk_backlog{head,tail,len}.

UDP/IPV6 should be addressed too in your patch.

Other questions raised by your discovery :
- What about other protocols that also use a backlog ?
- __release_sock() could run forever with no preemption, even with a
limit on backlog.


