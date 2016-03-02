From: Michal Kazior <michal.kazior@tieto.com>
Subject: Re: [RFC/RFT] mac80211: implement fq_codel for software queuing
Date: Wed, 2 Mar 2016 08:38:27 +0100
Message-ID: <CA+BoTQkritHYYWA53zb_AcGT4sc92fytQo3CGP6GQouWRift1w@mail.gmail.com>
References: <1456492163-11437-1-git-send-email-michal.kazior@tieto.com>
	<1456840971.3926.29.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Dave Taht <dave.taht@gmail.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Felix Fietkau <nbd@openwrt.org>,
	Tim Shepard <shep@alum.mit.edu>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:37632 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751167AbcCBHi3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 02:38:29 -0500
Received: by mail-wm0-f43.google.com with SMTP id p65so65274152wmp.0
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 23:38:28 -0800 (PST)
In-Reply-To: <1456840971.3926.29.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1 March 2016 at 15:02, Johannes Berg <johannes@sipsolutions.net> wro=
te:
> On Fri, 2016-02-26 at 14:09 +0100, Michal Kazior wrote:
>>
>> +typedef u64 codel_time_t;
>
> Do we really need this? And if yes, does it have to be in the public
> header file? Why a typedef anyway?

Hmm.. I don't think it's strictly necessary. I just wanted to keep as
much from the original codel implementation as possible. I'm fine with
using just u64.


>> - * @txq_ac_max_pending: maximum number of frames per AC pending in
>> all txq
>> - *   entries for a vif.
>> + * @txq_cparams: codel parameters to control tx queueing dropping
>> behavior
>> + * @txq_limit: maximum number of frames queuesd
>
> typo - queued
>
>> @@ -2133,7 +2155,8 @@ struct ieee80211_hw {
>>       u8 uapsd_max_sp_len;
>>       u8 n_cipher_schemes;
>>       const struct ieee80211_cipher_scheme *cipher_schemes;
>> -     int txq_ac_max_pending;
>> +     struct codel_params txq_cparams;
>
> Should this really be a parameter the driver determines?

I would think so, or at least it should be able to influence it in
*some* way. You can have varying degree of induced latency depending
on fw/hw tx queue depth, air conditions and possible tx rates implying
different/varying RTT. Cake[1] even has a few RTT presets like: lan,
internet, satellite.

I don't really have a plan how exactly a driver could make use of it
for benefit though. It might end up not being necessary after all if
generic tx scheduling materializes in mac80211.


[1]: http://www.bufferbloat.net/projects/codel/wiki/Cake


>> +static void ieee80211_if_setup_no_queue(struct net_device *dev)
>> +{
>> +     ieee80211_if_setup(dev);
>> +     dev->priv_flags |=3D IFF_NO_QUEUE;
>> +     /* Note for backporters: use dev->tx_queue_len =3D 0 instead
>> of IFF_ */
>
> Heh. Remove that comment; we have an spatch in backports already :)

I've put it in the RFC specifically in case anyone wants to port this
bypassing backports, e.g. to openwrt's quilt (so when compilation
fails, you can quickly fix it up). I'll remove it before proper
submission obviously :)


>> --- a/net/mac80211/sta_info.h
>> +++ b/net/mac80211/sta_info.h
>> @@ -19,6 +19,7 @@
>>  #include <linux/etherdevice.h>
>>  #include <linux/rhashtable.h>
>>  #include "key.h"
>> +#include "codel_i.h"
>>
>>  /**
>>   * enum ieee80211_sta_info_flags - Stations flags
>> @@ -327,6 +328,32 @@ struct mesh_sta {
>>
>>  DECLARE_EWMA(signal, 1024, 8)
>>
>> +struct txq_info;
>> +
>> +/**
>> + * struct txq_flow - per traffic flow queue
>> + *
>> + * This structure is used to distinguish and queue different traffi=
c
>> flows
>> + * separately for fair queueing/AQM purposes.
>> + *
>> + * @txqi: txq_info structure it is associated at given time
>> + * @flowchain: can be linked to other flows for RR purposes
>> + * @backlogchain: can be linked to other flows for backlog sorting
>> purposes
>> + * @queue: sk_buff queue
>> + * @cvars: codel state vars
>> + * @backlog: number of bytes pending in the queue
>> + * @deficit: used for fair queueing balancing
>> + */
>> +struct txq_flow {
>> +     struct txq_info *txqi;
>> +     struct list_head flowchain;
>> +     struct list_head backlogchain;
>> +     struct sk_buff_head queue;
>> +     struct codel_vars cvars;
>> +     u32 backlog;
>> +     u32 deficit;
>> +};
>> +
>>  /**
>>   * struct sta_info - STA information
>>   *
>> diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
>> index af584f7cdd63..f42f898cb8b5 100644
>> --- a/net/mac80211/tx.c
>> +++ b/net/mac80211/tx.c
>> @@ -34,6 +34,7 @@
>>  #include "wpa.h"
>>  #include "wme.h"
>>  #include "rate.h"
>> +#include "codel.h"
>
>> +static inline codel_time_t
>> +custom_codel_get_enqueue_time(struct sk_buff *skb)
>
> There are a lot of inlines here - first of all, do they all need to b=
e
> inline?

I just followed the style of code found in codel implementation. I
figured there's a reason why is uses `inline` although I didn't do any
measurements myself.


> And secondly, perhaps it would make some sense to move this into
> another file?

I did consider it briefly but decided it'll be beneficial for the
compiler to have tx hotpath in a single file.


Micha=C5=82
