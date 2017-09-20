From: Petar Penkov <peterpenkov96@gmail.com>
Subject: Re: [PATCH,net-next,0/2] Improve code coverage of syzkaller
Date: Tue, 19 Sep 2017 21:26:14 -0700
Message-ID: <CA+DcSEjDe=h5Kk2Bg0vCOatQj2Zs8wTAyVH+z5curg4O4c3=Hw@mail.gmail.com>
References: <20170919073402.2292-1-peterpenkov96@gmail.com> <20170919.160134.534837308168786965.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:38388 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750785AbdITE0Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 00:26:16 -0400
Received: by mail-it0-f68.google.com with SMTP id 85so816287ith.5
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 21:26:15 -0700 (PDT)
In-Reply-To: <20170919.160134.534837308168786965.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 19, 2017 at 4:01 PM, David Miller <davem@davemloft.net> wrote:
> From: Petar Penkov <peterpenkov96@gmail.com>
> Date: Tue, 19 Sep 2017 00:34:00 -0700
>
>> The following patches address this by providing the user(syzkaller)
>> with the ability to send via napi_gro_receive() and napi_gro_frags().
>> Additionally, syzkaller can specify how many fragments there are and
>> how much data per fragment there is. This is done by exploiting the
>> convenient structure of iovecs. Finally, this patch series adds
>> support for exercising the flow dissector during fuzzing.
>>
>> The code path including napi_gro_receive() can be enabled via the
>> CONFIG_TUN_NAPI compile-time flag, and can be used by users other than
>> syzkaller. The remainder of the changes in this patch series give the
>> user significantly more control over packets entering the kernel. To
>> avoid potential security vulnerabilities, hide the ability to send
>> custom skbs and the flow dissector code paths behind a run-time flag
>> IFF_NAPI_FRAGS that is advertised and accepted only if CONFIG_TUN_NAPI
>> is enabled.
>>
>> The patch series will be followed with changes to packetdrill, where
>> these additions to the TUN driver are exercised and demonstrated.
>> This will give the ability to write regression tests for specific
>> parts of the early networking stack.
>>
>> Patch 1/ Add NAPI struct per receive queue, enable NAPI, and use
>>        napi_gro_receive()
>> Patch 2/ Use NAPI skb and napi_gro_frags(), exercise flow
>>        dissector, and allow custom skbs.
>
> I'm happy with everything except the TUN_NAPI Kconfig knob
> requirement.
>
> Rebuilding something just to test things isn't going to fly very well.
>
> Please make it secure somehow, enable this stuff by default.
>
> Thanks.

Without a compile-time option, the TUN/TAP driver will have a
code-path that allows
user control over kernel memory allocation, and specifically over the
SKBs that enter
the kernel. That path might be hard to exploit as it requires some
user privileges,
but it does exist and increases attack surface of the kernel. While
the flag certainly
inconveniences testing, I think the layer of security it adds
outweighs its disadvantages.

Furthermore, in a way testing already requires specific kernel configuration.
In this particular example, syzkaller prefers synchronous operation
and therefore needs
4KSTACKS disabled. Other features that require rebuilding are KASAN
and dbx. From
this point of view, I still think that having the TUN_NAPI flag has value.
