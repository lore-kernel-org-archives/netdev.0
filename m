From: Jeff Barnhill <0xeffeff@gmail.com>
Subject: Re: v6/sit tunnels and VRFs
Date: Tue, 31 Oct 2017 18:20:10 -0400
Message-ID: <CAL6e_pfr5HRHHU9SiNKZ9dASxVLUBSHeShb_=nNd1Hbna5cR8w@mail.gmail.com>
References: <CAL6e_pdXJFoVVCfAOc9D_kE73juGQzjoUueEBvEMS=cq5CDKkg@mail.gmail.com>
 <fc420b5d-f179-a1fb-9cf5-ce1820870c83@gmail.com> <CAL6e_pdBDWBO796tfCnygj0e-c7S81O1y3hvZz3rgbMgxUobOg@mail.gmail.com>
 <9cade21c-5d92-d435-386f-6d854e6b6d55@gmail.com> <CAL6e_pc=Z03obL1U_+EY1t2EQ3Q7pmmcfU72tuO-hPzqqgPgig@mail.gmail.com>
 <aa76d6b7-dbb1-5275-09f6-a4450aeceeb2@gmail.com> <CAL6e_pfAtUAFRmm_2Ykn43jk-0mQn7f9FAt+CgHV4nFHT-PdPQ@mail.gmail.com>
 <609f2e30-3e9d-f317-e2b4-ba3fb7d20532@gmail.com> <CAL6e_pcL3DF1J1-+w0pw0CZ=Zm_BRfKtz=5jML_GcZBZFW1JVA@mail.gmail.com>
 <abb3291a-222a-7eff-724c-9d06fea9f02d@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:43347 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753635AbdJaWUM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 18:20:12 -0400
Received: by mail-oi0-f66.google.com with SMTP id c77so831243oig.0
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 15:20:11 -0700 (PDT)
In-Reply-To: <abb3291a-222a-7eff-724c-9d06fea9f02d@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks, David.  Those slides are extremely helpful.

Also, I ran into a bug that manifested on big endian architecture:

diff --git i/drivers/net/vrf.c w/drivers/net/vrf.c
index b23bb2fae5f8..a5f984689aee 100644
--- i/drivers/net/vrf.c
+++ w/drivers/net/vrf.c
@@ -1130,7 +1130,7 @@ static int vrf_fib_rule(const struct net_device
*dev, __u8 family, bool add_it)
        frh->family = family;
        frh->action = FR_ACT_TO_TBL;

-       if (nla_put_u32(skb, FRA_L3MDEV, 1))
+       if (nla_put_u8(skb, FRA_L3MDEV, 1))
                goto nla_put_failure;

        if (nla_put_u32(skb, FRA_PRIORITY, FIB_RULE_PREF))

I was surprised that nlmsg_parse in fib_nl_newrule() didn't pick this
up, but I verified that the received value for this attribute was 0,
not 1 (w/o the patch).

Jeff



On Sun, Oct 29, 2017 at 11:48 AM, David Ahern <dsahern@gmail.com> wrote:
> On 10/27/17 8:43 PM, Jeff Barnhill wrote:
>> ping v4 loopback...
>>
>> jeff@VM2:~$ ip route list vrf myvrf
>> 127.0.0.0/8 dev myvrf proto kernel scope link src 127.0.0.1
>> 192.168.200.0/24 via 192.168.210.3 dev enp0s8
>> 192.168.210.0/24 dev enp0s8 proto kernel scope link src 192.168.210.2
>>
>> Lookups shown in perf script were for table 255.  Is it necessary to
>> put the l3mdev table first?  If I re-order the tables, it starts
>> working:
>
> Yes, we advise moving the local table down to avoid false hits (e.g.,
> duplicate addresses like this between the default VRF and another VRF).
>
> I covered that and a few other things at OSS 2017. Latest VRF slides for
> users:
>   http://schd.ws/hosted_files/ossna2017/fe/vrf-tutorial-oss.pdf
