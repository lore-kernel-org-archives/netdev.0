From: Andreas Schultz <aschultz@tpip.net>
Subject: Re: [PATCH net-next] net/gtp: Add udp source port generation
 according to flow hash
Date: Thu, 23 Feb 2017 18:19:16 +0100 (CET)
Message-ID: <109485900.208950.1487870356640.JavaMail.zimbra@tpip.net>
References: <1487257141-11706-1-git-send-email-ogerlitz@mellanox.com> <576077949.135577.1487282291666.JavaMail.zimbra@tpip.net> <CAJ3xEMijwHpWfxUFcaCiAkP_0P8R2u6Cv4L=Vc3b_dPf+beOBg@mail.gmail.com> <CALx6S34ibBFpmZvxAtUn6oqgX9M8C1a3gg1iZrWWzwbswatUSQ@mail.gmail.com> <20170223134947.GA4373@salvia> <635223204.206529.1487859673545.JavaMail.zimbra@tpip.net> <20170223164229.GA4996@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
        Or Gerlitz <gerlitz.or@gmail.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        laforge <laforge@gnumonks.org>, netdev <netdev@vger.kernel.org>
To: pablo <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:48959 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751107AbdBWRUF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Feb 2017 12:20:05 -0500
In-Reply-To: <20170223164229.GA4996@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- On Feb 23, 2017, at 5:42 PM, pablo pablo@netfilter.org wrote:

> On Thu, Feb 23, 2017 at 03:21:13PM +0100, Andreas Schultz wrote:
>> ----- On Feb 23, 2017, at 2:49 PM, pablo pablo@netfilter.org wrote:
> [...]
>> > According to specs, section 4.4.2.3 Encapsulated T-PDU, TS 29.281.
>> > 
>> > "The UDP Source Port is a locally allocated port number at the sending
>> > GTP-U entity."
>> > 
>> > Older specs that refer to GTP-U such as TS 09.60 and TS 29.060 also
>> > state the same.
>> 
>> It is absolutely valid the choose any sending port you want. I only
>> think you should know which port you did send on.
>> 
>> TS 29.281, Sect. 5.2.2.1 defines the UDP port extension to be used
>> in error indications. It provides the UDP source port of a G-PDU
>> that triggered an error.
>> 
>> If the send side does not know which port it uses to send, how
>> can it use this indication to correlate an error? That's the reason
>> I thought it would be better to add the UDP source port to the
>> PDP context and allow the control path to assign the source port
>> on context creation.
>> 
>> Of course, this header is optional and the receiving side is not
>> required to use it.
>> 
>> About the RSS spreading in the receive side, I would think that
>> a receiver would prefer to process all packets that belong to a
>> give TEID with the same receive instance. So keeping the UDP
>> source port for a given TEID stable would be beneficial. As far
>> as I understand it, the hash used in the patch uses the source
>> and destination values from the original flow. This would mean
>> that GTP packets that belong to the same TEID would end up with
>> different UDP source ports.
> 
> The receiver needs to scale up, and that happens if packets are
> distributed between CPUs in a way that make sense. I don't think it
> makes sense to pass packets that belong to the same tunnel to the same
> CPU, this is exactly the scenario that makes DDOS easier to trigger.

When we are talking about the xmit path, then currently none of the
receivers we are talking to is going to be Linux and we have no
idea how they will behave nor do we have any influence on them. Do
we really need to make assumptions about other vendors implementations?

Traces on live GRX networks show that about 90% of the SGSN/S-GW
that would talk to us always use the default GTP-U port as source
port. Some multi chassis GSN's seem to assign source port ranges to
chassis, but that has nothing todo with DDOS protection.

So, even when do the randomization on TX, it won't help our receiver
scale up. We have to deal what the other (100% non Linux side is
going to throw at us).

>> So what about this as a compromise, we dd a UDP source port field
>> to the PDP context, it defaults to 0 (zero), the control instance
>> can optionally initialize this field, when we hit the xmit code
>> and the port is non zero, use that value, if it is zero use the hash?
> 
> You want to use this for your VRF concept? I would like that you take
> the time to explain us your usecases.

I only want the normal multi APN per GGSN/P-GW setup that every mobile
carrier on this world is running on the big commercial vendor boxes, nothing
more and nothing less.

I have tried to explain this multiple times already, but it seems I
failed every time to put it in intelligible form. The last attempt
was here: http://marc.info/?l=linux-netdev&m=148700022003294&w=2

> How are you going to use this mapping between tunnels and UDP source ports?

There is no mapping between tunnels and UDP source ports. UDP source
ports do not matter to the receiving side at all in GTP tunnels. There
is one error handling case that can benefit from knowing the source port
and I think that case shouldn't be discarded lightly.

A GTP-U tunnel is only defined by its destination IP, destination UDP port
(which is constant 2152) and it's TEID. This also means that a GTP tunnel
is a one-way construct. Only the GTP-C instance knows that a PDP context
is actually two GTP-U tunnels, one in each direction.

We had the discussion if the source IP does play a role in this. The
3GPP specifications do not make a 100% clear statement for GTP-U on that.
So the case can be made that the GTP-U tunnel pair should be symmetric
(the destination IP of one tunnel is the source of the other). There
are various other statements in the documents that imply that this is
not always the case.

I thought we had come to the conclusion (with Harald) to make the reverse
GSN peer filter an option. Then every control path implementation has
the choice to use it or not. The same should IMHO apply to the source port
randomization.

For GTP-C the situation is clear, the control instance has to accept
traffic of a given TEID from any source, otherwise certain handover
procedures would not work.

> An explaination would be better than searching at some optional
> (corner case) extension in the specs whose usage is questionable.
> 
> In any case, I think we want a good default behaviour, and I think
> Or's patch provides it.

Andreas
