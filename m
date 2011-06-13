From: Aaron Wu <aaronwu06@gmail.com>
Subject: Question on IP_TOS options
Date: Mon, 13 Jun 2011 15:28:19 +0800
Message-ID: <BANLkTinnhZSvREW8MrL7R2DUirHtG_eQUw@mail.gmail.com>
References: <BANLkTikJKzWPU2qb2GkYGej0yE=O3Z+EWw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:64280 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752119Ab1FMH2V convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2011 03:28:21 -0400
Received: by qwk3 with SMTP id 3so2050134qwk.19
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2011 00:28:19 -0700 (PDT)
In-Reply-To: <BANLkTikJKzWPU2qb2GkYGej0yE=O3Z+EWw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greetings!

Recently I am looking into some network performance test, but have no
idea how the IP_TOS, to be specific the 0xa0 (means
IPTOS_PREC_CRITIC_ECP?) works. Here is the full story:
By starting two iperf sessions at the same time, followed by the third
iperf session right after 10 seconds like below:

1)iperf -c <serverip> -p 5001 -u -t 20 -S 0x00 -b 3.2M -i 2
2)iperf -c <serverip> -p 5002 -u -t 20 -S 0xa0 -b 2.8M -i 2

3)iperf -c <serverip> -p 5003 -u -t 20 -S 0x00 -b 3.2M -i 2

The total network bandwidth is about 6M, so first we fill all the
bandwidth with session 1 and sesson 2, session one is marked as low
priority by -S 0x00 and session 2 as high prioirty with -S 0xa0.
Then 10 seconds later, we start the third low priority session. The
expected result is: bandwidth for session 2=A0will not drop to 90%=A0of
it's original value before the insertion of session 3, as it's the
high priority session. However, the actual test result varies=A0from
platform to platform, on=A0a=A0ubuntu 10.04 X86 computer is works as
expected, on another embedded platform also running the=A0IPV4,
bandwidth for session 2 decreased=A0greatly due to the insertion of
session 3. We tracked the code and find=A0-S option for iperf eventuall=
y
invokes the following code in=A0net/ipv4/ip_sockglue.c:

=A0=A0case IP_TOS:=A0=A0=A0 /* This sets both TOS and Precedence */
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 printk("Setting IP_TOS, v=
al is 0x%x\n", val);
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (sk->sk_type =3D=3D SO=
CK_STREAM) {
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 v=
al &=3D ~3;
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 v=
al |=3D inet->tos & 3;
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 p=
rintk("Setting IP_TOS, is stream val is 0x%x\n", val);
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 }
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (inet->tos !=3D val) {
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 i=
net->tos =3D val;
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 s=
k->sk_priority =3D rt_tos2priority(val);
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 s=
k_dst_reset(sk);
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 p=
rintk("Setting IP_TOS, set tos to val is 0x%x\n", val);
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 }
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 break;
We don't have idea on the 0xa0 (IPTOS_PREC_CRITIC_ECP) for IP_TOS
option and have no idea why on X86 it works well and on the embedded
platform it does not. Appreciate very much if someone could shed some
light.

Best regards,
Aaron
