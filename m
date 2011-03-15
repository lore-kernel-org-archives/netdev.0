From: Jesse Gross <jesse@nicira.com>
Subject: Re: sky2, vlan and nat/masquerading
Date: Mon, 14 Mar 2011 18:55:17 -0700
Message-ID: <AANLkTikXBz6ZpuSgqaAV-=Jr3qtDQ3T_We42R65Sd20O@mail.gmail.com>
References: <20110309181522.61ca1cc7@leda.vpn.lugor.de> <AANLkTi=AJJA0d0=CFuS66=+O6b80Ejj0w3NfKQ+OWzsK@mail.gmail.com>
 <20110314111105.5a62e092@leda.vpn.lugor.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Christian Hesse <mail@eworm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:42743 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053Ab1COBzi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 21:55:38 -0400
Received: by vxi39 with SMTP id 39so150080vxi.19
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 18:55:37 -0700 (PDT)
In-Reply-To: <20110314111105.5a62e092@leda.vpn.lugor.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 14, 2011 at 3:11 AM, Christian Hesse <mail@eworm.de> wrote:
> On Fri, 11 Mar 2011 16:39:02 -0800 Jesse Gross <jesse@nicira.com> wro=
te:
>> On Wed, Mar 9, 2011 at 9:15 AM, Christian Hesse <mail@eworm.de> wrot=
e:
>> > Hello everybody,
>> >
>> > I have a Samsung NF310, running kernel 2.6.37.3 with a patch to ma=
ke my
>> > ethernet controller work for vlans. It was discussed with the subj=
ect
>> > "sky2: convert to new VLAN model (v0.2)" and made it to to kernel =
tree
>> > with commit 86aa77854f47ab6f5f9c687507af1f57d2b89004.
>>
>> Does that commit actually change the behavior that you are seeing? =A0=
It
>> shouldn't be necessary for correct functionality.
>
> Plain 2.6.37 did not work at all. Received packets with vlan tag did =
not make
> it to the vlan interface but ended on the native ethernet interface i=
irc.

Hmm, that is very odd.  I don't see anything in the patch that would
change behavior in that regard.

>
>> Do you know if this
>> worked at some point in the past?
>
> This was the first time I used nat with two vlan interfaces.
>
>> > However it does not work properly, here are the details:
>> >
>> > * Switch with one trunk port and several port in corresponding vla=
n ports
>> > * Host connected to one of the vlan ports
>> > * Samsung Netbook (see above) connected to the trunk port.
>> >
>> > I get an IP address 192.168.x.x/24 via DHCP on interface connected=
 to
>> > vlan 1. The interface connected to vlan 2 has 172.16.0.1/24 and se=
rves
>> > addresses via DHCP. The system is set up to masquerade from 172.16=
=2E0.1/24.
>> >
>> > I can access my netbook from the host in vlan 2, however I can not=
 access
>> > anything behind. The packets contain a broken vlan tag and the hos=
t does
>> > not recognize them.
>>
>> When you say "the host does not recognize them", what host do you
>> mean? =A0This is a different host on vlan 1?
>
> No, this is the host in vlan2.
> The packet contains the vlan tag with vid 0. It should not. The host =
discards
> it as it does not have a vlan interface with vid 0.
>
>> > I've attached a tcpdump log. Please take a look at the icmp echo r=
equest
>> > and reply packets, especially the last one.
>>
>> What do you mean by broken? =A0I only see one tag in the trace, whic=
h is
>> on the packet originating from 192.168.100.3 and it has a vid of 0.
>
> The tag itself is valid. But it should not be there as it comes from
> a native ethernet port.
>
>> Where was this trace captured?
>
> This trace was captured on the host in vlan2.
>
> Ok, let me explain step by step:

Thank you, this helps a lot in understanding your setup.

>
> * Host sends icmp echo request (172.16.0.21 -> 192.168.100.3) to rout=
er
> =A0172.16.0.1, the packet is untagged.
> * Switch receives the packet on native interface with vid 2, tags it =
and sends
> =A0it to the trunk)
> * Netbook receives the packet from trunk, untags it an queues it to v=
lan
> =A0interface 2.
> * Netbook nats the packet (192.168.x.140 > 192.168.100.3), tags it wi=
th vlan
> =A02 and sends it to the trunk.

=46or clarity, I'm assuming that this is supposed to be vlan 1?

> * Switch receives the packet from trunk, untags it and sends it to na=
tive
> =A0interface with vlan 1.
> * The packet and its answer (192.168.100.3 -> 192.168.x.140) make the=
ir way
> =A0through the network.
> * Switch receives the icmp echo reply on native interface with vlan 1=
, tags
> =A0it and sends it to the trunk
> * Netbook receives the packet from trunk, untags it an queues it to v=
lan
> =A0interface 1.
> * Netbooks restores the original addresses from nat (192.168.100.3 ->
> =A0172.16.0.21), _tags_it_with_vlan_0_, tags it with vlan 2 and sends=
 it to the
> =A0trunk

Can you capture a packet trace on the netbook's Ethernet interface to
see what it thinks it is sending?
