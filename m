From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [REGRESSION] Warning in tcp_fastretrans_alert() of net/ipv4/tcp_input.c
Date: Mon, 18 Sep 2017 10:18:37 -0700
Message-ID: <CAK6E8=fF0hMmQ+m4JZPWFFJixYa3Vp5WrQapYu4zq9Zc5eMe_w@mail.gmail.com>
References: <10035198.1vE6NFrMDO@natalenko.name> <CADVnQymkqE+mt4OwtkL1ddpRbqJYPH8CJ0JhNn6ML9YPJdCJxA@mail.gmail.com>
 <12759907.teKvueDKTR@natalenko.name> <22474097.Jky8MxLkJU@natalenko.name>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Neal Cardwell <ncardwell@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Netdev <netdev@vger.kernel.org>
To: Oleksandr Natalenko <oleksandr@natalenko.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f178.google.com ([209.85.128.178]:43768 "EHLO
        mail-wr0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932707AbdIRRTT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 13:19:19 -0400
Received: by mail-wr0-f178.google.com with SMTP id a43so1102891wrc.0
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 10:19:18 -0700 (PDT)
In-Reply-To: <22474097.Jky8MxLkJU@natalenko.name>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 17, 2017 at 11:43 AM, Oleksandr Natalenko
<oleksandr@natalenko.name> wrote:
> Hi.
>
> Just to note that it looks like disabling RACK and re-enabling FACK preve=
nts
> warning from happening:
>
> net.ipv4.tcp_fack =3D 1
> net.ipv4.tcp_recovery =3D 0
>
> Hope I get semantics of these tunables right.
Thanks.

One difference between RACK and FACK is that RACK can detect lost
retransmission in CA_Recovery (fast recovery) and CA_Loss  (post RTO)
mode, while the current FACK can not. A previous FACK version can also
detect lost retransmission in CA_recovery with limited-transmit. I
suspect it is RACK's special ability that triggers this warning.

IMO, however, this warning itself is questionably valid: with undo
(TCP Eifel), the sender can detect and revert a false CA_Recovery /
CA_Loss to CA_Open, with spurious retransmission in-flight
(tp->retrans_out > 0). Then another SACK after undo triggers this
warning. Neal and I are not sure if this is causing the panics you're
seeing, but personally I'd argue this warning is false, or at least
should be revised to skip undo case.


>
> On p=C3=A1tek 15. z=C3=A1=C5=99=C3=AD 2017 21:04:36 CEST Oleksandr Natale=
nko wrote:
>> Hello.
>>
>> With net.ipv4.tcp_fack set to 0 the warning still appears:
>>
>> =3D=3D=3D
>> =C2=BB sysctl net.ipv4.tcp_fack
>> net.ipv4.tcp_fack =3D 0
>>
>> =C2=BB LC_TIME=3DC dmesg -T | grep WARNING
>> [Fri Sep 15 20:40:30 2017] WARNING: CPU: 1 PID: 711 at net/ipv4/tcp_inpu=
t.c:
>> 2826 tcp_fastretrans_alert+0x7c8/0x990
>> [Fri Sep 15 20:40:30 2017] WARNING: CPU: 0 PID: 711 at net/ipv4/tcp_inpu=
t.c:
>> 2826 tcp_fastretrans_alert+0x7c8/0x990
>> [Fri Sep 15 20:48:37 2017] WARNING: CPU: 1 PID: 711 at net/ipv4/tcp_inpu=
t.c:
>> 2826 tcp_fastretrans_alert+0x7c8/0x990
>> [Fri Sep 15 20:48:55 2017] WARNING: CPU: 0 PID: 711 at net/ipv4/tcp_inpu=
t.c:
>> 2826 tcp_fastretrans_alert+0x7c8/0x990
>>
>> =C2=BB ps -up 711
>> USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
>> root       711  4.3  0.0      0     0 ?        S    18:12   7:23 [irq/12=
3-
>> enp3s0]
>> =3D=3D=3D
>>
>> Any suggestions?
>>
>> On p=C3=A1tek 15. z=C3=A1=C5=99=C3=AD 2017 16:03:00 CEST Neal Cardwell w=
rote:
>> > Thanks for testing that. That is a very useful data point.
>> >
>> > I was able to cook up a packetdrill test that could put the connection
>> > in CA_Disorder with retransmitted packets out, but not in CA_Open. So
>> > we do not yet have a test case to reproduce this.
>> >
>> > We do not see this warning on our fleet at Google. One significant
>> > difference I see between our environment and yours is that it seems
>> >
>> > you run with FACK enabled:
>> >   net.ipv4.tcp_fack =3D 1
>> >
>> > Note that FACK was disabled by default (since it was replaced by RACK)
>> > between kernel v4.10 and v4.11. And this is exactly the time when this
>> > bug started manifesting itself for you and some others, but not our
>> > fleet. So my new working hypothesis would be that this warning is due
>> > to a behavior that only shows up in kernels >=3D4.11 when FACK is
>> > enabled.
>> >
>> > Would you be able to disable FACK ("sysctl net.ipv4.tcp_fack=3D0" at
>> > boot, or net.ipv4.tcp_fack=3D0 in /etc/sysctl.conf, or equivalent),
>> > reboot, and test the kernel for a few days to see if the warning still
>> > pops up?
>> >
>> > thanks,
>> > neal
>> >
>> > [ps: apologies for the previous, mis-formatted post...]
>
>
