From: Kovacs Krisztian <hidden@balabit.hu>
Subject: Re: [PATCH] ipv4 tcp autobind problem
Date: Tue, 30 Sep 2003 09:14:59 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F792D73.50309@balabit.hu>
References: <3F782E1F.4030500@balabit.hu> <20030929222209.4d02c542.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030929222209.4d02c542.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


   Hi,

David S. Miller wrote:
> Once connect() has been called on a socket, you may not ever again
> perform any action that would try to connect that socket.
> 
> Said another way, a socket that has failed to connect() is a socket
> that you may not use in any usable way ever again except to close
> that file descriptor.

   Yes, I know that. Exactly this is why I felt it a problem that sk->num 
gets a new value if you call send() after an unsuccessful connect(). (I 
know that in theory one should not call send() in this case, but one _can_ 
call it in reality.) And, the problem occurs not only when send() is 
called after an unsuccessful connect(), but also when an RST is received 
between two send() calls, which is perfectly legal, and cannot be viewed 
as buggy user-space software.

   I don't really understand why the inet_sendmsg() calls inet_autobind() 
for SOCK_STREAM sockets: for these kind of sockets, one must call 
connect() anyway, before doing any other kind of operations. And, the side 
effect of the code

         /* We may need to bind the socket. */
         if (!inet_sk(sk)->num && inet_autobind(sk))
                 return -EAGAIN;

in inet_sendmsg() is that when an RST is received, sk->num is set to zero, 
and when the next inet_sendmsg() call occurs, the socket is rebound to a 
new port _before_ returning an error.

   In our transparent proxying patch, this causes problems, because it 
assumes that after a socket is bound (by connect(), for example), the 
local port (sk->sport) remains unchanged until the socket is closed. 
However, this is not true because of the mentioned side effect of 
inet_sendmsg(). This is why I proposed that inet_sendmsg() should call 
inet_autobind() only if it's not a SOCK_STREAM socket.

-- 
   Regards,
     Krisztian KOVACS
