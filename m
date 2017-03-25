From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 00/12] Mellanox mlx5e XDP performance optimization
Date: Sat, 25 Mar 2017 15:30:11 +0300
Message-ID: <CALzJLG_5yPXULm_n8cSdpcL8TZBFEZVpTEt7Dx7NQnUQYcGAJA@mail.gmail.com>
References: <20170324215214.25711-1-saeedm@mellanox.com> <420dc52e-8b39-a083-941e-d87eb941771a@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:36147 "EHLO
        mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751293AbdCYMad (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 25 Mar 2017 08:30:33 -0400
Received: by mail-qk0-f172.google.com with SMTP id p22so9771677qka.3
        for <netdev@vger.kernel.org>; Sat, 25 Mar 2017 05:30:32 -0700 (PDT)
In-Reply-To: <420dc52e-8b39-a083-941e-d87eb941771a@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 25, 2017 at 2:26 AM, Alexei Starovoitov <ast@fb.com> wrote:
> On 3/24/17 2:52 PM, Saeed Mahameed wrote:
>>
>> Hi Dave,
>>
>> This series provides some preformancee optimizations for mlx5e
>> driver, especially for XDP TX flows.
>>
>> 1st patch is a simple change of rmb to dma_rmb in CQE fetch routine
>> which shows a huge gain for both RX and TX packet rates.
>>
>> 2nd patch removes write combining logic from the driver TX handler
>> and simplifies the TX logic while improving TX CPU utilization.
>>
>> All other patches combined provide some refactoring to the driver TX
>> flows to allow some significant XDP TX improvements.
>>
>> More details and performance numbers per patch can be found in each patch
>> commit message compared to the preceding patch.
>>
>> Overall performance improvemnets
>>   System: Intel(R) Xeon(R) CPU E5-2620 v3 @ 2.40GHz
>>
>> Test case                   Baseline      Now      improvement
>> ---------------------------------------------------------------
>> TX packets (24 threads)     45Mpps        54Mpps      20%
>> TC stack Drop (1 core)      3.45Mpps      3.6Mpps     5%
>> XDP Drop      (1 core)      14Mpps        16.9Mpps    20%
>> XDP TX        (1 core)      10.4Mpps      13.7Mpps    31%
>
>
> Excellent work!
> All patches look great, so for the series:
> Acked-by: Alexei Starovoitov <ast@kernel.org>
>

Thanks Alexei !

> in patch 12 I noticed that inline_mode is being evaluated.
> I think for xdp queues it's guaranteed to be fixed.
> Can we optimize that path little bit more as well?

Yes, you are right, we do evaluate it in  mlx5e_alloc_xdpsq
+       if (sq->min_inline_mode != MLX5_INLINE_MODE_NONE) {
+               inline_hdr_sz = MLX5E_XDP_MIN_INLINE;
+               ds_cnt++;
+       }

and check it again in mlx5e_xmit_xdp_frame

+      /* copy the inline part if required */
+      if (sq->min_inline_mode != MLX5_INLINE_MODE_NONE) {

sq->min_inline_mode is fixed in run-time, but it is different across
HW versions.
This condition is needed so we would not copy inline headers and waste
CPU cycles while it is not required from ConnectX-5 and later.
Actually this is a 5% XDP_TX optimization you get when you run over
ConnectX-5 [1].

in ConnectX-4 and 4-LX driver is still required to copy L2 headers
into TX descriptor so the HW can make the loopback decision correctly
(needed in case you want XDP program to switch packets between
different PFs/VFs running on the same box/NIC).

So i don't see anyway to do this without breaking XDP loopback
functionality or removing the connectX-5 optimization.

for my taste this condition is good as is.

[1] https://www.spinics.net/lists/netdev/msg419215.html

> Thanks!
