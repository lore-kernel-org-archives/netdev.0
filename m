From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] ipv4: fix memory leaks in ip_cmsg_send() callers
Date: Mon, 15 Feb 2016 12:11:34 -0800
Message-ID: <CAM_iQpWq2=Z70Qxh=WFgsPer7XwDo9T7P0ZhCDbk2zaBr3ZmWQ@mail.gmail.com>
References: <CACT4Y+YMUc8j4_-oJfi0XmQebhaTZa2NTipSFY_ra38V-TAyXQ@mail.gmail.com>
	<1454594653.7627.290.camel@edumazet-glaptop2.roam.corp.google.com>
	<1454595808.7627.296.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Vyukov <dvyukov@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f182.google.com ([209.85.160.182]:34719 "EHLO
	mail-yk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751785AbcBOULe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 15:11:34 -0500
Received: by mail-yk0-f182.google.com with SMTP id u9so64614472ykd.1
        for <netdev@vger.kernel.org>; Mon, 15 Feb 2016 12:11:34 -0800 (PST)
In-Reply-To: <1454595808.7627.296.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 4, 2016 at 6:23 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Dmitry reported memory leaks of IP options allocated in
> ip_cmsg_send() when/if this function returns an error.
>
> Callers are responsible for the freeing.

Right, because there is a loop in ip_cmsg_send(), so the callers
are easier to free it than the callee.

The other thing is we perhaps have another leak in the following code:

        if (ipc.opt && ipc.opt->opt.srr) {
                if (!daddr)
                        return -EINVAL;
                faddr = ipc.opt->opt.faddr;
        }

since ipc.opt could be allocated on heap... We need something like:

@@ -770,8 +770,11 @@ static int ping_v4_sendmsg(struct sock *sk,
struct msghdr *msg, size_t len)
        ipc.addr = faddr = daddr;

        if (ipc.opt && ipc.opt->opt.srr) {
-               if (!daddr)
+               if (!daddr) {
+                       if (free)
+                               kfree(ipc.opt);
                        return -EINVAL;
+               }
                faddr = ipc.opt->opt.faddr;
        }
        tos = get_rttos(&ipc, inet);
