From: Rolf Neugebauer <rolf.neugebauer@docker.com>
Subject: Re: Long stalls creating a new netns after a netns with a SMB client exits
Date: Fri, 28 Jul 2017 19:58:45 +0100
Message-ID: <CA+pO-2cUUy=_Krwnvt5GL-DUsu+oBOHwhF-TE8sqW=7PFMBrbA@mail.gmail.com>
References: <CA+pO-2cm7bz861KvPMpugP8rVwf6rU8QYrVq7PVO-ZXx2kh1fw@mail.gmail.com>
 <CAM_iQpW+gSgCDWdGoHvN0wObda_g40FcyCBem5VVJ4XLHNMRaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Rolf Neugebauer <rolf.neugebauer@docker.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:33519 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752204AbdG1S6q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 14:58:46 -0400
Received: by mail-pg0-f50.google.com with SMTP id c14so21895759pgn.0
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 11:58:46 -0700 (PDT)
In-Reply-To: <CAM_iQpW+gSgCDWdGoHvN0wObda_g40FcyCBem5VVJ4XLHNMRaQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 28, 2017 at 6:49 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> Hello,
>
> On Fri, Jul 28, 2017 at 9:47 AM, Rolf Neugebauer
> <rolf.neugebauer@docker.com> wrote:
>> Creating the new namespace is stalling for around 200 seconds and
>> there 20 odd messages on the console, like:
>>
>> [   67.372603] unregister_netdevice: waiting for lo to become free.
>> Usage count = 1
>>
>
> Sounds like another netdev refcnt leak.

I don't think it's a leak as such because the system eventually
recovers after around 200 seconds.

>
>> Adding a 'sleep 1' before deleting the original network namespace
>> "solves" the issue, but that doesn't sound like a good fix. Not using
>> unmount also does not help (understandable).
>
>
> Interesting, if sleeping for 1sec help, why did you see the stall for
> 200sec? The "leak" should go away eventually without 'sleep 1',
> right?

Yes. I suspect, that with a sleep some cleanup code (maybe umount)
gets run and the ref count gets decremented within the second. Without
the sleep, something gets yanked, and whatever operation needs to be
done can't get performed, times out after 200s and then the ref count
gets decremented.


>
>>
>> While the creation of the new namespace is stalled, I used 'sysrq' a
>> few times to dump the work queues. There is an example below. Also,
>> the hung task detection kicks in after 120 seconds (also below)
>
> Yeah, the net_mutex is held by cleanup_net().
>
>>
>> I can readily reproduce this on 4.9.39, 4.11.12 and another user
>> repro-ed it on 4.12.3. It seems to happen every time. At least one
>> user reported issues with NFS mounts as well, but we were not able to
>> reproduce it. It's not clear to me if this is directly related to
>> 'mount.cifs' or if that just happens to reliably repro it.
>
> OK, so commit d747a7a51b00984127a88113c does not help this case
> either.

d747a7a51b009("tcp: reset sk_rx_dst in tcp_disconnect()") indeed seems
a different issue. As I understand that actually caused the ref count
never to get decremented, while here eventually some cleanup kicks in
after a long timeout.

>
>>
>> It would be great if someone more familiar with the code could take a
>> look. I'm happy to provide additional info (perf traces etc) or test
>> patches if needed.
>>
>
> The last time I debugged this kind of netdev refcnt leak problem,
> I added a few trace_printk() to dev_hold() and dev_put(),
> so you can try it too. I will see if I can use your reproducer
> here.

The last time I encountered the same symptoms were here
http://www.spinics.net/lists/netdev/msg403433.html but this had an
entirely different cause.

I'll also try if I can get some traces out of dev_hold()/dev_put().

Rolf

>
> Thanks.
