From: Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC/RFT] mac80211: implement fq_codel for software queuing
Date: Thu, 3 Mar 2016 09:00:16 -0800
Message-ID: <CAA93jw6yC42rA-_7RBG5hB1NE3yOypCGpJm5xDL5TcE_0pvYHg@mail.gmail.com>
References: <1456492163-11437-1-git-send-email-michal.kazior@tieto.com>
	<1456840971.3926.29.camel@sipsolutions.net>
	<CA+BoTQkritHYYWA53zb_AcGT4sc92fytQo3CGP6GQouWRift1w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
	Tim Shepard <shep-FrUbXkNCsVf2fBVCVOL8/A@public.gmane.org>
To: Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+BoTQkritHYYWA53zb_AcGT4sc92fytQo3CGP6GQouWRift1w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 1, 2016 at 11:38 PM, Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org=
> wrote:
> On 1 March 2016 at 15:02, Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> w=
rote:
>> On Fri, 2016-02-26 at 14:09 +0100, Michal Kazior wrote:
>>>
>>> +typedef u64 codel_time_t;
>>
>> Do we really need this? And if yes, does it have to be in the public
>> header file? Why a typedef anyway?
>
> Hmm.. I don't think it's strictly necessary. I just wanted to keep as
> much from the original codel implementation as possible. I'm fine wit=
h
> using just u64.

This is an artifact of the original codel keeping time in (nsec >> 10)
to fit into a 32 bit int.

In codel5 we switched to native 64 bit timekeeping as simpler, to
improve logging and reason about.

u64 is fine.

>
>>> - * @txq_ac_max_pending: maximum number of frames per AC pending in
>>> all txq
>>> - *   entries for a vif.
>>> + * @txq_cparams: codel parameters to control tx queueing dropping
>>> behavior
>>> + * @txq_limit: maximum number of frames queuesd
>>
>> typo - queued
>>
>>> @@ -2133,7 +2155,8 @@ struct ieee80211_hw {
>>>       u8 uapsd_max_sp_len;
>>>       u8 n_cipher_schemes;
>>>       const struct ieee80211_cipher_scheme *cipher_schemes;
>>> -     int txq_ac_max_pending;
>>> +     struct codel_params txq_cparams;
>>
>> Should this really be a parameter the driver determines?
>
> I would think so, or at least it should be able to influence it in
> *some* way. You can have varying degree of induced latency depending
> on fw/hw tx queue depth, air conditions and possible tx rates implyin=
g
> different/varying RTT. Cake[1] even has a few RTT presets like: lan,
> internet, satellite.

While those presets have been useful in testing codel and (more
generically in cake we can rapidly change the bandwidth from userspace
for testing), in the real world you don't move from orbit to desktop
and back as rapidly as wifi does.

> I don't really have a plan how exactly a driver could make use of it
> for benefit though. It might end up not being necessary after all if
> generic tx scheduling materializes in mac80211.

What we envisioned here is ewma smoothing the target based on the
total service time needed for all active stations, per round. (There
are other possible approaches)

Say you serve 10 stations at 1ms each in one round, a codel target of
5ms will try to push things down too far.  If in the next round, you
only serve 2 stations at 1ms each (but get back 10 responses at .5ms
each), you're still too high. If it's just one station, well, you can
get below 2ms if the driver is only sending 1ms, but maybe it's
sending 5ms...

If you have a large multicast burst, that burp will cause lost packets.

Merely getting typical wifi latencies under load down below the 20ms
range would be a good start, after that some testing, hard thought,
and evaluation are going to be needed..... for early testing I think a
20ms fixed target would be safer than the existing 5ms.

Pushing the fq part of fq_codel on a per station basis as close to the
hardware as possible, and having better airtime fairness between
stations is a huge win in itself.





>
> [1]: http://www.bufferbloat.net/projects/codel/wiki/Cake
>
>
>>> +static void ieee80211_if_setup_no_queue(struct net_device *dev)
>>> +{
>>> +     ieee80211_if_setup(dev);
>>> +     dev->priv_flags |=3D IFF_NO_QUEUE;
>>> +     /* Note for backporters: use dev->tx_queue_len =3D 0 instead
>>> of IFF_ */
>>
>> Heh. Remove that comment; we have an spatch in backports already :)
>
> I've put it in the RFC specifically in case anyone wants to port this
> bypassing backports, e.g. to openwrt's quilt (so when compilation
> fails, you can quickly fix it up). I'll remove it before proper
> submission obviously :)
>
>
>>> --- a/net/mac80211/sta_info.h
>>> +++ b/net/mac80211/sta_info.h
>>> @@ -19,6 +19,7 @@
>>>  #include <linux/etherdevice.h>
>>>  #include <linux/rhashtable.h>
>>>  #include "key.h"
>>> +#include "codel_i.h"
>>>
>>>  /**
>>>   * enum ieee80211_sta_info_flags - Stations flags
>>> @@ -327,6 +328,32 @@ struct mesh_sta {
>>>
>>>  DECLARE_EWMA(signal, 1024, 8)
>>>
>>> +struct txq_info;
>>> +
>>> +/**
>>> + * struct txq_flow - per traffic flow queue
>>> + *
>>> + * This structure is used to distinguish and queue different traff=
ic
>>> flows
>>> + * separately for fair queueing/AQM purposes.
>>> + *
>>> + * @txqi: txq_info structure it is associated at given time
>>> + * @flowchain: can be linked to other flows for RR purposes
>>> + * @backlogchain: can be linked to other flows for backlog sorting
>>> purposes
>>> + * @queue: sk_buff queue
>>> + * @cvars: codel state vars
>>> + * @backlog: number of bytes pending in the queue
>>> + * @deficit: used for fair queueing balancing
>>> + */
>>> +struct txq_flow {
>>> +     struct txq_info *txqi;
>>> +     struct list_head flowchain;
>>> +     struct list_head backlogchain;
>>> +     struct sk_buff_head queue;
>>> +     struct codel_vars cvars;
>>> +     u32 backlog;
>>> +     u32 deficit;
>>> +};
>>> +
>>>  /**
>>>   * struct sta_info - STA information
>>>   *
>>> diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
>>> index af584f7cdd63..f42f898cb8b5 100644
>>> --- a/net/mac80211/tx.c
>>> +++ b/net/mac80211/tx.c
>>> @@ -34,6 +34,7 @@
>>>  #include "wpa.h"
>>>  #include "wme.h"
>>>  #include "rate.h"
>>> +#include "codel.h"
>>
>>> +static inline codel_time_t
>>> +custom_codel_get_enqueue_time(struct sk_buff *skb)
>>
>> There are a lot of inlines here - first of all, do they all need to =
be
>> inline?
>
> I just followed the style of code found in codel implementation. I
> figured there's a reason why is uses `inline` although I didn't do an=
y
> measurements myself.
>
>
>> And secondly, perhaps it would make some sense to move this into
>> another file?
>
> I did consider it briefly but decided it'll be beneficial for the
> compiler to have tx hotpath in a single file.
>
>
> Micha=C5=82
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
