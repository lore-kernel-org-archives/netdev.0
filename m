From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: SCTP path mtu support needs some ip layer support.
Date: Mon, 13 Jan 2003 16:49:33 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0301131609290.1861-100000@dyn9-47-18-98.beaverton.ibm.com>
References: <200301132322.CAA09642@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Sridhar Samudrala <sri@us.ibm.com>, <jgrimm2@us.ibm.com>,
   <davem@redhat.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: <kuznet@ms2.inr.ac.ru>
In-Reply-To: <200301132322.CAA09642@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 14 Jan 2003 kuznet@ms2.inr.ac.ru wrote:

> Hello!
> 
> > I am not clear on your other alternative of adding a socket flag. Could you
> > please elaborate on it?
> 
> Not to add any arguments just to help a broken protocol.
> Simply to behave like UDP, i.e. to fragment all the oversized frames.
> Probably, even new flag is not required, just check for
> sk->protocol == IPPROTO_SCTP can be enough.
> 
> It is almost equivalent, it also send fragmented crap only when
> mtu decreases. But this variant is _formally_ prohibited with:
> 
> >      fragmented.  Transmissions of new IP datagrams MUST have DF set.
> 
> BTW this MUST is even more ridiculous, you have to change ip_queue_xmit()
> to do this, we disable pmtu discovery sometimes.
> 
> 
> > I guess SCTP desginers have thought of this and explicitly indicate that we 
> 
> I am afraid SCTP designers thought with their spinal chrod. :-)
> Relying on IP fragmentation promotes all the protocol to the status
> of utter crap. So, long live TCP! :-)

Any record based protocol that supports path mtu discovery needs to rely on ip 
fragmentation when pmtu is lowered and a packet needs to be re-fragmented.
In fact, both ipv4 and ipv6 path mtu discovery RFCs have a section that talks 
about other transport protocols that have this behavior.

RFC1191
6.5. Issues for other transport protocols

   Some transport protocols (such as ISO TP4 [3]) are not allowed to
   repacketize when doing a retransmission.  That is, once an attempt is
   made to transmit a datagram of a certain size, its contents cannot be
   split into smaller datagrams for retransmission.  In such a case, the
   original datagram should be retransmitted without the DF bit set,
   allowing it to be fragmented as necessary to reach its destination.
   Subsequent datagrams, when transmitted for the first time, should be
   no larger than allowed by the Path MTU, and should have the DF bit
   set.

SCTP falls into the above category of transport protocols and basically needs 
a mechanism that is mid-way between TCP and UDP. Set DF bit most of the time, 
and unset DF bit only for messages that need to be refragmented.

I can think of another solution which does not add any overhead to TCP.

Add a second argument to ip_queue_xmit() to pass the value that will be set
to IP_DF bit. 
TCP calls this routine with htons(IP_DF) as the 2nd argument always.
     ip_queue_xmit(skb, htons(IP_DF))

SCTP calls this routine with htons(IP_DF) as the 2nd argument most of the time,
but with 0 as the 2nd argument when a packet needs to be re-fragmented. 

--- ip_output.c Mon Jan 13 16:43:10 2003
+++ ip_output.c.new     Mon Jan 13 16:43:13 2003
@@ -280,7 +280,7 @@
                return ip_finish_output(skb);
 }

-int ip_queue_xmit(struct sk_buff *skb)
+int ip_queue_xmit(struct sk_buff *skb, __u16 ip_df)
 {
        struct sock *sk = skb->sk;
        struct inet_opt *inet = inet_sk(sk);
@@ -338,7 +338,7 @@
        *((__u16 *)iph) = htons((4 << 12) | (5 << 8) | (inet->tos & 0xff));
        iph->tot_len = htons(skb->len);
        if (ip_dont_fragment(sk, &rt->u.dst))
-               iph->frag_off = htons(IP_DF);
+               iph->frag_off = ip_df;
        else
                iph->frag_off = 0;
        iph->ttl      = inet->ttl;

Is this more agreeable?

If not, do you prefer SCTP having its own ip_xmit routine that fills in its own
ip header and calls dst->output. Only requirement is that ip_options_build() is
exported. 

Thanks
Sridhar
