From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Subject: Re: bond link state mismatch, rtnl_trylock() vs rtnl_lock()
Date: Tue, 23 May 2017 14:30:47 -0700
Message-ID: <CAF2d9jiUh2iVG4=igP0+e6dzZkff_h8u02taQts6hC2B2qsM2g@mail.gmail.com>
References: <24c0747b-df09-66da-f3ac-a393a5902a72@tintri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-netdev <netdev@vger.kernel.org>
To: Nithin Sujir <nsujir@tintri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f51.google.com ([209.85.214.51]:37958 "EHLO
        mail-it0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1032179AbdEWVbY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 17:31:24 -0400
Received: by mail-it0-f51.google.com with SMTP id r63so28218170itc.1
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 14:31:19 -0700 (PDT)
In-Reply-To: <24c0747b-df09-66da-f3ac-a393a5902a72@tintri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 23, 2017 at 12:32 PM, Nithin Sujir <nsujir@tintri.com> wrote:
> Hi,
> We're encountering a problem in 4.4 LTS where, rarely, the bond link state
> is not updated when the slave link changes.
>
> I've traced the issue to the arp monitor unable to get the rtnl lock. The
> sequence resulting in failure is as below.
>
> bond_loadbalance_arp_mon() periodically called, if slave link is _down_, it
> checks if the slave is sending/receiving packets. If it is, it sets flags to
> be processed later down the function for bond link update. However, it sets
> the slave->link right away.
>
>                 if (slave->link != BOND_LINK_UP) {
>                         if (bond_time_in_interval(bond, trans_start, 1) &&
>                             bond_time_in_interval(bond, slave->last_rx, 1))
> {
>
>                                 slave->link  = BOND_LINK_UP;
>                                 slave_state_changed = 1;
>
>
> Later down the function, it tries to get the rtnl_lock. If it doesn't get
> it, it rearms and returns.
>
>         if (do_failover || slave_state_changed) {
>                 if (!rtnl_trylock())
>                         goto re_arm; <-- returns here
>
>                 if (slave_state_changed) {
>                         bond_slave_state_change(bond);
>
> This is the problem. The next time this function is called, the slave->link
> is already marked UP. And we will never update the bond link state to UP.
>
> Changing the rtnl_trylock() -> rtnl_lock() _does_ fix the issue.
>
> Is this the right way to fix it? If it is, I can submit this formally.
>
> What are the guidelines around using rtnl_lock() vs rtnl_trylock()? Some
> places are using rtnl_lock() and other rtnl_trylock(). Sorry, I couldn't
> find much via a google search or in Documentation/.
>
> Thanks,
> Nithin.
>
> --------------------
>
> diff --git a/drivers/net/bonding/bond_main.c
> b/drivers/net/bonding/bond_main.c
> index 5dca77e..1f60503 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -2614,8 +2614,7 @@ static void bond_loadbalance_arp_mon(struct
> work_struct *work)
>         rcu_read_unlock();
>
>         if (do_failover || slave_state_changed) {
> -               if (!rtnl_trylock())
> -                       goto re_arm;
> +               rtnl_lock();

Nitin, you can't do this. The tryRTNL code is to prevent deadlock
during work-cancellation during bond_close().

>
>                 if (slave_state_changed) {
>                         bond_slave_state_change(bond);
>
>
