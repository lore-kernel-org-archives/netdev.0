From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net-next 05/10] bnxt_en: Fix ethtool -l|-L inconsistent
 channel counts.
Date: Mon, 19 Sep 2016 02:40:45 -0700
Message-ID: <CACKFLi=H2dnv4hVi4hGCZC4LJabr4SK3f=z5+JzJE7y9jEMvMw@mail.gmail.com>
References: <1474271889-8229-1-git-send-email-michael.chan@broadcom.com>
 <1474271889-8229-6-git-send-email-michael.chan@broadcom.com>
 <BL2PR07MB23060109CAF0760E41A8BB288DF40@BL2PR07MB2306.namprd07.prod.outlook.com>
 <CACKFLikfTZYpmULGD5FvzixFRiCjqvQZxUKKquaaQ5qe9-PxuA@mail.gmail.com> <BL2PR07MB23063DF1E02AA72ABE37DB4B8DF40@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:33384 "EHLO
        mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751277AbcISJkr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 05:40:47 -0400
Received: by mail-oi0-f52.google.com with SMTP id r126so188856110oib.0
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 02:40:46 -0700 (PDT)
In-Reply-To: <BL2PR07MB23063DF1E02AA72ABE37DB4B8DF40@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 19, 2016 at 2:21 AM, Mintz, Yuval <Yuval.Mintz@cavium.com> wrote:
>> >> The existing code is inconsistent in reporting and accepting the
>> >> combined channel count.  bnxt_get_channels() reports maximum combined
>> >> as the maximum rx count.  bnxt_set_channels() accepts combined count
>> >> that cannot be bigger than max rx or max tx.
>> >>
>> >> For example, if max rx = 2 and max tx = 1, we report max supported
>> >> combined to be 2.  But if the user tries to set combined to 2, it
>> >> will fail because 2 is bigger than max tx which is 1.
>> >>
>> >> Fix the code to be consistent.  Max allowed combined = max(max_rx,
>> max_tx).
>> >> We will accept a combined channel count <= max(max_rx, max_tx).
>> >
>> > Don't you mean the 'max allowed combined = min(max_rx, max_tx)'.
>> > How does using 'max' change the faulty scenario you've described?
>>
>> I'm fixing the inconsistency described in the first 2 paragraphs.  The driver logic
>> allows a combined ring to be rx or tx only.  In the above example, we allow
>> combined to be set to 2.  The 2nd combined ring supports rx only.
>
> Then what makes it a combined channel?
> Sounds to me like in the above scenario you should have claimed support for:
>   - max rx == 2
>   - max tx == 1
>   - max combined == 1

Our implementation will report:

max rx 2
max tx 1
max combined 2

If the user chooses 2 rx and 1 tx, he will use 3 msix vectors (3
completion rings, etc).  If the user chooses 2 combined (1 with rx/tx,
1 with rx only), he will use 2 msix vectors (2 completion rings, etc).
With a large number of NPAR functions and SRIOV functions, the number
of rings available per function may not be symmetrical.  We just want
maximum flexibility to make use of all available resources in 2
different modes (one that uses more resources and one that uses less).
