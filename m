From: Ben Greear <greearb@candelatech.com>
Subject: =?UTF-8?Q?Re:_veth_regression_with_=22don=e2=80=99t_modify_ip=5fsum?=
 =?UTF-8?Q?med;_doing_so_treats_packets_with_bad_checksums_as_good.=22?=
Date: Thu, 24 Mar 2016 15:57:35 -0700
Message-ID: <56F470DF.2060002@candelatech.com>
References: <56F463D6.7080406@candelatech.com>
 <CAKUBDd91rR7QTwCO6L6ZfRe4fuHw0L5+Zi7qm0uF018dwVGCLg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cong Wang <cwang@twopensource.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	ej@evanjones.ca
To: Vijay Pandurangan <vijayp@vijayp.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:54972 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181AbcCXW5g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 18:57:36 -0400
In-Reply-To: <CAKUBDd91rR7QTwCO6L6ZfRe4fuHw0L5+Zi7qm0uF018dwVGCLg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/24/2016 03:49 PM, Vijay Pandurangan wrote:
> Hmm that's troubling. We tested various UDP configurations but I don'=
t think we tested this setup. Do you have code or more specific instruc=
tions we can use to
> replicate this bug?

The user-space app is not open source, and the routing setup is
a bit tricky as well.

I'm not certain it is specific to UDP, probably it is not.

I'm using sendmmsg to transmit frames on the packet socket, so
possibly something in that path is key.

Truth is, I can debug this with printk and see what is going
on if you have no immediate ideas what is going wrong.

Thanks,
Ben


>
> On Mar 24, 2016 6:02 PM, "Ben Greear" <greearb@candelatech.com <mailt=
o:greearb@candelatech.com>> wrote:
>
>     I have an application that creates two pairs of veth devices.
>
>     a <-> b       c <-> d
>
>     b and c have a raw packet socket opened on them and I 'bridge' fr=
ames
>     between b and c to provide network emulation (ie, configurable de=
lay).
>
>
>     I put IP 1.1.1.1/24 <http://1.1.1.1/24> on a, 1.1.1.2/24 <http://=
1.1.1.2/24> on d, and then create a UDP connection
>     (using policy based routing to ensure frames are sent on the appr=
opriate
>     interfaces).
>
>     This is user-space only app, and kernel in this case is completel=
y unmodified.
>
>     The commit below breaks this feature:  UDP frames are sniffed on =
both a and d ports
>     (in both directions), but the UDP socket does not receive frames.
>
>     Using normal ethernet ports, this network emulation feature works=
 fine, so it is
>     specific to VETH.
>
>     A similar test with just sending UDP between a single veth pair: =
 e <-> f
>     works fine.  Maybe it has something to do with raw packets?
>
>
>     The patch below is the culprit:
>
>
>     [greearb@ben-dt3 linux-2.6]$ git bisect bad
>     ce8c839b74e3017996fad4e1b7ba2e2625ede82f is the first bad commit
>     commit ce8c839b74e3017996fad4e1b7ba2e2625ede82f
>     Author: Vijay Pandurangan <vijayp@vijayp.ca <mailto:vijayp@vijayp=
=2Eca>>
>     Date:   Fri Dec 18 14:34:59 2015 -0500
>
>          veth: don=E2=80=99t modify ip_summed; doing so treats packet=
s with bad checksums as good.
>
>          Packets that arrive from real hardware devices have ip_summe=
d =3D=3D
>          CHECKSUM_UNNECESSARY if the hardware verified the checksums,=
 or
>          CHECKSUM_NONE if the packet is bad or it was unable to verif=
y it. The
>          current version of veth will replace CHECKSUM_NONE with
>          CHECKSUM_UNNECESSARY, which causes corrupt packets routed fr=
om hardware to
>          a veth device to be delivered to the application. This cause=
d applications
>          at Twitter to receive corrupt data when network hardware was=
 corrupting
>          packets.
>
>     ...
>
>     diff --git a/drivers/net/veth.c b/drivers/net/veth.c
>     index 0ef4a5a..ba21d07 100644
>     --- a/drivers/net/veth.c
>     +++ b/drivers/net/veth.c
>     @@ -117,12 +117,6 @@ static netdev_tx_t veth_xmit(struct sk_buff =
*skb, struct net_device *dev)
>                      kfree_skb(skb);
>                      goto drop;
>              }
>     -       /* don't change ip_summed =3D=3D CHECKSUM_PARTIAL, as tha=
t
>     -        * will cause bad checksum on forwarded packets
>     -        */
>     -       if (skb->ip_summed =3D=3D CHECKSUM_NONE &&
>     -           rcv->features & NETIF_F_RXCSUM)
>     -               skb->ip_summed =3D CHECKSUM_UNNECESSARY;
>
>              if (likely(dev_forward_skb(rcv, skb) =3D=3D NET_RX_SUCCE=
SS)) {
>                      struct pcpu_vstats *stats =3D this_cpu_ptr(dev->=
vstats);
>
>
>     Any suggestions for how to fix this so that I get the old working=
 behaviour and
>     the bug this patch was trying to fix is also resolved?
>
>     Thanks,
>     Ben
>
>     --
>     Ben Greear <greearb@candelatech.com <mailto:greearb@candelatech.c=
om>>
>     Candela Technologies Inc http://www.candelatech.com
>


--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
