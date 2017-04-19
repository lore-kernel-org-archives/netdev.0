From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: net: heap out-of-bounds in
 fib6_clean_node/rt6_fill_node/fib6_age/fib6_prune_clone
Date: Wed, 19 Apr 2017 17:51:44 -0600
Message-ID: <1dad955e-28c1-3f02-8876-90cce4a7d1f8@cumulusnetworks.com>
References: <CACT4Y+YrA45diWz_8f4St8oX6aTC1kuGXMUvniGRbqXSGwawZQ@mail.gmail.com>
 <CACT4Y+YpUZ+7f5bzPh1hATwUXaZaPTu4rYYdz0RY1MHA1WG3SA@mail.gmail.com>
 <328b1fa7-2d97-6ae3-3b87-e33a0d564ad9@cumulusnetworks.com>
 <CACT4Y+aQFe+M=ESuShQ4FYNWAd8CNEQ=0rW+aAB0P-tp=PpFyQ@mail.gmail.com>
 <CACT4Y+aQgM=9QMkyfcXF2B5gGidvL07JP_m_inNXTPXU22i=aA@mail.gmail.com>
 <CACT4Y+Yx1cgWCkC2c7bze1V1VaecgBfioMvKS2-FUeaRr4DGXg@mail.gmail.com>
 <CACT4Y+bcMz13ad2kLaZGvct5sQ+RDki0StnOEbz3exAa8=zxqQ@mail.gmail.com>
 <CACT4Y+Z6f4aOxMZW44WXdYEyDJbGBYLnjKsHBXfK800h+EkrxA@mail.gmail.com>
 <2270c1ca-9481-60c1-9c29-87669223bded@cumulusnetworks.com>
 <CACT4Y+aUROZgAczRfntp5Rgvzcypviz5ZWBPdE6MWSiO0-3jEg@mail.gmail.com>
 <CAAeHK+zx6W_yxnoEQ2Pc1AT4uLXqYZaoi5oQBeuCntdGS38TQg@mail.gmail.com>
 <580392d8-fa33-67bb-c5d6-27d262f1646a@cumulusnetworks.com>
 <CAAeHK+zZb=K4X9=NmSWQJL8bpgMbXoG+h4RasAyYDr+C5pkVYA@mail.gmail.com>
 <CAM_iQpXyDN5GD+QLmWgJSc0bqV0ViK5LxSdwAV3XsHWr6vLJ2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Mahesh Bandewar <maheshb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Cong Wang <xiyou.wangcong@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:36037 "EHLO
        mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S968137AbdDSXvs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 19:51:48 -0400
Received: by mail-io0-f175.google.com with SMTP id o22so46515015iod.3
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 16:51:47 -0700 (PDT)
In-Reply-To: <CAM_iQpXyDN5GD+QLmWgJSc0bqV0ViK5LxSdwAV3XsHWr6vLJ2Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/19/17 5:47 PM, Cong Wang wrote:
> On Wed, Apr 19, 2017 at 9:12 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
>>
>> Anyway, I just finished simplifying the reproducer. Give this one a try.
> 
> Thanks for providing such a minimal reproducer!
> 
> The following patch could fix this crash, but I am not 100% sure if we should
> just clear these bits or reject them with an errno.
> 
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 9db14189..cf524c2 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -2086,7 +2086,7 @@ static struct rt6_info
> *ip6_route_info_create(struct fib6_config *cfg)
>         } else
>                 rt->rt6i_prefsrc.plen = 0;
> 
> -       rt->rt6i_flags = cfg->fc_flags;
> +       rt->rt6i_flags = cfg->fc_flags & ~(RTF_PCPU | RTF_CACHE);
> 
>  install_route:
>         rt->dst.dev = dev;
> 

I sent a patch returning EINVAL if RTF_PCPU is set in fc_flags
