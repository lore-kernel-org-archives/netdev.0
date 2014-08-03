From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: weird behaviour, getting EAGAIN on a connect() call on a unix
 stream socket
Date: Sun, 03 Aug 2014 08:14:02 +0200
Message-ID: <1407046442.3178.64.camel@edumazet-glaptop2.roam.corp.google.com>
References: <53DC6039.2010002@windriver.com>
	 <1406960889.3178.60.camel@edumazet-glaptop2.roam.corp.google.com>
	 <53DCF19F.5030002@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Chris Friesen <chris.friesen@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:56828 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750858AbaHCGOG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Aug 2014 02:14:06 -0400
Received: by mail-wi0-f173.google.com with SMTP id f8so3357754wiw.6
        for <netdev@vger.kernel.org>; Sat, 02 Aug 2014 23:14:04 -0700 (PDT)
In-Reply-To: <53DCF19F.5030002@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-08-02 at 08:11 -0600, Chris Friesen wrote:
> On 08/02/2014 12:28 AM, Eric Dumazet wrote:
> > On Fri, 2014-08-01 at 21:51 -0600, Chris Friesen wrote:
> 
> >> I've got an app that tries to connect() to both of them in turn.  The connect()
> >> to the first socket fails with EAGAIN, the second one succeeds, and all
> >> subsequent retries on the first fail.  Here's an strace() of the sequence:
> >>
> >> socket(PF_FILE, SOCK_STREAM, 0)         = 6
> >> fcntl(6, F_GETFL)                       = 0x2 (flags O_RDWR)
> >> fcntl(6, F_SETFL, O_RDWR|O_NONBLOCK)    = 0
> >
> > Non blocking socket : If listener queue is full, -EAGAIN is expected
> 
> 
> That doesn't make any sense though, there is only one process that ever 
> attempts to connect() to this socket, and I only ran it one instance at 
> a time.  That implies that the first time I got EAGAIN the queue would 
> have been empty when the connection request came in.

This looks like an application bug, missing a POLLIN event and it always
call accept() too late.

> Looking at the qemu code I think it's calling listen(sock,1) which makes 
> sense since I think it's only designed to allow a single connection up 
> into the guest at a time.



> 
> Not sure how that could be the problem though, since there is only one 
> process that tries to connect() to the application, and I only ran it 
> one instance at a time.

Well, change listen() backlog to 10, and maybe it will hide the
application bug.

> 
> I'll give the patch a try, but how would that explain the sockets that 
> are in a CONNECTING state when as far as I can tell they don't belong to 
> any process?

The accept() call comes too late.

You have the CONNECTING state as long accept() was not yet called.
