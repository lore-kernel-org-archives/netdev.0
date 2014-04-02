From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of switch chip datapath
Date: Wed, 2 Apr 2014 08:37:28 -0700
Message-ID: <AC3C5F7C-E515-48FC-AA76-E7199C6FFB51@cumulusnetworks.com>
References: <20140325180009.GB15723@casper.infradead.org> <20140325193533.GF8102@hmsreliant.think-freely.org> <CAGVrzcbRggJV+5+EuZnXVoU+qdK9ugPRL+J-mp-UraGuo19jnQ@mail.gmail.com> <5332677F.2090404@cumulusnetworks.com> <5332B1FE.7080102@mojatatu.com> <53330639.8050403@cumulusnetworks.com> <20140326165934.GH2869@minipsycho.orion> <533312A3.5070600@cumulusnetworks.com> <20140326180356.GK2869@minipsycho.orion> <2D65D0C2-6BBC-4968-8400-4EB60BDF887A@cumulusnetworks.com> <20140402064118.GA2844@minipsycho.orion>
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Thomas Graf <tgraf@suug.ch>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	dborkman <dborkman@redhat.com>, ogerlitz <ogerlitz@mellanox.com>,
	jesse <jesse@nicira.com>, pshelar <pshelar@nicira.com>,
	azhou <azhou@nicira.com>, Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:33205 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758623AbaDBPjc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 11:39:32 -0400
In-Reply-To: <20140402064118.GA2844@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Apr 1, 2014, at 11:41 PM, Jiri Pirko <jiri@resnulli.us> wrote:

> Tue, Apr 01, 2014 at 09:13:00PM CEST, sfeldma@cumulusnetworks.com wro=
te:
>>=20
>> On Mar 26, 2014, at 11:03 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>=20
>>> Wed, Mar 26, 2014 at 06:47:15PM CET, roopa@cumulusnetworks.com wrot=
e:
>>>> On 3/26/14, 9:59 AM, Jiri Pirko wrote:
>>>>> Wed, Mar 26, 2014 at 05:54:17PM CET, roopa@cumulusnetworks.com wr=
ote:
>>>>> So you implement bonding netlink api? Or you hook into bonding dr=
iver
>>>>> itselt? Can you show us the code?
>>>> We use the netlink API and libnl. In our current model, our switch
>>>> chip driver listens to netlink notifications and programs the swit=
ch
>>>> chip. The switch chip driver uses libnl caches and libnl netlink a=
pis
>>>> to reflect the kernel state to switch chip.
>>>=20
>>>=20
>>> So when you configure for example bonding over 2 ports, you actuall=
y use
>>> bonding driver to do that. And you userspace app listens to
>>> notifications and programs the switch chip accordingly. Am I close?
>>>=20
>>> How about data? Is this new "bonding" interface able to assign ip t=
o is
>>> and send/receive packets.
>>>=20
>>> I'm still not sure I understand your concept. Do you have some
>>> documentation for it available?
>>=20
>> Actually Jiri this is the code you and I worked on recently to netli=
nk-ify bonding/slave attributes and active/inactive notification. You h=
ave it right, user uses normal ip link tools and bonding driver to crea=
te bond, set attributes, and enslave switch ports. RTM_NEWLINK is used =
to program ASIC to offload LAG to HW.  RTM_NEWLINK msgs contains bond a=
ttributes (mode, etc) and slave list, as well as slave status.  This is=
 enough information to program ASIC.  Once programmed, ASIC offloads th=
e data plane traffic, and in the case of egress, handles the LAG hash d=
istribution.  Only the LACP control plane traffic makes it to the bondi=
ng driver; data plane traffic does not make it to the bonding driver.
>>=20
>> So, not trying to sound like a smart-ass, but the documentation is t=
he bonding driver, specifically the netlink attributes/notifications.
>=20
> Ok, so no additional kernel code for this?

The kernel is rich with netlink.  Bonds, bridges, vlans, vxlans, L3 rou=
te tables, flow tables, neigh table, addr table, and the list goes on, =
all give up their info via netlink.  Add in a simple netdev-based abstr=
action for switch ports (such as yours) and you have everything (well, =
almost, the devil is in the details) you need to program switch chips. =
 From netlink you get the mgmt plane to HW offload the data plane from =
the kernel.

> Only some user pace agent programming the chip?

If using netlink, the agent programming the chip can live in the kernel=
 (preferred) or user-space.  Netlink listener can reside either place, =
since it=92s a multicast bus.

-scott
