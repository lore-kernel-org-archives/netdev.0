From: Toby Corkindale <tjc@wintrmute.net>
Subject: Re: Regression in bonding driver - devices without set_mac
Date: Sat, 7 Nov 2015 17:05:18 +1100
Message-ID: <CABEgq94XmWUUHyW8m59gmzFvJdCvpiPz-EMWsk-HL-kQGWWAiA@mail.gmail.com>
References: <CABEgq95FYdt86-KEgkarUr-9g_mHoesV6B7OtrFut4pBR0UGcQ@mail.gmail.com>
	<6968.1446849960@famine>
	<CABEgq96o2dXi06rLh6xmLGYVzh0-fVPs0rpjv8X3NTsk_=8+JQ@mail.gmail.com>
	<10340.1446863490@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Veaceslav Falico <vfalico@gmail.com>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f43.google.com ([209.85.213.43]:35398 "EHLO
	mail-vk0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750787AbbKGGFT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Nov 2015 01:05:19 -0500
Received: by vkfw189 with SMTP id w189so28483390vkf.2
        for <netdev@vger.kernel.org>; Fri, 06 Nov 2015 22:05:18 -0800 (PST)
In-Reply-To: <10340.1446863490@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7 November 2015 at 13:31, Jay Vosburgh <jay.vosburgh@canonical.com> wrote:
>
> Toby Corkindale <tjc@wintrmute.net> wrote:
> [...]
> >The thing is, I've been running PPP devices in balance-rr mode for
> >quite a while. It worked fine, and I'd like to continue having that
> >functionality.  These changes to the kernel have broken that
> >functionality, by requiring the MAC address support unconditionally.
> >
> >I guess using PPP devices is a special case, but it would be great if
> >that special case could continue to be supported.
>
>         Could you describe your configuration / use case a bit more?

Hi Jay,
Certainly, I can.

Some internet service providers allow you to purchase multiple DSL
services, which are bonded together. This provides performance equal
to the total aggregate bandwidth, allowing for high-speed connections
in areas that are only serviced by basic ADSL. To use these services,
you need multiple ADSL modems, and the bonding network driver
aggregates them for receiving data, and for sending data back
upstream.

It works quite nicely, and avoids the need to purchase specialised
multi-port ADSL modems, or dedicated Cisco devices.


>         The nominal reason for the MAC change in balance-rr or
> balance-xor modes is that those modes are designed to interoperate with
> Etherchannel (static link aggregation) type of systems, which expect all
> ports participating in the aggregation to use the same MAC address.
>
>         Relaxing the restriction is likely a matter of causing
> fail_over_mac to be obeyed in addtional modes other than active-backup,
> which is actually what's catching the ppp case right now.  The check for
> the set_mac function passes, but later, the test for "should the slave's
> MAC be changed" is
>
>         if (!bond->params.fail_over_mac ||
>             BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP) {
>                 [ change the slave MAC ]
>         }
>
>         so this block is entered for anything other than active-backup
> mode with fail_over_mac enabled.  This block was changed for
>
> commit 00503b6f702eaf23e7257d6287da72805d7d014c
> Author: dingtianhong <dingtianhong@huawei.com>
> Date:   Sat Jan 25 13:00:29 2014 +0800
>
>     bonding: fail_over_mac should only affect AB mode at enslave and removal pro
> cessing
>
>         So that's probably when you saw the behavior change.
>
>         Are you able to test a patch?  I believe the following would
> change the behavior, although some of the release logic may not be
> correct (I've not tested this).

I don't know if you saw one of my later posts on the topic, but I
submitted a patch. There's a couple of spots that try to fetch the MAC
address to put in a netlink info struct, and which will fail out if
that is not successful.
You will need to incorporate that into your own patch before it will work.
You can find my patch in the earlier post under this thread, or else
at the Bugzilla ticket here:
https://bugzilla.kernel.org/show_bug.cgi?id=89161

It's the middle of the weekend here in Australia, but I can test out
patches tomorrow evening (24 hours from now).

Cheers
Toby
