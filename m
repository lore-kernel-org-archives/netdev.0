From: Manfred Spraul <manfred@colorfullife.com>
Subject: Re: oops in tcp_v4_rcv.
Date: Thu, 29 May 2003 03:15:57 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3ED55F4D.1070306@colorfullife.com>
References: <3ED54DBC.4020203@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Andrew Morton <akpm@digeo.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <3ED54DBC.4020203@colorfullife.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[netdev added to cc list]

I think I understand now what causes the crash:
The tcp_ehash assumes that the entries are of the type 'struct inet_sock'.
But the actual entry is of the type tcp_tw_bucket. And 'sk->inet.daddr' 
is not shared between both structures.


 << net/ipv4/tcp_ipv4, line 510:
        /* Must check for a TIME_WAIT'er before going to listener hash. */
        for (sk = (head + tcp_ehash_size)->chain; sk; sk = sk->next)
               if (TCP_IPV4_MATCH(sk, acookie, saddr, daddr, ports, dif))
                    goto hit;
<<
preprocessor output:
<<
for (sk = (head + (tcp_hashinfo.__tcp_ehash_size))->chain; sk; sk = 
sk->next)
      if ((((&((struct inet_sock *)sk)->inet)->daddr == (saddr)) &&
           ((&((struct inet_sock *)sk)->inet)->rcv_saddr == (daddr)) &&
           ((*((__u32 *)&((&((struct inet_sock *)sk)->inet)->dport)))== 
(ports)) &&
           (!((sk)->bound_dev_if) || ((sk)->bound_dev_if == (dif)))))
                       goto hit;
<<


Manfred Spraul wrote:

> Hi,
>
> I'm looking at crashes that occur during network stress testing with 
> the CONFIG_DEBUG_PAGEALLOC from -mm: Pages that are not in use are 
> immediately unmapped from the linear mapping, and thus reading stale 
> pointer causes an immediate oops.
>
> I've now analyzed one crash:
> the oops is in __tcp_v4_lookup_established, in the 2nd look [i.e. 
> looking at TIME_WAIT sockets. Easy to identify due to the access to 
> __tcp_ehash_size].
>
> The entry in the hash table is an tcp_tw_bucket, and that structure is 
> only ~88 bytes long. The oops is caused by an access to objp+0x168, 
> which doesn't exist.
