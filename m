From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] pktgen: Clone skb to avoid corruption of skbs in ndo_start_xmit
 methods
Date: Tue, 19 Jul 2011 21:19:10 -0700
Message-ID: <4E26573E.5060202@candelatech.com>
References: <1311105179-26408-1-git-send-email-nhorman@tuxdriver.com> <1311105738.3113.11.camel@edumazet-laptop> <20110719202922.GA2352@minipsycho> <1311108107.3113.22.camel@edumazet-laptop> <20110720001904.GA1992@neilslaptop.think-freely.org> <1311122593.3113.46.camel@edumazet-laptop> <4E2626E1.6030005@candelatech.com> <20110720020737.GB2692@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:55838 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750726Ab1GTETW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 00:19:22 -0400
In-Reply-To: <20110720020737.GB2692@neilslaptop.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/19/2011 07:07 PM, Neil Horman wrote:
> On Tue, Jul 19, 2011 at 05:52:49PM -0700, Ben Greear wrote:
>> On 07/19/2011 05:43 PM, Eric Dumazet wrote:
>>> Le mardi 19 juillet 2011 =E0 20:19 -0400, Neil Horman a =E9crit :

>> When the features-flags work gets completed so that we can start add=
ing
>> new flags, we could add a CANT_DO_MULTI_SKB flag to drivers with kno=
wn
>> issues and then restrict pktgen config accordingly.
>>
> I think this is a good idea.  It lets pktgen dynamically make the clo=
ne/share
> decision dynamically and only impacts performance for those systems.
>
>> Upstream code already clears skb memory to avoid leaking kernel memo=
ry
>> contents, so if you take away multi-skb too, pktgen is going to suck
>> at what it is supposed to do:  run fast as possible.
>>
> I don't want to take away multi-skb, but I do want pktgen to work rel=
iably.  I
> think flagging drivers that need unshared skbs is the way to go.

Lets all cheer on the Intel NIC driver guys and Mr. Miraslaw then!

>> If you want real fun, use pktgen on a wlan0 device...it will crash
>> regardless of whether you use multi-skb or not because of xmit-queue
>> number issues :P
>>
> I'll try that, thanks :)

Here's a probably-white-space damaged, and deemed-unfit-for-kernel patc=
h
that at least works around the problem...my users don't really need pkt=
gen
on wlans, so I didn't put any extra effort into it, but for someone
more motivated..this might be a good starting point :)

I guess it doesn't really crash, but if I recall correctly, it filled
up the queues in a bad way and effectively blocked all wifi traffic
until reboot, or maybe rmmod ath9k.


 From d57130f29843cab30196b11d4476231f245e3f92 Mon Sep 17 00:00:00 2001
=46rom: Ben Greear <greearb@candelatech.com>
Date: Wed, 9 Feb 2011 16:58:42 -0800
Subject: [PATCH 31/38] mac80211: Set up tx-queue-mapping in subif_start=
_xmit.

Otherwise, ath9k gets confused about which queue to use
and spews a warning like this when driving traffic with
pktgen.

WARNING: at /home/greearb/git/linux.wireless-testing-ct/drivers/net/wir=
eless/ath/ath9k/xmit.c:1748 ath_tx_start+0x4a2/0x662 [ath9k]()
Hardware name: To Be Filled By O.E.M.
Modules linked in: ath5k arc4 ath9k mac80211 ath9k_common ath9k_hw ath =
cfg80211 nfs lockd bluetooth cryptd aes_i586 aes_generic veth 8021q gar=
p stp l]
Pid: 1729, comm: kpktgend_0 Tainted: G        W   2.6.38-rc4-wl+ #21
Call Trace:
  [<c043091b>] ? warn_slowpath_common+0x65/0x7a
  [<fabe784e>] ? ath_tx_start+0x4a2/0x662 [ath9k]
  [<c043093f>] ? warn_slowpath_null+0xf/0x13
  [<fabe784e>] ? ath_tx_start+0x4a2/0x662 [ath9k]
  [<fabe14d0>] ? ath9k_tx+0x14f/0x183 [ath9k]
  [<fab9026d>] ? __ieee80211_tx+0x10c/0x18c [mac80211]
  [<fab90397>] ? ieee80211_tx+0xaa/0x188 [mac80211]
  [<fab905f3>] ? ieee80211_xmit+0x17e/0x186 [mac80211]
  [<fab8ecc0>] ? ieee80211_skb_resize+0x8e/0xd2 [mac80211]
  [<fab9148b>] ? ieee80211_subif_start_xmit+0x643/0x65c [mac80211]
  [<c0440000>] ? rescuer_thread+0x25/0x1c8
  [<f92cd354>] ? pktgen_thread_worker+0x114c/0x1b44 [pktgen]
  [<fab90e48>] ? ieee80211_subif_start_xmit+0x0/0x65c [mac80211]
  [<c042d612>] ? default_wake_function+0xb/0xd
  [<c04254c7>] ? __wake_up_common+0x34/0x5c
  [<c0443a29>] ? autoremove_wake_function+0x0/0x2f
  [<f92cc208>] ? pktgen_thread_worker+0x0/0x1b44 [pktgen]
  [<c044371a>] ? kthread+0x62/0x67
  [<c04436b8>] ? kthread+0x0/0x67
  [<c04035f6>] ? kernel_thread_helper+0x6/0x10

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 64e0f75... e8ff199... M	net/mac80211/tx.c
  net/mac80211/tx.c |    2 ++
  1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 64e0f75..e8ff199 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1971,6 +1971,8 @@ netdev_tx_t ieee80211_subif_start_xmit(struct sk_=
buff *skb,
  	} else
  		memcpy(skb_push(skb, hdrlen), &hdr, hdrlen);

+	skb_set_queue_mapping(skb, ieee80211_select_queue(sdata, skb));
+
  	nh_pos +=3D hdrlen;
  	h_pos +=3D hdrlen;

--=20
1.7.3.4


>
> Regards
> Neil


--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
