From: Alan Burlison <Alan.Burlison@oracle.com>
Subject: Re: Fw: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Tue, 20 Oct 2015 19:31:25 +0100
Message-ID: <5626887D.5050308@oracle.com>
References: <20151019095938.72ea48e6@xeon-e3>	 <1445297584.30896.29.camel@edumazet-glaptop2.roam.corp.google.com>	 <562594E1.8040403@oracle.com>	 <1445305532.30896.40.camel@edumazet-glaptop2.roam.corp.google.com>	 <56261092.7080003@oracle.com>	 <1445347173.22974.6.camel@edumazet-glaptop2.roam.corp.google.com>	 <56264596.90104@oracle.com> <1445355027.22974.22.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:29510 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751285AbbJTSbd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 14:31:33 -0400
In-Reply-To: <1445355027.22974.22.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20/10/2015 16:30, Eric Dumazet wrote:

> A close() does _not_ wakeup an accept() or a poll() (this is exactly the
> same problem), or any blocking system call using the same 'file'

Not waking up the accept() is one thing, allowing the accept() to 
successfully complete some indeterminate time after the socket has been 
closed is something else entirely. You shouldn't have to call shutdown() 
to terminate an accept() on a socket, close() should suffice. Yes, if 
you want to use the shutdown() 'feature' to kick the accept() thread out 
of the call to accept() without closing the FD and you don't care about 
cross-platform compatibility then you can call shutdown() followed by 
close(). However that's only ever required on Linux as far as I can 
tell, and even on Linux applications that deal with the thread race by 
other means shouldn't be forced to use shutdown() when just close() 
would suffice.

The problem with poll() is that it returns immediately when passed a FD 
that is in the listening state. rather than waiting until there's an 
incoming connection to handle. As I said, that means you can't use 
poll() to multiplex between read/write/accept sockets.

> close() man page states :
>
> NOTES
>        It  is  probably unwise to close file descriptors while they may be in
>        use by system calls in other threads in the  same  process.   Since  a
>        file  descriptor may be reused, there are some obscure race conditions
>        that may cause unintended side effects.
>
> You are in this grey zone.

No, the race issue with file descriptor reuse and the close() behaviour 
are not the same thing. The manpage comment is correct, but not relevant.

-- 
Alan Burlison
--
