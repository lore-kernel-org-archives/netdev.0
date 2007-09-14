From: "Kok, Auke" <sofar@foo-projects.org>
Subject: Re: [git patches] net driver fixes
Date: Fri, 14 Sep 2007 14:09:48 -0700
Message-ID: <46EAF89C.4080808@foo-projects.org>
References: <20070913053022.GA16891@havoc.gtf.org>
 <1189793598.2508.4.camel@xo-3E-67-34.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Dan Williams <dcbw@redhat.com>, netdev@vger.kernel.org,
	Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms046pub.verizon.net ([206.46.252.46]:54381 "EHLO
	vms046pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755189AbXIOANt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2007 20:13:49 -0400
In-reply-to: <1189793598.2508.4.camel@xo-3E-67-34.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dan Williams wrote:
> On Thu, 2007-09-13 at 01:30 -0400, Jeff Garzik wrote:
>> Please pull from 'upstream-linus' branch of
>> master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git u=
pstream-linus
>>
>> to receive the following updates:
>>
>>  drivers/net/atl1/atl1_main.c |   19 +++++++------------
>>  drivers/net/ehea/ehea.h      |    5 ++++-
>>  drivers/net/ehea/ehea_main.c |   16 ++++++++++++++--
>>  drivers/net/phy/phy.c        |    4 ++--
>>  drivers/net/phy/phy_device.c |    4 ++--
>>  drivers/net/sky2.c           |    9 ++++++++-
>>  drivers/net/spider_net.c     |   12 ++++--------
>>  7 files changed, 41 insertions(+), 28 deletions(-)
>>
>> Hans-J=C3=BCrgen Koch (1):
>>       Fix a lock problem in generic phy code
>>
>> Ishizaki Kou (1):
>>       spidernet: fix interrupt reason recognition
>>
>> Jan-Bernd Themann (2):
>>       ehea: propagate physical port state
>>       ehea: fix last_rx update
>>

maybe a little bit late with this comment:

>>  			ehea_error("Failed setting port speed");
>>  		}
>>  	}
>> -	netif_carrier_on(port->netdev);
>> +	if (!prop_carrier_state || (port->phy_link =3D=3D EHEA_PHY_LINK_UP=
))
>> +		netif_carrier_on(port->netdev);
>> +
>>  	kfree(cb4);
>>  out:
>>  	return ret;
>> @@ -869,13 +875,19 @@ static void ehea_parse_eqe(struct ehea_adapter=
 *adapter, u64 eqe)
>>  			}
>> =20
>>  		if (EHEA_BMASK_GET(NEQE_EXTSWITCH_PORT_UP, eqe)) {
>> +			port->phy_link =3D EHEA_PHY_LINK_UP;
>>  			if (netif_msg_link(port))
>>  				ehea_info("%s: Physical port up",
>>  					  port->netdev->name);
>> +			if (prop_carrier_state)
>> +				netif_carrier_on(port->netdev);
>>  		} else {
>> +			port->phy_link =3D EHEA_PHY_LINK_DOWN;
>>  			if (netif_msg_link(port))
>>  				ehea_info("%s: Physical port down",
>>  					  port->netdev->name);
>> +			if (prop_carrier_state)
>> +				netif_carrier_off(port->netdev);

maybe it was better to code this as 'ehea_carrier_off/on()' which then =
tests=20
(prop_carrier_state) - this now begs for regressions where this isn't p=
roperly=20
done in future commits, and on top of that there are all these extra co=
nditions now.

Cheers,

Auke

