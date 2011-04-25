From: Carsten Wolff <carsten@wolffcarsten.de>
Subject: Re: Linux TCP's Robustness to Multipath Packet Reordering
Date: Mon, 25 Apr 2011 14:59:12 +0200
Message-ID: <201104251459.13254.carsten@wolffcarsten.de>
References: <BANLkTimpgXCpweZKCihCQkLjSZw5zL4=Pg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Dominik Kaspar <dokaspar.ietf@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h1346787.stratoserver.net ([85.214.49.182]:46454 "EHLO
	h1346787.stratoserver.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751992Ab1DYNIT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2011 09:08:19 -0400
In-Reply-To: <BANLkTimpgXCpweZKCihCQkLjSZw5zL4=Pg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dominik,

On Monday 25 April 2011, Dominik Kaspar wrote:
> Hello,
>=20
> Knowing how critical packet reordering is for standard TCP, I am
> currently testing how robust Linux TCP is when packets are forwarded
> over multiple paths (with different bandwidth and RTT). Since Linux
> TCP adapts its "dupAck threshold" to an estimated level of packet
> reordering, I expect it to be much more robust than a standard TCP
> that strictly follows the RFCs. Indeed, as you can see in the
> following plot, my experiments show a step-wise adaptation of Linux
> TCP to heavy reordering. After many minutes, Linux TCP finally reache=
s
> a data throughput close to the perfect aggregated data rate of two
> paths (emulated with characteristics similar to IEEE 802.11b (WLAN)
> and a 3G link (HSPA)):
>=20
> http://home.simula.no/~kaspar/static/mptcp-emu-wlan-hspa-00.png
>=20
> Does anyone have clues what's going on here? Why does the aggregated
> throughput increase in steps? And what could be the reason it takes
> minutes to adapt to the full capacity, when in other cases, Linux TCP
> adapts much faster (for example if the bandwidth of both paths are
> equal). I would highly appreciate some advice from the netdev
> community.

the throughput increase in steps is most likely caused by Linux's reord=
ering=20
detection and quantization. The DupThresh (tp->reordering) is only incr=
eased=20
when reordering is detected and is then set to a value that depends on =
current=20
inflight/pipe. This means, on a path with only reordering and no loss, =
where a=20
very large DupThresh is best, you will see those steps in the throughpu=
t=20
everytime when Linux detects reordering during a time where cwnd is lar=
ge.=20
This on the other hand depends purely on timing/luck.
Linux is also only able to quantize reordering during disorder state, w=
hich=20
leaves out many possible quantization samples, escpecially the larger o=
nes,=20
which would increase DupThresh to higher values.

Also, reordering detection depends very much on TCP options. Which TCP =
Options=20
were enabled in your test? Timestamps? D-SACK?

Carsten

>=20
> Implementation details:
> This multipath TCP experiment ran between a sending machine with a
> single Ethernet interface (eth0) and a client with two Ethernet
> interfaces (eth1, eth2). The machines are connected through a switch
> and tc/netem is used to emulate the bandwidth and RTT of both paths.
> TCP connections are established using iperf between eth0 and eth1 (th=
e
> primary path). At the sender, an iptables' NFQUEUE is used to "spoof"
> the destination IP address of outgoing packets and force some to
> travel to eth2 instead of eth1 (the secondary path). This multipath
> scheduling happens in proportion to the emulated bandwidths, so if th=
e
> paths are set to 500 and 1000 KB/s, then packets are distributed in a
> 1:2 ratio. At the client, iptables' RAWDNAT is used to translate the
> spoofed IP addresses back to their original, so that all packets end
> up at eth1, although a portion actually travelled to eth2. ACKs are
> not scheduled over multiple paths, but always travel back on the
> primary path. TCP does not notice anything of the multipath
> forwarding, except the side-effect of packet reordering, which can be
> huge if the path RTTs are set very differently.
>=20
> Best regards,
> Dominik
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--=20
           /\-=C2=B4-/\
          (  @ @  )
________o0O___^___O0o________
