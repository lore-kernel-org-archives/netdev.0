From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next 2/2] mpls: allow TTL propagation to/from IP
 packets to be configured
Date: Tue, 9 Feb 2016 16:10:01 +0000
Message-ID: <56BA0F59.8070501@brocade.com>
References: <1454700472-13543-1-git-send-email-rshearma@brocade.com>
 <1454700472-13543-3-git-send-email-rshearma@brocade.com>
 <87r3gpadpc.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:10650 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757894AbcBIQKW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 11:10:22 -0500
In-Reply-To: <87r3gpadpc.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/02/16 18:36, Eric W. Biederman wrote:
> Robert Shearman <rshearma@brocade.com> writes:
>
>> It is sometimes desirable to present an MPLS transport network as a
>> single hop to traffic transiting it because it prevents confusion when
>> diagnosing failures. An example of where confusion can be generated is
>> when addresses used in the provider network overlap with addresses in
>> the overlay network and the addresses get exposed through ICMP errors
>> generated as packets transit the provider network.
>
> The configuration you are talking about is a bug.  ICMP errors can
> be handled without confusion simplify by forwarding the packets out
> to the end of the tunnel.  Which is how the standards require that
> situation to be handled if an ICMP error is generated.

You're absolutely right that the standards say how the ICMP errors 
should be handled in order for them to be forwarded correctly back to 
the sender, but I'm referring to what source addresses customers of 
service provider see in those ICMP errors generated when e.g. doing a 
traceroute. Furthermore, the mechanism that you mention adds for scope 
for mis-diagnosis since a traceroute won't show any information for hops 
PE1, P1 and P2 if PE2 is dropping the traffic for that LSP (because the 
mechanism you describe relies on PE2 or even a further CE to hairpin the 
ICMP error back to the originator of the error-causing traffic).

If you need further evidence that this is something that network 
operators might want to do, then see RFC 3032, s2.4.3 where it states:

    It is recognized that there may be situations where a network
    administration prefers to decrement the IPv4 TTL by one as it
    traverses an MPLS domain, instead of decrementing the IPv4 TTL by the
    number of LSP hops within the domain.

And one more reference is that this behaviour is codified in RFC 3443. 
For the purposes of clarity, Uniform Model in RFC 3443 corresponds to 
ip_ttl_propagate = 1 (default) and (Short) Pipe Model corresponds to 
ip_ttl_propagate = 0.

>
>> Therefore, provide the ability to control whether the TTL value from
>> an MPLS packet is propagated to an IPv4/IPv6 packet when the last
>> label is popped through the addition of a new per-namespace sysctl:
>> "net.mpls.ip_ttl_propagate" which defaults to enabled.
>>
>> Use the same sysctl to control whether the TTL is propagated from IP
>> packets into the MPLS header. If the TTL isn't propagated then a
>> default TTL value is used which can be configured via a new sysctl:
>> "net.mpls.default_ttl".
>
> Ugh.  There is a case for this, but this feels much more like a per
> tunnel/label/route egress property not a per network interface property.
>
> I don't recall all of the gory details but some flavors of mpls labels
> always require ttl propogation (the ip over mpls default) and some
> flavors of mpls labels always require no propagation (pseudo wires).

Clearly, if the label isn't used for the purposes of encapsulating L3 
traffic, then you can't propagate the L3 TTL into it and you have to put 
some other value in there instead. I envisaged that the value of 
default_ttl would be used in these cases and this is why I worded the 
documentation for the default_ttl sysctl like so:

	Default TTL value to use for MPLS packets where it cannot be
	propagated from an IP header, either because one isn't present
	or ip_ttl_propagate has been disabled.

Given that traffic arriving with a pseudo-wire label will have to be 
forwarded differently from traffic arriving for labels with L3 traffic, 
you will know that the label is associated with L2 traffic and that the 
TTL cannot be propagated.

> There may be something cute in between.  For something that is a per
> tunnel property I don't feel comfortable with a sysctl.

I cannot think of a use-case where it would make sense to have a mix of 
TTL being propagated and not being propagated on a per-LSP basis. I note 
that all of the most widely used proprietary MPLS implementations 
support global IP TTL propagation configuration and I'm not aware of any 
MPLS implementation that implements a per-LSP control for IP TTL 
propagation.

> Especially when it is something as potentially dangerous as enabling
> packets to loop in a network.  As I recall most IP over IP tunnels
> also propogate the ttl between the inner and outer ip packets to prevent
> loops.

There is no possibility of packets looping in a network as the TTL is 
always decremented when a label is pushed, whether the packet came in as 
IP or MPLS, and when swapping a label egress TTL must be one less than 
the ingress TTL, as defined by the MPLS RFC. When popping the last label 
we have to ensure that the MPLS TTL is not propagated to IP TTL so that 
there's no possibility of set the IP TTL beyond the value it entered the 
LSP (after the TTL decrement done as part of IP switching) with, but 
that is what this code does. Note that this is only the case if all 
routers are configured to not propagate the TTL, but the network 
operator can ensure that - if they don't then it's a configuration bug.

Thanks,
Rob
