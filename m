From: Thomas De Schampheleire <patrickdepinguin@gmail.com>
Subject: Re: [Bonding-devel] ethernet bonding + VLAN: additional VLAN tag in tcpdump
Date: Wed, 30 Nov 2011 10:06:47 +0100
Message-ID: <CAAXf6LXDYmjaQK6g0q6vZLeDCH1yb5MT03c21Ehqv6TgUB_R3w@mail.gmail.com>
References: <CAAXf6LXiONe5Kb8tdQbQs3SWg8cc6SK_md7-vOV8qN4vYmL8qw@mail.gmail.com>
	<4ED541F4.4080601@gmail.com>
	<20111130075237.GA2109@minipsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>, bonding-devel@lists.sourceforge.net,
	tcpdump-workers@lists.tcpdump.org,
	Ronny Meeus <ronny.meeus@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:50034 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755967Ab1K3JGs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 04:06:48 -0500
Received: by vbbfc26 with SMTP id fc26so160401vbb.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 01:06:47 -0800 (PST)
In-Reply-To: <20111130075237.GA2109@minipsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2011 at 8:52 AM, Jiri Pirko <jpirko@redhat.com> wrote:
> Tue, Nov 29, 2011 at 09:35:00PM CET, nicolas.2p.debian@gmail.com wrot=
e:
>>Le 29/11/2011 14:38, Thomas De Schampheleire a =E9crit :
>>>Hi,
>>>
>>>I'm seeing incorrect tcpdump output in the following scenario:
>>>
>>>* ethernet bonding enabled in the kernel, and a single network
>>>interface (eth0) added as slave
>>>* bonding mode was set to broadcast, but I don't think this matters
>>>* VLAN added to the bond0 network interface
>>>* ip address set on the vlan interface (bond0.1234)
>>>* tcpdump capturing full packets (-xx or even -x) on the eth0 interf=
ace
>>>
>>>Then, when pinging from another machine to this ip address, the ping
>>>reply packets shown by tcpdump incorrectly have a double VLAN tag.
>>>However, what really appears on the wire is correct: a single VLAN
>>>tag.
>>
>>Copied netdev, because bonding and vlan developers are there.
>>
>>Jiri, don't you think this might be related to the work you have done
>>to make non-hw-accel rx path similar to hw-accel?
>
> I do not think so. The changes you are reffering to are unrelated to =
tx
> path (where this issue has most probably roots in)
>
>>
>> =A0 =A0 =A0 Nicolas.
>>
>>>
>>>Here is the output from tcpdump:
>>># /tmp/tcpdump =A0-i eth0 -xx
>
> What hw is this?

This is on a Freescale P4080 DPA mac (fsl,p4080-fman-1g-mac).

>
>>>tcpdump: verbose output suppressed, use -v or -vv for full protocol =
decode
>>>listening on eth0, link-type EN10MB (Ethernet), capture size 65535 b=
ytes
>>>01:04:04.607880 IP 192.168.1.2> =A0192.168.1.1: ICMP echo request, i=
d 26933, seq 4
>>>16, length 64
>>> =A0 =A0 =A0 =A0 0x0000: =A00600 0000 0020 0600 0000 0020 8100 0ffe
>>> =A0 =A0 =A0 =A0 0x0010: =A00800 4500 0054 0000 4000 4001 b755 c0a8
>>> =A0 =A0 =A0 =A0 0x0020: =A00102 c0a8 0101 0800 98d7 6935 01a0 e528
>>> =A0 =A0 =A0 =A0 0x0030: =A00f2a 0000 0000 0000 0000 0000 0000 0000
>>> =A0 =A0 =A0 =A0 0x0040: =A00000 0000 0000 0000 0000 0000 0000 0000
>>> =A0 =A0 =A0 =A0 0x0050: =A00000 0000 0000 0000 0000 0000 0000 0000
>>> =A0 =A0 =A0 =A0 0x0060: =A00000 0000 0000
>>>01:04:04.607889 IP 192.168.1.1> =A0192.168.1.2: ICMP echo reply, id =
26933, seq 416
>>>, length 64
>>> =A0 =A0 =A0 =A0 0x0000: =A00600 0000 0020 0600 0000 0020 8100 0ffe
>>> =A0 =A0 =A0 =A0 0x0010: =A08100 0ffe 0800 4500 0054 cc07 0000 4001<=
--------
>>>extra VLAN header at 0x10
>>> =A0 =A0 =A0 =A0 0x0020: =A02b4e c0a8 0101 c0a8 0102 0000 a0d7 6935
>>> =A0 =A0 =A0 =A0 0x0030: =A001a0 e528 0f2a 0000 0000 0000 0000 0000
>>> =A0 =A0 =A0 =A0 0x0040: =A00000 0000 0000 0000 0000 0000 0000 0000
>>> =A0 =A0 =A0 =A0 0x0050: =A00000 0000 0000 0000 0000 0000 0000 0000
>>> =A0 =A0 =A0 =A0 0x0060: =A00000 0000 0000 0000 0000
>>>
>>>
>>>Initial debugging showed that the addition of the extra VLAN header
>>>takes place in function pcap_read_linux_mmap() of libpcap, in the
>>>following snippet:
>>>
>>>#ifdef HAVE_TPACKET2
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (handle->md.tp_version =3D=3D TP=
ACKET_V2&& =A0h.h2->tp_vlan_tci&&
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp_snaplen>=3D 2 * ETH_ALEN=
) {
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct vlan_tag *ta=
g;
>>>
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bp -=3D VLAN_TAG_LE=
N;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memmove(bp, bp + VL=
AN_TAG_LEN, 2 * ETH_ALEN);
>>>
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tag =3D (struct vla=
n_tag *)(bp + 2 * ETH_ALEN);
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tag->vlan_tpid =3D =
htons(ETH_P_8021Q);
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tag->vlan_tci =3D h=
tons(h.h2->tp_vlan_tci);
>>>
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pcaphdr.caplen +=3D=
 VLAN_TAG_LEN;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pcaphdr.len +=3D VL=
AN_TAG_LEN;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>>>#endif
>
> I haven't look into this code yet, but where's the code which does th=
e
> first header inclusion?

I would assume this is done by the VLAN layer. This is a ping reply
originating from the icmp code, passing down to the vlan layer, then
to the ethernet bonding layer, and then to the hardware. But before
this is passed to hardware, libpcap captures the packet.

I haven't debugged that part, though, so I can't give you a direct
pointer to the code that does it.

>
>
>>>
>>>Upon entry of this code, the packet in bp already contains a VLAN he=
ader.
>>>
>>>It's unclear to me where the problem lies exactly. I suspect it has
>>>something to do with the ethernet bonding layer indicating it has
>>>hardware vlan tagging support, while it does already fill in the vla=
n
>>>header, and libpcap being confused by this.
>>>
>>>As mentioned previously, the packets on the wire are correct, and th=
is
>>>is purely a capturing problem.
>>>


Best regards,
Thomas
