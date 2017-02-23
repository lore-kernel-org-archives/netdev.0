From: Andreas Schultz <aschultz@tpip.net>
Subject: Re: [PATCH net-next] net/gtp: Add udp source port generation
 according to flow hash
Date: Thu, 23 Feb 2017 15:21:13 +0100 (CET)
Message-ID: <635223204.206529.1487859673545.JavaMail.zimbra@tpip.net>
References: <1487257141-11706-1-git-send-email-ogerlitz@mellanox.com> <576077949.135577.1487282291666.JavaMail.zimbra@tpip.net> <CAJ3xEMijwHpWfxUFcaCiAkP_0P8R2u6Cv4L=Vc3b_dPf+beOBg@mail.gmail.com> <CALx6S34ibBFpmZvxAtUn6oqgX9M8C1a3gg1iZrWWzwbswatUSQ@mail.gmail.com> <20170223134947.GA4373@salvia>
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
Received: from mail.tpip.net ([92.43.49.48]:36671 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750828AbdBWOVT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Feb 2017 09:21:19 -0500
In-Reply-To: <20170223134947.GA4373@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

----- On Feb 23, 2017, at 2:49 PM, pablo pablo@netfilter.org wrote:

> On Wed, Feb 22, 2017 at 01:47:17PM -0800, Tom Herbert wrote:
>> On Wed, Feb 22, 2017 at 1:29 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>> > On Thu, Feb 16, 2017 at 11:58 PM, Andreas Schultz <aschultz@tpip.net> wrote:
>> >> Hi Or,
>> >> ----- On Feb 16, 2017, at 3:59 PM, Or Gerlitz ogerlitz@mellanox.com wrote:
>> >>
>> >>> Generate the source udp header according to the flow represented by
>> >>> the packet we are encapsulating, as done for other udp tunnels. This
>> >>> helps on the receiver side to apply RSS spreading.
>> >>
>> >> This might work for GTPv0-U, However, for GTPv1-U this could interfere
>> >> with error handling in the user space control process when the UDP port
>> >> extension  header is used in error indications.
>> >
>> >
>> > in the document you posted there's this quote "The source IP and port
>> > have no meaning and can change at any time" -- I assume it refers to
>> > v0? can we identify in the kernel code that we're on v0 and have the
>> > patch come into play?
>> >
>> >> 3GPP TS 29.281 Rel 13, section 5.2.2.1 defines the UDP port extension and
>> >> section 7.3.1 says that the UDP source port extension can be used to
>> >> mitigate DOS attacks. This would IMHO imply that the user space control
>> >> process needs to know the TEID to UDP source port mapping.
>> >
>> >> The other question is, on what is this actually hashing. When I understand
>> >> the code correctly, this will hash on the source/destination of the orignal
>> >> flow. I would expect that a SGSN/SGW/eNodeB would like the keep flow
>> >> processing on a per TEID base, so the port hashing should be base on the TEID.
>> >
>> > is it possible for packets belonging to the same TCP session or UDP
>> > "pseudo session" (given pair of src/dst ip/port) to be encapsulated
>> > using different TEID?
>> >
>> > hashing on the TEID imposes a harder requirement on the NIC HW vs.
>> > just UDP based RSS.
>> 
>> This shouldn't be taken as a HW requirement and it's unlikely we'd add
>> explicit GTP support in flow_dissector. If we can't get entropy in the
>> UDP source port then IPv6 flow label is a potential alternative (so
>> that should be supported in NICs for RSS).
> 
> According to specs, section 4.4.2.3 Encapsulated T-PDU, TS 29.281.
> 
> "The UDP Source Port is a locally allocated port number at the sending
> GTP-U entity."
> 
> Older specs that refer to GTP-U such as TS 09.60 and TS 29.060 also
> state the same.

It is absolutely valid the choose any sending port you want. I only
think you should know which port you did send on.

TS 29.281, Sect. 5.2.2.1 defines the UDP port extension to be used
in error indications. It provides the UDP source port of a G-PDU
that triggered an error.

If the send side does not know which port it uses to send, how
can it use this indication to correlate an error? That's the reason
I thought it would be better to add the UDP source port to the
PDP context and allow the control path to assign the source port
on context creation.

Of course, this header is optional and the receiving side is not
required to use it.

About the RSS spreading in the receive side, I would think that
a receiver would prefer to process all packets that belong to a
give TEID with the same receive instance. So keeping the UDP
source port for a given TEID stable would be beneficial. As far
as I understand it, the hash used in the patch uses the source
and destination values from the original flow. This would mean
that GTP packets that belong to the same TEID would end up with
different UDP source ports.

So what about this as a compromise, we dd a UDP source port field
to the PDP context, it defaults to 0 (zero), the control instance
can optionally initialize this field, when we hit the xmit code
and the port is non zero, use that value, if it is zero use the hash?

Regards
Andreas

> 
> So Or patch looks fine to me.
