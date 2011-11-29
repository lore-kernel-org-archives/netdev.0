From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [Bonding-devel] ethernet bonding + VLAN: additional VLAN tag
 in	tcpdump
Date: Tue, 29 Nov 2011 21:35:00 +0100
Message-ID: <4ED541F4.4080601@gmail.com>
References: <CAAXf6LXiONe5Kb8tdQbQs3SWg8cc6SK_md7-vOV8qN4vYmL8qw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas De Schampheleire <patrickdepinguin@gmail.com>,
	bonding-devel@lists.sourceforge.net,
	tcpdump-workers@lists.tcpdump.org,
	Ronny Meeus <ronny.meeus@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:47741 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755488Ab1K2Ue7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 15:34:59 -0500
Received: by bkas6 with SMTP id s6so994325bka.19
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2011 12:34:58 -0800 (PST)
In-Reply-To: <CAAXf6LXiONe5Kb8tdQbQs3SWg8cc6SK_md7-vOV8qN4vYmL8qw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 29/11/2011 14:38, Thomas De Schampheleire a =E9crit :
> Hi,
>
> I'm seeing incorrect tcpdump output in the following scenario:
>
> * ethernet bonding enabled in the kernel, and a single network
> interface (eth0) added as slave
> * bonding mode was set to broadcast, but I don't think this matters
> * VLAN added to the bond0 network interface
> * ip address set on the vlan interface (bond0.1234)
> * tcpdump capturing full packets (-xx or even -x) on the eth0 interfa=
ce
>
> Then, when pinging from another machine to this ip address, the ping
> reply packets shown by tcpdump incorrectly have a double VLAN tag.
> However, what really appears on the wire is correct: a single VLAN
> tag.

Copied netdev, because bonding and vlan developers are there.

Jiri, don't you think this might be related to the work you have done t=
o make non-hw-accel rx path=20
similar to hw-accel?

	Nicolas.

>
> Here is the output from tcpdump:
> # /tmp/tcpdump  -i eth0 -xx
> tcpdump: verbose output suppressed, use -v or -vv for full protocol d=
ecode
> listening on eth0, link-type EN10MB (Ethernet), capture size 65535 by=
tes
> 01:04:04.607880 IP 192.168.1.2>  192.168.1.1: ICMP echo request, id 2=
6933, seq 4
> 16, length 64
>          0x0000:  0600 0000 0020 0600 0000 0020 8100 0ffe
>          0x0010:  0800 4500 0054 0000 4000 4001 b755 c0a8
>          0x0020:  0102 c0a8 0101 0800 98d7 6935 01a0 e528
>          0x0030:  0f2a 0000 0000 0000 0000 0000 0000 0000
>          0x0040:  0000 0000 0000 0000 0000 0000 0000 0000
>          0x0050:  0000 0000 0000 0000 0000 0000 0000 0000
>          0x0060:  0000 0000 0000
> 01:04:04.607889 IP 192.168.1.1>  192.168.1.2: ICMP echo reply, id 269=
33, seq 416
> , length 64
>          0x0000:  0600 0000 0020 0600 0000 0020 8100 0ffe
>          0x0010:  8100 0ffe 0800 4500 0054 cc07 0000 4001<--------
> extra VLAN header at 0x10
>          0x0020:  2b4e c0a8 0101 c0a8 0102 0000 a0d7 6935
>          0x0030:  01a0 e528 0f2a 0000 0000 0000 0000 0000
>          0x0040:  0000 0000 0000 0000 0000 0000 0000 0000
>          0x0050:  0000 0000 0000 0000 0000 0000 0000 0000
>          0x0060:  0000 0000 0000 0000 0000
>
>
> Initial debugging showed that the addition of the extra VLAN header
> takes place in function pcap_read_linux_mmap() of libpcap, in the
> following snippet:
>
> #ifdef HAVE_TPACKET2
>                  if (handle->md.tp_version =3D=3D TPACKET_V2&&  h.h2-=
>tp_vlan_tci&&
>                      tp_snaplen>=3D 2 * ETH_ALEN) {
>                          struct vlan_tag *tag;
>
>                          bp -=3D VLAN_TAG_LEN;
>                          memmove(bp, bp + VLAN_TAG_LEN, 2 * ETH_ALEN)=
;
>
>                          tag =3D (struct vlan_tag *)(bp + 2 * ETH_ALE=
N);
>                          tag->vlan_tpid =3D htons(ETH_P_8021Q);
>                          tag->vlan_tci =3D htons(h.h2->tp_vlan_tci);
>
>                          pcaphdr.caplen +=3D VLAN_TAG_LEN;
>                          pcaphdr.len +=3D VLAN_TAG_LEN;
>                  }
> #endif
>
> Upon entry of this code, the packet in bp already contains a VLAN hea=
der.
>
> It's unclear to me where the problem lies exactly. I suspect it has
> something to do with the ethernet bonding layer indicating it has
> hardware vlan tagging support, while it does already fill in the vlan
> header, and libpcap being confused by this.
>
> As mentioned previously, the packets on the wire are correct, and thi=
s
> is purely a capturing problem.
>
> Best regards,
> Thomas
>
> ---------------------------------------------------------------------=
---------
> All the data continuously generated in your IT infrastructure
> contains a definitive record of customers, application performance,
> security threats, fraudulent activity, and more. Splunk takes this
> data and makes sense of it. IT sense. And common sense.
> http://p.sf.net/sfu/splunk-novd2d
> _______________________________________________
> Bonding-devel mailing list
> Bonding-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/bonding-devel
>
