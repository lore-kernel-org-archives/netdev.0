From: <Tero.Kristo@nokia.com>
Subject: RE: Network stack timer hacks for power saving
Date: Tue, 19 May 2009 11:46:58 +0200
Message-ID: <1F18D6510CF0474A8C9500565A7E41A20544D9255A@NOK-EUMSG-02.mgdnok.nokia.com>
References: <1F18D6510CF0474A8C9500565A7E41A20544D923FF@NOK-EUMSG-02.mgdnok.nokia.com>
 <4A127608.5020109@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:28881 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752212AbZESJrj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 05:47:39 -0400
In-Reply-To: <4A127608.5020109@cosmosbay.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=20

>-----Original Message-----
>From: ext Eric Dumazet [mailto:dada1@cosmosbay.com]=20
>Sent: 19 May, 2009 12:04
>To: Kristo Tero (Nokia-D/Tampere)
>Cc: netdev@vger.kernel.org
>Subject: Re: Network stack timer hacks for power saving
>
>Tero.Kristo@nokia.com a =E9crit :
>> Hi,
>>=20
>> I have been looking at network stack timer optimization for power=20
>> saving in embedded ARM environment, basically trying to=20
>avoid as many=20
>> wakeups as possible. I have changed several timers in the network=20
>> stack into deferred ones, i.e. they do not wake up the=20
>device from low=20
>> power modes but instead they are deferred until next wakeup=20
>from some=20
>> other source, like another (non-deferred) timer or some I/O.=20
>Attached=20
>> a patch about the changes I've done, is something like this safe to=20
>> do?
>>=20
>> -Tero
>
>Hi Tero
>

Hi Eric,

Thanks for comments. Also, I think I need to make one clarification her=
e, I am not proposing these changes to be made into linux network stack=
, at least not as such because I am aware that these might cause some p=
roblems on some systems. If something like this would be merged, I thin=
k this should be added behind a kernel config option.

>
>When tcp communications are active, we setup a timer for=20
>*every* frame we receive or we send. These timers wont be=20
>deferrable anyway.
>
>delaying one wakeup every 60 seconds (if I take your=20
>net/ipv4/route.c change) wont change that much power savings,=20
>or did I missed something ?

No, this won't change it that much, but it still affects a bit. Also, i=
f everybody thinks that a 1 minute timer does not matter too much, we s=
oon have 60 timers expiring once a minute and can basically cause a wak=
eup from low power modes every second in the worst case.

>
>On big routers, we need to set ip_rt_gc_interval from 60=20
>seconds to one second, in order to perform an effective=20
>garbage collection.
>
>So, if we use a deferred timer and :
>
>schedule_delayed_work(&expires_work, HZ);
>
>How many times worker will be started every minute ?

I think big routers do not enter any low power states, due to heavy net=
work traffic keeping them busy. Even if they do enter low power mode, I=
 guess network HW will basically wake them up rather quickly causing th=
e delayed work to be executed approximately around the time (or probabl=
y exactly at the time) it was scheduled. I might be wrong here, as I do=
 not really know too much about network router power management.

Here is some data I grabbed from /proc/timer_stats before doing these c=
hanges (just added the network stack stuff here and calculated expiry r=
ates.) I already changed most of the timers to deferrable in this sampl=
e, and also made a hack to show workqueues properly. Device was basical=
ly just idling during this measurement, not doing any frequent net comm=
unication.

Timer Stats Version: v0.2
Sample period: 59672.362 s
7455D,     1 swapper          neigh_table_init_no_netlink (neigh_period=
ic_timer) [neighbour.c, rate 1 per 8s]
  995,     0 workqueue        queue_delayed_work (rt_worker_func) [rout=
e.c, rate 1 per min]
 498D,     1 swapper          inet_initpeers (peer_check_expire) [inetp=
eer.c, rate 1 per 2 min]
  99D,     1 swapper          flow_cache_init (flow_cache_new_hashrnd) =
[flow.c, rate 1 per 10 min]
  99D,     1 swapper          inet_frags_init (inet_frag_secret_rebuild=
) [inet_fragment.c, rate 1 per 10 min]

-Tero