From: Neal Cardwell <ncardwell@google.com>
Subject: Re: tcp_bbr: Forcing set of BBR congestion control as default
Date: Mon, 2 Jan 2017 14:12:16 -0500
Message-ID: <CADVnQymyX1G4=1qaegDYfbq89k15NsG-Acw7mTHRc7jo7=xbQw@mail.gmail.com>
References: <CA+icZUXd8fN5BAZuCna=zpgSJcXivSG1S6cV1eMMJMWwL7RrLA@mail.gmail.com>
 <CADVnQy=q88Hvh2aYnGCpCQH_b5PNwTZr_AWfgU0NnuSs6aatVQ@mail.gmail.com> <CA+icZUUxHFDqfEj+DitFFH6P9+P5kOfMLoQpnK1qW+EZ6PmPKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>
To: sedat.dilek@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:35111 "EHLO
        mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756219AbdABTMs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 14:12:48 -0500
Received: by mail-oi0-f51.google.com with SMTP id b126so488428269oia.2
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2017 11:12:47 -0800 (PST)
In-Reply-To: <CA+icZUUxHFDqfEj+DitFFH6P9+P5kOfMLoQpnK1qW+EZ6PmPKQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 2, 2017 at 1:49 PM, Sedat Dilek <sedat.dilek@gmail.com> wrote:
> On Mon, Jan 2, 2017 at 7:17 PM, Neal Cardwell <ncardwell@google.com> wrote:
>> On Mon, Jan 2, 2017 at 12:05 AM, Sedat Dilek <sedat.dilek@gmail.com> wrote:
>>>
>>> Hi,
>>>
>>> I am trying to force the set of BBR congestion control as default.
>>> My old linux-config uses CUBIC as default.
>>> I want both BBR and CUBIC to be built but BBR shall be my default.
>>>
>>> I tried the below snippet.
>>>
>>> I refresh my new linux-config like this...
>>>
>>> $ MAKE="make V=1" ; COMPILER="mycompiler" ; MAKE_OPTS="CC=$COMPILER
>>> HOSTCC=$COMPILER" ; yes "" | $MAKE $MAKE_OPTS oldconfig && $MAKE
>>> $MAKE_OPTS silentoldconfig < /dev/null
>>>
>>> What am I doing wrong?
>>
>> Perhaps your build directory already has an old .config file that sets
>> the DEFAULT_TCP_CONG to be "cubic", and your "make oldconfig" and
>> "make silentoldconfig" are maintaining those lines from the old
>> .config?
>>
>> If you want to start with your existing .config but then make BBR the
>> default, then it might be simplest just to edit your .config directly:
>>
>> -CONFIG_DEFAULT_TCP_CONG="cubic"
>> +CONFIG_DEFAULT_TCP_CONG="bbr"
>>
>
> Just to clarify...
>
> I can have both TCP_CONG cubic and bbr built and switch for example via sysctl?

Yes, you can set the default congestion control using sysctl, eg:

  sysctl net.ipv4.tcp_congestion_control=bbr

And (as mentioned in the quick-start guide) on many Linux systems you
can make this "sticky" after reboots with something like:

  sudo bash -c 'echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf'

> Which tc version is required?
> Here tc is from iproute (20121211-2~precise).
> Is that enough?

You should not need a particular version of tc to install "fq".

In the BBR quick-start guide we recommend setting fq to be the default qdisc:

  sudo bash -c 'echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf'

But if that doesn't work in your environment, then I believe you
should be able to install the fq qdisc with any version of tc, with
something like:

  tc qdisc replace dev eth0 root fq

You just won't be able to set or view configuration options.

>> BTW, I presume you have seen the warning in the BBR commit message or
>> tcp_bbr.c about ensuring that BBR is used with the "fq" qdisc:
>>
>>   NOTE: BBR *must* be used with the fq qdisc ("man tc-fq") with pacing
>>   enabled, since pacing is integral to the BBR design and
>>   implementation. BBR without pacing would not function properly, and
>>   may incur unnecessary high packet loss rates.
>>
>> The BBR quick-start guide has some details about how to build and
>> enable BBR and fq:
>>
>>   https://github.com/google/bbr/blob/master/Documentation/bbr-quick-start.md
>>
>
> Hmmm...
>
> From [1] Section "Further reading"...
>
> egrep '(CONFIG_TCP_CONG_BBR|CONFIG_NET_SCH_FQ)=' .config
>
> then you see exactly the following lines:
>
> CONFIG_TCP_CONG_BBR=y
> CONFIG_NET_SCH_FQ=y
>
> Should CONFIG_TCP_CONG_BBR have a "select CONFIG_NET_SCH_FQ" in its Kconfig?
> That would be safer.
>
> [1] https://github.com/google/bbr/blob/master/Documentation/bbr-quick-start.md

That would be a little safer, but not sufficient (since the qdisc
still has to be configured to be in the transmit path somewhere).

thanks,
neal
