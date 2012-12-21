From: Zhiyun Qian <zhiyunq@umich.edu>
Subject: Re: TCP sequence number inference attack on Linux
Date: Fri, 21 Dec 2012 18:52:22 -0500
Message-ID: <CALvgte-tpvyBF608MahqLc_JFZNzg2q1FpsUY72fDDicbdsBWA@mail.gmail.com>
References: <CALvgte86miv450KnOcFRR-oEm_f=qRXarDfQkyU7T3OLqq816A@mail.gmail.com>
	<1356114663.21834.7697.camel@edumazet-glaptop>
	<CALvgte9x4LWV8rsquKzNoVcXM14xZjvyuTgpHr-ynZXfGtzzpw@mail.gmail.com>
	<1356118052.21834.7793.camel@edumazet-glaptop>
	<CALvgte9WJRR95B5WCTavF0w3Kvf+MksZtyY4OQ=ioAe71BasCw@mail.gmail.com>
	<1356129948.21834.8002.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <erdnetdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:37699 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752618Ab2LUXwY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 18:52:24 -0500
Received: by mail-wg0-f45.google.com with SMTP id dq12so2449809wgb.24
        for <netdev@vger.kernel.org>; Fri, 21 Dec 2012 15:52:23 -0800 (PST)
In-Reply-To: <1356129948.21834.8002.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 21, 2012 at 5:45 PM, Eric Dumazet <erdnetdev@gmail.com> wrote:
> On Fri, 2012-12-21 at 14:49 -0500, Zhiyun Qian wrote:
>
>> If I am not mistaken, line 6142 in kernel v3.7.1 corresponds to
>> tcp_rcv_state_process(). According to the comments, "This function
>> implements the receiving procedure of RFC 793 for all states except
>> ESTABLISHED and TIME_WAIT." Are you referring to a different kernel
>> version?
>
> You are not mistaken, it seems code is too permissive.
>
> We should reject a frame without ACK flag while in ESTABLISHED state.
>
> Thats explicitly stated in RFC 973.
>
> Then we should make all possible safety checks before even sending a
> frame or changing socket variables.

I completely agree!

>
> (For instance the tests done in tcp_ack() should be done before calling
> tcp_validate_incoming())
>

It seems that it is not straightforward to simply move tcp_ack()
before tcp_validate_incoming() as tcp_ack() currently assumes the tcp
sequence number is already validated and it may adjust certain states
purely depending on the ACK number. I guess the solution is to extract
all safety checks out and put at the very beginning. The rest of the
code in tcp_validate_incoming() and tcp_ack() may still need to
perform the redundant checks since if some state changes are dependent
on the sequence number or ACK number (e.g., window update).

I'm willing to help on this. Perhaps I can draft an initial patch and
you can help take a look before I submit it?

> John Dykstra in commit 96e0bf4b5193d0 (tcp: Discard segments that ack
> data not yet sent) did a step into right direction, but missed this.
>
> Current code assumes the incoming frame is mostly legitimate.
>
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index a136925..2ea4937 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -5551,7 +5551,7 @@ slow_path:
>                 return 0;
>
>  step5:
> -       if (th->ack && tcp_ack(sk, skb, FLAG_SLOWPATH) < 0)
> +       if (!th->ack || tcp_ack(sk, skb, FLAG_SLOWPATH) < 0)
>                 goto discard;
>
>         /* ts_recent update must be made after we are sure that the packet
>
>

Neat change. This should enforce the ACK flag and ACK number check for
every packet received in established state.
