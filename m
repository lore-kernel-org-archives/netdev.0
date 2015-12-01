From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Tue,  1 Dec 2015 11:32:23 +0900
Message-ID: <1448937147-38043-1-git-send-email-lorenzo@google.com>
References: <CAHo-OoyN7OgvHSuXxjk7C4FitXhoWffOxY1wkQBWwi+nc013_w@mail.gmail.com>
Cc: davem@davemloft.net, hannes@stressinduktion.org,
	eric.dumazet@gmail.com, ek@google.com, tom@herbertland.com,
	zenczykowski@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36294 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755647AbbLACcf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 21:32:35 -0500
Received: by pacdm15 with SMTP id dm15so204822592pac.3
        for <netdev@vger.kernel.org>; Mon, 30 Nov 2015 18:32:34 -0800 (PST)
In-Reply-To: <CAHo-OoyN7OgvHSuXxjk7C4FitXhoWffOxY1wkQBWwi+nc013_w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is an updated version of the SOCK_DESTROY patch
incorporating some of the feedback received.

There were two substantial concerns expressed on the approach
taken in this patch. The first was that it allows applications
to cause the Linux TCP stack to behave improperly. I believe
this is addressed as follows:

1. This new patchset sends a RST in addition to clearing state.
   This is compliant behaviour: it is the ABORT operation
   specified in RFC 793 [1]. Any app today can do this by
   enabling SO_LINGER with a timeout of 0 and calling close.
2. Multiple other operating systems implement this behaviour:
   - FreeBSD has had this since 5.4 in 2005 [2]. It is available
     to privileged userspace and there is a tool to use it [3].
   - The FreeBSD commit description states that the idea came
     from OpenBSD.
   - iOS has been administratively closing app sockets since
     iOS 4 [see 4, which states that a socket "might get
     reclaimed by the kernel" and after that will return EBADF].

The second concern was that userspace should not be in the
business of making reachability determinations for TCP sockets;
that job belongs to the kernel. But userspace makes reachability
determinations all the time. Most relevant to this patchset:
"-j REJECT --reject-with tcp-reset" has exactly the same
effect as SOCK_DESTROY, except it only does so when the app does
write or the kernel sends a keepalive, not when blocked on read.

Also, there are real use cases where the kernel does not have
enough information to know that a connection is now inoperable.
The kernel can know if a packet can't be routed, but in general
it won't if a TCP connection is dead in the water because it is
now routed to a network where its source address is no longer
valid [5][6]. 

Other concerns have been addressed in this version, as follows:

1. tcp_diag_destroy now does a proper RFC 793 ABORT, i.e., sends
   a RST to the peer. This is consistent with BSD's tcpdrop, and
   is more correct in general, even though in most use cases
   SOCK_DESTROY will only be called when sending a RST is no
   longer possible (e.g., the network has disconnected).
2. Blocking socket operations are interrupted with ECONNABORTED
   instead of ETIMEDOUT. This addresses Tom's point that
   ETIMEDOUT is vague and an explicit notification is needed.
   ECONNABORTED was chosen because it is consistent with BSD.
3. SOCK_DESTROY is placed behind an INET_DIAG_DESTROY
   configuration option, which is off by default.

[1] http://tools.ietf.org/html/rfc793#page-50
[2] http://svnweb.freebsd.org/base?view=revision&revision=141381
[3] https://www.freebsd.org/cgi/man.cgi?query=tcpdrop&sektion=8&manpath=FreeBSD+5.4-RELEASE
[4] https://developer.apple.com/library/ios/technotes/tn2277/_index.html#//apple_ref/doc/uid/DTS40010841-CH1-SUBSECTION3
[5] http://www.spinics.net/lists/netdev/msg352775.html
[6] http://www.spinics.net/lists/netdev/msg352952.html
