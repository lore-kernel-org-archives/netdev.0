From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next v3] packet: packet fanout rollover during socket overload
Date: Wed, 20 Mar 2013 02:37:59 -0400
Message-ID: <CA+FuTSeN1wXrSP8-piCdnv8MuqgokndSYsiidvdtC=d2tCqcDQ@mail.gmail.com>
References: <1363724291-27580-1-git-send-email-willemb@google.com>
 <1363725437.2558.22.camel@edumazet-glaptop> <20130319.171631.896160775901462168.davem@davemloft.net>
 <CA+FuTSeDd4Xjh0KsbdZscrkSMk_o_1y+w_t_N-7FM3GG4i+LzA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f170.google.com ([209.85.210.170]:49205 "EHLO
	mail-ia0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751747Ab3CTGia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 02:38:30 -0400
Received: by mail-ia0-f170.google.com with SMTP id h8so1146461iaa.1
        for <netdev@vger.kernel.org>; Tue, 19 Mar 2013 23:38:30 -0700 (PDT)
In-Reply-To: <CA+FuTSeDd4Xjh0KsbdZscrkSMk_o_1y+w_t_N-7FM3GG4i+LzA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 19, 2013 at 5:34 PM, Willem de Bruijn <willemb@google.com> wrote:
> On Tue, Mar 19, 2013 at 5:16 PM, David Miller <davem@davemloft.net> wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Tue, 19 Mar 2013 13:37:17 -0700
>>
>>> On Tue, 2013-03-19 at 16:18 -0400, Willem de Bruijn wrote:
>>>> Changes:
>>>>   v3->v2: rebase (no other changes)
>>>>           passes selftest
>>>>   v2->v1: read f->num_members only once
>>>>           fix bug: test rollover mode + flag
>>  ...
>>>> Signed-off-by: Willem de Bruijn <willemb@google.com>
>>  ...
>>> Reviewed-by: Eric Dumazet <edumazet@google.com>
>>
>> Applied, and I added the selftest too
>
> Thanks!
>
>>, but it fails for me on my
>> 128-cpu sparc64 machine:
>>
>> make[1]: Entering directory `/home/davem/src/GIT/net-next/tools/testing/selftests/net-afpacket'
>> --------------------
>> running psock_fanout test
>> --------------------
>> test: control single socket
>> test: control multiple sockets
>> test: datapath 0x0
>> info: count=0,0, expect=0,0
>> info: count=0,20, expect=15,5
>> ERROR: incorrect queue lengths
>
> I'm looking into it. The test needs the packet sockets to be able to
> hold an exact number of test packets and then overflow. Queue
> length configured in bytes (SO_RCVBUF) was arrived at by
> experimentation. My best hunch so far is that this differs between
> platforms/nic, if skb->truesize does. If queue length is the problem,
> I'll switch to a packet ring. Booting another machine right now.

I was able to reproduce this. The issue is not queue length, but an
rxhash collision. The test either passes or fails consistently between
reboots. Rebooting to get a different hashrnd seed may change the test
outcome.

Before finding this, I had already updated the patch to use a packet
ring (still better than the estimated queue length) and added
testcases for the LB and CPU modes. I may need to clean it up, but I
will send the current patch to see if it resolves the bug.


>> [FAIL]
