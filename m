From: Veaceslav Falico <darkmag@gmail.com>
Subject: Re: [PATCH] netconsole: release the spinlock before __netpoll_cleanup()
Date: Mon, 11 Mar 2013 11:08:02 +0100
Message-ID: <CAE3RKN=ix96skUHw3j5snbue-r8SOnSovw4_zh4RX4t-uDW2Cw@mail.gmail.com>
References: <1362581203-8994-1-git-send-email-vfalico@redhat.com>
 <20130307000824.GA5702@neilslaptop.think-freely.org> <20130307100325.GA31105@redhat.com>
 <20130307.161438.396456319050281566.davem@davemloft.net> <20130310152546.GA4897@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, nhorman@tuxdriver.com,
	netdev@vger.kernel.org, amwang@redhat.com
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:50256 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752812Ab3CKKIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 06:08:23 -0400
Received: by mail-pb0-f47.google.com with SMTP id rp2so3560789pbb.20
        for <netdev@vger.kernel.org>; Mon, 11 Mar 2013 03:08:23 -0700 (PDT)
In-Reply-To: <20130310152546.GA4897@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 10, 2013 at 4:25 PM, Veaceslav Falico <vfalico@redhat.com> wrote:
> On Thu, Mar 07, 2013 at 04:14:38PM -0500, David Miller wrote:
>>
...snip...
>> Quite a bit of email corruption of this patch.
>
>
> Sorry, somehow messed it.
>
>
>>
>> Also, this code block is probably too deeply indented to be sane,
>> consider creating a small helper function to call instead.
>
>
> It gets quite ugly if I try to move it to another function. However, maybe
> something like that will work - it's effectively the same code, just that
> I've moved the long part out of the if () { } block. Looks a lot more
> readable, though one line still breaks 80chars limit. I've reworked the
> subject/commit message too.
>
> Subject: [PATCH] netconsole: don't call __netpoll_cleanup() while atomic
>
> __netpoll_cleanup() is called in netconsole_netdev_event() while holding a
> spinlock. Release/acquire the spinlock before/after it and restart the
>
> loop.
>
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
> ---
>    drivers/net/netconsole.c |   22 +++++++++++++++-------
>    1 files changed, 15 insertions(+), 7 deletions(-)
>
> diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
> index 37add21..38eaa8c 100644
>
> --- a/drivers/net/netconsole.c
> +++ b/drivers/net/netconsole.c
> @@ -666,6 +666,7 @@ static int netconsole_netdev_event(struct notifier_block
> *this,
>                 goto done;
>         spin_lock_irqsave(&target_list_lock, flags);
> +restart:
>         list_for_each_entry(nt, &target_list, list) {
>                 netconsole_target_get(nt);
>                 if (nt->np.dev == dev) {
> @@ -679,14 +680,21 @@ static int netconsole_netdev_event(struct
> notifier_block *this,
>                                 /*
>
>                                  * rtnl_lock already held
>                                  */
> -                               if (nt->np.dev) {
> -                                       __netpoll_cleanup(&nt->np);
> -                                       dev_put(nt->np.dev);
> -                                       nt->np.dev = NULL;
> +                               if (!nt->np.dev) {
> +                                       nt->enabled = 0;
> +                                       stopped = true;
> +                                       break;
>                                 }
> -                               nt->enabled = 0;
> -                               stopped = true;
> -                               break;
> +                               /*
> +                                * we might sleep in __netpoll_cleanup()
> +                                */
> +                               spin_unlock_irqrestore(&target_list_lock,
> flags);
> +                               __netpoll_cleanup(&nt->np);
> +                               spin_lock_irqsave(&target_list_lock, flags);
> +                               dev_put(nt->np.dev);
> +                               nt->np.dev = NULL;
>
> +                               netconsole_target_put(nt);
> +                               goto restart;
>                         }
>                 }
>                 netconsole_target_put(nt);
> --
> 1.7.1

Self-NAK this patch, I've triggered another kernel panic with it. Will
send another one shortly. Basicly, the whole if (!nt->np.dev) is not
needed and nt->enabled=0 should always be set, otherwise we
end up with nt->np.dev == NULL and nt->enabled == 1, thus
triggering panics in places like write_msg(), where it verifies only
if the nt->enabled is true.

-- 
Best regards,
Veaceslav Falico
