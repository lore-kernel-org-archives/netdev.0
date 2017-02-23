From: Andreas Schultz <aschultz@tpip.net>
Subject: Re: [PATCH net-next] net/gtp: Add udp source port generation
 according to flow hash
Date: Thu, 23 Feb 2017 10:35:56 +0100 (CET)
Message-ID: <7810166.196078.1487842556962.JavaMail.zimbra@tpip.net>
References: <1487257141-11706-1-git-send-email-ogerlitz@mellanox.com> <576077949.135577.1487282291666.JavaMail.zimbra@tpip.net> <CAJ3xEMijwHpWfxUFcaCiAkP_0P8R2u6Cv4L=Vc3b_dPf+beOBg@mail.gmail.com> <CALx6S34ibBFpmZvxAtUn6oqgX9M8C1a3gg1iZrWWzwbswatUSQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        pablo <pablo@netfilter.org>, laforge <laforge@gnumonks.org>,
        netdev <netdev@vger.kernel.org>,
        timo lindhorst <timo.lindhorst@travelping.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:60035 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751070AbdBWJgC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Feb 2017 04:36:02 -0500
In-Reply-To: <CALx6S34ibBFpmZvxAtUn6oqgX9M8C1a3gg1iZrWWzwbswatUSQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

----- On Feb 22, 2017, at 10:47 PM, Tom Herbert tom@herbertland.com wrote:

> On Wed, Feb 22, 2017 at 1:29 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>> On Thu, Feb 16, 2017 at 11:58 PM, Andreas Schultz <aschultz@tpip.net> wrote:
>>> Hi Or,
>>> ----- On Feb 16, 2017, at 3:59 PM, Or Gerlitz ogerlitz@mellanox.com wrote:
>>>
>>>> Generate the source udp header according to the flow represented by
>>>> the packet we are encapsulating, as done for other udp tunnels. This
>>>> helps on the receiver side to apply RSS spreading.
>>>
>>> This might work for GTPv0-U, However, for GTPv1-U this could interfere
>>> with error handling in the user space control process when the UDP port
>>> extension  header is used in error indications.
>>
>>
>> in the document you posted there's this quote "The source IP and port
>> have no meaning and can change at any time" -- I assume it refers to
>> v0? can we identify in the kernel code that we're on v0 and have the
>> patch come into play?
>>
>>> 3GPP TS 29.281 Rel 13, section 5.2.2.1 defines the UDP port extension and
>>> section 7.3.1 says that the UDP source port extension can be used to
>>> mitigate DOS attacks. This would IMHO imply that the user space control
>>> process needs to know the TEID to UDP source port mapping.
>>
>>> The other question is, on what is this actually hashing. When I understand
>>> the code correctly, this will hash on the source/destination of the orignal
>>> flow. I would expect that a SGSN/SGW/eNodeB would like the keep flow
>>> processing on a per TEID base, so the port hashing should be base on the TEID.
>>
>> is it possible for packets belonging to the same TCP session or UDP
>> "pseudo session" (given pair of src/dst ip/port) to be encapsulated
>> using different TEID?
>>
>> hashing on the TEID imposes a harder requirement on the NIC HW vs.
>> just UDP based RSS.
> 
> This shouldn't be taken as a HW requirement and it's unlikely we'd add
> explicit GTP support in flow_dissector. If we can't get entropy in the
> UDP source port then IPv6 flow label is a potential alternative (so
> that should be supported in NICs for RSS).
> 
> I'll also reiterate my previous point about the need for GTP testing--
> in order for us to be able to evaluate the GTP datapath for things
> like performance or how they withstand against DDOS we really need an
> easy way to isolate the datapath.

GTP as specified is very unsecure by definition. It is meant to be run
only on *private* mobile carrier and intra mobile carrier EPC networks.
Running it openly on the public internet would be extremly foolish.

There are some mechanisms in GTPv1-C on how to handle overload and
more extensive mechanisms in GTPv2-C for overload handling. The basic
guiding principle is to simply drop any traffic that it can't handle.

Anyhow, I havn't seen anything in 3GPP or GSMA documents that deals
with DDOS.

There are guidelines like the GSMA's IR.88 that describe how the intra
carrier roaming should work and what security measures should be
implemented.

Traffic coming in at Gi/SGi or form the UE could create a DDOS on tunnel.
However, on the UE side you still have the RAN (eNODE, SGSN, S-GW) or
an ePDG that has to apply QoS and thereby limit traffic. On the Gi/SGi
side side you have the PCEF that does the same.

So in a complete 3GPP node (GGSN, P-GW) that uses the GTP tunnel
implementation, malicious traffic should be blocked before it can reach
the tunnel.

And as I stated before, the GTP tunnel module is not supposed to be
use without any of those components. So the DDOS concern should not
be handled at the tunnel level.

Andreas

> 
> Tom
