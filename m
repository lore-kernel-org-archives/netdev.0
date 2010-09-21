From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] xmit_compl_seq: information to reclaim vmsplice
 buffers
Date: Tue, 21 Sep 2010 23:38:51 +0200
Message-ID: <1285105131.6378.19.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1009211154150.32565@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, sridharr@google.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37452 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754325Ab0IUVjG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 17:39:06 -0400
Received: by wyf22 with SMTP id 22so5869433wyf.19
        for <netdev@vger.kernel.org>; Tue, 21 Sep 2010 14:39:04 -0700 (PDT)
In-Reply-To: <alpine.DEB.1.00.1009211154150.32565@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 21 septembre 2010 =C3=A0 11:57 -0700, Tom Herbert a =C3=A9crit=
 :
> In this patch we propose to adds some socket API to retrieve the
>  "transmit completion sequence number", essentially a byte counter
> for the number of bytes that have been transmitted and will not be
> retransmitted.  In the case of TCP, this should correspond to snd_una=
=2E
>=20
> The purpose of this API is to provide information to userspace about
> which buffers can be reclaimed when sending with vmsplice() on a
> socket.
>=20
> There are two methods for retrieving the completed sequence number:
> through a simple getsockopt (implemented here for TCP), as well as
> returning the value in the ancilary data of a recvmsg.
>=20
> The expected flow would be something like:
>    - Connect is created
>    - Initial completion seq # is retrieved through the sockopt, and i=
s
>      stored in userspace "compl_seq" variable for the connection.
>    - Whenever a send is done, compl_seq +=3D # bytes sent.
>    - When doing a vmsplice the completion sequence number is saved
>      for each user space buffer, buffer_compl_seq =3D compl_seq.
>    - When recvmsg returns with a completion sequence number in
>      ancillary data, any buffers cover by that sequence number
>      (where buffer_compl_seq < recvmsg_compl_seq) are reclaimed
>      and can be written to again.
>    - If no data is receieved on a connection (recvmsg does not
>      return), a timeout can be used to call the getsockopt and
>      reclaim buffers as a fallback.
>=20
> Using recvmsg data in this manner is sort of a cheap way to get a
> "callback" for when a vmspliced buffer is consumed.  It will work
> well for a client where the response causes recvmsg to return.
> On the server side it works well if there are a sufficient
> number of requests coming on the connection (resorting to the
> timeout if necessary as described above).
>=20
> Signed-off-by: Tom Herbert <therbert@google.com>


> + * Copy the first unacked seq into the receive msg control part.
> + */
> +static inline void tcp_sock_xmit_compl_seq(struct msghdr *msg,
> +					   struct sock *sk)
> +{
> +	if (sock_flag(sk, SOCK_XMIT_COMPL_SEQ)) {
> +		struct tcp_sock *tp =3D tcp_sk(sk);
> +		if (msg->msg_controllen >=3D sizeof(tp->snd_una)) {
> +			put_cmsg(msg, SOL_SOCKET, SCM_XMIT_COMPL_SEQ,
> +			    sizeof(tp->snd_una), &tp->snd_una);
> +		}
> +	}
> +}

I am wondering if this part could be done outside of socket lock,
provided you latch tp->snd_una value right before release_sock();

u32 snd_una;
=2E..
tcp_cleanup_rbuf(sk, copied);
TCP_CHECK_TIMER(sk);
snd_una =3D tp->snd_una;
release_sock(sk);
tcp_sock_xmit_compl_seq(msg, sk, snd_una);
return copied;



