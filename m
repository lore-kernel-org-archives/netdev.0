From: Syed Muhammad Mohsin Kazmi <08beesmmkazmi@seecs.edu.pk>
Subject: Re: data is truncated in skb
Date: Sat, 3 Mar 2012 13:00:23 +0500
Message-ID: <CAAZheXnG7_ER0eO_suYFg-rr8tjFEHVFrY2jNAcL_JV4JoLfxw@mail.gmail.com>
References: <CAAZheX=A9=iuSDS+w4u_kqn4QvffdboKngopJgTegrsOUHQrHg@mail.gmail.com>
	<CAAZheXmgb=Se6YJdp=LpH0G1vco1oms2XARtXs3HTf3DKZtrRA@mail.gmail.com>
	<20120301200726.6b0d845c@nehalam.linuxnetplumber.net>
	<CAAZheX=R-MVoa1Cgs8+=zON6ZC7Van8tH-GermuCTK1PEK-9ew@mail.gmail.com>
	<20120302144357.GC31240@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:60907 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752867Ab2CCIAY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Mar 2012 03:00:24 -0500
Received: by vcqp1 with SMTP id p1so2133655vcq.19
        for <netdev@vger.kernel.org>; Sat, 03 Mar 2012 00:00:23 -0800 (PST)
In-Reply-To: <20120302144357.GC31240@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am not doing this for my proprietary use. However, somehow it is
related to my academic work but i am doing this for open source
contribution. I have run short of time as i have less than two months
to do it. Anybody like to contribute in this implementation is welcome
to do so.

Here is now, I elaborate  what i am doing and what is the problem :
       I am trying to write down very basic version of trill as Radia
Perlman has requested us personally. I have no previous experience in
Linux Kernel network programming. So, it is my bottle-neck. I have
studied few topics related to bridging and basic data structures as
sk_buff etc.
I have written a code as a start which encapsulates and decapsulates
packets with trill header. This is done fine and These encapsulated
packets routes to their destination exactly but due to encapsulated
data of the packets are truncated from the end by the size of
encapsulation header.
The topology upon which i am testing it is:

         virtual_host_1_eth0 ------ openvpn_tap0_bridge1_eth0
------------------- eth1_bridge2_openvpn_tap0 ------
eth0_virtual_host_2

where bridge1 and bridge2 are physical machines while host1 and host2
are virtual hosts on these physical machines.
I have run the wireshark on all of these machines (physical and virtual=
).

If i ping from one virtual host to other, the ICMP packets generated
by virtual host are encapsulated by its local bridge with trill header
and send them to other bridge where these packets are decapsulated.
Then these packets are send to its local virtual host where i have
seen them on wireshark.
I don't get the reply message from that host as original data is
truncated so may be these packets are discarded at its destination.

Secondly, i have got that message "protocol 0x22f3 is buggy at dev
tap0" on destination's local bridge.

I think so, first problem is, originally the packet is received by the
local bridge, device that receive it fill some field with number of
receive bytes may be in struct sock *sk (int recvbuf). So when the
device send these packets, it truncates the data that is exceeding
from this receiving byte field. I have checked skb_copy_expand()
funcation and skb_rellocate_headroom(). But not succeeded yet.
Any idea or suggestion that is closely related to the problem.

Second problem is, when the device receives the packet, it fills
skb->protocol field with 0x22f3 as a packet protocol in dev.c. When i
send the decapsulated packets then that field is remain same as
skb->protocol =3D 0x22f3. So, tap0 checks the protocol field with the
one used in packet that is now changed to 0x0800 for IP, so it
generates that message "protocol 0x22f3 is buggy at dev tap0". When i
changed that field skb->protocol to 0x0800 in decapsulating function.
Then these packets are not even received by virtual host.
So, any solution to this problem.

Regards,
Syed M. Mohsin Kazmi





On Fri, Mar 2, 2012 at 7:43 PM, Francois Romieu <romieu@fr.zoreil.com> =
wrote:
>
> Syed Muhammad Mohsin Kazmi <08beesmmkazmi@seecs.edu.pk> :
> [...]
> > =A0 =A0 =A0 if(skb->data =3D=3D push3)
> > =A0 =A0 =A0 {
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_set_mac_header(skb,0);
> >
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_pull(skb,ETH_HLEN);
>
> May be this skb_pull as a start. Hard to tell without context (and I =
am not
> a free as in beer consultant for proprietary or academic homework).
>
> [...]
> > =A0 =A0 =A0 printk("\t\t\tencapsulated Buffer\n");
>
> Help yourself: see Documentation/trace/kprobetrace.txt and check the
> skb_xyz calls.
>
> --
> Ueomor
