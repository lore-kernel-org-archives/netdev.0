From: David Ahern <dsahern@gmail.com>
Subject: Re: out-of-bounds access with virtio-net
Date: Wed, 19 Jul 2017 12:33:34 -0600
Message-ID: <79f22f18-893e-58f6-ec16-e5ebdde8ed62@gmail.com>
References: <b3c684fd-72eb-f67b-90f3-bc1185d8b576@gmail.com>
 <CAM_iQpUUPhGRkac5eJb7PwG-EGGjf9fpcdfJO1L3QMhiMMUBtg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36340 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754507AbdGSSdg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 14:33:36 -0400
Received: by mail-pf0-f194.google.com with SMTP id a11so594216pfj.3
        for <netdev@vger.kernel.org>; Wed, 19 Jul 2017 11:33:36 -0700 (PDT)
In-Reply-To: <CAM_iQpUUPhGRkac5eJb7PwG-EGGjf9fpcdfJO1L3QMhiMMUBtg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/19/17 12:23 PM, Cong Wang wrote:
> On Wed, Jul 19, 2017 at 9:59 AM, David Ahern <dsahern@gmail.com> wrote:
>> Changing the mac address on a virtio-net based nic is triggering an
>> out-of-bounds access. Nothing fancy with the command:
>>
>> ip li set dev eth2 addr 01:02:34:56:78:9a
>>
>> virtnet_set_mac_address is calling kmemdup for sizeof sockaddr, yet only
>> ETH_ALEN + sizeof(sa_family_t) bytes were malloc'ed.
> 
> Previously we have a dev->addr_len longer than sizeof sockaddr,
> now we a shorter one... This mac addr thing is really a mess currently.
> 
> 
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index d1ba90980be1..d13bebdf6465 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -2031,7 +2031,7 @@ static int do_setlink(const struct sk_buff *skb,
>                 struct sockaddr *sa;
>                 int len;
> 
> -               len = sizeof(sa_family_t) + dev->addr_len;
> +               len = sizeof(sa_family_t) + max(dev->addr_len, sizeof(*sa));
>                 sa = kmalloc(len, GFP_KERNEL);
>                 if (!sa) {
>                         err = -ENOMEM;
> 

seems reasonable. I am heading to the mountains in a few hours; won't
have time to test until Friday. Please submit formally; no need to wait
for me.
