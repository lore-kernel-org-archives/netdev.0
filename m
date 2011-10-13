From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next PATCH] net: allow vlan traffic to be received under
 bond
Date: Thu, 13 Oct 2011 10:42:25 -0700
Message-ID: <4E972301.4030004@intel.com>
References: <20111010191641.2496.84845.stgit@jf-dev1-dcblab> <20111010223752.GB2373@minipsycho> <1318518274.9266.94.camel@sakura.staff.proxad.net>,<20111013153850.GA2031@minipsycho> <C8A6796DE7C66C4ABCBC18106CB6C1CC106D903179@ESESSCMS0356.eemea.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>, Maxime Bizon <mbizon@freebox.fr>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"fubar@us.ibm.com" <fubar@us.ibm.com>
To: =?ISO-8859-1?Q?Hans_Schillstr=F6m?= <hans.schillstrom@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:12703 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752906Ab1JMRm0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Oct 2011 13:42:26 -0400
In-Reply-To: <C8A6796DE7C66C4ABCBC18106CB6C1CC106D903179@ESESSCMS0356.eemea.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/13/2011 8:59 AM, Hans Schillstr=F6m wrote:
> Thu, Oct 13, 2011 at 05:04:34PM CEST, mbizon@freebox.fr wrote:
>>>
>>> On Tue, 2011-10-11 at 00:37 +0200, Jiri Pirko wrote:
>>>
>>>> Hmm, I must look at this again tomorrow but I have strong feeling =
this
>>>> will break some some scenario including vlan-bridge-macvlan.
>>>
>>> unless I'm mistaken, today's behaviour:
>>>
>>> # vconfig add eth0 100
>>> # brctl addbr br0
>>> # brctl addif br0 eth0
>>>
>>> =3D> eth0.100 gets no more packets, br0.100 is to be used
>>>
>>> after the patch won't we get the opposite ?
>>
>> Looks like it. The question is what is the correct behaviour...
>=20
> I think this it become correct now, you should not destroy lover leve=
l if possible.
> I.e. as John wrote "it's not an unexpected behaviour"
>=20
> Consider adding a bridge to a vlan like this
>=20
> vconfig add eth0 100
> brctl addbr br1
> brctl addif br1 eth0.100
>=20
> If you later add a bridge (or bond) should the previous added bridge =
still work ?=20
> Yes I think so, for me it's the expected behaviour.
>=20
> brctl addbr br0
> brctl addif br0 eth0
>=20
> Regards
> Hans
>=20
>=20

Sorry I'm not entirely sure I followed the above two posts. Note
this patch restores behavior that has existed for most of the
2.6.x kernels. In the 3.x kernels VLAN100 is dropped in the
schematic below (assuming eth0 is active), I think this is
incorrect.

       ---> eth0.100
       |
       |
eth0 -----> br0

With this patch VLAN100 is delivered to eth0.100 as I expect. Now
adding a VLAN100 to br0.


       ---> eth0.100
       |
       |
eth0 -----> br0---> br0.100

With this patch in the above case VLAN100 is delivered to the
first matching vlan. Here eth0.100 will receive the packet If
you really want br0.100 to receive the packet remove eth0.100.
Without this patch the packet will be delivered to br0.100,
but no configuration will allow a packet to be delivered to
eth0.100 with a bond.

The first schematic is used for doing bonding on LAN traffic
and SAN (storage) traffic with MPIO. So I think my expectations
are correct and have a real use case.

Thanks,
John
