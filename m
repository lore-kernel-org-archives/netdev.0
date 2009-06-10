From: Gil Beniamini <gil.beniamini@gmail.com>
Subject: Re: SOCK_RAW does not receive broadcast (with VLAN unless PROMISC)
Date: Wed, 10 Jun 2009 17:24:58 +0300
Message-ID: <91ac27070906100724v25c2328x6b343315358c8e12@mail.gmail.com>
References: <91ac27070906081105x30171bedra10d244d382a6934@mail.gmail.com>
	 <4A2E4A32.1060705@trash.net>
	 <91ac27070906090608me50af3bv23b150d8d0cd0080@mail.gmail.com>
	 <200906091430.32294.bcook@bpointsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Brent Cook <bcook@bpointsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:18062 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757450AbZFJOY6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 10:24:58 -0400
In-Reply-To: <200906091430.32294.bcook@bpointsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick,
My application is a "proxy" and need to support few VLANs (for example =
vlan 24).
I define all vlans on interface 'eth0' which is my "out i/f", while
the other interface 'eth1' (used as "in i/f") I use with PF_PACKET /
SOCK_RAW in order to handle VLANs by my application (starting with
"arp broadcast").
When I try to define the same (relevant VLAN) on eth1 (inorder to
check your suggestion), I get "Error: trying to add VLAN #24 to IF
-:eth1:- error: file exist".
It seems that linux does not allow to define the same VLAN # on more
than a single i/f?!
Thanks Gil

Brent,
Thanks I am aware of BPF and if I don't find a better solution, this
will be my filter.
Thanks Gil

On Tue, Jun 9, 2009 at 10:30 PM, Brent Cook<bcook@bpointsys.com> wrote:
> On Tuesday 09 June 2009 08:08:01 am Gil Beniamini wrote:
>> Patrick,
>> On the specific NIC (eth1) no vlan is defined, and in the new Linux
>> the application receive NOTHING at all. In order to debug, I start
>> "wireshark as root" and "wireshark" set PROMISC on, and the
>> application start receive the raw packets as expected. Later I start=
ed
>> setting PROMISC by my application, and it can receive the packets ev=
en
>> when "wireshark" is not running.
>> The problem that I have with PROMISC mode, is that I need to do the
>> irelevant =A0unicast filtering in software rather than get it from t=
he
>> hardware (as it works in old kernel 2.6.20).
>> Thanks a lot, Gil
>
> One solution is to attach a BPF filter to the socket. Then you will o=
nly
> receive packets for whatever you are filtering. This is still in soft=
ware, but
> it is higher up in the abstraction, and undoubtedly more efficient th=
an doing
> it at the app level.
>
> Simply compile the BPF program you wish to filter, e.g:
>
> # tcpdump -dd vlan 4
> { 0x28, 0, 0, 0x0000000c },
> { 0x15, 0, 4, 0x00008100 },
> { 0x28, 0, 0, 0x0000000e },
> { 0x54, 0, 0, 0x00000fff },
> { 0x15, 0, 1, 0x00000004 },
> { 0x6, 0, 0, 0x00000060 },
> { 0x6, 0, 0, 0x00000000 },
>
> Then attach it to your socket:
>
> =A0 =A0struct sock_filter filter[] =3D {
> =A0 =A0 =A0{ 0x28, 0, 0, 0x0000000c },
> =A0 =A0 =A0{ 0x15, 0, 4, 0x00008100 },
> =A0 =A0 =A0{ 0x28, 0, 0, 0x0000000e },
> =A0 =A0 =A0{ 0x54, 0, 0, 0x00000fff },
> =A0 =A0 =A0{ 0x15, 0, 1, 0x00000004 },
> =A0 =A0 =A0{ 0x6, 0, 0, 0x00000060 },
> =A0 =A0 =A0{ 0x6, 0, 0, 0x00000000 },
> =A0 =A0};
>
> =A0 =A0struct sock_fprog inbound_filter =3D {
> =A0 =A0 =A0 =A0.len =3D 7, .filter =3D filter
> =A0 =A0};
>
> =A0 =A0if (setsockopt(fd, SOL_SOCKET, SO_ATTACH_FILTER,
> =A0 =A0 =A0 =A0&inbound_filter, sizeof(inbound_filter)) < 0) {
> =A0 =A0 =A0 =A0return -1;
> =A0 =A0}
>
> Also, note, you can easily set promiscuous mode directly with socket =
opts too.
> If you're more curious, just look at libpcap source.
>
> =A0- Brent
>
