From: kuznet@ms2.inr.ac.ru
Subject: Re: Fw: issues with SO_PRIORITY and IP_TOS
Date: Tue, 4 Nov 2003 15:33:03 +0300 (MSK)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311041233.PAA15518@yakov.inr.ac.ru>
References: <20031030120140.678b721b.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@redhat.com, cfriesen@nortelnetworks.com, hadi@znyx.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com (David S. Miller)
In-Reply-To: <20031030120140.678b721b.davem@redhat.com> from "David S. Miller" at ïËÔ 30, 2003 12:01:40 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

[cced to Jamal]

> I've always been confused about all of the weird things
> we do to handle DSCP et al. when masking the TOS bits all
> over the place.

TOS bits are masked only in one place: when doing routing by TOS,
implemented by some existing routing engines sort of OSPF. No bits
but TOS bits are used for these things.


> Alexey, what is going on here?

#1. Setting priority derived from TOS is different thing, it is
just to make life more convenient for old and still existing
applications: telnet, ftp, ssh, which set TOS bits in some way, which
used to be reasonable. Actually, even not four bits but only two bits
are used.

#2. If the host is inside diffserv environment all these things just
have no effects and make no sense. That's why we do not change anything
(except for disabling access to ECN bits).


> reasons.  Firstly, if we're using the old bit fields it should be the 
> precedence bits that are used for the skb priority rather than the tos 
> field. Secondly, the whole precedence/tos thing has been obsoleted by 
> the 6-bit DSCP field, of which the first 3 bits are supposed to be 
> backwards compatible with the old precedence field.  Shouldn't we 
> properly handle that?

See above #1. Precedence bits used to be _non-sense_ in the past and their use
outside of context of setup of your routers (in pre-DS world) or outide
context of diffserv does not make sense.

What's about "backward-compatibility", it sounds funny, DS is made compatible
with Cisco use precedence and this has nothing to do with end users
(where socket options make sense), precedence bits are rewritten by routers
for their own use.


> Secondly, for vlan priority tagging there are only 3 bits available. 
> This means that practically speaking anyone using vlan priorities needs 
> to limit themselves to priorities 0-7.

Thirdly. :-)

Technically speaking, direct access of user to such things is prohibited
in any case. So, use proper classifiers to do right mappings.


> Currently, for me to send a packet with IP precedence bits set to a 
> nonzero value *and* vlan priority set to the same value, I have to do 
> the following:
> 
> int opt = PRIORITY << 5;
> setsockopt(mysocks[i], SOL_IP, IP_TOS, &opt, sizeof(opt));
> opt = PRIORITY;
> setsockopt(mysocks[i], SOL_SOCKET, SO_PRIORITY, &opt, sizeof(opt));

This is right.


> This is kind of ugly.

Hmm.. This is kinda nice. IP_TOS sets real TOS bits without any funny
shifts and masks, but with some reasonable access control, SO_PRIORITY
sets priority. TOS and PRIORITY are not related.


>	  I propose adding a new IP socket option, IP_DSCP, 
> which would let you set the 6-bit DSCP value (which is then shifted by 
> two bits in the kernel to generate the 8-bit value for the header 
> field).  

I do not even think that IP_DSCP makes sense in diffserv environment.
Packets are marked according to DS rules, not according to desire
of particular user.

Anyway, the thing which you suggest is equal to IP_TOS in this part.


>	The high-order 3 bits would then be automatically used to set 
> the socket priority to make a vlan egress mapping simple.

Not even subject to discuss... In old current world it is just wrong,
in new world it is even wronger.

If DSCP is used for prioritizing, it is used via proper classifiers,
not via some rules hardcoded to kernel.

Alexey
