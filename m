From: Yuchung Cheng <ycheng@google.com>
Subject: Re: A bug report for Linux TCP congestion control algorithms
Date: Fri, 26 May 2017 09:51:58 -0700
Message-ID: <CAK6E8=fHMNmAvxhpi3A5Wgf7UJ=UivUShL6nD62SK=g8BfdVMw@mail.gmail.com>
References: <CAMN46fP_a_Jti_rcLze=7yoaDroQ7qn8kek9HMKtFEQpbm7R3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev <netdev@vger.kernel.org>
To: Wei Sun <wsun@cse.unl.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f45.google.com ([209.85.214.45]:34011 "EHLO
        mail-it0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S944335AbdEZQx1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 12:53:27 -0400
Received: by mail-it0-f45.google.com with SMTP id a10so3137076itg.1
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 09:52:39 -0700 (PDT)
In-Reply-To: <CAMN46fP_a_Jti_rcLze=7yoaDroQ7qn8kek9HMKtFEQpbm7R3A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 25, 2017 at 11:08 PM, Wei Sun <wsun@cse.unl.edu> wrote:
>
> Hi there,
>
> we find a special case for Linux TCP undo operations where
> tp->snd_cwnd could be extremely large (e.g., 4294967294) by two
> consecutive cwnd undo operations when using
> reno/veno/vegas/highspeed/HTCP/yeah/westwood/hybla/illinois/scalable/lp
> congestion control algorithms in the latest long-term kernel 4.9.
>
> e.g., a simple trace for sender-side tcp state variables
> cwnd               ssthresh              ca_state
> 10                   2147483647            0
> 10                   2147483647            0
> 1                           5                        4
> 11                    2147483647           4                   first
> undo operation
> 4294967294    2147483647           0                   second undo operation
> 4294967294    2147483647           0
>
>
> By debugging the code, we find that the second undo operation was
> triggered by F-RTO mechanism without checking current tp->undo_marker.
>
> The case should be existing for all kernel versions depending on F-RTO
> internals (i.e., this bug exists for kernels 4.10 and earlier)
Thanks for discovering that. Note this issue is addressed by

commit 89fe18e44f7ee5ab1c90d0dff5835acee7751427
Author: Yuchung Cheng <ycheng@google.com>
Date:   Thu Jan 12 22:11:37 2017 -0800

    tcp: extend F-RTO to catch more spurious timeouts


>
>
> Just Let you know in case of some vulnerabilities as it is not hard to
> trigger this specific case.
>
> Attached is a simple Google's packetdrill script to trigger it and a
> possible patch to fix it. Thanks
