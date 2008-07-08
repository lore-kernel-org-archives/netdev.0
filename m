From: "John Heffner" <johnwheffner@gmail.com>
Subject: Re: setsockopt()
Date: Tue, 8 Jul 2008 14:54:47 -0700
Message-ID: <1e41a3230807081454n6460778u8cb889600d07421e@mail.gmail.com>
References: <48725DFE.6000504@citi.umich.edu> <20080707142408.43aa2a2e@extreme>
	 <48728B09.1050801@citi.umich.edu>
	 <20080707.144912.76654646.davem@davemloft.net>
	 <20080708201217.GA16119@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, aglo@citi.umich.edu, shemminger@vyatta.com,
	bfields@fieldses.org
To: "Jim Rees" <rees@umich.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.250]:13280 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751157AbYGHVyt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 17:54:49 -0400
Received: by an-out-0708.google.com with SMTP id d40so549271and.103
        for <netdev@vger.kernel.org>; Tue, 08 Jul 2008 14:54:48 -0700 (PDT)
In-Reply-To: <20080708201217.GA16119@citi.umich.edu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 8, 2008 at 1:12 PM, Jim Rees <rees@umich.edu> wrote:
> David Miller wrote:
>
>  If you set the socket buffer sizes explicitly, you essentially turn
>  off half of the TCP stack because it won't do dynamic socket buffer
>  sizing afterwards.
>
>  There is no reason these days to ever explicitly set the socket
>  buffer sizes on TCP sockets under Linux.
>
> So it seems clear that nfsd should stop setting the socket buffer sizes.
>
> The problem we run into if we try that is that the server won't read any
> incoming data from its socket until an entire rpc has been assembled and is
> waiting to be read off the socket.  An rpc can be almost any size up to
> about 1MB, but the socket buffer never grows past about 50KB, so the rpc can
> never be assembled entirely in the socket buf.
>
> Maybe the nfsd needs a way to tell the socket/tcp layers that it wants a
> minimum size socket buffer.  Or maybe nfsd needs to be modified so that it
> will read partial rpcs.  I would appreciate suggestions as to which is the
> better fix.


This is an interesting observation.  It turns out that the best way to
solve send-side autotuning is not to "tune" the send buffer at all,
but to change its semantics.  From you example, we can clearly see
that the send buffer is overloaded.  It's used to buffer data between
a scheduled application and the event-driven kernel, and also to store
data that may need to be retransmitted.  If you separate the socket
buffer from the retransmit queue, you can size the socket buffer based
on the application's needs (e.g., you want about 1 MB), and the
retransmit queue's size will naturally be bound by cwnd.

I implemented this split about six years ago, but never submitted
largely because it wasn't clear how to handle backward/cross-platform
compatibility of socket options, and because no one seemed to care
about it too much.  (I think you are the first person I remember to
bring up this issue.)

Unfortunately, where this leaves you is still trying to guess the
right socket buffer size.  I actually like your idea for a "soft"
SO_SNDBUF -- ask the kernel for at least that much, but let it
autotune higher if needed.  This is almost trivial to implement --
it's the same as SO_SNDBUF but don't set the sock sndbuf lock.

One thing to note here.  While this option would solve your problem,
there's another similar issue that would not be addressed.  Some
applications want to "feel" the network -- that is, want to as quickly
as possible observe changes in sending rate.  (Say you have an
adaptive codec.)  This application would want a small send buffer, but
a larger retransmit queue.  It's not possible to do this without
splitting the send buffer.

  -John
