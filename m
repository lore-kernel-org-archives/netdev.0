From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: Re: [PATCH net-next 0/5] qed/qede: Tunnel hardware GRO support
Date: Wed, 22 Jun 2016 17:16:17 +0000
Message-ID: <CO2PR11MB008891D4ECFF86F32B1C32CC972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1466583926-27762-1-git-send-email-manish.chopra@qlogic.com>,<CAKgT0Ue6_cPb88wfTtMMetJzBSJnGDNWj8YVHWC=9WdztCxOuQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Ariel Elior" <Ariel.Elior@qlogic.com>,
	Tom Herbert <tom@herbertland.com>,
	"Hannes Frederic Sowa" <hannes@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>,
	Manish Chopra <manish.chopra@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0146.outbound.protection.outlook.com ([157.56.110.146]:48460
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751357AbcFVRQU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 13:16:20 -0400
In-Reply-To: <CAKgT0Ue6_cPb88wfTtMMetJzBSJnGDNWj8YVHWC=9WdztCxOuQ@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> This series adds driver support for the processing of tunnel
>> [specifically vxlan/geneve/gre tunnels] packets which are
>> aggregated [GROed] by the hardware before driver passes
>> such packets upto the stack.

> First off I am pretty sure this isn't GRO.=A0 This is LRO.=A0
Nopes. This is GRO - each MSS-sized frame will arrive on its
own frag, whereas the headers [both  internal & external]
would arrive on the linear part of the SKB.

> Also I don't know if you have been paying attention to recent
> discussions on the mailing list but the fact is GRO over UDP tunnels
> is still a subject for debate.=A0 This patch takes things in the
> opposite direction of where we are currently talking about going with
> GRO.=A0 I've added Hannes and Tom to this discussion just to make sur=
e I
> have the proper understanding of all this as my protocol knowledge is
> somewhat lacking.
I guess we're on the exact opposite side of the discussion - I.e., we'r=
e
the vendor that tries pushing offload capabilities to the device.
Do notice however that we're not planning on pushing anything new
feature-wise, just like we haven't done anything for regular TCP GRO -
All we do is allow our HW/FW to aggregate packets instead of stack.

> Ideally we need to be able to identify that a given packet terminates
> on a local socket in our namespace before we could begin to perform
> any sort of mangling on the local packets.=A0 It is always possible t=
hat
> we could be looking at a frame that uses the same UDP port but is not
> the tunnel protocol if we are performing bridging or routing.=A0 The
> current GRO implementation fails in that regard and there are
> discussions between several of us on how to deal with that.=A0 It is
> likely that we would be forcing GRO for tunnels to move a bit further
> up the stack if bridging or routing so that we could verify that the
> frame is not being routed back out before we could aggregate it.
I'm aware of the on-going discussion, but I'm not sure this should
bother us greatly - the aggregation is done based on the
inner TCP connection; I.e., it's guaranteed all the frames belong to
the same TCP connection. While HW requires the UDP port for the
initial classification effort, it doesn't take decision solely on that.

> Also I would be interested in knowing how your hardware handles
> tunnels with outer checksums.=A0 Is it just ignoring the frames in su=
ch
> a case, ignoring the checksum, or is it actually validating the frame=
s
> and then merging the resulting checksum?
HW is validating both inner and outer csum; if it wouldn't be able to
due to some limitation, it would not try to pass the packet as a GRO
aggregation but rather as regular seperated packets.
But I don't believe it merges the checksum, only validate each
independently [CSUM_UNNECESSARY].
