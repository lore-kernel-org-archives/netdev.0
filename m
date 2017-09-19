From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: cross namespace interface notification for tun devices
Date: Tue, 19 Sep 2017 23:02:14 +0200
Message-ID: <CAHmME9oSZeAoDtSLxoGiEcTcCbmPLf-nj3OJcJ1ma8fs4BWQAw@mail.gmail.com>
References: <CAHmME9pD_kees+xrjTeWXgi26UdhbMVgvoddbCyueTZkbguvAg@mail.gmail.com>
 <CAM_iQpVvDNRbtj_47_3XXa_ezyrT=a_VzDtK5SCR9a4_2Gqw9w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Netdev <netdev@vger.kernel.org>, Mathias <mathias@hall-andersen.dk>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:54135 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751074AbdISVCR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 19 Sep 2017 17:02:17 -0400
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTP id e4220e8f
        for <netdev@vger.kernel.org>;
        Tue, 19 Sep 2017 20:54:09 +0000 (UTC)
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTPSA id 91339655 (TLSv1.2:ECDHE-RSA-AES128-GCM-SHA256:128:NO)
        for <netdev@vger.kernel.org>;
        Tue, 19 Sep 2017 20:54:09 +0000 (UTC)
Received: by mail-io0-f170.google.com with SMTP id e189so2193109ioa.4
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 14:02:16 -0700 (PDT)
In-Reply-To: <CAM_iQpVvDNRbtj_47_3XXa_ezyrT=a_VzDtK5SCR9a4_2Gqw9w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 19, 2017 at 10:40 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> By "notification" I assume you mean netlink notification.

Yes, netlink notification.

> The question is why does the process in A still care about
> the device sitting in B?
>
> Also, the process should be able to receive a last notification
> on IFF_UP|IFF_RUNNING before device is finally moved to B.
> After this point, it should not have any relation to netns A
> any more, like the device were completely gone.

That's very clearly not the case with a tun device. Tun devices work
by letting a userspace process control the inputs (ndo_start_xmit) and
outputs (netif_rx) of the actual network device. This controlling
userspace process needs to know when its own interface that it
controls goes up and down. In the kernel, we can do this by just
checking dev->flags&IFF_UP, and receive notifications on ndo_open and
ndo_stop. In userspace, the controlling process looses the ability to
receive notifications like ndo_open/ndo_stop when the interface is
moved to a new namespace. After the interface is moved to a namespace,
the process will still control inputs and ouputs (ndo_start_xmit and
netif_rx), but it will no longer receive netlink notifications for the
equivalent of ndo_open and ndo_stop. This is problematic.
