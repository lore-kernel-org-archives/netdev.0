From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: Re: [PATCH 7/8] af_unix: implement poll(POLLOUT) for multicast
 sockets
Date: Wed, 9 Feb 2011 14:14:44 +0000
Message-ID: <20110209141444.6f496013@chocolatine.cbg.collabora.co.uk>
References: <20110121143751.57b1453d@chocolatine.cbg.collabora.co.uk>
	<1295620788-6002-7-git-send-email-alban.crequy@collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Lennart Poettering <lennart@poettering.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ian Molton <ian.molton@collabora.co.uk>
To: Alban Crequy <alban.crequy@collabora.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1295620788-6002-7-git-send-email-alban.crequy@collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le Fri, 21 Jan 2011 14:39:47 +0000,
Alban Crequy <alban.crequy@collabora.co.uk> a =C3=A9crit :

> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index 4147d64..138d9a2 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
=2E..
>  	sock_poll_wait(file, sk_sleep(sk), wait);
                             ^^^^^^^^^^^^
> +#ifdef CONFIG_UNIX_MULTICAST
> +	/*
> +	 * On multicast sockets, we need to check if the receiving queue is
> +	 * full on all peers who don't have UNIX_MREQ_DROP_WHEN_FULL.
> +	 */
> +	if (!other || !unix_sk(other)->mcast_group)
> +		goto skip_multicast;
> +	others =3D unix_find_multicast_recipients(sk,
> +		unix_sk(other)->mcast_group, &err);
> +	if (!others)
> +		goto skip_multicast;
> +	for (i =3D others->offset ; i < others->cnt ; i++) {
> +		if (others->items[i].flags & UNIX_MREQ_DROP_WHEN_FULL)
> +			continue;
> +		if (unix_peer(others->items[i].s) !=3D sk) {
> +			sock_poll_wait(file,
> +				&unix_sk(others->items[i].s)->peer_wait, wait);
                                                              ^^^^^^^^^

This code does not work correctly: a poller cannot sleep on two wait
queues at the same time. When the poller is added in ->peer_wait, it
will not be in sk_sleep(sk) so it will miss POLLIN events.

I think I need another wait queue at the group level for waiters of
POLLIN|POLLOUT events. Waiters on that global wait queue would be woken
up when a message is delivered to any peer (in unix_dgram_sendmsg along
sk_data_ready) and when a member of the group receives a message (in
unix_dgram_recvmsg along wake_up_interruptible_sync_poll).
