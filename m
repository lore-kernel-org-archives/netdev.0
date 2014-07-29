From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 2/2] net: filter: don't release unattached filter
 through call_rcu()
Date: Tue, 29 Jul 2014 09:09:46 -0700
Message-ID: <CAMEtUuxGN_v5SP6HJ74p6fEuop6qXhe0Q-6tkpcCkrnsAtQUvw@mail.gmail.com>
References: <1406648188-3681-1-git-send-email-pablo@netfilter.org>
	<1406648188-3681-2-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netfilter-devel <netfilter-devel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Willem de Bruijn <willemb@google.com>,
	Kees Cook <keescook@chromium.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f178.google.com ([74.125.82.178]:38920 "EHLO
	mail-we0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750852AbaG2QJs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2014 12:09:48 -0400
Received: by mail-we0-f178.google.com with SMTP id w61so9257066wes.37
        for <netdev@vger.kernel.org>; Tue, 29 Jul 2014 09:09:46 -0700 (PDT)
In-Reply-To: <1406648188-3681-2-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 29, 2014 at 8:36 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> sk_unattached_filter_destroy() does not always need to release the
> filter object via rcu. Since this filter is never attached to the
> socket, the caller should be responsible for releasing the filter
> in a safe way, which may not necessarily imply rcu.
>
> This is a short summary of clients of this function:
>
> 1) xt_bpf.c and cls_bpf.c use the bpf matchers from rules, these rules
>    are removed from the packet path before the filter is released. Thus,
>    the framework makes sure the filter is safely removed.
>
> 2) In the ppp driver, the ppp_lock ensures serialization between the
>    xmit and filter attachment/detachment path. This doesn't use rcu
>    so deferred release via rcu makes no sense.
>
> 3) In the isdn/ppp driver, it is called from isdn_ppp_release()
>    the isdn_ppp_ioctl(). This driver uses mutex and spinlocks, no rcu.
>    Thus, deferred rcu makes no sense to me either, the deferred releases
>    may be just masking the effects of wrong locking strategy, which
>    should be fixed in the driver itself.
>
> 4) In the team driver, this is the only place where the rcu
>    synchronization with unattached filter is used. Therefore, this
>    patch introduces synchronize_rcu() which is called from the
>    genetlink path to make sure the filter doesn't go away while packets
>    are still walking over it. I think we can revisit this once struct
>    bpf_prog (that only wraps specific bpf code bits) is in place, then
>    add some specific struct rcu_head in the scope of the team driver if
>    Jiri thinks this is needed.

Correct.
There are also:
5) ptp_classifer - which is ok as well, since there is no filter_destroy.

6) seccomp - there I think it's also ok, since filter is called from syscall
and filter freeing is done on task exit
