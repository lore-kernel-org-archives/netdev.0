From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fw: [Bug 106241] New: shutdown(3)/close(3) behaviour is
 incorrect for sockets in accept(3)
Date: Mon, 19 Oct 2015 18:45:32 -0700
Message-ID: <1445305532.30896.40.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151019095938.72ea48e6@xeon-e3>
	 <1445297584.30896.29.camel@edumazet-glaptop2.roam.corp.google.com>
	 <562594E1.8040403@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Alan Burlison <Alan.Burlison@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35749 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751969AbbJTBpe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 21:45:34 -0400
Received: by pasz6 with SMTP id z6so3963709pas.2
        for <netdev@vger.kernel.org>; Mon, 19 Oct 2015 18:45:33 -0700 (PDT)
In-Reply-To: <562594E1.8040403@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-10-20 at 02:12 +0100, Alan Burlison wrote:

> Another problem is that if I call close() on a Linux socket that's in 
> accept() the accept call just sits there until there's an incoming 
> connection, which succeeds even though the socket is supposed to be 
> closed, but then an immediately following accept() on the same socket 
> fails. 

This is exactly what the comment I pasted documents.

On linux, doing close(listener) on one thread does _not_ wakeup other
threads doing accept(listener)

So I guess allowing shutdown(listener) was a way to somehow propagate
some info on the threads stuck in accept()

This is a VFS issue, and a long standing one.

Think of all cases like dup() and fd passing games, and the close(fd)
being able to signal out of band info is racy.

close() is literally removing one ref count on a file.
Expecting it doing some kind of magical cleanup of a socket is not
reasonable/practical.

On a multi threaded program, each thread doing an accept() increased the
refcount on the file.

Really, I have no idea of how Solaris coped with this, and I do not want
to know.
