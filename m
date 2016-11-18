From: Iago Abal <iago.abal-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Potential deadlock BUG in drivers/net/wireless/st/cw1200/sta.c (Linux 4.9)
Date: Fri, 18 Nov 2016 22:58:00 +0100
Message-ID: <CAGbDTvrA85Qao_y0FxCFR_cE26WejoLLrA=PA1qhTButiDp3xg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Solomon Peachy <pizza-pCgMCH4qpMRg9hUCZPvPmw@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

With the help of a static bug finder (EBA -
https://github.com/models-team/eba) I have found a potential deadlock
in drivers/net/wireless/st/cw1200/
sta.c. This happens due to a recursive mutex_lock on `priv->conf_mutex'.

If this is indeed a bug, I will be happy to help with a patch.

A quick (not elegant) fix could be to unlock before the call to
`cw1200_do_unjoin' in line 1174, and lock again afterwards. It seems
that `cw1200_join_complete' is always called with `priv->conf_mutex'
held. Another option could be to add a Boolean parameter to
`cw1200_do_unjoin' to choose whether this function should take the
lock itself. Yet another option would be to have a
`__cw1200_do_unjoin' that does not lock, and make `cw1200_do_unjoin' a
wrapper over this that adds the locking; `cw1200_join_complete' would
call `__cw1200_do_unjoin' instead.

Someone who is actually familiar with this code may have a better
proposal though.

The trace is as follows:

1. Function `cw1200_join_complete_work' takes the first lock in line 1189:

    // see https://github.com/torvalds/linux/blob/v4.9-rc5/drivers/net/wireless/st/cw1200/sta.c#L1189
    mutex_lock(& priv->conf_mutex);

2. and subsequently calls `cw1200_join_complete';
3. which calls `cw1200_do_unjoin' in line 1174;
4. and this latter function takes the lock for the second time in line 1387:

    // see https://github.com/torvalds/linux/blob/v4.9-rc5/drivers/net/wireless/st/cw1200/sta.c#L1387
    mutex_lock(& priv->conf_mutex);

Hope it helps!

--
iago
