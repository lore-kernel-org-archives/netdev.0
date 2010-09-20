From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] xmit_compl_seq: information to reclaim vmsplice buffers
Date: Mon, 20 Sep 2010 11:22:21 +0800
Message-ID: <AANLkTinyZxF4ep7tv_uSpcPD8gfNoddX6G7p+ZuA2ze9@mail.gmail.com>
References: <alpine.DEB.1.00.1009191451090.5120@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, sridharr@google.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43565 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754403Ab0ITDWm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Sep 2010 23:22:42 -0400
Received: by wyf22 with SMTP id 22so3913042wyf.19
        for <netdev@vger.kernel.org>; Sun, 19 Sep 2010 20:22:41 -0700 (PDT)
In-Reply-To: <alpine.DEB.1.00.1009191451090.5120@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 20, 2010 at 5:55 AM, Tom Herbert <therbert@google.com> wrot=
e:
> In this patch we propose to adds some socket API to retrieve the
> =A0"transmit completion sequence number", essentially a byte counter
> for the number of bytes that have been transmitted and will not be
> retransmitted. =A0In the case of TCP, this should correspond to snd_u=
na.
>
> The purpose of this API is to provide information to userspace about
> which buffers can be reclaimed when sending with vmsplice() on a
> socket.
>
> There are two methods for retrieving the completed sequence number:
> through a simple getsockopt (implemented here for TCP), as well as
> returning the value in the ancilary data of a recvmsg.
>
> The expected flow would be something like:
> =A0 - Connect is created
> =A0 - Initial completion seq # is retrieved through the sockopt, and =
is
> =A0 =A0 stored in userspace "compl_seq" variable for the connection.
> =A0 - Whenever a send is done, compl_seq +=3D # bytes sent.
> =A0 - When doing a vmsplice the completion sequence number is saved
> =A0 =A0 for each user space buffer, buffer_compl_seq =3D compl_seq.
> =A0 - When recvmsg returns with a completion sequence number in
> =A0 =A0 ancillary data, any buffers cover by that sequence number
> =A0 =A0 (where buffer_compl_seq < recvmsg_compl_seq) are reclaimed
> =A0 =A0 and can be written to again.
> =A0 - If no data is receieved on a connection (recvmsg does not
> =A0 =A0 return), a timeout can be used to call the getsockopt and
> =A0 =A0 reclaim buffers as a fallback.
>
> Using recvmsg data in this manner is sort of a cheap way to get a
> "callback" for when a vmspliced buffer is consumed. =A0It will work
> well for a client where the response causes recvmsg to return.

In this case, we don't need it. The response is sufficient to indicate
the request is sent out, and the corresponding pages are available for
the other use.

> On the server side it works well if there are a sufficient
> number of requests coming on the connection (resorting to the
> timeout if necessary as described above).

If no response is sent out by the client, the timeout mechanism may
slow down the data transfer.

I think we should not mix RX and TX. Maybe we can add a new epoll
event to indicate that the snd bufer is advanced.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
