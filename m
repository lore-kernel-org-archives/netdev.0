From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Re:Re: Re: [PATCH net] ppp: Fix a scheduling-while-atomic bug in del_chan
Date: Tue, 8 Aug 2017 12:45:53 -0700
Message-ID: <CAM_iQpW8W24=2atSyStwKPYJ9zmOO5XiznktT3V_3qn00R7r=Q@mail.gmail.com>
References: <1501495658-119725-1-git-send-email-gfree.wind@vip.163.com>
 <CAM_iQpVEsTpg17RZ1Y1jN2e0wb_X6gtxx05rmUSGa=A=XSj=Eg@mail.gmail.com>
 <CAM_iQpVta2EFVjutndCmoLBPWko7dgzP=Q1i2krPqyYuNBV4RA@mail.gmail.com>
 <31c9755c.ff6.15dba5238fc.Coremail.gfree.wind@vip.163.com>
 <CAM_iQpWmJmk=_yoV8=krOWonE_0orTC5Z4GaCnPg8Jv3GX6dmw@mail.gmail.com>
 <697dbbd.7911.15dbf5ca3a6.Coremail.gfree.wind@vip.163.com> <16ae6009.7a67.15dbf64b398.Coremail.gfree.wind@vip.163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: xeb@mail.ru, David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Gao Feng <gfree.wind@vip.163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f67.google.com ([209.85.213.67]:33933 "EHLO
        mail-vk0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752163AbdHHTqO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 15:46:14 -0400
Received: by mail-vk0-f67.google.com with SMTP id d124so2720337vkf.1
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2017 12:46:14 -0700 (PDT)
In-Reply-To: <16ae6009.7a67.15dbf64b398.Coremail.gfree.wind@vip.163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 7, 2017 at 6:10 PM, Gao Feng <gfree.wind@vip.163.com> wrote:
>
> Sorry, I don't get you clearly. Why the sock_hold() isn't helpful?

I already told you, the dereference happends before sock_hold().

        sock = rcu_dereference(callid_sock[call_id]);
        if (sock) {
                opt = &sock->proto.pptp;
                if (opt->dst_addr.sin_addr.s_addr != s_addr) <=== HERE
                        sock = NULL;
                else
                        sock_hold(sk_pppox(sock));
        }

If we don't wait for readers properly, sock could be freed at the
same time when deference it.

> The pptp_release invokes synchronize_rcu after del_chan, it could make sure the others has increased the sock refcnt if necessary
> and the lookup is over.
> There is no one could get the sock after synchronize_rcu in pptp_release.


If this were true, then this code in pptp_sock_destruct()
would be unneeded:

        if (!(sk->sk_state & PPPOX_DEAD)) {
                del_chan(pppox_sk(sk));
                pppox_unbind_sock(sk);
        }


>
>
> But I think about another problem.
> It seems the pptp_sock_destruct should not invoke del_chan and pppox_unbind_sock.
> Because when the sock refcnt is 0, the pptp_release must have be invoked already.
>


I don't know. Looks like sock_orphan() is only called
in pptp_release(), but I am not sure if there is a case
we call sock destructor before release.

Also note, this socket is very special, it doesn't support
poll(), sendmsg() or recvmsg()..
