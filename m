From: Dave Taht <dave.taht@gmail.com>
Subject: Re: SFQ on HFSC leaf does not seem to work
Date: Fri, 23 Dec 2011 07:32:41 +0100
Message-ID: <CAA93jw5FZ=Sz0afmnwwZ-COmSi=HfcXDJfokQgn3_nHEquTb5Q@mail.gmail.com>
References: <1324620022.10184.100.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:36474 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751672Ab1LWGcn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 01:32:43 -0500
Received: by iaeh11 with SMTP id h11so14626181iae.19
        for <netdev@vger.kernel.org>; Thu, 22 Dec 2011 22:32:43 -0800 (PST)
In-Reply-To: <1324620022.10184.100.camel@denise.theartistscloset.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 23, 2011 at 7:00 AM, John A. Sullivan III
<jsullivan@opensourcedevel.com> wrote:
> Hello, all. =A0I have an experimental HFSC setup with three leaf clas=
ses
> each with SFQ as the final qdisc. =A0One queue is for ssh on port 822=
, one
> is for tcp traffic on port 443, the third is the default.
>
> If I flood the 443 queue with netcat, my ssh sessions are responsive =
and
> my continuous ping shows a round trip time of around 50ms in keeping
> with my netem settings.
>
> However, if I flood the default queue with netcat on port 80, ssh is
> still responsive but my ping round trip times shoot up over 3000ms.
>
> I thought it might be the bufferbloat phenomenon so I reduced the
> txqueuelen on both sides of the ping to 0. =A0Both sides use old 10Ba=
seT
> NICs and have no ring buffer. =A0I also set the SFQ limit on the defa=
ult
> queue to 2 just in case. =A0Still no difference.

Your txqueuelen on the ifb devices is probably 1000.



>
> The default queue is dequeuing at roughly 400 kbits which matches my
> HFSC configuration. =A0A full sized packet should take 30 ms to pass =
at
> that rate ((1514 * 8)/400,000) so, if I am round robining the queues,=
 I
> would expect latency on a default sized ping to be only 30 ms plus th=
e
> netem delay.
>
> Where might this 3000 ms delay be coming from?
>
> Here is the rule set:
>
> tc qdisc add dev eth1 root handle 1: hfsc default 20
> tc class add dev eth1 parent 1: classid 1:1 hfsc sc rate 1490kbit ul =
rate 1490kbit
> tc class add dev eth1 parent 1:1 classid 1:20 hfsc rt rate 400kbit ls=
 rate 200kbit
> tc qdisc add dev eth1 parent 1:20 handle 1201 sfq perturb 10
> tc class add dev eth1 parent 1:1 classid 1:10 hfsc rt umax 16kbit dma=
x 50ms rate 200kbit ls rate 1000kbit
> tc qdisc add dev eth1 parent 1:10 handle 1101 sfq perturb 60
> tc class add dev eth1 parent 1:1 classid 1:30 hfsc rt umax 1514b dmax=
 20ms rate 20kbit
> tc qdisc add dev eth1 parent 1:30 handle 1301 sfq perturb 60
> iptables -t mangle -A POSTROUTING -p 6 --syn --dport 443 -j CONNMARK =
--set-mark 0x10
> iptables -t mangle -A PREROUTING -p 6 --syn --dport 822 -j CONNMARK -=
-set-mark 0x11
> iptables -t mangle -A POSTROUTING -o eth1 -p 6 -j CONNMARK --restore-=
mark
> modprobe ifb
> ifconfig ifb0 up
> ifconfig ifb1 up
> tc filter add dev eth1 parent 1:0 protocol ip prio 1 handle 0x11 fw f=
lowid 1:30 action mirred egress redirect dev ifb1
> tc filter add dev eth1 parent 1:0 protocol ip prio 1 handle 0x10 fw f=
lowid 1:10 action mirred egress redirect dev ifb1
> tc filter add dev eth1 parent 1:0 protocol ip prio 2 u32 match u32 0 =
0 flowid 1:20 action mirred egress redirect dev ifb1
> tc qdisc add dev eth1 ingress
> tc filter add dev eth1 parent ffff: protocol ip prio 50 u32 match u32=
 0 0 action mirred egress redirect dev ifb0
> tc qdisc add dev ifb0 root handle 1: hfsc default 20
> tc class add dev ifb0 parent 1: classid 1:1 hfsc sc rate 1490kbit ul =
rate 1490kbit
> tc class add dev ifb0 parent 1:1 classid 1:20 hfsc rt rate 400kbit ls=
 rate 200kbit
> tc qdisc add dev ifb0 parent 1:20 handle 1201 netem delay 25ms 5ms di=
stribution normal loss 0.1% 30%
> tc class add dev ifb0 parent 1:1 classid 1:10 hfsc rt umax 16kbit dma=
x 50ms rate 200kbit ls rate 1000kbit
> tc qdisc add dev ifb0 parent 1:10 handle 1101 netem delay 25ms 5ms di=
stribution normal loss 0.1% 30%
> tc class add dev ifb0 parent 1:1 classid 1:30 hfsc rt umax 1514b dmax=
 20ms rate 20kbit
> tc qdisc add dev ifb0 parent 1:30 handle 1301 netem delay 25ms 5ms di=
stribution normal loss 0.1% 30%
> tc filter add dev ifb0 parent 1:0 protocol ip prio 1 handle 6: u32 di=
visor 1
> tc filter add dev ifb0 parent 1:0 protocol ip prio 1 u32 match ip pro=
tocol 6 0xff link 6: offset at 0 mask 0x0f00 shift 6 plus 0 eat
> tc filter add dev ifb0 parent 1:0 protocol ip prio 1 u32 ht 6:0 match=
 tcp src 443 0x00ff flowid 1:10
> tc filter add dev ifb0 parent 1:0 protocol ip prio 1 u32 ht 6:0 match=
 tcp dst 822 0xff00 flowid 1:30
> tc qdisc add dev ifb1 root handle 2 netem delay 25ms 5ms distribution=
 normal loss 0.1% 30%
>
> Thanks - John
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html



--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
=46R Tel: 0638645374
http://www.bufferbloat.net
