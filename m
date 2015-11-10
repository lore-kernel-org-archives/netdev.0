From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next 4/4] net: af_unix: implement splice for
 stream af_unix sockets
Date: Mon, 09 Nov 2015 17:11:58 -0800
Message-ID: <1447117918.17135.59.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cover.1432220158.git.hannes@stressinduktion.org>
	 <2608f83f33225b05eb8a4bf0275f05dce83edfd3.1432220158.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, cwang@twopensource.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:32808 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030AbbKJBMA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2015 20:12:00 -0500
Received: by pabfh17 with SMTP id fh17so216516572pab.0
        for <netdev@vger.kernel.org>; Mon, 09 Nov 2015 17:12:00 -0800 (PST)
In-Reply-To: <2608f83f33225b05eb8a4bf0275f05dce83edfd3.1432220158.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-05-21 at 17:00 +0200, Hannes Frederic Sowa wrote:

> +
> +static ssize_t skb_unix_socket_splice(struct sock *sk,
> +				      struct pipe_inode_info *pipe,
> +				      struct splice_pipe_desc *spd)
> +{
> +	int ret;
> +	struct unix_sock *u = unix_sk(sk);
> +
> +	mutex_unlock(&u->readlock);
> +	ret = splice_to_pipe(pipe, spd);
> +	mutex_lock(&u->readlock);
> +
> +	return ret;
> +}
> +

Hi Hannes

Since we release u->readlock, what prevents another thread to read() the
same af_unix socket and consume the skb while we splice it ?

TCP stack has special code to take care of this possibility.

tcp_read_sock() :

                        used = recv_actor(desc, skb, offset, len);
                        if (used <= 0) {
                                if (!copied)
                                        copied = used;
                                break;
                        } else if (used <= len) {
                                seq += used;
                                copied += used;
                                offset += used;
                        }
                        /* If recv_actor drops the lock (e.g. TCP splice
                         * receive) the skb pointer might be invalid when
                         * getting here: tcp_collapse might have deleted it
                         * while aggregating skbs from the socket queue.
                         */
                        skb = tcp_recv_skb(sk, seq - 1, &offset);
                        if (!skb)
                                break;
                        /* TCP coalescing might have appended data to the skb.
                         * Try to splice more frags
                         */
                        if (offset + 1 != skb->len)
                                continue;
