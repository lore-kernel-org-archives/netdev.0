From: Andreas Schultz <aschultz@tpip.net>
Subject: Re: [PATCH net-next v3 1/8] gtp: add documentation
Date: Wed, 22 Feb 2017 12:30:07 +0100 (CET)
Message-ID: <404391156.187750.1487763007868.JavaMail.zimbra@tpip.net>
References: <20170213153624.14170-1-aschultz@tpip.net> <20170213153624.14170-2-aschultz@tpip.net> <20170220161552.tnewzagg4z4azikd@nataraja> <1839823227.173727.1487611687205.JavaMail.zimbra@tpip.net> <20170222083631.722ycqfcyc2ma34u@nataraja>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: pablo <pablo@netfilter.org>, netdev <netdev@vger.kernel.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        osmocom-net-gprs <osmocom-net-gprs@lists.osmocom.org>,
        Jonas Bonn <jonas@southpole.se>
To: laforge <laforge@gnumonks.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:41934 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932234AbdBVLaN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 22 Feb 2017 06:30:13 -0500
In-Reply-To: <20170222083631.722ycqfcyc2ma34u@nataraja>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Harald,

----- On Feb 22, 2017, at 9:36 AM, laforge laforge@gnumonks.org wrote:

> Hi Andreas,
> 
> thanks for your feedback.
> 
> On Mon, Feb 20, 2017 at 06:28:07PM +0100, Andreas Schultz wrote:
>> > Are you absolutely sure about this?
>> 
>> Yes. It took me a while to realize this. The crux is this statement in TS
>> 29.060,
>> Section 7.3.1:
>> 
>> > The SGSN shall include an SGSN Address for control plane and an SGSN address for
>> > user traffic, which may differ from that provided by the underlying network
>> > service
>> > (e.g. IP). The GGSN shall store these SGSN Addresses and use them when sending
>> > control plane on this GTP tunnel or G-PDUs to the SGSN for the MS.
>> 
>> IMHO, this implies that the source IP of GTP-U and GTP-C frames does not have to
>> match the GSN address specified by a Create PDP Context Request.
> 
> Yes, I follow that reasoning for GTP-C (i.e. the transport-layer S-GW
> source IP of the CREATE PDP CTX REQ may differ from the one signalled
> inside GTP-C.
> 
> For GTP-U however, this just means that GTP-U in general can use
> different IP addresses from GTP-C.  This is well-known and I also have
> no doubts about this.
> 
> But what I still doubt is whether within an ongoing GTP-U tunnel, the
> source IP address can change at any time without any signaling
> announcing that change.
> 
>> TS 29.274, Section 4.2.2.1, Initial Messages:
>> 
>> > During the establishment of the GTP tunnel, the GTPv2 entity selects and
>> > communicates to the peer GTPv2 entity the IP Destination Address at which
>> > it expects to receive subsequent control plane Initial messages related
>> > to that GTP tunnel via .....
>> 
>> TS 23.401, Annex D, Sect. D.3.3. makes is clear beyond doubt that we have to
>> accept packet for a valid TEID from virtually any IP. If you look at figure
>> D.3.3-1, step 16, you will see that only the new SGSN is contacting the P-GW.
>> There is no prior advertisement of the change from the old SGSN.
> 
> Yes, but that is again GTP-C, and not GTP-U.
> 
>> Step 16 would therefor not work if we limited the tunnel to a specific source
>> IP.
> 
> correct. But it is a GTP-C transaction.
> 
>> > I so far always assumed that you use GTP-C "MODIFY PDP CONTEXT" in case
>> > of such mobility situations, i.e. the control plane explicitly notifies
>> > the GTP-U entity of a change in the SGSN/S-GW address.
>> 
>> Yes, it does. But that notification only applies to the tunnel endpoint at
>> the SGSN/S-GW in the GGSN/P-GW to SGSN/S-GW direction.
>> 
>> > At least for 3G this seems to be the case, and my assumption appears to
>> > be confirmed with sources such as e.g. page 15 of
>> > http://www.nwadmin.de/presentation_mobility_manag ement_in_UMTS.pdf
>> > 
>> > Also, for LTE, it seems that there's a GTPv2-C "Modify Bearer
>> > Request/Response" involved in relocation from one S-GW to another S-GW:
>> > http://www.lteandbeyond.com/2012/03/x2-based-handover-with-sgw-relocation.html
>> 
>> I think this affirms my argument, Step 3a is sending GTP packets from a
>> source IP that is know to the P-GW before. The fact that this is only
>> used for GTP-C does IMHO not mean that the same should not apply to
>> GTP-U.
>> 
>> >> Step 3. The target Serving GW assigns addresses and TEIDs (one per
>> >> bearer) for downlink traffic from the PDN GW. The Serving GW allocates
>> >> DL TEIDs on S5/S8 even for non-accepted bearers. It sends a Modify
>> >> Bearer Request (Serving GW addresses for user plane and TEID(s))
>> >> message per PDN connection to the PDN GW(s). The SGW also includes
>> >> User Location Information IE and/or UE Time Zone IE if it is present
>> >> in step 2. The PDN GW updates its context field and returns a Modify
>> >> Bearer Response (Charging Id, MSISDN, etc.) message to the Serving GW.
>> >> The MSISDN is included if the PDN GW has it stored in its UE context.
>> >> The PDN GW starts sending downlink packets to the target GW using the
>> >> newly received address and TEIDs. These downlink packets will use the
>> >> new downlink path via the target Serving GW to the target eNodeB. The
>> >> Serving GW shall allocate TEIDs for the failed bearers and inform to
>> >> the MME.
>> > 
>> > Section 5.5.1.1.3 of TS 23.401 agrees with the GTPv2C signalling during
>> > relocation, AFAICT.
>> 
>> Again, there is nothing in there that defines a IP *source*, a F-TEID is
>> a tunnel ENDPOINT id not a tunnel SOURCE id.
>> 
>> >> +Therefor the receiving side only identifies tunnels based on TEID's, not based
>> >> +on the source IP.
>> > 
>> > I'm wondering if this really is neccesary. Do you have actual protocol
>> > traces, specs or any other literature confirming this?
>> 
>> So far I have only seen symmetric GTP-U tunnels. However I believe there
>> is nothing that would stop a SGSN/S-GW from switching GPT-U tunnel source
>> transparently across IP's (for example a system with multiple shelves might
>> use different shelve in DL/UL direction and have therefore multiple IP's.
> 
> yes, it might.  But then, on the other hand - at least for what I know
> about 2G/3G - it is typically very cumbersome to announce IP addresses
> to roaming partners.  It involves manual updating of related GSMA
> [paper?] forms, exchanging them with all roaming partners, and
> coordinating a change with them.  AFAIK, it is not possible to announce
> 'this is my range of S-GW IP addreses', but you have to individually
> manually announce each of them in the related documents.   There are
> projects out there where people are building additional layers of
> address translation just to work around those long and error-prone
> manual procedures, making sure that the externally visible IP addresses
> of a given SGSN/GGSN are always the same ones.
> 
> So yes, all of the above are practical/procedural concerns, but they
> would be explanations why this scenario - even if it might be supported
> by the specs - is unlikely in practise, at least within current/past
> procedures and practises.
> 
> Finally, from the point of view of packet filtering (which operators
> typically implement, otherwise the manual announcement of SGSN IP
> addresses by the above procedures wouldn't be required), it would be
> impossible to do state based filtering if there were use cases where an
> random IP address colud send valid traffic for a given tunnel.

All of above applies to roaming, however provider internal traffic is
usually not filtered and bound to GSMA IR.21 process. The use cases
and procedures supported in roaming might therefore be different from
the ones when connected to the home PLMN.

If a firewall is deployed, then it's a decision made at that point to
block or allow certain scenarios, but that should not have an impact
on what we would like to support at the GTP-U instance.

I believe we should attempt to support all defined and legal use-cases
and leave the filtering to other layers (iptables, nftables or external
firewalls).

The GSMA has also something to say about firewall and GTP IP source
addresses (although I think this mostly applies to GTP-C),
GSMA IR.33 v8.01, Section A.2:

> Unlike GTP version 0, in GTP version 1 the GGSN is allowed to send
> GTP response messages back to an SGSN with the source IP address set
> to an IP address different to that which was in the destination address 
> of the associated GTP request message. The change was made in 3GPP to
> optimize internal processing of GGSNs.

I then goes on to describe how state-aware firewalls will have problems
with that.

Anyhow, this clearly indicates that using different source IP's is a valid
use case (whether or not that might break in roaming scenarios).

>> > I find it somewhat surprising, given how much this opens the door for
>> > arbitrary spoofing from anyone (with access to the respective private
>> > network such as GRX).
>> 
>> Yes it is, but it is mandated without a doubt by the specification for
>> GTP-C. For the reasons outline before, I think that this applies to
>> GTP-U as well.
> 
> For GTP-U it may be the case.  I'm not entirely convinced, though.
> Also, even if the specifications wanted to support such scenarios, I
> think it is doubtful that this is actually implemented in practise.

I've done a test with a GTP implementation in a router from a big vendor
(an ePDG, not a GGSN/PGW). That implementation did not like asymmetric
GTP-U endpoint IP's. However, this seems to be a limitation of some kind
of receive path optimization and not a deliberate filter (at least when
I interpret the error messages correctly).

> If it was my choice, and I had to support the "loose matching", I would
> make it a configuration option (sysctl? netlink attribute?) and default
> to the more strict matching, including the source address.  It just
> seems to make much more sense and be more safe/sane.  For those people
> who really need the loose matching (and who are willing to pay the price
> for it in terms of opening up to spoofing and making packet filtering
> harder), they can set the option.

That might be an idea, not in the sense of matching but as an additional
filter. After the all the TEID is supposed the unique identifier for the
tunnel in the GTP-U entity.

We currently do not match or filter on the peer GSN source IP. That should
IMHO remain the default. Adding a per PDP context flag to filter on the
peer GSN address should be relatively simple.

> But then, I'm not the one doing that implementation, so it is up to you.
> My opinion is just an opinion.
> 
> Regards,
>	Harald

Regards,
Andreas

> 
> --
> - Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
> ============================================================================
> "Privacy in residential applications is a desirable marketing option."
>                                                   (ETSI EN 300 175-7 Ch. A6)
