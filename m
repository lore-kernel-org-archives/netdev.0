From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next-2.6] tc: report informations for multiqueue
 devices
Date: Thu, 3 Sep 2009 00:17:27 +0200
Message-ID: <20090902221727.GD3018@ami.dom.local>
References: <20090902081429.GB4878@ff.dom.local>
 <4A9E2CC7.1010103@gmail.com>
 <20090902.013002.181288977.davem@davemloft.net>
 <4A9E6551.4030209@gmail.com>
 <4A9E708D.5040806@trash.net>
 <4A9E7807.2080901@gmail.com>
 <4A9E7C07.9000109@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, cl@linux-foundation.org,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:36130 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752596AbZIBWRc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 18:17:32 -0400
Received: by fxm17 with SMTP id 17so1146376fxm.37
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2009 15:17:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A9E7C07.9000109@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 02, 2009 at 04:07:03PM +0200, Patrick McHardy wrote:
> Eric Dumazet wrote:
> > Patrick McHardy a =E9crit :
> >> Eric Dumazet wrote:
> >>> [PATCH net-next-2.6] tc: report informations for multiqueue devic=
es
> >>>
> >>> qdisc and classes are not yet displayed by "tc -s -d {qdisc|class=
} show"
> >>> for multiqueue devices.
> >>>
> >>> We use a new TCA_QINDEX attribute, to report queue index to user =
space.
> >>> iproute2 tc should be changed to eventually display this queue in=
dex as in :
> >>>
> >>> $ tc -s -d qdisc
> >>> qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 =
0 1 1 1 1 1 1 1 1
> >>>  Sent 52498 bytes 465 pkt (dropped 0, overlimits 0 requeues 0)
> >>>  rate 0bit 0pps backlog 0b 0p requeues 0
> >>> qdisc pfifo_fast 0: dev eth0 qindex 1 root bands 3 priomap  1 2 2=
 2 1 2 0 0 1 1 1 1 1 1 1 1
> >>>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> >>>  rate 0bit 0pps backlog 0b 0p requeues 0
> >> This might confuse existing userspace since the handle is not uniq=
ue
> >> anymore. libnl f.i. will treat all but the first root qdisc as an
> >> update and use it to update the state of the first one. There's al=
so
> >> no combined view for applications unaware of multiqueue.
> >>
> >> Please have a look at the mail I just wrote for some possible ways
> >> around this.
> >=20
> > Hum, how can we combine infos on qdisc/class if in the future we al=
low each queue index
> > to have its own qdisc/classes ?
> >=20
> > htb on queue index 0
> > cbq on queue index 1
>=20
> My suggestion was to only dump the statistics in the combined
> view and use a virtual qdisc, something like:
>=20
> qdisc multiqueue 0: dev eth0 root queues 8
>   Sent ...
>   rate ...
>=20
> and show each real qdisc as child of this qdisc:
>=20
> qdisc pfifo_fast <unique handle> dev eth0 parent 0: bands 3 ...
> qdisc pfifo_fast <unique handle> dev eth0 parent 0: bands 3 ...
>=20
> Configuration would be symetrical to this:
>=20
> tc qdisc add dev eth0 handle 0: root multiqueue
> tc qdisc add dev eth0 handle x: parent 0: pfifo_fast
> ...

Actually, I wonder why it can't be a real "virtual" qdisc with
classes, similar to... multiq, doing such mappings inside, according
to the current api:

tc qdisc add dev eth0 handle 1: root multiqueue
tc qdisc add dev eth0 handle x: parent 1:1 pfifo_fast

Jarek P.

PS: but I'd prefer (more) different name, even mq, mtq or something.
