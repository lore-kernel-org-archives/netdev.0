From: LOUVET Eric ATOS 7SB K236 p5036 <eric.louvet@regis-dgac.net>
Subject: Problem with TCP
Date: Thu, 27 Feb 2003 09:21:15 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E5DCA7B.5050507@regis-dgac.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hello to all of you !
    I 'm sorry to disturb you, it is not a spaming mail !

Alan Cox says me netdev@oss.sgi.com is the place to tell my
story.

 In case you can help me to undestand something, I would like
to describe a problem I encounter with TCP, under kernel 2.4.20.

Here it is, I use almost successfully the TCP stack in kernel code,
(in a streams driver to be precise).
 the only problem I have is this :

I have an established connection, when this connection is local,
I kill the client, or stop it, so it close its socket.

 From the server side I'm alerted of that by the state change callback
of my socket, then I detach from it my callbacks fcn -state_change 
data_ready etc...
and call sock_release .....

I observe this : 
sock_release call tcp_close, the socket is in 
TCP_LAST_ACK state !!! tcp_close call tcp_send_fin 
after that call, something as been inserted
in the backlog queue of the tcp socket.
and then when tcp_close call release_sock, then __release_sock runs
because backlog is not empty, I encounter a crash, due to poisonning
of free slab block.

If poisonning is not active, the kernel crash later at random place .... ;-)

remember __release_sock :


void __release_sock(struct sock *sk)
{
        struct sk_buff *skb = sk->backlog.head;
               
               
        do {
                sk->backlog.head = sk->backlog.tail = NULL; <- crashing code !
                bh_unlock_sock(sk);
               
                do {
                        struct sk_buff *next = skb->next;

                        skb->next = NULL;
                        sk->backlog_rcv(sk, skb);
                        skb = next;
                } while (skb != NULL);
 
                bh_lock_sock(sk);
        } while((skb = sk->backlog.head) != NULL); 
}


The crash is due to the value of skb, which is 0x5a5a5a5a (poisonned),
which seems to indicate that sk has been freed ?

How can this be possible ? what are the stuff I forgot to consider ?

In fact, another point of matter is this :
the crash only occur when the connection is local,
when the client is not local, there is no crash.


 I hope some of you understand my story,
sorry for my poor english, I hope you can give me ideas
about my problem, that can help me to find what I'm doing wrong.

Best regards to you all.

                        Eric.
