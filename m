From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC net-next] net: sch_clsact: add support for global per-netns
 classifier mode
Date: Tue, 5 Sep 2017 18:25:47 -0400
Message-ID: <87ec7558-5714-845f-82d8-7fe45f4c68ec@mojatatu.com>
References: <1504615701-20912-1-git-send-email-nikolay@cumulusnetworks.com>
 <CAM_iQpUYGH4BQ-ZUShbRAy6aJD2fYuM+oc_kWYyQ51n+===CQw@mail.gmail.com>
 <CAJieiUj_-o-Cg2AzN5b0vrdnBD69ryMmpu4fcC64-MHEmQ-u4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Ahern <dsa@cumulusnetworks.com>,
        Jiri Pirko <jiri@resnulli.us>
To: Roopa Prabhu <roopa@cumulusnetworks.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33509 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753789AbdIEWZu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 18:25:50 -0400
Received: by mail-it0-f66.google.com with SMTP id f64so787076itf.0
        for <netdev@vger.kernel.org>; Tue, 05 Sep 2017 15:25:49 -0700 (PDT)
In-Reply-To: <CAJieiUj_-o-Cg2AzN5b0vrdnBD69ryMmpu4fcC64-MHEmQ-u4g@mail.gmail.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-09-05 06:01 PM, Roopa Prabhu wrote:

> 
> yes, like Nikolay says we have been discussing this as well. Nikolay's
> patch is a cleaver and most importantly non-invasive
> way today given the anchor point for tc rules is a netdev. we have
> also considered a separate implicit tc anchor device.
>   lo seemed like a good fit for all global rules given it is already
> available. And it is not uncommon to hang off global
> network config on the loopback interface.
> 

IMO, Jiri has done all the necessary work already with the concept of
blocks. We dont really need the netdev to be the attachment point.

You can add to a block in many locations in the kernel by
constructing the proper "coordinates" in the tcmsg.
i.e this:
   tcmsg {
         unsigned char   tcm_family;
         unsigned char   tcm__pad1;
         unsigned short  tcm__pad2;
         int             tcm_ifindex;
         __u32           tcm_handle;
         __u32           tcm_parent;
}

If you were to set tcm_ifindex to -1 (since that is not a legit
ifindex) then all we need to do is define a parent for a
different location. Current locations tied to netdevs are:
-----
#define TC_H_ROOT       (0xFFFFFFFFU)
#define TC_H_INGRESS    (0xFFFFFFF1U)
#define TC_H_CLSACT     TC_H_INGRESS

#define TC_H_MIN_INGRESS        0xFFF2U
#define TC_H_MIN_EGRESS         0xFFF3U
-----

You should be able to say add a location which maps to a pre-routing
or post-routing etc; and this would work as well...

cheers,
jamal
