From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net] ipv4: add reference counting to metrics
Date: Fri, 26 May 2017 10:13:00 -0700
Message-ID: <CANn89i+_TqFHa9dNFFSbe6msYaWyWr7RfN7_LURs+XL9gd94Pw@mail.gmail.com>
References: <1493934857-6693-1-git-send-email-xiyou.wangcong@gmail.com>
 <1494370451.7796.93.camel@edumazet-glaptop3.roam.corp.google.com>
 <1494371348.7796.95.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpU+fXO7eFroAYMv6vqDzCK_ZYXjrTPAMfoDR2BDqaK9rQ@mail.gmail.com>
 <alpine.LFD.2.20.1705100937330.1938@ja.home.ssi.bg> <CAM_iQpX22qTqo4yfM_Je1bvJHxjAGK_tvm5KgQSnJzsYq7K55Q@mail.gmail.com>
 <alpine.LFD.2.20.1705102141320.1928@ja.home.ssi.bg> <CAM_iQpW0fJJXPS=FoTf-o4f5-mOC=mZYNP8=uqiUOmvX+CDwWw@mail.gmail.com>
 <CAM_iQpWxDKHF4N1xor7qj+5s91GrctgcGnzN0buw18qs7__-gQ@mail.gmail.com>
 <alpine.LFD.2.20.1705120659370.1811@ja.home.ssi.bg> <CAM_iQpVQSMd_LYMqm3EauRRgJhfkW=zsdvKRf4-YcGWwSufuvQ@mail.gmail.com>
 <alpine.LFD.2.20.1705122151001.2835@ja.home.ssi.bg> <CAM_iQpXtWUZoGS_KEqfZc+ZbzYxaF1hbAV7H9Qd82=r4auJojw@mail.gmail.com>
 <alpine.LFD.2.20.1705152317090.4002@ja.home.ssi.bg> <CAM_iQpWAjTJL54h_Pdg3DigjEK4kQdSz0pmAks6ByoP67ROOFg@mail.gmail.com>
 <alpine.LFD.2.20.1705160955310.1856@ja.home.ssi.bg> <CAM_iQpVuqBkQxq=g4n5t33Gv0mxR_S0iOtQxgBHKceam8pmwfQ@mail.gmail.com>
 <CAM_iQpVBKjwqmU1p-xLYwy=032fewdCfDetaSxC+aQoE=dgMfQ@mail.gmail.com>
 <1495572267.6465.79.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpX0X3h4Sf+bHUXdJgBqUTxNat0FBT0PeRpLYWju9ci59Q@mail.gmail.com>
 <CANn89i+mPR+7-AVO2Dsd=KfO=COOVY42AKjwEs=0=GUCML6HUQ@mail.gmail.com>
 <CAM_iQpUfLmN3yWsCfpx4ZTptBnuYFNuY5CjBKdwoDpvH5K8P=w@mail.gmail.com>
 <1495665921.6465.95.camel@edumazet-glaptop3.roam.corp.google.com>
 <1495747655.6465.113.camel@edumazet-glaptop3.roam.corp.google.com> <CAM_iQpWDnNz5u9Jtk0MAywNs=N4F8ogvT3bRji3vYj1Tfk830g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        Andrey Konovalov <andreyknvl@google.com>,
        Julian Anastasov <ja@ssi.bg>, netdev <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f175.google.com ([209.85.161.175]:36530 "EHLO
        mail-yw0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752409AbdEZRNB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 13:13:01 -0400
Received: by mail-yw0-f175.google.com with SMTP id b68so7399508ywe.3
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 10:13:01 -0700 (PDT)
In-Reply-To: <CAM_iQpWDnNz5u9Jtk0MAywNs=N4F8ogvT3bRji3vYj1Tfk830g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 26, 2017 at 10:08 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Thu, May 25, 2017 at 2:27 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Just one nit below.
>
>> -const u32 dst_default_metrics[RTAX_MAX + 1] = {
>> +const struct dst_metrics dst_default_metrics = {
>>         /* This initializer is needed to force linker to place this variable
>>          * into const section. Otherwise it might end into bss section.
>>          * We really want to avoid false sharing on this variable, and catch
>>          * any writes on it.
>>          */
>> -       [RTAX_MAX] = 0xdeadbeef,
>> +       .refcnt = ATOMIC_INIT(1),
>>  };
>
> The code comment above is no longer needed since
> we have to initialize refcnt to 1, instead of merely for const
> section.

I believe the comment is still needed, because normally we make sure
dst_default_metrics.refcnt is never touched (incremened nor
decremented)

So its value should not really matter ?

I found that ATOMIC_INIT(1) was less ugly than the 0xdeadbeef
