From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Re:Re: Re:Re: Re: [PATCH net] ppp: Fix a scheduling-while-atomic
 bug in del_chan
Date: Wed, 9 Aug 2017 14:00:19 -0700
Message-ID: <CAM_iQpWTfV00qcda75f1Oh3LcFt9w8kPsp3HHF18vjO9mv+Dbg@mail.gmail.com>
References: <1501495658-119725-1-git-send-email-gfree.wind@vip.163.com>
 <CAM_iQpVEsTpg17RZ1Y1jN2e0wb_X6gtxx05rmUSGa=A=XSj=Eg@mail.gmail.com>
 <CAM_iQpVta2EFVjutndCmoLBPWko7dgzP=Q1i2krPqyYuNBV4RA@mail.gmail.com>
 <31c9755c.ff6.15dba5238fc.Coremail.gfree.wind@vip.163.com>
 <CAM_iQpWmJmk=_yoV8=krOWonE_0orTC5Z4GaCnPg8Jv3GX6dmw@mail.gmail.com>
 <697dbbd.7911.15dbf5ca3a6.Coremail.gfree.wind@vip.163.com>
 <16ae6009.7a67.15dbf64b398.Coremail.gfree.wind@vip.163.com>
 <CAM_iQpW8W24=2atSyStwKPYJ9zmOO5XiznktT3V_3qn00R7r=Q@mail.gmail.com>
 <73e6ac77.45ea.15dc569d56a.Coremail.gfree.wind@vip.163.com> <1abb4a1f.6499.15dc5dae314.Coremail.gfree.wind@vip.163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: xeb@mail.ru, David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Gao Feng <gfree.wind@vip.163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f65.google.com ([209.85.213.65]:33929 "EHLO
        mail-vk0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752095AbdHIVAm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 17:00:42 -0400
Received: by mail-vk0-f65.google.com with SMTP id d124so4272123vkf.1
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 14:00:41 -0700 (PDT)
In-Reply-To: <1abb4a1f.6499.15dc5dae314.Coremail.gfree.wind@vip.163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 9, 2017 at 12:17 AM, Gao Feng <gfree.wind@vip.163.com> wrote:
> Hi Cong,
>
> Actually I have one question about the SOCK_RCU_FREE.
> I don't think it could resolve the issue you raised even though it exists really.
>
> I checked the SOCK_RCU_FREE, it just defer the __sk_destruct after one rcu period.
> But when it performs, someone still could find this sock by callid during the del_chan period and it may still deference the sock which may freed soon.
>
> The right flow should be following.
> del_chan()
> wait a rcu period
> sock_put() ------------ It is safe that someone gets the sock because it already hold sock refcnt.
>
> When using SOCK_RCU_FREE, its flow would be following.
> wait a rcu period
> del_chan()
> free the sock directly -------- no sock refcnt check again.
> Because the del_chan happens after rcu wait, not before, so it isn't helpful with SOCK_RCU_FREE.


Yes, good point! With SOCK_RCU_FREE the sock_hold() should
not be needed. For RCU, unpublish should indeed happen before
grace period.


>
> I don't know if I misunderstand the SOCK_RCU_FREE usage.
>
> But it is a good news that the del_chan is only invoked in pptp_release actually and it would wait a rcu period before sock_put.
>

Looking at the code again, the reader lookup_chan() is actually
invoked in BH context, but neither add_chan() nor del_chan()
actually disables BH...
