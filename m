From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: net: Fix inconsistent teardown and release of private netdev state.
Date: Mon, 10 Jul 2017 04:07:02 +0200
Message-ID: <CAHmME9qjhOOGvOuXi0LEcEPE6Z5dK8MO-01dxb++RkAkpr91dw@mail.gmail.com>
References: <20170706142427.GA32086@zx2c4.com> <CAM_iQpV5hz-Nuw_s7A8w7KE-d3c-MELQjeYMjznh8Kg6DcZ+_Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Netdev <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:49921 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753128AbdGJCHI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 9 Jul 2017 22:07:08 -0400
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTP id 524b049c
        for <netdev@vger.kernel.org>;
        Mon, 10 Jul 2017 02:02:32 +0000 (UTC)
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTPSA id fc2653c6 (TLSv1.2:ECDHE-RSA-AES128-GCM-SHA256:128:NO)
        for <netdev@vger.kernel.org>;
        Mon, 10 Jul 2017 02:02:32 +0000 (UTC)
Received: by mail-wr0-f169.google.com with SMTP id r103so118688520wrb.0
        for <netdev@vger.kernel.org>; Sun, 09 Jul 2017 19:07:04 -0700 (PDT)
In-Reply-To: <CAM_iQpV5hz-Nuw_s7A8w7KE-d3c-MELQjeYMjznh8Kg6DcZ+_Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 8, 2017 at 12:39 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote=
:
> On Thu, Jul 6, 2017 at 7:24 AM, Jason A. Donenfeld <Jason@zx2c4.com> wrot=
e:
>>         list_add(&priv->list, &list_of_things);
>>
>>         ret =3D register_netdevice(); // if ret is < 0, then destruct ab=
ove is automatically called
>>
>>         // RACE WITH LIST_ADD/LIST_DEL!! It's impossible to call list_ad=
d only after
>>         // things are brought up successfully. This is problematic.
>>
>>         if (!ret)
>>                 pr_info("Yay it worked!\n");
>
> I fail to understand what you mean by RACE here.
>
> Here you should already have RTNL lock, so it can't race with any other
> newlink() calls. In fact you can't acquire RTNL lock in your destructor
> since register_netdevice() already gets it. Perhaps you mean
> netdev_run_todo() calls it without RTNL lock?
>
> I don't know why you reorder the above list_add(), you can order it
> as it was before, aka, call it after register_netdevice(), but you have t=
o
> init the priv->list now for the list_del() on error path.

The race is that there's a state in which priv->list is part of
list_of_things before the interface is actually successfully setup and
ready to go.

And no, it's not possible to order it _after_ register_netdevice,
since register_netdevice might call priv_destructor, and
priv_destructor calls list_del, so if it's not already on the list,
we'll OOPS. In otherwords, API problem.

To work around this shortcoming, I'm actually just assigning
dev->priv_device *after* a successful call to register_netdevice. This
seems to be working well and allows me to retain =C2=B1 the old behavior.
Hopefully this is an okay way to go about things?

Jason
