From: =?UTF-8?Q?Lars_Erik_Storbuk=C3=A5s?= <storbukas.dev@gmail.com>
Subject: TCP get SND_CWND change on loss event
Date: Sat, 27 May 2017 14:12:22 +0200
Message-ID: <CAF0XkCANsVVYBeaD8A=Y5NR_=SF=11Vto75HD+O45RGZD2tKYQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f50.google.com ([209.85.214.50]:38553 "EHLO
        mail-it0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756540AbdE0MMX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 08:12:23 -0400
Received: by mail-it0-f50.google.com with SMTP id r63so8650615itc.1
        for <netdev@vger.kernel.org>; Sat, 27 May 2017 05:12:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I want to store the value of snd_cwnd when a congestion event occurs
(value before snd_cwnd is reduced), and the new value of snd_cwnd (the
value it has been reduced to). In other words: the congestion window
before and after a congestion event occurs.

I'm uncertain where (and how) it would be logical to implement this. I
have found two possible locations in the tcp_input.c where (I think)
it could be implemented:

static void tcp_cong_control(...) {
 ...
  if (tcp_in_cwnd_reduction(sk)) {
    struct tcp_sock *tp =3D tcp_sk(sk);
    prior_congestion_window =3D tp->snd_cwnd;

    /* Reduce cwnd if state mandates */
    tcp_cwnd_reduction(sk, acked_sacked, flag);

    reduced_congestion_window =3D tp->snd_cwnd;
  }
 ...
}

or

static void tcp_fastretrans_alert(...) {
  ...
  default:
    ...
    struct tcp_sock *tp =3D tcp_sk(sk);
    prior_congestion_window =3D tp->snd_cwnd;

    /* Otherwise enter Recovery state */
    tcp_enter_recovery(sk, (flag & FLAG_ECE));
    fast_rexmit =3D 1;

    reduced_congestion_window =3D tp->snd_cwnd;
  ...
}

Does anyone have advice on where (and how) to implement this? Does any
of the proposed solutions above seem logical?

/ Lars Erik Storbuk=C3=A5s
