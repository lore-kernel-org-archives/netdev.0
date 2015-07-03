From: Sam Protsenko <semen.protsenko@linaro.org>
Subject: problems with L2TP
Date: Fri, 3 Jul 2015 16:49:51 +0300
Message-ID: <CAKaJLVuu8vZ8fq32jqbC0MKRms9ikmT_d9KKA+hJ8kwpEYBhmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sumit Semwal <sumit.semwal@linaro.org>
To: James Chapman <jchapman@katalix.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:33676 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754840AbbGCNtw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2015 09:49:52 -0400
Received: by igcur8 with SMTP id ur8so144520077igc.0
        for <netdev@vger.kernel.org>; Fri, 03 Jul 2015 06:49:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm having issues running user-space code, which uses net/l2tp/l2tp_ppp.c.
The code is supposed to be running in LAC mode (which is I believe is default).
My server configuration described here: https://wiki.linaro.org/LMG/Kernel/PPP

I was trying to use next code snippets as user-space part:
  1. Code example from comments in net/l2tp/l2tp_ppp.c
  2. Code examples from Documentation/networking/l2tp.txt
  3. Code from this project: http://www.kvack.org/~bcrl/pppol2tp/multihop.c

Basically, I was trying two options for user-space code:
  1. Creating only one sockaddr_pppol2tp, like this:

    <<<<<<<<<<<<<<<<<<<<<< cut here >>>>>>>>>>>>>>>>>>
    session_fd = socket(AF_PPPOX, SOCK_DGRAM, PX_PROTO_OL2TP);
    session_sa.sa_family = AF_PPPOX;
    session_sa.sa_protocol = PX_PROTO_OL2TP;
    session_sa.pppol2tp.fd = udp_fd;
    session_sa.pppol2tp.s_tunnel = local_tunnel;
    session_sa.pppol2tp.s_session = local_session;
    session_sa.pppol2tp.d_tunnel = remote_tunnel;
    session_sa.pppol2tp.d_session = remote_session;
    connect(session_fd, (struct sockaddr *)&session_sa,
            sizeof(session_sa));
    <<<<<<<<<<<<<<<<<<<<<< cut here >>>>>>>>>>>>>>>>>>

    In that case user-space tool was failing on connect() call.

  2. Creating two sockaddr_pppol2tp, like this:

    <<<<<<<<<<<<<<<<<<<<<< cut here >>>>>>>>>>>>>>>>>>

    tunnel_fd = socket(AF_PPPOX, SOCK_DGRAM, PX_PROTO_OL2TP);
    tunnel_sa.sa_family = AF_PPPOX;
    tunnel_sa.sa_protocol = PX_PROTO_OL2TP;
    tunnel_sa.pppol2tp.fd = the_socket; /* UDP socket */
    tunnel_sa.pppol2tp.s_tunnel = local_tunnel;
    tunnel_sa.pppol2tp.s_session = 0; /* special case: mgmt socket */
    tunnel_sa.pppol2tp.d_tunnel = remote_tunnel;
    tunnel_sa.pppol2tp.d_session = 0; /* special case: mgmt socket */
    connect(tunnel_fd, (struct sockaddr *)&tunnel_sa,
            sizeof(tunnel_sa));

    session_fd = socket(AF_PPPOX, SOCK_DGRAM, PX_PROTO_OL2TP);
    session_sa.sa_family = AF_PPPOX;
    session_sa.sa_protocol = PX_PROTO_OL2TP;
    session_sa.pppol2tp.fd = udp_fd;
    session_sa.pppol2tp.s_tunnel = local_tunnel;
    session_sa.pppol2tp.s_session = local_session;
    session_sa.pppol2tp.d_tunnel = remote_tunnel;
    session_sa.pppol2tp.d_session = remote_session;
    connect(session_fd, (struct sockaddr *)&session_sa,
            sizeof(session_sa));
    <<<<<<<<<<<<<<<<<<<<<< cut here >>>>>>>>>>>>>>>>>>

    In this case my user-space tool works fine, but my server shows
next errors in /var/log/syslog:

    <<<<<<<<<<<<<<<<<<<<<< cut here >>>>>>>>>>>>>>>>>>
    Jul  3 16:32:49 joe-laptop xl2tpd[2978]: Can not find tunnel 25061
(refhim=0)
    Jul  3 16:32:49 joe-laptop xl2tpd[2978]: network_thread: unable to
find call or tunnel to handle packet.  call = 48566, tunnel = 25061
Dumping.
    <<<<<<<<<<<<<<<<<<<<<< cut here >>>>>>>>>>>>>>>>>>

UDP socket was created next way (for both cases):
https://android.googlesource.com/platform/external/mtpd/+/0269612ac00a0700997dda333faf0a3c33a388b8/mtpd.c#253

(see the_socket variable in create_socket() function).

So my questions are:
1. Am I doing something wrong in userspace part? Because my server
part is working fine with Android kernel implementation of LAC
(drivers/net/ppp/pppolac.c). When I'm trying to do the same with
mainline kernel implementation of LAC -- I'm having issues described
above.
2. Do we have some testing code for L2TP (particularly LAC)? Or maybe
just some working user-space code sample?

Thanks!
