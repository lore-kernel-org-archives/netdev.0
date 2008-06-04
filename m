From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: How I can reset TCP sockets after long suspend/resume cyscle
Date: Wed, 4 Jun 2008 14:15:33 -0700
Message-ID: <20080604141533.35eb6df0@extreme>
References: <200806011515.14103.maximlevitsky@gmail.com>
	<4846B5F2.8090805@gmail.com>
	<396556a20806040909q7e5eb8abi7cbc8b5ed11ed54e@mail.gmail.com>
	<484700A6.3020707@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Adam Langley <agl@imperialviolet.org>, netdev@vger.kernel.org
To: Maxim Levitsky <maximlevitsky@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:54092 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754296AbYFDVPe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2008 17:15:34 -0400
In-Reply-To: <484700A6.3020707@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 04 Jun 2008 23:52:54 +0300
Maxim Levitsky <maximlevitsky@gmail.com> wrote:

> Adam Langley wrote:
> > On Wed, Jun 4, 2008 at 8:34 AM, Maxim Levitsky <maximlevitsky@gmail.com> wrote:
> >>> Is there a way to close all TCP sockets before/after suspend to ram?
> > 
> > As with most things, you should consider how this can be done from
> > userspace first.
> > 
> > You can find the processes with TCP connections open by walking
> > /proc/*/fd and readlink()ing the dents therein. Then you can match the
> > inode numbers up with /proc/net/tcp to see if the given TCP connection
> > is remote or not.
> > 
> > Now you want to kill those connections somehow. You could imagine
> > doing it by injecting RST packets back into the kernel, but for that
> > you would need to know the SEQ/ACK numbers for the connection. Since
> > that's sensitive information, /proc/net/tcp doesn't carry it. It would
> > have to be CAP_NET_ADMIN (read: root user) only and changing the
> > formats of proc files based on the reading user is a no-no. So that
> > would require another proc file; I've no idea how well that patch
> > would be received.
> This isn't a problem, since suspend/resume is done by root.
> I was thinking about something like that, and thought that it is 
> implemented, so I asked here.
> 
> So small question, as a root, I can get SEQ/ACK numbers of a connection?
> 
> I am thinking, that maybe such thing can be put in kernel (as optional 
> feature)
> 
> I can even add a suspend timeout, so if suspend was longer that it, then 
> reset the sockets, otherwise not.
> setting the timeout to 0 (default) will disable the feature.
> 
> 
> > 
> > Another option would be to close the TCP connections from within the
> > processes which have them. You could enumerate the processes, ptrace
> > attach each one, wait() for SIGSTOP, get the current instr pointer and
> > patch in some code to close the fds then unpatch the process and let
> > it continue. That would be architecture specific, of couse.
> > 
> > When the process comes to reading/selecting the fds again it would get
> > a 0 read and act like they had been closed.
> > 
> > I'll admit that neither solution is terribly wonderful.
> > 
> > 
> > AGL
> > 
> 
> Best regards,
> 	Maxim Levitsky

Another idea would be for the kernel to prematurely run the keepalive
timer for all TCP connections after resume. The keepalive code would send
an ACK (out of window) which causes other side to send a RST or ACK.

It is normal behaviour, the change would just make the timer happen sooner.
