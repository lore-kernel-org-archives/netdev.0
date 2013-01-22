From: Yannick Koehler <yannick@koehler.name>
Subject: Unix Socket buffer attribution
Date: Mon, 21 Jan 2013 21:01:53 -0500
Message-ID: <CAJ4BwwFZo=ktoNBpw14yxyvR1QPQ_xVzKRs=R7qv03g1uwn8pg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f177.google.com ([74.125.82.177]:63158 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751874Ab3AVCBy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 21:01:54 -0500
Received: by mail-we0-f177.google.com with SMTP id d7so498466wer.36
        for <netdev@vger.kernel.org>; Mon, 21 Jan 2013 18:01:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Hi, I got pointed to this list, I have this question about the unix
socket domain buffer attribution system (sorry about the language,
trying to do my best).

  I believe I have found a problem on how memory is associated with a
given socket when using Unix Socket Domains in datagram mode, the
problem is possibly also present in other mode but I have not checked.
 I am not that familiar with kernel debugging, and got to this level
after attempting to understand a user-space application situation.

  I have a server socket, using a unix domain socket.  Many clients
connect to this server.  If one of the client stop calling recvfrom()
on the socket, all others clients stops receiving anymore events.
This is pretty much a observer/subscriver model, where clients do not
need to send stuff in order to receive.

  At the technical level, when my server try to send data to any of my
clients, I get errno EAGAIN (11) on a sendto.  I would have expected
that in such situation, I would get the EAGAIN when calling sendto()
with the address of the particular client which stop calling
recvfrom(), but I actually am getting EAGAIN on all clients, even
those which properly behave and empty their receive buffer using
recvfrom().

  I believe I tracked down in the kernel why this is occurring.  When
sending, the af_unix.c uses sock_alloc_send_skb() and passes as the
first parameter the sk variable that hold my server socket.  This
increase the sk_wmem_alloc variable associated with the server socket.
 Then the code retrieve the socket associated with my destination and
place it under the variable "other".

  It then validate that this "other" socket structure receive queue
isn't full, and then add the newly created skb to that queue.  But,
the memory cost is still accounted for under the server sk_rmem_alloc,
and will only get cleared when the skb gets free using kfree_skb()
which will invoke sock_wfree() and decrease the count.

  Since one of the client isn't calling recvfrom(), the kfree_skb will
never get invoked and therefore the count will only increase.  When
the count exceed or reach the sk_sendrcv_size then the
sock_alloc_send_skb() function always return EAGAIN, independently of
which destination I am trying to reach.

  I believe that the problem is that once we move the skb into the
client's receive queue we need to decrease the sk_wmem_alloc variable
of the server socket since that skb is no more tied to the server.
The code should then account for this memory as part of the
sk_rmem_alloc variable on the client's socket.  The function
"skb_set_owner_r(skb,owner)" would seem to be the function to do that,
so it would seem to me.

--
Yannick Koehler
