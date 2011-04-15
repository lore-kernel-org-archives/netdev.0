From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: The bonding driver should notify userspace of MAC address change
Date: Fri, 15 Apr 2011 14:45:32 -0700
Message-ID: <16422.1302903932@death>
References: <20110415184407.550abd88@pomiocik.lan> <4DA89114.9040900@gmail.com> <10227.1302893590@death> <4DA89ADC.7040808@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?us-ascii?Q?=3D=3FUTF-8=3FB=3FTWljaGHFgiBHw7Nybnk=3D=3F=3D?=
	<mgorny@gentoo.org>, netdev@vger.kernel.org, roy@marples.name,
	Andy Gospodarek <andy@greyhouse.net>
To: =?us-ascii?Q?=3D=3FUTF-8=3FB=3FTmljb2xhcyBkZSBQZXNsb8O8YW4=3D=3F=3D?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:51526 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757077Ab1DOVpg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 17:45:36 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e39.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3FLWDnp020450
	for <netdev@vger.kernel.org>; Fri, 15 Apr 2011 15:32:13 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3FLjZIN103446
	for <netdev@vger.kernel.org>; Fri, 15 Apr 2011 15:45:35 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3FLjYX6012703
	for <netdev@vger.kernel.org>; Fri, 15 Apr 2011 15:45:35 -0600
In-reply-to: <4DA89ADC.7040808@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas de Peslo=C3=BCan <nicolas.2p.debian@gmail.com> wrote:

>Agreed.
>
>> 	Is there some race window there between the register and the
>> netif_carrier_off?
>
>It might be that dhcpd does not wait for link to be up before starting=
 to send DHCP requests.

	It looks like it's not related to carrier state at all:

#212: dhcpcd requires restart to get an IP address for bonded interface
-----------------------+-----------------
  Reporter:  mgorny@=E2=80=A6  |      Owner:  roy
      Type:  defect    |     Status:  new
  Priority:  major     |  Milestone:
 Component:  dhcpcd    |    Version:  5.1
Resolution:            |   Keywords:
-----------------------+-----------------

Comment (by roy):

 Sorry, the above isn't too clear.

 dhcpcd will read the hardware address when the interface is marked IFF=
_UP
 or when given RTM_NEWLINK with ifi->ifi_change =3D ~0U, the latter bei=
ng
 sent by some drivers to tell userland that an interface characteristic=
 has
 changed - like say a hardware address - if the driver supports such a
 change whilst still up. Normal behaviour is to mark device as DOWN bef=
ore
 changing hardware address. bonding does this whilst marked UP, hence t=
his
 issue.

 carrier going up / down is just that, it's not a signal to re-read the
 interface characteristics.


	Now this confuses me again; I thought that running the dhcp
client (dhcpcd) over bonding has worked for years, although I've not
personally tried it recently.  Perhaps it varies by distro.  In any
event, this behavior of bonding (setting the bond's MAC without a
down/up flip) has never been different in my memory.

	I've not yet dug down to see if NETDEV_CHANGEADDR will result in
an RTM_NEWLINK to user space.  At first glance it doesn't look like it.

	When bonding goes link up, however, I think linkwatch_do_dev
will issue an RTM_NEWLINK (via a call to netdev_state_change), or,
alternately, dev_change_flags will do it at IFF_UP time.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
