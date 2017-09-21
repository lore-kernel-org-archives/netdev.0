From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Latest net-next from GIT panic
Date: Wed, 20 Sep 2017 18:17:19 -0700
Message-ID: <1505956639.29839.108.camel@edumazet-glaptop3.roam.corp.google.com>
References: <4745525f-18e4-7f69-fe21-8e507e407b33@itcare.pl>
         <8f0b0143-657e-d574-c442-24d3d017bc87@itcare.pl>
         <54d058d4-b9d1-54cb-f064-45cec430fe5d@itcare.pl>
         <6c073f86-ab71-0a8f-7b9a-91d5ae5da214@itcare.pl>
         <7fee43ee-75b5-c2f5-cf8d-684ceefcd2d1@itcare.pl>
         <c278dec6-e018-62e0-a613-1fa79741aaab@itcare.pl>
         <cfc04422-51bd-0a28-6a8c-6b57179e8af2@itcare.pl>
         <3324f95f-7686-81e0-a973-1a9220c918fe@itcare.pl>
         <1505913075.29839.90.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpV8qV8a_yFT0--4Z==FuWda=4EQzKJzHTL+op4S5b9E0A@mail.gmail.com>
         <3c227be7-a954-a406-1987-24e908cf214c@itcare.pl>
         <CAM_iQpUOOCcES4d_ueK2wizn2oyDZPEzLfWQFu3oOq=BuRzdiw@mail.gmail.com>
         <1505932231.29839.106.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpVF3Gf3G=543o8g+5N2dtEL4DcUPN3a6=L8V_G0CXZ65w@mail.gmail.com>
         <07f0c800-7ee7-1ebe-9f5f-eaad52a7b42d@itcare.pl>
         <548a893c-8a8f-3b07-00f7-d75de1d777ad@itcare.pl>
         <7d8731ee-6c91-bbfd-6313-c95f52d7b49a@itcare.pl>
         <26e8b899-d8b1-caa4-436b-e23ffe384b0f@itcare.pl>
         <6c36fa00-13e6-8cd7-ff5c-df7739220736@itcare.pl>
         <CAEA6p_DpSr84cYu3pXqoHV=V=daSsbiOcnzsF+Kt0r4Wv_jmdg@mail.gmail.com>
         <CAEA6p_AiLvZxsyu+iOCrPzW-H28N=HBnWycy8w6gdZHFk2Q1dQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: Wei Wang <weiwan@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:56635 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751641AbdIUBRW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 21:17:22 -0400
Received: by mail-pf0-f182.google.com with SMTP id g65so2404424pfe.13
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 18:17:22 -0700 (PDT)
In-Reply-To: <CAEA6p_AiLvZxsyu+iOCrPzW-H28N=HBnWycy8w6gdZHFk2Q1dQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-09-20 at 18:09 -0700, Wei Wang wrote:
> > Thanks very much Pawel for the feedback.
> >
> > I was looking into the code (specifically IPv4 part) and found that in
> > free_fib_info_rcu(), we call free_nh_exceptions() without holding the
> > fnhe_lock. I am wondering if that could cause some race condition on
> > fnhe->fnhe_rth_input/output so a double call on dst_dev_put() on the
> > same dst could be happening.
> >
> > But as we call free_fib_info_rcu() only after the grace period, and
> > the lookup code which could potentially modify
> > fnhe->fnhe_rth_input/output all holds rcu_read_lock(), it seems
> > fine...
> >
> 
> Hi Pawel,
> 
> Could you try the following debug patch on top of net-next branch and
> reproduce the issue check if there are warning msg showing?
> 
> diff --git a/include/net/dst.h b/include/net/dst.h
> index 93568bd0a352..82aff41c6f63 100644
> --- a/include/net/dst.h
> +++ b/include/net/dst.h
> @@ -271,7 +271,7 @@ static inline void dst_use_noref(struct dst_entry
> *dst, unsigned long time)
>  static inline struct dst_entry *dst_clone(struct dst_entry *dst)
>  {
>         if (dst)
> -               atomic_inc(&dst->__refcnt);
> +               dst_hold(dst);
>         return dst;
>  }
> 
> Thanks.
> Wei
> 


Yes, we believe skb_dst_force() and skb_dst_force_safe() should be
unified  (to the 'safe' version)

We no longer have gc to protect from 0 -> 1 transition of dst refcount.
