From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net: Fix inconsistent teardown and release of private netdev state.
Date: Fri, 7 Jul 2017 15:39:09 -0700
Message-ID: <CAM_iQpV5hz-Nuw_s7A8w7KE-d3c-MELQjeYMjznh8Kg6DcZ+_Q@mail.gmail.com>
References: <20170706142427.GA32086@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Netdev <netdev@vger.kernel.org>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:33291 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750726AbdGGWjb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2017 18:39:31 -0400
Received: by mail-wr0-f196.google.com with SMTP id x23so10657325wrb.0
        for <netdev@vger.kernel.org>; Fri, 07 Jul 2017 15:39:30 -0700 (PDT)
In-Reply-To: <20170706142427.GA32086@zx2c4.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 6, 2017 at 7:24 AM, Jason A. Donenfeld <Jason@zx2c4.com> wrote:
>         list_add(&priv->list, &list_of_things);
>
>         ret = register_netdevice(); // if ret is < 0, then destruct above is automatically called
>
>         // RACE WITH LIST_ADD/LIST_DEL!! It's impossible to call list_add only after
>         // things are brought up successfully. This is problematic.
>
>         if (!ret)
>                 pr_info("Yay it worked!\n");

I fail to understand what you mean by RACE here.

Here you should already have RTNL lock, so it can't race with any other
newlink() calls. In fact you can't acquire RTNL lock in your destructor
since register_netdevice() already gets it. Perhaps you mean
netdev_run_todo() calls it without RTNL lock?

I don't know why you reorder the above list_add(), you can order it
as it was before, aka, call it after register_netdevice(), but you have to
init the priv->list now for the list_del() on error path.
