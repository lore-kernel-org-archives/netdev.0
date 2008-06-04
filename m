From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: How I can reset TCP sockets after long suspend/resume cyscle
Date: Wed, 4 Jun 2008 09:21:54 -0700
Message-ID: <20080604092154.7511c9d3@extreme>
References: <200806011515.14103.maximlevitsky@gmail.com>
	<4846B5F2.8090805@gmail.com>
	<396556a20806040909q7e5eb8abi7cbc8b5ed11ed54e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Maxim Levitsky" <maximlevitsky@gmail.com>, netdev@vger.kernel.org
To: "Adam Langley" <agl@imperialviolet.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:37872 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752574AbYFDQV4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2008 12:21:56 -0400
In-Reply-To: <396556a20806040909q7e5eb8abi7cbc8b5ed11ed54e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 4 Jun 2008 09:09:29 -0700
"Adam Langley" <agl@imperialviolet.org> wrote:

> On Wed, Jun 4, 2008 at 8:34 AM, Maxim Levitsky <maximlevitsky@gmail.com> wrote:
> >> Is there a way to close all TCP sockets before/after suspend to ram?
> 
> As with most things, you should consider how this can be done from
> userspace first.
> 
> You can find the processes with TCP connections open by walking
> /proc/*/fd and readlink()ing the dents therein. Then you can match the
> inode numbers up with /proc/net/tcp to see if the given TCP connection
> is remote or not.
> 
> Now you want to kill those connections somehow. You could imagine
> doing it by injecting RST packets back into the kernel, but for that
> you would need to know the SEQ/ACK numbers for the connection. Since
> that's sensitive information, /proc/net/tcp doesn't carry it. It would
> have to be CAP_NET_ADMIN (read: root user) only and changing the
> formats of proc files based on the reading user is a no-no. So that
> would require another proc file; I've no idea how well that patch
> would be received.
> 
> Another option would be to close the TCP connections from within the
> processes which have them. You could enumerate the processes, ptrace
> attach each one, wait() for SIGSTOP, get the current instr pointer and
> patch in some code to close the fds then unpatch the process and let
> it continue. That would be architecture specific, of couse.
> 
> When the process comes to reading/selecting the fds again it would get
> a 0 read and act like they had been closed.
> 
> I'll admit that neither solution is terribly wonderful.
> 
> 
> AGL

TCP should recover from this anyway. As soon as any activity happens
on the connection the other end will respond with reset.  For an IMAP
session doing the next get-mail should cause a connection reset.
Now it is possible that mail client has other problems.

> 
