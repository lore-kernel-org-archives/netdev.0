From: Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: Re: hung task in mac80211
Date: Wed, 06 Sep 2017 14:28:47 +0200
Message-ID: <1687127.jlFxtL242B@debian64>
References: <CAGnkfhwi9MmtLneeU23iWEGLj9cb1ODb3KzzOqTDvA6nNVsugg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
To: Matteo Croce <mcroce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAGnkfhwi9MmtLneeU23iWEGLj9cb1ODb3KzzOqTDvA6nNVsugg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wednesday, September 6, 2017 1:57:47 PM CEST Matteo Croce wrote:
> Hi,
> 
> I have an hung task on vanilla 4.13 kernel which I haven't on 4.12.
> The problem is present both on my AP and on my notebook,
> so it seems it affects AP and STA mode as well.
> The generated messages are:
> 
> INFO: task kworker/u16:6:120 blocked for more than 120 seconds.
>       Not tainted 4.13.0 #57
> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> kworker/u16:6   D    0   120      2 0x00000000
> Workqueue: phy0 ieee80211_ba_session_work [mac80211]
> Call Trace:
>  ? __schedule+0x174/0x5b0
>  ? schedule+0x31/0x80
>  ? schedule_preempt_disabled+0x9/0x10
>  ? __mutex_lock.isra.2+0x163/0x480
>  ? select_task_rq_fair+0xb9f/0xc60
>  ? __ieee80211_start_rx_ba_session+0x135/0x4d0 [mac80211]
>  ? __ieee80211_start_rx_ba_session+0x135/0x4d0 [mac80211]
>  ? try_to_wake_up+0x1f1/0x340
>  ? update_curr+0x88/0xd0
>  ? ieee80211_ba_session_work+0x148/0x230 [mac80211]
> 
> I did a bisect and the offending commit is:
> 
> commit 699cb58c8a52ff39bf659bff7971893ebe111bf2
> Author: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> Date:   Tue May 30 16:34:46 2017 +0200
> 
>     mac80211: manage RX BA session offload without SKB queue

I looked at this briefly:

ieee80211_ba_session_work acquires:
mutex_lock(&sta->ampdu_mlme.mtx) @
<http://elixir.free-electrons.com/linux/v4.13/source/net/mac80211/ht.c#L321>

But it now also calls
__ieee80211_start_rx_ba_session() @
http://elixir.free-electrons.com/linux/v4.13/source/net/mac80211/ht.c#L336

which also wants to hold mutex_lock(&sta->ampdu_mlme.mtx) in:
http://elixir.free-electrons.com/linux/v4.13/source/net/mac80211/agg-rx.c#L314

I guess this is where it deadlocks?

Regards,
Christian
