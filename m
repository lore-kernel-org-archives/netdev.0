From: "Raghurama 'REDDY'" <rreddy@psc.edu>
Subject: Output on raw sockets ignores IP_DF when packet is bigger than pmtu
Date: Thu, 6 Mar 2003 11:01:45 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <03030611014533.2221238e.7643064@psc.edu>
Reply-To: rreddy@psc.edu
Cc: RREDDY@vms.psc.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: NETDEV@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

We are looking at the "traceroute" code, in particular the behavior of
the "-M" option (path MTU discovery) on a 2.4.20 kernel.

In attempting to get a "Framentation required message" from an
intermediate router, the code does the following:

    - Open a raw socket
    - Send a packet that is smaller than interface MTU but
      bigger than the MTU of an intermediate router with IP_DF set 
      (the NIC has an MTU of 4400, and pmtu is 1500).

What is observed is that when route cache is flushed, it works as
expected.  We get a "Framentation Required" message from the
intermediate router.

But when the cache is *not* flushed, the packets are fragmented based on
pmtu before sending the packets out on the net, inspite of the fact that
IP_DF is set (based on the tcpdump observations).  Is this the right
behavior?

But looking at 2.4.20 kernel code in "include/net/ip.h":

Not sure if "ip_send" is the in the call tree or not;  I am *not*
intimately familiar with the code ...   :-(                   

------------------
static inline int ip_send(struct sk_buff *skb)
{
        if (skb->len > skb->dst->pmtu)
                return ip_fragment(skb, ip_finish_output);
        else
                return ip_finish_output(skb);
}
------------------

This seems to indicate that it would fragment the packet if the packet
is bigger than path MTU irrespetive of the IP_DF flag.

Is there a way to get the host to not fragment when IP_DF is set,
iresspective what the pmtu is?

Thanks!

--rr
