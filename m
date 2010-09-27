From: Bob Arendt <rda@rincon.com>
Subject: Re: IGMP v3 reponse
Date: Mon, 27 Sep 2010 16:51:15 -0700
Message-ID: <4CA12DF3.6050608@rincon.com>
References: <20100927200500.GB25879@obsidianresearch.com> <OF056C7E7C.A9A5EFC7-ON882577AB.006E6B89-882577AB.006F2C1E@us.ibm.com> <alpine.DEB.2.00.1009271521510.14117@router.home> <4CA1048C.8020508@rincon.com> <OF9D99FA29.B3F53176-ON882577AB.00780023-882577AB.0078FAAE@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <cl@linux.com>,
	Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"netdev-owner@vger.kernel.org" <netdev-owner@vger.kernel.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rinconresearch.com ([67.128.198.140]:13247 "EHLO
	autodiscover.rincon.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751608Ab0I0XvQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 19:51:16 -0400
In-Reply-To: <OF9D99FA29.B3F53176-ON882577AB.00780023-882577AB.0078FAAE@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/27/10 15:01, David Stevens wrote:
> Bob Arendt<rda@rincon.com>  wrote on 09/27/2010 01:54:36 PM:
>> And it turns out that  force_igmp_version=2 doesn't fully work.
>> If the host sees a IGMPv3 query, it still responds with a v3 Join
>> despite the flag.  Bug report and candidate patch here:
>> https://bugzilla.kernel.org/show_bug.cgi?id=18212
>
>          This is a special case. The "correct" alternative is to drop
> the query and not send any report at all. Sending an answer in the
> originating protocol doesn't hurt anything here, because MC routers
> are required to use the earlier version too; there should be no such
> thing as an "IGMPv3-only querier" as in that report. IGMPv3 compliance
> *requires* falling back to IGMPv2 if there is a v2 query by another
> router.
>          By answering instead of dropping, it allows fuller filter
> information from a manual query to be returned even if the network
> is using v2 MC routers, but dropping and ignoring the query as
> required by RFC does not fix the bug&  patch submitter's problem.
> Which is why I also NACKed that patch.
>
>                                                          +-DLS
>
>
Per rfc 2236, the v2 client *can't* drop the IGMPv3 query.  From para 2.5:
   2.5.  Other fields
    Note that IGMP messages may be longer than 8 octets, especially
    future backwards-compatible versions of IGMP.  As long as the Type is
    one that is recognized, an IGMPv2 implementation MUST ignore anything
    past the first 8 octets while processing the packet.  However, the
    IGMP checksum is always computed over the whole IP payload, not just
    over the first 8 octets.

The IGMPv3 query *is* a valid v2 query with extra crap at the end (it's
backward compatible).  Per rfc 2236 p2.5, the v3 query has to be regarded
as a valid v2 query if you're correctly implementing IGMPv2.  Some switch
vendors (Cisco for one) only generate v3 queries when operating as an
IGMP snooping switch, since a proper v2 client will respond with IGMPv2
packets and it handles this properly.  However, we're seeing some switches
get confused when a client initial joins with v2, then responds to a query
with v3.  It ends up creating 2 entries, and only one is cleared by the
leave message.  This is also an issue when the primary (querier) switch
only generates v3 queries, and some intermediate switches only support v2.
We set all the Linux clients to v2 .. but they respond the v2 query with
v3 protocols, which could be missed by the intermediate switch.

I believe the intent of the bug 18212 patch is correct.

-Bob Arendt
