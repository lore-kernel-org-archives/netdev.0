From: Ronghua Zhang <rz5b@cs.virginia.edu>
Subject: synchronization between net_bh and user-context
Date: Thu, 5 Dec 2002 16:36:09 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0212051612560.712-100000@bobbidi.cs.virginia.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <linux-kernel@vger.kernel.org>,
   <linux-net@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: kernelnewbies@nl.linux.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I am reading the TCP/IP code of kernel 2.2.15 and doing some development
based on it(yes, I know it's an old version, but I have to). I got a
little confused about the synchronization between net_bh and user-context,
and hope someone can help me out.

Specifically, why the following is impossible?
destroy_sock is called on CPU1, and a little bit later net_bh() is
executed on CPU2, which will grab the pointer to the socket just before
it's destroyed, and its later access becomes invalid.

CPU 1                                 CPU2
destroy_sock()
 lock_sock()
   sk->sock_readers++
   synchronize_bh(), no bh is running

                                    now net_bh() get called
                                    =>tcp_v4_rcv()
                                       sk = __tcp_v4_lookup(...)
                                        sk has not been destroyed

 tcp_v4_destroy_sock()
 kill_sk_now() free sk
                                         now sk has been destroyed
                                       if (!atomic_read(&sk->sock_readers))
                                            <-- sk become invalid


ronghua
