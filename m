From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net 1/6] sctp: remove the unnecessary state check in
 sctp_outq_tail
Date: Fri, 9 Sep 2016 10:28:41 -0400
Message-ID: <20160909142841.GB15908@hmsreliant.think-freely.org>
References: <cover.1473326067.git.lucien.xin@gmail.com>
 <1718155e984f63995d1be9b053c58aa1a645718e.1473326067.git.lucien.xin@gmail.com>
 <20160908142701.GC16608@hmsreliant.think-freely.org>
 <CADvbK_dxTYrPPFJT5UPZErZLbW9y9oRm+VWbQXxhruwV6UgOZA@mail.gmail.com>
 <20160908192319.GD16608@hmsreliant.think-freely.org>
 <CADvbK_ddvZ4855B1PPLYVY2JV1okKzYXCpv-quNMBXp0Qb5Otw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        davem <davem@davemloft.net>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:41420 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751092AbcIIO24 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 10:28:56 -0400
Content-Disposition: inline
In-Reply-To: <CADvbK_ddvZ4855B1PPLYVY2JV1okKzYXCpv-quNMBXp0Qb5Otw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 09, 2016 at 03:11:57PM +0800, Xin Long wrote:
> >>
> > Its not enough to just look at the paths where outq_tail is called, because
> > the outq_tail function is checking a state variable that can update
> > asynchronously in the side effect processing queue.  Look at any one of the
> > timer functions.  Those all fire asynchronous to the outq list, but they all
> 
> Fortunately, sctp_do_sm is protected by lock_sock.
> I just checked all the sctp_do_sm calling in  timer functions.
> 
> ------------
>         bh_lock_sock(sk);
>         if (sock_owned_by_user(sk)) {    <----------- [1]
>                 pr_debug("%s: sock is busy\n", __func__);
>                 /* Try again later.  */
>                 mod_timer()
>                 goto out_unlock;
>         }
>         error = sctp_do_sm(net, SCTP_EVENT_T_TIMEOUT,
> out_unlock:
>         bh_unlock_sock(sk);
> 
> 
> which means sctp_do_sm is *non-reenterable* because of
> sock lock's protection. even if it's interrupted by something
> like timers, they have to delay their real process until sock
> lock is released.
> 
> So It's still safe here. pls double-check.
> 
I don't know, I still don't feel safe about it.  I agree the socket lock keeps
the state from changing during a single transmission, which makes the use case
you are focused on correct.

That said, have you considered the retransmit case?  That is to say, if you
queue and flush the outq, and some packets fail delivery, and in the time
between the intial send and the expiration of the RTX timer (during which the
socket lock will have been released), an event may occur which changes the
transport state, which will then be ignored with your patch.

Neil
