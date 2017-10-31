From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net 00/16] net_sched: fix races with RCU callbacks
Date: Tue, 31 Oct 2017 07:00:22 -0400
Message-ID: <0dfff609-d67e-0701-399f-1dbe2ef09bf3@mojatatu.com>
References: <20171027012443.3306-1-xiyou.wangcong@gmail.com>
 <CAMDBHYJGU-8SgYnzMKJsD6QKdMBSi4evHxJi2p-fJ12+09fBsw@mail.gmail.com>
 <CAM_iQpW=1kbpLxwCbBtGj3D+aVy5QseEAU+omEJUmJJwJ6P58A@mail.gmail.com>
 <CAMDBHYJTMv4MDQENNKjOXaUBHyXicOnkM_j+i7__3d1CAgdVRg@mail.gmail.com>
 <CAM_iQpUTG6hzi=kPP2t=Svoj_MHgfcs7m+_ruWVafJq26RFV8g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Chris Mi <chrism@mellanox.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jiri Pirko <jiri@resnulli.us>,
        John Fastabend <john.fastabend@gmail.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Cong Wang <xiyou.wangcong@gmail.com>,
        Lucas Bates <lucasb@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:55180 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751667AbdJaLAZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 07:00:25 -0400
Received: by mail-io0-f195.google.com with SMTP id e89so34040174ioi.11
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 04:00:24 -0700 (PDT)
In-Reply-To: <CAM_iQpUTG6hzi=kPP2t=Svoj_MHgfcs7m+_ruWVafJq26RFV8g@mail.gmail.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-10-31 01:44 AM, Cong Wang wrote:
> On Mon, Oct 30, 2017 at 6:03 PM, Lucas Bates <lucasb@mojatatu.com> wrote:
>> On Oct 30, 2017 19:13, "Cong Wang" <xiyou.wangcong@gmail.com> wrote:
>>>

> Can you try this patch? From your stack trace it is not clear where
> the cause is, but we know that the crash is in __tcf_idr_release(),
> this is how I came up with the following patch:
> 
> 
> diff --git a/include/net/act_api.h b/include/net/act_api.h
> index b944e0eb93be..5072446d5f06 100644
> --- a/include/net/act_api.h
> +++ b/include/net/act_api.h
> @@ -122,7 +122,9 @@ void tcf_idrinfo_destroy(const struct tc_action_ops *ops,
> 
>   static inline void tc_action_net_exit(struct tc_action_net *tn)
>   {
> +       rtnl_lock();
>          tcf_idrinfo_destroy(tn->ops, tn->idrinfo);
> +       rtnl_unlock();
>          kfree(tn->idrinfo);
>   }
> 
>

Looks like an excellent bet;-> tdc kills the container at the end of the
test.

cheers,
jamal
