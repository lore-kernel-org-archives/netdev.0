From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: SCTP path mtu support needs some ip layer support.
Date: Mon, 13 Jan 2003 14:54:06 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0301131417440.1691-100000@dyn9-47-18-98.beaverton.ibm.com>
References: <200301132048.XAA09194@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jon Grimm <jgrimm2@us.ibm.com>, <davem@redhat.com>, <sri@us.ibm.com>,
   <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: <kuznet@ms2.inr.ac.ru>
In-Reply-To: <200301132048.XAA09194@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 13 Jan 2003 kuznet@ms2.inr.ac.ru wrote:

> Hello!
> 
> > Well, I personally like having the flexibility to do either.  So, we'll 
> > take you up on your offer to allow control over DF.
> 
> Beware! To all that I can say, clearing DF on some packets compromises
> path mtu discovery. If you need to have cleared DF on some packets in a flow,
> this means in fact, that path mtu discovery is not supported at protocol level
> at all.
> 
> So, I would like to ask you to consult SCTP designers. If the thing which
> you have said is true this means they desinged a crippled protocol.

I guess SCTP desginers have thought of this and explicitly indicate that we 
should resort to IP fragmentation when it is detected that an already fragmented
message exceeds the PMTU.

>From Sec 6.9 of RFC 2960,
   Note: Once a message is fragmented it cannot be re-fragmented.
   Instead if the PMTU has been reduced, then IP fragmentation must be
   used.  Please see Section 7.3 for details of PMTU discovery.

>From Sec 7.3 of RFC 2960,
   4) Since data transmission in SCTP is naturally structured in terms
      of TSNs rather than bytes (as is the case for TCP), the discussion
      in Section 6.5 of RFC 1191 applies: When retransmitting an IP
      datagram to a remote address for which the IP datagram appears too
      large for the path MTU to that address, the IP datagram SHOULD be
      retransmitted without the DF bit set, allowing it to possibly be
      fragmented.  Transmissions of new IP datagrams MUST have DF set.

> 
> Support of pmtu discovery as described in rfc means possibility of semantic
> fragmentation to retransmit any data bits. If SCTP is not ablet to do this,
> then you should not support pmtu discovery at all like most of people make
> for UDP or to follow UDP pattern, fragmenting frames when their size exceeds
> mtu. It is not necessary to cripple ip_queue_xmit calling conventions
> to make this, just add a flag to socket to clear DF on oversized
> frames.

PMTU discovery is a must for SCTP and moreover DF bit needs to be set only
for a few messages which are already fragmented. This may happen only when
the PMTU of a route changes which should not happen very frequently. So i don't
think not supporting PMTU discovery is a good solution.
The chances of running into ip-id wrap-around issues with SCTP should be pretty
low as only a few packets on a flow may need to disable DF bits causing ip
fragmentation.

Are you suggesting that another flag be added to struct inet_opt similar to
pmtudisc, that is checked in ip_dont_fragment()? Even with this flag, i think 
each packet needs to checked if it is oversized.

I was planning to add a 2nd argument, ipfragok to ip_queue_xmit() and make
the following change in ip_queue_xmit()
-        if (ip_dont_fragment(sk, &rt->u.dst))
+        if (ip_dont_fragment(sk, &rt->u.dst) && !ipfragok)

I am not clear on your other alternative of adding a socket flag. Could you
please elaborate on it?

Thanks
Sridhar
