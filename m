From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: out-of-bounds access with virtio-net
Date: Wed, 19 Jul 2017 11:23:05 -0700
Message-ID: <CAM_iQpUUPhGRkac5eJb7PwG-EGGjf9fpcdfJO1L3QMhiMMUBtg@mail.gmail.com>
References: <b3c684fd-72eb-f67b-90f3-bc1185d8b576@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:35129 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753349AbdGSSX1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 14:23:27 -0400
Received: by mail-wm0-f42.google.com with SMTP id w126so6082574wme.0
        for <netdev@vger.kernel.org>; Wed, 19 Jul 2017 11:23:26 -0700 (PDT)
In-Reply-To: <b3c684fd-72eb-f67b-90f3-bc1185d8b576@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 19, 2017 at 9:59 AM, David Ahern <dsahern@gmail.com> wrote:
> Changing the mac address on a virtio-net based nic is triggering an
> out-of-bounds access. Nothing fancy with the command:
>
> ip li set dev eth2 addr 01:02:34:56:78:9a
>
> virtnet_set_mac_address is calling kmemdup for sizeof sockaddr, yet only
> ETH_ALEN + sizeof(sa_family_t) bytes were malloc'ed.

Previously we have a dev->addr_len longer than sizeof sockaddr,
now we a shorter one... This mac addr thing is really a mess currently.


diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d1ba90980be1..d13bebdf6465 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2031,7 +2031,7 @@ static int do_setlink(const struct sk_buff *skb,
                struct sockaddr *sa;
                int len;

-               len = sizeof(sa_family_t) + dev->addr_len;
+               len = sizeof(sa_family_t) + max(dev->addr_len, sizeof(*sa));
                sa = kmalloc(len, GFP_KERNEL);
                if (!sa) {
                        err = -ENOMEM;
