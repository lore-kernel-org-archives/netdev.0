From: Kovacs Krisztian <hidden@balabit.hu>
Subject: ipv4 tcp autobind problem
Date: Mon, 15 Sep 2003 09:56:26 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F6570AA.6050903@balabit.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


   Hi,

   While testing the tproxy (transparent proxying) patch for linux-2.4
(http://www.balabit.com/downloads/tproxy/linux-2.4), Stas Grabois has
found a quite strange aspect of Linux 2.4 TCP. Imagine the following
scenario: you create a new socket (AF_INET, SOCK_STREAM), bind it to local
port 0, and try to connect() to a closed port. Of course, the peer sends
back an RST, indicating no one is listening on that port. However, if your
application does not care about the return value of connect(), and calls
send() on the not connected socket, inet_autobind() is called and a new
local port is allocated for the socket. So, besides returning an error,
there is also a side effect of the send(). The same thing happens with an
established TCP session if the peer sends an RST between two send() calls,
the second call will autobind the socket, and then return error.

   Is this behaviour intentional? Isn't rebinding a TCP socket to a new
local port a bug? I mean, possibly inet_sendmsg() should check if the
socket is SOCK_STREAM before calling inet_autobind() if sk->num is zero.

   It would be important to know if this is considered a bug or not, since
the tproxy patch relies on sk->sport being unchanged while a socket is
alive. (It finds the corresponding entry in its own hash table based on
the sk->sport value, so if it changes, it cannot remove the entry when
closing the corresponding socket...)

-- 
   Regards,
     Krisztian KOVACS
