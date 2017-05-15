From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Subject: Re: [PATCH] kmod: don't load module unless req process has CAP_SYS_MODULE
Date: Sun, 14 May 2017 19:42:08 -0700
Message-ID: <CAF2d9jh6zARipRGM92drOjjrpicF6177cnUf=6oHbR9tHX1ObA@mail.gmail.com>
References: <20170512232259.10820-1-mahesh@bandewar.net> <20170514104537.GA29323@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Mahesh Bandewar <mahesh@bandewar.net>,
        Ingo Molnar <mingo@kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        Kees Cook <keescook@chromium.org>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:33917 "EHLO
        mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751166AbdEOCma (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 14 May 2017 22:42:30 -0400
Received: by mail-io0-f170.google.com with SMTP id k91so65662511ioi.1
        for <netdev@vger.kernel.org>; Sun, 14 May 2017 19:42:29 -0700 (PDT)
In-Reply-To: <20170514104537.GA29323@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 14, 2017 at 3:45 AM, Greg Kroah-Hartman
<gregkh@linuxfoundation.org> wrote:
> On Fri, May 12, 2017 at 04:22:59PM -0700, Mahesh Bandewar wrote:
>> From: Mahesh Bandewar <maheshb@google.com>
>>
[...]
>>   Now try to create a bridge inside this newly created net-ns which would
>>   mean bridge module need to be loaded.
>>   # ip link add br0 type bridge
>>   # echo $?
>>   0
>>   # lsmod | grep bridge
>>   bridge                110592  0
>>   stp                    16384  1 bridge
>>   llc                    16384  2 bridge,stp
>>   #
>>
>>   After this patch -
>>   # ip link add br0 type bridge
>>   RTNETLINK answers: Operation not supported
>>   # echo $?
>>   2
>>   # lsmod | grep bridge
>>   #
>
> Well, it only loads this because the kernel asked for it to be loaded,
> right?
>
Yes, kernel asked for it because of a user action.

>>
>> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>> ---
>>  kernel/kmod.c | 3 +++
>>  1 file changed, 3 insertions(+)
>>
>> diff --git a/kernel/kmod.c b/kernel/kmod.c
>> index 563f97e2be36..ac30157169b7 100644
>> --- a/kernel/kmod.c
>> +++ b/kernel/kmod.c
>> @@ -133,6 +133,9 @@ int __request_module(bool wait, const char *fmt, ...)
>>  #define MAX_KMOD_CONCURRENT 50       /* Completely arbitrary value - KAO */
>>       static int kmod_loop_msg;
>>
>> +     if (!capable(CAP_SYS_MODULE))
>> +             return -EPERM;
>
> At first glance this looks right, but I'm worried what this will break
> that currently relies on this.  There might be lots of systems that are
> used to this being the method that the needed module is requested.  What
> about when userspace asks for a random char device and that module is
> then loaded?  Does this patch break that functionality?
>
Any module when loaded gets loaded system-wide as we can't allow
module loading per-ns. To validate the behavior I was comparing it
with insmod/modprobe, if that doesn't allow because of lack of this
capability in default-ns, then this *indirect* method of loading
module should not allow the same action and the behavior should be
consistent. So with that logic if userspace asks for a random
char-device if insmod/modprobe cannot load it, then this method should
not load it either for the consistency, right?

> thanks,
>
> greg k-h
