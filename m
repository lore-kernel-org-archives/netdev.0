From: Riccardo Trebbi <riccardo.trebbi89@gmail.com>
Subject: Function to get bytes/s received on a socket
Date: Wed, 29 Feb 2012 18:41:26 +0100
Message-ID: <CABzZ0PHPshVp6+8skcawTaW64=kwxwFiWpaDCWpKhnYvm2ugKg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:50453 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752388Ab2B2Rl2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Feb 2012 12:41:28 -0500
Received: by lahj13 with SMTP id j13so3826155lah.19
        for <netdev@vger.kernel.org>; Wed, 29 Feb 2012 09:41:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I am working on a project for the university and I needed a function
that could calculate the throughput of a socket in terms of bytes/s
received.

I followed the line of=A0=A0tcp_rcv_space_adjust()=A0in=A0net/ipv4/tcp_=
input.c
=A0and I did something like this.

=46irst I modified the=A0struct tcp_sock=A0to add this:

+++++++++++++++++++++++++++++++++++++++++++++++++
/* Throughput estimation of the receiver */
=A0 =A0 struct {
=A0 =A0 =A0 =A0 u32 time; =A0 // time we got the seq
=A0 =A0 =A0 =A0 u32 seq; =A0 =A0// seq number we expected at time
=A0 =A0 =A0 =A0 u32 thrpt; =A0 // last value of throughput
=A0 =A0 } thrpt_est;
+++++++++++++++++++++++++++++++++++++++++++++++++

Then I implemented this function in=A0net/ipv4/tcp_input.c:

+++++++++++++++++++++++++++++++++++++++++++++++++

/* This function is used to calculate the throughput of a
=A0* tcp_sock that is receiveing data */
void my_function(struct sock *sk)
{
=A0 =A0 struct tcp_sock *tp =3D tcp_sk(sk);
u32 time;
u32 rcvd_bytes;

if (tp->thrpt_est.time =3D=3D 0 || tp->thrpt_est.seq =3D=3D 0)
goto new_measure;

time =3D tcp_time_stamp - tp->thrpt_est.time;

if(time < 100)
=A0 =A0 =A0 =A0 return;

=A0 =A0 if(tp->rcv_nxt < tp->thrpt_est.seq)
=A0 =A0 =A0 =A0 printk("tp->rcv_nxt < tp->thrpt_est.seq\n");

=A0 =A0 rcvd_bytes =3D tp->rcv_nxt - tp->thrpt_est.seq;

=A0 =A0 if(time =3D=3D 0)
=A0 =A0 =A0 =A0 goto new_measure;

=A0 =A0 tp->thrpt_est.thrpt =3D rcvd_bytes / time;

new_measure:
tp->thrpt_est.seq =3D tp->rcv_nxt;
tp->thrpt_est.time =3D tcp_time_stamp;
}

+++++++++++++++++++++++++++++++++++++++++++++++++

The=A0my_function()=A0is called when=A0tcp_rcv_space_adjust()=A0is call=
ed.

The value in=A0tp->thrpt_est.thrpt=A0is bytes/ms but I can get the byte=
s/s
with a simple conversion.

I am a total newbie in kernel hacking and there's so many things I don'=
t know,
but I thought that this was quite simple and should have worked.

The problem is the value in=A0tp->thrpt_est.thrpt=A0is way higher than =
the
real throughput.
I get values 4-5 times higher than the reality.

Would you please help me understand?

Thanks,

Riccardo
