From: Kovacs Krisztian <hidden@balabit.hu>
Subject: Re: Fw: Re: [PATCH] ipv4 tcp autobind problem
Date: Tue, 30 Sep 2003 16:19:39 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F7990FB.7030606@balabit.hu>
References: <200309301237.QAA01426@yakov.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, jmorris@redhat.com,
        netdev@oss.sgi.com, linux-net@vger.rutgers.edu,
        Balazs Scheidler <bazsi@balabit.hu>
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200309301237.QAA01426@yakov.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


   Hi,

kuznet@ms2.inr.ac.ru wrote:
>>in inet_sendmsg() is that when an RST is received, sk->num is set to zero, 
> 
> Yes, I remember this. This funny thing was added to avoid using reserved
> ports obtained from accept() to do connect(). Before that sockets were never
> unbound after they bound once exactly to avoid weirdness of the kind
> descibed in your mail, but this happened to be insecure.
> 
> From this mail I still do not see why autobinding of void socket is so
> bad thing, that it requires marginal fixing at the place which is already
> marginal. What is the real problem? So, bad sendmsg() selects some port as
> a side effect. It makes it on udp and tcp. What is the deal? If it is disaster
> for tcp, why it is not bad for udp?
> 
>>local port (sk->sport) remains unchanged until the socket is closed.
> 
> Socket is _closed_. Local port is reset only after socket is closed,
> unless PORT_USERLOCK is set. And sk->sport remains unchanged even
> after socket is closed, btw, so... 

   No, sk->sport does not remain unchanged. Imagine the following 
situation: the TCP stack receives an RST, tcp_reset() gets called. It 
calls tcp_done() -> tcp_set_state(TCP_CLOSE) -> tcp_put_port() -> 
__tcp_put_port(). __tcp_put_port() sets sk->num to zero. So, when you call 
send() from userspace, the mentioned part of inet_sendmsg() calls 
inet_autobind(), which changes sk->sport, too...

> I do recognize that current behaviour is weird, but I still want to know
> how this marginal weirdness escaped to be seen in reality.

   Yes, it is our "transparent proxy kernel hack" ((C) davem :) that have 
problem with this behaviour. Transparent proxying works the following way:

- You have to assign a foreign address to a bound socket using a specific 
setsockopt call. This creates a new entry in the tproxy local IP hash 
table, and the hash key is based on the local ip:port.
- tproxy registers its Netfilter hooks, and if a new connection comes in, 
it looks up its hash tables, to see if it is a transparent proxied 
connection (it uses Netfilter's connection tracking subsystem). If it has 
to be proxyed, the appropriate NAT mappings are applied to the connection.
- When the socket is closed (inet_release() is called, tproxy has its 
"callback" function here), the corresponding entries are deleted from 
tproxy's hash tables, again, based on the local ip:port pair.

   So, the weirdness causes the following problem: since sk->sport changes 
after the corresponding entry was inserted into the hash table, it 
changes, so the entry cannot be deleted when userspace calls close() on 
the socket.

   Eventually, it should be enough if inet_sendmsg() did not call 
inet_autobind() if the socket is in an errorneous state, but I had no idea 
how this could be implemented. (sk->err gets zeroed by sock_error(), so it 
cannot be checked twice.)

   In the case of UDP, you cannot get an RST-like thing, so AFAIK there is 
no such situation in which sk->num of a bound socket could be reset to 
zero. This is why inet_sendmsg()'s mentioned part did not cause problems 
for us.

-- 
   Regards,
     Krisztian KOVACS
