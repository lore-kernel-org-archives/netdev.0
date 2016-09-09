From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net 1/6] sctp: remove the unnecessary state check in sctp_outq_tail
Date: Fri, 9 Sep 2016 15:11:57 +0800
Message-ID: <CADvbK_ddvZ4855B1PPLYVY2JV1okKzYXCpv-quNMBXp0Qb5Otw@mail.gmail.com>
References: <cover.1473326067.git.lucien.xin@gmail.com> <1718155e984f63995d1be9b053c58aa1a645718e.1473326067.git.lucien.xin@gmail.com>
 <20160908142701.GC16608@hmsreliant.think-freely.org> <CADvbK_dxTYrPPFJT5UPZErZLbW9y9oRm+VWbQXxhruwV6UgOZA@mail.gmail.com>
 <20160908192319.GD16608@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        davem <davem@davemloft.net>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:35749 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751386AbcIIHL6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 03:11:58 -0400
In-Reply-To: <20160908192319.GD16608@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>
> Its not enough to just look at the paths where outq_tail is called, because
> the outq_tail function is checking a state variable that can update
> asynchronously in the side effect processing queue.  Look at any one of the
> timer functions.  Those all fire asynchronous to the outq list, but they all

Fortunately, sctp_do_sm is protected by lock_sock.
I just checked all the sctp_do_sm calling in  timer functions.

------------
        bh_lock_sock(sk);
        if (sock_owned_by_user(sk)) {    <----------- [1]
                pr_debug("%s: sock is busy\n", __func__);
                /* Try again later.  */
                mod_timer()
                goto out_unlock;
        }
        error = sctp_do_sm(net, SCTP_EVENT_T_TIMEOUT,
out_unlock:
        bh_unlock_sock(sk);


which means sctp_do_sm is *non-reenterable* because of
sock lock's protection. even if it's interrupted by something
like timers, they have to delay their real process until sock
lock is released.

So It's still safe here. pls double-check.
