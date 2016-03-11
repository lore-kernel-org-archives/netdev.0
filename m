From: Michal Kazior <michal.kazior@tieto.com>
Subject: Re: [RFC/RFT] mac80211: implement fq_codel for software queuing
Date: Fri, 11 Mar 2016 09:32:03 +0100
Message-ID: <CA+BoTQ=-qSt3MQ-sU_rav1pTi6AWL41pL1DW7H+ceNk4xEiqcQ@mail.gmail.com>
References: <1456492163-11437-1-git-send-email-michal.kazior@tieto.com>
	<CAA93jw4XsEnp3jTgPL7OKWTJP-83VwRaCdb+foc8nCuqxk3WZA@mail.gmail.com>
	<CA+BoTQk+3jhwK57_fDw0scNCGzu_Edqp9-Beeppz8xj9kSQcoQ@mail.gmail.com>
	<CAA93jw47wtioiUUD8ZTm4hFSVL7Uc8ubpSG5urHtWQhfAo1nmQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Felix Fietkau <nbd@openwrt.org>,
	Tim Shepard <shep@alum.mit.edu>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:34590 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934767AbcCKIcF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 03:32:05 -0500
Received: by mail-wm0-f45.google.com with SMTP id p65so8109429wmp.1
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2016 00:32:04 -0800 (PST)
In-Reply-To: <CAA93jw47wtioiUUD8ZTm4hFSVL7Uc8ubpSG5urHtWQhfAo1nmQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10 March 2016 at 19:57, Dave Taht <dave.taht@gmail.com> wrote:
>>> regular fq_codel uses 1024 and there has not been much reason to
>>> change it. In the case of an AP which has more limited memory, 256 =
or
>>> 1024 would be a good setting, per station. I'd stick to 1024 for no=
w.
>>
>> Do note that the 4096 is shared _across_ station-tid queues. It is n=
ot
>> per-station. If you have 10 stations you still have 4096 flows
>> (actually 4096 + 16*10, because each tid - and there are 16 - has it=
's
>> own fallback flow in case of hash collision on the global flowmap to
>> maintain per-sta-tid queuing).
>
> I have to admit I didn't parse this well - still haven't, I think I
> need to draw. (got a picture?)

No picture, sorry. Let me rehash instead:

 - there's a pool of 4096 tubes (flows),
 - tubes in the pool are empty,
 - each tube has an id sticker (0,1,2,3,...),
 - each wi-fi station has 16 boxes (tids) for tubes as well,
 - each station box has 1 extra immovable tube (flow),
 - packets are hashed into tube id stickers,
 - matching tube can be:
   - in the pool;
     - move the tube into station-box the packet is associated with
     - put the packet into tube
   - in the station-box the packet is associated with
     - just put the packet into tube
   - in a station-box different from the one the packet is associated w=
ith
     - (this is the collision case for fallback flow)
     - put the packet into the immovable tube of station box the
packet is associated with
 - whenever a tube becomes empty it is moved back to the pool


> Where is this part happening in the code (or firmware?)

It's in the ieee80211_txq_enqueue(). My patch originally contains a
mistake (pointed out by Felix) and the function should actually look
like this:

> static void ieee80211_txq_enqueue(struct ieee80211_local *local,
>                                   struct txq_info *txqi,
>                                   struct sk_buff *skb)
> {
>         struct ieee80211_fq *fq =3D &local->fq;
>         struct ieee80211_hw *hw =3D &local->hw;
>         struct txq_flow *flow;
>         struct txq_flow *i;
>         size_t idx =3D fq_hash(fq, skb);
>
>         flow =3D &fq->flows[idx];
>
>         if (flow->txqi && flow->txqi !=3D txqi)
>                 flow =3D &txqi->flow;
[...]


> I assembled a few of the patches to date (your fq_codel patch, avery'=
s
> and tims ath9k stuff) and tested them, to no measurable effect,
> against linus's tree a day or two back. I also acquired an ath10k car=
d
> - would one of these suit?
>
> http://www.amazon.com/gp/product/B011SIMFR8?psc=3D1&redirect=3Dtrue&r=
ef_=3Doh_aui_detailpage_o08_s00

I haven't used this particular card. It's an older chip (no MU-MIMO)
but otherwise should work fine.


Micha=C5=82
