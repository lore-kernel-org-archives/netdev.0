From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as
 drain mode
Date: Fri, 25 Mar 2016 11:29:10 -0400
Message-ID: <CAEfhGizvwATcG--OH_xhrV-c1t11ie-vNibJY8kqFAq3GX9upw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:36016 "EHLO
	mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751908AbcCYP3N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 11:29:13 -0400
Received: by mail-lf0-f66.google.com with SMTP id r8so6208457lfe.3
        for <netdev@vger.kernel.org>; Fri, 25 Mar 2016 08:29:12 -0700 (PDT)
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com. [209.85.217.175])
        by smtp.gmail.com with ESMTPSA id mt7sm1962807lbb.25.2016.03.25.08.29.10
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Mar 2016 08:29:10 -0700 (PDT)
Received: by mail-lb0-f175.google.com with SMTP id qe11so49762845lbc.3
        for <netdev@vger.kernel.org>; Fri, 25 Mar 2016 08:29:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 24, 2016 at 2:00 PM, Willy Tarreau <w@1wt.eu> wrote:
> The pattern is :
>
>   t0 : unprivileged processes 1 and 2 are listening to the same port
>        (sock1@pid1) (sock2@pid2)
>        <------ listening ------>
>
>   t1 : new processes are started to replace the old ones
>        (sock1@pid1) (sock2@pid2) (sock3@pid3) (sock4@pid4)
>        <------ listening ------> <------ listening ------>
>
>   t2 : new processes signal the old ones they must stop
>        (sock1@pid1) (sock2@pid2) (sock3@pid3) (sock4@pid4)
>        <------- draining ------> <------ listening ------>
>
>   t3 : pids 1 and 2 have finished, they go away
>                                  (sock3@pid3) (sock4@pid4)
>         <------ gone ----->      <------ listening ------>

To address the documentation issues, I'd like to reference the following:
- The filter.txt document in the kernel tree:
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/Documentation/networking/filter.txt
- It uses (and extends) the BPF instruction set defined in the
original BSD BPF paper: http://www.tcpdump.org/papers/bpf-usenix93.pdf
- The kernel headers define all of the user-space structures used:
  * https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/filter.h
  * https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/bpf.h

I've been trying to come up with an example BPF program for use in the
example Willy gave earlier in this thread (using 4 points in time and
describing one process with two listening sockets replacing another
with two listening sockets).  Everything except the last step is
pretty straight forward using what is currently available in the
kernel.  I'm using random distribution for simplicity, but you could
easily do something smarter using more information about the specific
hardware:

t0: Evenly distrubute load to two SO_REUSEPORT sockets in a single process:
  ld rand
  mod #2
  ret a

t1: Fork a new process, create two new listening sockets in the same
group. Even after calling listen(), but before updating the BPF
program, only the first two sockets will see new connections.  The
program is trivially modified to use all 4.
  ld rand
  mod #4
  ret a

t2: Stop sending new connections to the first two sockets (draining)
  ld rand
  mod #2
  add #2
  ret a

t3: Close the first two sockets and only use the last two.  This is
the tricky step.  Before this point, the sockets are numbered 0
through 3 from the perspective of the BPF program (in the order
listen() was called).  As soon as socket 0 is closed, the last socket
in the list replaces it (what was 3 becomes 0).  When socket 1 is
closed, socket 2 moves into that position.  The assumptions about the
socket indexes in the BPF program need to change as the indexes change
as a result of closing them.

Even if you use an EBPF map as a level of indirection here, you still
have the issue that the socket indexes change as a result of some of
them leaving the group.  I'm not sure yet how to properly fix this,
but it will probably mean changing the way the socket indexing
works...  The current scheme is really an implementation detail
optimized for efficiency.  It may be worth modifying or creating a
mode which results in a stable mapping.  This will probably be
necessary for any scheme which expects sockets to regularly enter or
leave the group.
