From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net/dccp: dccp_create_openreq_child freed held lock
Date: Thu, 2 Mar 2017 11:11:06 +0100
Message-ID: <CACT4Y+ZNrE4k24gHSqTVL5DdQY8Ogj0oob9pS7NM5xDs1Bd1HA@mail.gmail.com>
References: <CACT4Y+ZOAWRzJH3=xJ1z5bFVCM2-smuVSykziQPhSgkv1k3FBQ@mail.gmail.com>
 <20170301153510.GE15145@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
        David Miller <davem@davemloft.net>, dccp@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Arnaldo Carvalho de Melo <acme@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f171.google.com ([209.85.217.171]:35720 "EHLO
        mail-ua0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751302AbdCBM7u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 07:59:50 -0500
Received: by mail-ua0-f171.google.com with SMTP id q7so43439092uaf.2
        for <netdev@vger.kernel.org>; Thu, 02 Mar 2017 04:58:50 -0800 (PST)
In-Reply-To: <20170301153510.GE15145@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 1, 2017 at 4:35 PM, Arnaldo Carvalho de Melo
<acme@kernel.org> wrote:
> Em Wed, Mar 01, 2017 at 10:38:54AM +0100, Dmitry Vyukov escreveu:
>> Hello,
>>
>> I've got the following report while running syzkaller fuzzer on
>> 86292b33d4b79ee03e2f43ea0381ef85f077c760:
>>
>>
>> It seems that dccp_create_openreq_child needs to unlock the sock if
>> dccp_feat_activate_values fails.
>
> Yeah, can you please use the patch below, that mimics the error paths in
> sk_clone_new(), from where I think even the comment about it being a raw
> copy came, but the bh_unlock_sock() didn't?
>
> - Arnaldo
>
> diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
> index 53eddf99e4f6..d20d948a98ed 100644
> --- a/net/dccp/minisocks.c
> +++ b/net/dccp/minisocks.c
> @@ -122,6 +122,7 @@ struct sock *dccp_create_openreq_child(const struct sock *sk,
>                         /* It is still raw copy of parent, so invalidate
>                          * destructor and make plain sk_free() */
>                         newsk->sk_destruct = NULL;
> +                       bh_unlock_sock(newsk);
>                         sk_free(newsk);
>                         return NULL;
>                 }


Applied the patch on bots. Will report if it happens again.
