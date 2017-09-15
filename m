From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [REGRESSION] Warning in tcp_fastretrans_alert() of net/ipv4/tcp_input.c
Date: Fri, 15 Sep 2017 10:03:00 -0400
Message-ID: <CADVnQymkqE+mt4OwtkL1ddpRbqJYPH8CJ0JhNn6ML9YPJdCJxA@mail.gmail.com>
References: <10035198.1vE6NFrMDO@natalenko.name> <CADVnQy=dzjROPgrOw3vAZvtb9ETRJgTPVGtau8Q3ChteDKnYow@mail.gmail.com>
 <1760119.uO98D2ft6f@natalenko.name>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Netdev <netdev@vger.kernel.org>,
        Yuchung Cheng <ycheng@google.com>
To: Oleksandr Natalenko <oleksandr@natalenko.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f169.google.com ([209.85.220.169]:44371 "EHLO
        mail-qk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751207AbdIOODW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2017 10:03:22 -0400
Received: by mail-qk0-f169.google.com with SMTP id b23so2172201qkg.1
        for <netdev@vger.kernel.org>; Fri, 15 Sep 2017 07:03:22 -0700 (PDT)
In-Reply-To: <1760119.uO98D2ft6f@natalenko.name>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 15, 2017 at 1:03 AM, Oleksandr Natalenko
<oleksandr@natalenko.name> wrote:
> Hi.
>
> I've applied your test patch but it doesn't fix the issue for me since the
> warning is still there.
>
> Were you able to reproduce it?

Hi,

Thanks for testing that. That is a very useful data point.

I was able to cook up a packetdrill test that could put the connection
in CA_Disorder with retransmitted packets out, but not in CA_Open. So
we do not yet have a test case to reproduce this.

We do not see this warning on our fleet at Google. One significant
difference I see between our environment and yours is that it seems
you run with FACK enabled:

  net.ipv4.tcp_fack = 1

Note that FACK was disabled by default (since it was replaced by RACK)
between kernel v4.10 and v4.11. And this is exactly the time when this
bug started manifesting itself for you and some others, but not our
fleet. So my new working hypothesis would be that this warning is due
to a behavior that only shows up in kernels >=4.11 when FACK is
enabled.

Would you be able to disable FACK ("sysctl net.ipv4.tcp_fack=0" at
boot, or net.ipv4.tcp_fack=0 in /etc/sysctl.conf, or equivalent),
reboot, and test the kernel for a few days to see if the warning still
pops up?

thanks,
neal

[ps: apologies for the previous, mis-formatted post...]
