From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] [PATCH net] net: Do not hold the reference for the same sk_rx_dst.
Date: Thu, 16 Mar 2017 11:42:10 -0700
Message-ID: <CAM_iQpX3jZBAmJQ=9OsObJQdoXzWLODbJLfEsPMyw27Ap5Byzw@mail.gmail.com>
References: <1489651711-4105-1-git-send-email-kaiwen.xu@hulu.com>
 <87h92tv8uv.fsf@redhat.com> <242C9F89-8639-4C31-B3E5-B56C4F785E41@hulu.com>
 <87fuidv6ts.fsf@redhat.com> <20170316181839.GA61894@kevinmbp.test.hulu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jakub Sitnicki <jkbs@redhat.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Kaiwen Xu <kaiwen.xu@hulu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:35062 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753297AbdCPSmc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 14:42:32 -0400
Received: by mail-wm0-f51.google.com with SMTP id u132so42612732wmg.0
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 11:42:31 -0700 (PDT)
In-Reply-To: <20170316181839.GA61894@kevinmbp.test.hulu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 16, 2017 at 11:18 AM, Kaiwen Xu <kaiwen.xu@hulu.com> wrote:
> On Thu, Mar 16, 2017 at 11:45:03AM +0100, Jakub Sitnicki wrote:
>> On Thu, Mar 16, 2017 at 10:12 AM GMT, Kevin Xu wrote:
>> > Do you mean the message looping endlessly?
>>
>> No, the message is emitted just once. Around 100 seconds after
>> destroying a few namespaces. Occurs not so often, maybe once per ten
>> runs.
>>
>> -Jakub
>>
>
> I saw that happening from time to time during my test as well, I suspect
> it was because some TCP sockets stays in either TCP_TIME_WAIT or
> TCP_FIN_WAIT1. But eventually those sockets get destroyed and lo gets
> deleted as well.

But TIMEWAIT sockets are purged by inet_twsk_purge() during netns
destroy, apparently before lo is destroyed.

>
> The patch was fixing an issue I am seeing, that the message gets looped
> forever, and causing a deadlock on new network ns creation.
>

But as DaveM said, the race still could happen after your patch,
the if check you add is not atomic at all.

Also, we should already lock the sock at the time we call
inet_sk_rx_dst_set(), but perhaps not for TCP_LISTEN case...
