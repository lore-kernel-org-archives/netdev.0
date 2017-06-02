From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: loosing netdevices with namespaces and unshare?
Date: Fri, 2 Jun 2017 16:25:44 -0700
Message-ID: <CAM_iQpWaJ7WKOEQe=00AX35x_gCKHoHikVTGH6UQTPw+3oD_pw@mail.gmail.com>
References: <20170530220741.ldmhwj3bsvdoaofc@nataraja> <CAM_iQpW2ARBTmGK8JhVXSFCaB1F-WPDKeDZwEbxMLf_Xi7aXQw@mail.gmail.com>
 <20170531122752.siaou43verg4epep@nataraja> <CAM_iQpU517NR1xsrDrAohnESdS33WoToHsdGD0yOWSiGU9Yiqg@mail.gmail.com>
 <87a85si5f2.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Harald Welte <laforge@gnumonks.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:33407 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750971AbdFBX0G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 19:26:06 -0400
Received: by mail-wm0-f48.google.com with SMTP id m7so14512401wmg.0
        for <netdev@vger.kernel.org>; Fri, 02 Jun 2017 16:26:05 -0700 (PDT)
In-Reply-To: <87a85si5f2.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 31, 2017 at 11:32 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> Cong Wang <xiyou.wangcong@gmail.com> writes:
>> Network namespace does not special-case the physical devices,
>> it treats them all equally as abstract net devices.
>
> Absolutely not true.
>
> The relevant code is in net/core/dev.c:default_device_exit
>
> If a network device does not implement rntl_link_ops it is returned to
> the initial network namespace.   Anything else will loose physical
> devices.

Hmm, I never noticed that if check...

>
> Only for pure software based devices do we delete them.  Perhaps your
> sub interface implements rtnl_link_ops?  Either that or something is
> still holding a reference to your network namespace, which would prevent
> the network device from being returned.
>

But this simply sucks:

                snprintf(fb_name, IFNAMSIZ, "dev%d", dev->ifindex);
                err = dev_change_net_namespace(dev, &init_net, fb_name);
                if (err) {
                        pr_emerg("%s: failed to move %s to init_net: %d\n",
                                 __func__, dev->name, err);
                        BUG();
                }

It is essentially hard to handle the error here, but it is quite easy to
trigger such BUG() by naming other device devX, it is no better
than just losing it.
