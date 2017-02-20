From: Andreas Schultz <aschultz@tpip.net>
Subject: Re: [PATCH net-next v3 1/8] gtp: add documentation
Date: Mon, 20 Feb 2017 18:28:07 +0100 (CET)
Message-ID: <1839823227.173727.1487611687205.JavaMail.zimbra@tpip.net>
References: <20170213153624.14170-1-aschultz@tpip.net> <20170213153624.14170-2-aschultz@tpip.net> <20170220161552.tnewzagg4z4azikd@nataraja>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: pablo <pablo@netfilter.org>, netdev <netdev@vger.kernel.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        osmocom-net-gprs <osmocom-net-gprs@lists.osmocom.org>,
        Jonas Bonn <jonas@southpole.se>
To: laforge <laforge@gnumonks.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:47634 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754413AbdBTR2P (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Feb 2017 12:28:15 -0500
In-Reply-To: <20170220161552.tnewzagg4z4azikd@nataraja>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

----- On Feb 20, 2017, at 5:15 PM, laforge laforge@gnumonks.org wrote:

> Hi Andreas,
> 
> this is not really about the documentation, but it still makes sense to
> discuss here as the issue is best described:
> 
> On Mon, Feb 13, 2017 at 04:36:17PM +0100, Andreas Schultz wrote:
>> +Local GTP-U entity and tunnel identification
>> +--------------------------------------------
>> +
>> +GTP-U uses UDP for transporting PDU's. The receiving UDP port is 2152 for
>> +GTPv1-U and 3386 for GTPv0-U.
>> +
>> +There is only one GTP-U entity (and therefor SGSN/GGSN/S-GW/PDN-GW instance)
>> +per IP address. Tunnel Endpoint Identifier (TEID) are unique per GTP-U entity.
>> +
>> +A specific tunnel is only defined by the destination entity. Since the
>> +destination port is constant, only the destination IP and TEID define
>> +a tunnel. The source IP and Port have no meaning for the tunnel.
> 
> Are you absolutely sure about this?

Yes. It took me a while to realize this. The crux is this statement in TS 29.060,
Section 7.3.1:

> The SGSN shall include an SGSN Address for control plane and an SGSN address for
> user traffic, which may differ from that provided by the underlying network service
> (e.g. IP). The GGSN shall store these SGSN Addresses and use them when sending
> control plane on this GTP tunnel or G-PDUs to the SGSN for the MS.

IMHO, this implies that the source IP of GTP-U and GTP-C frames does not have to
match the GSN address specified by a Create PDP Context Request.

For GTPv2-C there is no such clear statement. However, GTPv2-C makes it clear
that a TEID describes the local tunnel ENDPOINT, there nothing that defines
the tunnel *source* (the same is true for GTPv1-C, except that is not so
explicit).

TS 29.274, Section 4.2.2.1, Initial Messages:

> During the establishment of the GTP tunnel, the GTPv2 entity selects and
> communicates to the peer GTPv2 entity the IP Destination Address at which
> it expects to receive subsequent control plane Initial messages related
> to that GTP tunnel via .....

TS 23.401, Annex D, Sect. D.3.3. makes is clear beyond doubt that we have to
accept packet for a valid TEID from virtually any IP. If you look at figure
D.3.3-1, step 16, you will see that only the new SGSN is contacting the P-GW.
There is no prior advertisement of the change from the old SGSN.

Step 16 would therefor not work if we limited the tunnel to a specific source
IP.

The same applies to figure D.3.4-1, step 18.

>> +[3GPP TS 29.281] Section 4.3.0 defines this so:
>> +
>> +> The TEID in the GTP-U header is used to de-multiplex traffic incoming from
>> +> remote tunnel endpoints so that it is delivered to the User plane entities
>> +> in a way that allows multiplexing of different users, different packet
>> +> protocols and different QoS levels. Therefore no two remote GTP-U endpoints
>> +> shall send traffic to a GTP-U protocol entity using the same TEID value
>> except
>> +> for data forwarding as part of mobility procedures.
>> +
>> +The definition above only defines that two remote GTP-U endpoints *should not*
>> +send to the same TEID, it *does not* forbid or exclude such a scenario. In
>> +fact, the mentioned mobility procedures make it necessary that the GTP-U entity
>> +accepts traffic for TEID's from multiple or unknown peers.
> 
> I so far always assumed that you use GTP-C "MODIFY PDP CONTEXT" in case
> of such mobility situations, i.e. the control plane explicitly notifies
> the GTP-U entity of a change in the SGSN/S-GW address.

Yes, it does. But that notification only applies to the tunnel endpoint at
the SGSN/S-GW in the GGSN/P-GW to SGSN/S-GW direction.

> At least for 3G this seems to be the case, and my assumption appears to
> be confirmed with sources such as e.g. page 15 of
> http://www.nwadmin.de/presentation_mobility_manag ement_in_UMTS.pdf
> 
> Also, for LTE, it seems that there's a GTPv2-C "Modify Bearer
> Request/Response" involved in relocation from one S-GW to another S-GW:
> http://www.lteandbeyond.com/2012/03/x2-based-handover-with-sgw-relocation.html

I think this affirms my argument, Step 3a is sending GTP packets from a
source IP that is know to the P-GW before. The fact that this is only
used for GTP-C does IMHO not mean that the same should not apply to
GTP-U.

>> Step 3. The target Serving GW assigns addresses and TEIDs (one per
>> bearer) for downlink traffic from the PDN GW. The Serving GW allocates
>> DL TEIDs on S5/S8 even for non-accepted bearers. It sends a Modify
>> Bearer Request (Serving GW addresses for user plane and TEID(s))
>> message per PDN connection to the PDN GW(s). The SGW also includes
>> User Location Information IE and/or UE Time Zone IE if it is present
>> in step 2. The PDN GW updates its context field and returns a Modify
>> Bearer Response (Charging Id, MSISDN, etc.) message to the Serving GW.
>> The MSISDN is included if the PDN GW has it stored in its UE context.
>> The PDN GW starts sending downlink packets to the target GW using the
>> newly received address and TEIDs. These downlink packets will use the
>> new downlink path via the target Serving GW to the target eNodeB. The
>> Serving GW shall allocate TEIDs for the failed bearers and inform to
>> the MME.
> 
> Section 5.5.1.1.3 of TS 23.401 agrees with the GTPv2C signalling during
> relocation, AFAICT.

Again, there is nothing in there that defines a IP *source*, a F-TEID is
a tunnel ENDPOINT id not a tunnel SOURCE id.

>> +Therefor the receiving side only identifies tunnels based on TEID's, not based
>> +on the source IP.
> 
> I'm wondering if this really is neccesary. Do you have actual protocol
> traces, specs or any other literature confirming this?

So far I have only seen symmetric GTP-U tunnels. However I believe there
is nothing that would stop a SGSN/S-GW from switching GPT-U tunnel source
transparently across IP's (for example a system with multiple shelves might
use different shelve in DL/UL direction and have therefore multiple IP's.
 
> I find it somewhat surprising, given how much this opens the door for
> arbitrary spoofing from anyone (with access to the respective private
> network such as GRX).

Yes it is, but it is mandated without a doubt by the specification for
GTP-C. For the reasons outline before, I think that this applies to
GTP-U as well.

> So in which situations specifically will thre be a S-GW side Address
> change without associated GTP-C signaling informing the P-GW about the
> new S-GW side Address + TEID?

As above, multi shelve systems with asymmetric UL/DL path.

Regards,
Andreas


> 
> Regards,
>	Harald
> --
> - Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
> ============================================================================
> "Privacy in residential applications is a desirable marketing option."
>                                                   (ETSI EN 300 175-7 Ch. A6)
