From: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>
Subject: Re: [PATCH net] tg3: Avoid NULL pointer dereference in
 tg3_io_error_detected()
Date: Tue, 27 Sep 2016 18:27:17 -0300
Message-ID: <57EAE435.4000905@linux.vnet.ibm.com>
References: <1475006728-15307-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
 <CACKFLi=MVovAMnZwTe3Swb1+hgy+h9CfTURPVrZsM0MJGV9Khw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Siva Reddy Kallam <siva.kallam@broadcom.com>,
        Prashant Sreedharan <prashant@broadcom.com>,
        Michael Chan <mchan@broadcom.com>,
        Netdev <netdev@vger.kernel.org>,
        Milton Miller <miltonm@us.ibm.com>
To: Michael Chan <michael.chan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:49729 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752240AbcI0V11 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 17:27:27 -0400
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8RLMWYT110678
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 17:27:27 -0400
Received: from e24smtp05.br.ibm.com (e24smtp05.br.ibm.com [32.104.18.26])
        by mx0a-001b2d01.pphosted.com with ESMTP id 25qt3f39ge-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 17:27:26 -0400
Received: from localhost
        by e24smtp05.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gpiccoli@linux.vnet.ibm.com>;
        Tue, 27 Sep 2016 18:27:24 -0300
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
        by d24dlp02.br.ibm.com (Postfix) with ESMTP id 1CFE21DC0070
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 17:27:22 -0400 (EDT)
Received: from d24av02.br.ibm.com (d24av02.br.ibm.com [9.8.31.93])
        by d24relay01.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u8RLRMSI5193980
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 18:27:22 -0300
Received: from d24av02.br.ibm.com (localhost [127.0.0.1])
        by d24av02.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u8RLRL7u027485
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 18:27:21 -0300
In-Reply-To: <CACKFLi=MVovAMnZwTe3Swb1+hgy+h9CfTURPVrZsM0MJGV9Khw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/27/2016 05:58 PM, Michael Chan wrote:
> On Tue, Sep 27, 2016 at 1:05 PM, Guilherme G. Piccoli
> <gpiccoli@linux.vnet.ibm.com> wrote:
>> From: Milton Miller <miltonm@us.ibm.com>
>>
>> While the driver is probing the adapter, an error may occur before the
>> netdev structure is allocated and attached to pci_dev. In this case,
>> not only netdev isn't available, but the tg3 private structure is also
>> not available as it is just math from the NULL pointer, so dereferences
>> must be skipped.
>>
>> The following trace is seen when the error is triggered:
>>
>>    [1.402247] Unable to handle kernel paging request for data at address 0x00001a99
>>    [1.402410] Faulting instruction address: 0xc0000000007e33f8
>>    [1.402450] Oops: Kernel access of bad area, sig: 11 [#1]
>>    [1.402481] SMP NR_CPUS=2048 NUMA PowerNV
>>    [1.402513] Modules linked in:
>>    [1.402545] CPU: 0 PID: 651 Comm: eehd Not tainted 4.4.0-36-generic #55-Ubuntu
>>    [1.402591] task: c000001fe4e42a20 ti: c000001fe4e88000 task.ti: c000001fe4e88000
>>    [1.402742] NIP: c0000000007e33f8 LR: c0000000007e3164 CTR: c000000000595ea0
>>    [1.402787] REGS: c000001fe4e8b790 TRAP: 0300   Not tainted  (4.4.0-36-generic)
>>    [1.402832] MSR: 9000000100009033 <SF,HV,EE,ME,IR,DR,RI,LE>  CR: 28000422  XER: 20000000
>>    [1.403058] CFAR: c000000000008468 DAR: 0000000000001a99 DSISR: 42000000 SOFTE: 1
>>    GPR00: c0000000007e3164 c000001fe4e8ba10 c0000000015c5e00 0000000000000000
>>    GPR04: 0000000000000001 0000000000000000 0000000000000039 0000000000000299
>>    GPR08: 0000000000000000 0000000000000001 c000001fe4e88000 0000000000000006
>>    GPR12: 0000000000000000 c00000000fb40000 c0000000000e6558 c000003ca1bffd00
>>    GPR16: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
>>    GPR20: 0000000000000000 0000000000000000 0000000000000000 c000000000d52768
>>    GPR24: c000000000d52740 0000000000000100 c000003ca1b52000 0000000000000002
>>    GPR28: 0000000000000900 0000000000000000 c00000000152a0c0 c000003ca1b52000
>>    [1.404226] NIP [c0000000007e33f8] tg3_io_error_detected+0x308/0x340
>>    [1.404265] LR [c0000000007e3164] tg3_io_error_detected+0x74/0x340
>>
>> This patch avoids the NULL pointer dereference by moving the access after
>> the netdev NULL pointer check on tg3_io_error_detected().
>>
>> Fixes: 0486a063b1ff ("tg3: prevent ifup/ifdown during PCI error recovery")
>> Fixes: dfc8f370316b ("net/tg3: Release IRQs on permanent error")
>> Tested-by: Guilherme G. Piccoli <gpiccoli@linux.vnet.ibm.com>
>> Signed-off-by: Milton Miller <miltonm@us.ibm.com>
>> Signed-off-by: Guilherme G. Piccoli <gpiccoli@linux.vnet.ibm.com>
>
> Looks good.  Do we need to add !netdev check in tg3_io_resume()?

Thanks Michael. It's a good point - I didn't trigger any error without 
the check, but looking at error handlers, every one seems to have this 
check except tg3_io_resume().

Do you want us to send a v2 including this check? Or maybe another patch?

Cheers,



Guilherme
