From: Nick Carter <ncarter100@gmail.com>
Subject: Re: bridge vs. bonding/pause frames (was: Forward EAPOL...)
Date: Fri, 1 Jul 2011 22:10:38 +0100
Message-ID: <BANLkTinU=JPHcDCtZnBBuX6Y0q6XLLauew@mail.gmail.com>
References: <BANLkTi=goXU4SpP6dxX9C+YeLcVMEkcKHw@mail.gmail.com>
	<20110628202200.GB2121496@jupiter.n2.diac24.net>
	<BANLkTim1owW7iMS3hgKhm7DzTzE4X-jxHA@mail.gmail.com>
	<20110628210434.GD2121496@jupiter.n2.diac24.net>
	<BANLkTikN_TPPcyywVT5W9CrGAFJX8qQiyQ@mail.gmail.com>
	<20110628214637.GE2121496@jupiter.n2.diac24.net>
	<BANLkTi=4-xYNyaBOzeL04VioK8D0Q8secg@mail.gmail.com>
	<20110629163423.1d73b0ef@nehalam.ftrdhcpuser.net>
	<20110701101625.GB3988422@jupiter.n2.diac24.net>
	<BANLkTimjnP87CAA7JVAe5hqeP08Hd7766g@mail.gmail.com>
	<20110701151626.GC2613105@jupiter.n2.diac24.net>
	<BANLkTin_rCS1bJFRhAEGhE0+skFxbrE5_Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Lamparter <equinox@diac24.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, davem@davemloft.net
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:40693 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755121Ab1GAVKj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 17:10:39 -0400
Received: by pzk9 with SMTP id 9so125485pzk.19
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2011 14:10:38 -0700 (PDT)
In-Reply-To: <BANLkTin_rCS1bJFRhAEGhE0+skFxbrE5_Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/7/1 Micha=B3 Miros=B3aw <mirqus@gmail.com>:
> W dniu 1 lipca 2011 17:16 u=BFytkownik David Lamparter
> <equinox@diac24.net> napisa=B3:
>> On Fri, Jul 01, 2011 at 04:58:56PM +0200, Micha=B3 Miros=B3aw wrote:
>> [...]
>>> > We _MUST_NOT_ pass bonding frames in any case, but we
>>> > currently do that if STP is off. (cf. my earlier patch 1/2)
>>>
>>> If you use linux box as a (invisible) L2 network tap, then you want=
 to
>>> pass everything in the hub mode (including LACP/whatever).
>>
>> We must not do that by default, this breaks bridges with bonding dev=
ices
>> as ports. I'm actively band-aiding that problem with ebtables on one=
 of
>> my boxes currently.
>>
>> How about I change "stp_forward_802local" to "forward_802local" and =
it
>> gets 3 values like:
>> - 0 (default) behave like a switch, if STP is on then drop all 16
>> =A0groups, if STP is off then drop :01 and :02
>> - 1 forward regular groups - drop :01 and :02, forward everything el=
se
>> - 2 forward everything ("invisible tap mode")
>> optional:
>> - -1 drop all 16 groups even if STP is off (not needed, can be done =
with
>> =A0ebtables...)
>>
>> btw, since the drivers should eat up pause frames, you're not a full=
y
>> invisible L2 tap anyway.
>
> If -1 can be done with ebtables what is different for 0 and 1 cases?
>
> Another idea: you could make this a 16-bit bitmap (bit per group) x2
> (STP vs non-STP) - that would cover all uses with the same amount of
> code.
That is exactly what I thought yesterday and I wrote and tested the
code today :)

+++ b/net/bridge/br_input.c
@@ -166,6 +166,9 @@ struct sk_buff *br_handle_frame(struct sk_buff *skb=
)
 		if (p->br->stp_enabled =3D=3D BR_NO_STP && dest[5] =3D=3D 0)
 			goto forward;

+		if (p->br->group_fwd_mask & (1 << dest[5]))
+			goto forward;

+++ b/net/bridge/br_private.h
@@ -244,6 +244,13 @@ struct net_bridge
 	struct timer_list		multicast_query_timer;
 #endif

+	/* Each bit used to match the LSB of the IEEE 802.1D group address
+	 * 01-80-C2-00-00-00 bit 0
+	 * ..
+	 * 01-80-C2-00-00-0F bit 15
+	 */
+	u16				group_fwd_mask;
+

I will post the full diffs to netdev now.  With this 'knob' users can
have any behaviour they require.
Nick

>
> Best Regards,
> Micha=B3 Miros=B3aw
>
