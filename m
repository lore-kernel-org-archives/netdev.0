From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Dynamic number of TCP listeners and SO_REUSEPORT
Date: Tue, 25 Mar 2014 07:35:23 -0700
Message-ID: <1395758123.12610.128.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAKQ1sVMzoVG9rBAR7fUOTp4eXxUWXLMhcYt-SHyKec=9_vLB-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>
To: Yann Ylavic <ylavic.dev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:44660 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752090AbaCYOfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 10:35:25 -0400
Received: by mail-pa0-f50.google.com with SMTP id kq14so522033pab.37
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 07:35:24 -0700 (PDT)
In-Reply-To: <CAKQ1sVMzoVG9rBAR7fUOTp4eXxUWXLMhcYt-SHyKec=9_vLB-w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-03-25 at 14:41 +0100, Yann Ylavic wrote:
> Hi,
> 
> while trying to modify some server's code to take advantage of the new
> SO_REUSEPORT option (introduced in 3.9), I'm currently facing the
> problem described in the original commit message
> (https://lwn.net/Articles/542738/) :
> 
> "The TCP implementation has a problem in that the request sockets for a
> listener are attached to a listener socket.  If a SYN is received, a
> listener socket is chosen and request structure is created (SYN-RECV
> state).  If the subsequent ack in 3WHS does not match the same port
> by so_reusport, the connection state is not found (reset) and the
> request structure is orphaned.  This scenario would occur when the
> number of listener sockets bound to a port changes (new ones are
> added, or old ones closed).  We are looking for a solution to this,
> maybe allow multiple sockets to share the same request table..."
> 
> If the number of listening processes is (forcibly) made constant,
> things work well and performances are really improved compared to not
> using the option (accept mutex, odd scheduling...).
> However this is not the model used by the server, and recycling
> processes is also part of its scalability.
> 
> My tests are with the latest 3.13, but I could not find any reference
> for this issue on the list since the original commit...
> 
> Is this something still being worked on, planned, or already fixed in
> the latest kernel versions?
> 
> Thanks for your answers/pointers.

CC Neal

We are currently working on this issue.

Two mains parts :

1) short term, can be backported

Idea would be to record cpu used by a thread doing an accept(), and
slightly change SO_REUSEPORT selection to check the current cpu
(servicing SYN packet) and the cpu used by the thread.

This would work well only if user threads are cpu bound, or you accept
that the 3rd packet (of the 3WHS) might reach a different LISTENer.

2) Medium term

 I am working on a TCP LISTEN refactoring. In this work, the selection
of the socket to deliver the new child socket is done at the time we
create the full socket, not the request sock. This removes the
constraints and allow full parallelism.

Stay tuned ;)
