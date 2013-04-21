From: "f6bvp@free" <f6bvp@free.fr>
Subject: Re: [PATCH -next] netrom: fix invalid use of sizeof in nr_recvmsg()
Date: Sun, 21 Apr 2013 20:05:07 +0200
Message-ID: <51742A53.4030907@free.fr>
References: <51742437.6080406@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-hams@vger.kernel.org, netdev@vger.kernel.org
To: Mathias Krause <minipli@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:47930 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751305Ab3DUSGG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Apr 2013 14:06:06 -0400
In-Reply-To: <51742437.6080406@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Mathias,

Thank you for the copy of the thread and sorry for the second post.
It is good to know that someone is taking care of this nice piece of 
network code.

Bernard Pidoux


On Sun, Apr 21, 2013 at 7:39 PM, f6bvp@free <f6bvp@free.fr> wrote:
> Hi,
>
> According to the proximity of NetRom and Rose codes I looked at af_rose.c
> and it seems that similarly sockaddr_rose structure is let uninitialized in
> rose_recvmsg().
>
> Then, would you consider the following patch interesting to be committed ?
>
> --- a/net/rose/af_rose.c        2013-04-17 07:11:28.000000000 +0200
> +++ b/net/rose/af_rose.c        2013-04-21 17:26:06.914967897 +0200
> @@ -1257,6 +1257,7 @@ static int rose_recvmsg(struct kiocb *io
>         skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
>
>         if (srose != NULL) {
> +               memset(srose, 0, sizeof(*srose));
>                 srose->srose_family = AF_ROSE;
>                 srose->srose_addr   = rose->dest_addr;
>                 srose->srose_call   = rose->dest_call;
>
>

Thanks, but something more complete is already in Linus tree
(sizeof(*srose) is not enough):

commit 4a184233f21645cf0b719366210ed445d1024d72
Author: Mathias Krause <minipli@googlemail.com>
Date:   Sun Apr 7 01:51:59 2013 +0000

     rose: fix info leak via msg_name in rose_recvmsg()

     The code in rose_recvmsg() does not initialize all of the members of
     struct sockaddr_rose/full_sockaddr_rose when filling the sockaddr info.
     Nor does it initialize the padding bytes of the structure inserted by
     the compiler for alignment. This will lead to leaking uninitialized
     kernel stack bytes in net/socket.c.

     Fix the issue by initializing the memory used for sockaddr info with
     memset(0).

     Cc: Ralf Baechle <ralf@linux-mips.org>
     Signed-off-by: Mathias Krause <minipli@googlemail.com>
     Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index cf68e6e..9c83474 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -1253,6 +1253,7 @@ static int rose_recvmsg(struct kiocb *iocb, struct 
socket
         skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);

         if (srose != NULL) {
+               memset(srose, 0, msg->msg_namelen);
                 srose->srose_family = AF_ROSE;
                 srose->srose_addr   = rose->dest_addr;
                 srose->srose_call   = rose->dest_call;
