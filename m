From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH/RFC net-next] rocker: forward packets to CPU when a port
 in promiscuous mode
Date: Wed, 08 Jul 2015 22:38:51 -0700
Message-ID: <559E08EB.1000402@gmail.com>
References: <1436415931-16469-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Simon Horman <simon.horman@netronome.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:35277 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721AbbGIFim (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 01:38:42 -0400
Received: by obbop1 with SMTP id op1so165231463obb.2
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 22:38:41 -0700 (PDT)
In-Reply-To: <1436415931-16469-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-07-08 09:25 PM, Simon Horman wrote:
> This change allows the CPU to see all packets seen by a port when the
> netdev associated with the port is in promiscuous mode.
>=20
> This change was previously posted as part of a larger patch and in tu=
rn
> patchset which also aimed to allow rocker interfaces to receive packe=
ts
> when not bridged. That problem has subsequently been addressed in a
> different way by Scott Feldman.
>=20
> When this change was previously posted Scott indicated that he had so=
me
> reservations about sending all packets from a switch to the CPU. The
> purpose of posting this patch is to start discussion of weather this
> approach is appropriate and if not how else we might move forwards.
>=20
> In my opinion if host doesn't want all packets its shouldn't put a po=
rt
> in promiscuous mode. But perhaps that is an overly na=EFve view to ta=
ke.
>=20
> My main motivation for this change at this time is to allow rocker to
> work with Open vSwitch and it appears that this change is sufficient =
to
> reach that goal. Another approach might be to teach
> rocker_port_master_changed() about Open vSwitch.
>=20

My opinion would be to not confuse a host concept 'promiscuous mode'
and allow it to impact how the forwarding is done by the hardware. I
think a better approach would be to put a default low priority rule in
one of the hardware match action tables to mirror all traffic to the
port you want to mirror traffic to. And if it happens to be a CPU port
then it will be pushed to the host.

My problem with the semantics here is it seems overload how we use
promiscuous mode in the NIC today. For example I don't see how to use
it in an SR-IOV case or multi-function device. How would you handle
this if more than one port was put in promiscuous mode? Mirror to both
ports? Today when we put a device in a promiscuous mode behind a
switch we don't expect to start receiving all traffic.

I think at very least we need to be very specific about how we define
it and when it applies if we overload promisc field. Also wouldn't
it break any 'bridge/vswitch' software that puts the port in promisc
mode by default.

> In the longer term I believe Open vSwitch should be able to program
> flows into rocker 'hardware' and thus not all packets would reach the=
 CPU.

Agree with this point.

>=20
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> ---
>  drivers/net/ethernet/rocker/rocker.c | 33 ++++++++++++++++++++++++++=
+++----
>  1 file changed, 29 insertions(+), 4 deletions(-)
>=20
