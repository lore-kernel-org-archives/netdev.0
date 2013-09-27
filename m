From: Salam Noureddine <noureddine@aristanetworks.com>
Subject: Re: [PATCH 2/2] ipv4 igmp: use del_timer_sync instead of del_timer in ip_mc_down
Date: Fri, 27 Sep 2013 16:04:00 -0700
Message-ID: <CAO7SqHA5pBs7Tmop1ukS_AEXO8K9Np7odo20QdTYHBg2qoV49Q@mail.gmail.com>
References: <1378363404-37749-1-git-send-email-noureddine@aristanetworks.com>
	<20130905084312.091f73b7@nehalam.linuxnetplumber.net>
	<CAO7SqHA4LJhy_NBkPLViJB3s7hM85qd88pmjy3hq-hCCuQstaA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f50.google.com ([209.85.212.50]:46238 "EHLO
	mail-vb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753445Ab3I0XEB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 19:04:01 -0400
Received: by mail-vb0-f50.google.com with SMTP id x14so2303505vbb.37
        for <netdev@vger.kernel.org>; Fri, 27 Sep 2013 16:04:00 -0700 (PDT)
In-Reply-To: <CAO7SqHA4LJhy_NBkPLViJB3s7hM85qd88pmjy3hq-hCCuQstaA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I tried using in_dev_put instead of __in_dev_put and it seems to work
fine in my testing on linux-3.4. I don't quite understand the reason
for having __in_dev_put decrement the refcnt without destroying the
in_device in case it reaches 0. If the timer handler assumes it cannot
be the last one to hold a reference then that would mean it doesn't
need the reference in the first place.

If this solution is preferable to using del_timer_sync I would go
ahead and submit a new patch.

Thanks,

Salam

On Thu, Sep 5, 2013 at 10:22 AM, Salam Noureddine
<noureddine@aristanetworks.com> wrote:
> On Thu, Sep 5, 2013 at 8:43 AM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
>> On Wed,  4 Sep 2013 23:43:24 -0700
>> Salam Noureddine <noureddine@aristanetworks.com> wrote:
>>
>>> Delete timers using del_timer_sync in ip_mc_down. Otherwise, it is
>>> possible for the timer to be the last to release its reference to the
>>> in_device and since __in_dev_put doesn't destroy the in_device we
>>> would end up leaking a reference to the net_device and see messages
>>> like the following,
>>>
>>> unregister_netdevice: waiting for eth0 to become free. Usage count = 1
>>>
>>> Tested on linux-3.4.43.
>>>
>>> Signed-off-by: Salam Noureddine <noureddine@aristanetworks.com>
>>
>> Why not just call in_dev_put instead which just proper cleanup.
>> It is less risky of deadlock than del_timer_sync.
>
> I was wondering if there was a reason behind using __in_dev_put since
> the multicast code
> is the only user of that function. I can test using in_dev_put
> instead. Should __in_dev_put
> be removed altogether in that case?
>
> Thanks,
>
> Salam
