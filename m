From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] ppp: Fix a scheduling-while-atomic bug in del_chan
Date: Wed, 2 Aug 2017 10:13:36 -0700
Message-ID: <CAM_iQpVta2EFVjutndCmoLBPWko7dgzP=Q1i2krPqyYuNBV4RA@mail.gmail.com>
References: <1501495658-119725-1-git-send-email-gfree.wind@vip.163.com> <CAM_iQpVEsTpg17RZ1Y1jN2e0wb_X6gtxx05rmUSGa=A=XSj=Eg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: xeb@mail.ru, David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Gao Feng <gfree.wind@vip.163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:38410 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751192AbdHBRN6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 13:13:58 -0400
Received: by mail-wm0-f66.google.com with SMTP id y206so7907718wmd.5
        for <netdev@vger.kernel.org>; Wed, 02 Aug 2017 10:13:57 -0700 (PDT)
In-Reply-To: <CAM_iQpVEsTpg17RZ1Y1jN2e0wb_X6gtxx05rmUSGa=A=XSj=Eg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Gao

On Tue, Aug 1, 2017 at 1:39 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> From my understanding, this RCU is supposed to protect the pppox_sock
> pointers in 'callid_sock' which could be NULL'ed in del_chan(). And the
> pppox_sock is freed when the last refcnt is gone, that is, when sock
> dctor is called. pptp_release() is ONLY called when the fd in user-space
> is gone, not necessarily the last refcnt.

Your commit is probably not the right fix. Can you try the following fix?

diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
index 6dde9a0cfe76..e75bb95c107f 100644
--- a/drivers/net/ppp/pptp.c
+++ b/drivers/net/ppp/pptp.c
@@ -519,7 +519,6 @@ static int pptp_release(struct socket *sock)

        po = pppox_sk(sk);
        del_chan(po);
-       synchronize_rcu();

        pppox_unbind_sock(sk);
        sk->sk_state = PPPOX_DEAD;
@@ -564,6 +563,7 @@ static int pptp_create(struct net *net, struct
socket *sock, int kern)
        sk->sk_family      = PF_PPPOX;
        sk->sk_protocol    = PX_PROTO_PPTP;
        sk->sk_destruct    = pptp_sock_destruct;
+       sock_set_flag(sk, SOCK_RCU_FREE);

        po = pppox_sk(sk);
        opt = &po->proto.pptp;
