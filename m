From: Piergiorgio Beruto <piergiorgio.beruto@gmail.com>
Subject: Possible bugfix for AF_UNIX, SOCK_SEQPACKET sockets
Date: Tue, 14 Feb 2012 23:05:27 +0100
Message-ID: <CAFJW8X86fGhK4cwH0=dQrK8TSJdmPB51TgLjcK=wdOBQzNeF-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:55334 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760888Ab2BNWF2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 17:05:28 -0500
Received: by qcqw6 with SMTP id w6so292639qcq.19
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2012 14:05:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
I would like to have your opinion regarding what I think could be a
misbehaviour of the SIOCINQ ioctl on AF_UNIX domain sockets.

I was implementing an IPC user-space library which makes use of a
variety of sockets for sending data all around.
When dealing with datagram sockets (i.e. SOCK_DGRAM, SOCK_RDM and
SOCK_SEQPACKET) I used to implement the following paradigm:

1) issue the SIOCINQ (aka FIONREAD) ioctl and get the "size of the
first queued datagram"
2) allocate memory of that size and fill it reading out data from the socket

This works very fine for UDP and TIPC (including SOCK_SEQPACKET)
sockets but when using AF_UNIX (SEQPACKET) sockets the same ioctl
returns instead the number of bytes queued (sum of all pending
datagrams) .

In short, there is no way (as far as I know) to work out how much
memory to allocate in userspace before reading out the datagram.
The workaround for this is to use a fixed swap buffer of the max
possible size of your packets (assuming you know / can retrieve it
somehow) and make a copy of your data (which is bad for performance
anyway).

Looking at the kernel code I've found this in the
linux/net/unix/af_unix.c file (my comment with ////)

case SIOCINQ:
	{
	        struct sk_buff *skb;
	
	        if (sk->sk_state == TCP_LISTEN) {
	                err = -EINVAL;
	                break;
	        }
	
	        spin_lock(&sk->sk_receive_queue.lock);
	        if (sk->sk_type == SOCK_STREAM ||
	            sk->sk_type == SOCK_SEQPACKET) {           //// <--------
treats SEQPACKET as SOCK_STREAM
	                skb_queue_walk(&sk->sk_receive_queue, skb)
	                        amount += skb->len;
	        } else {
	                skb = skb_peek(&sk->sk_receive_queue);
	                if (skb)
	                        amount = skb->len;
	        }
	        spin_unlock(&sk->sk_receive_queue.lock);
	        err = put_user(amount, (int __user *)arg);
	        break;
	}

In my opinion SOCK_SEQPACKETS are similar to SOCK_STREAM because they
are "connection oriented" sockets but from the I/O point of view are
more similar to datagram ones.

My proposal is to remove the above condition from the test and let the
function process SOCK_SEQPACKETS as if they were SOCK_DGRAM for this
particular ioctl.

Thank you for your time,
Regards,

PIergiorgio
