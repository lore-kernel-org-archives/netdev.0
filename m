From: Dimitris Michailidis <dmichail@google.com>
Subject: Re: [PATCH] net: don't lose features in netdev_add_tso_features()
Date: Tue, 17 May 2016 14:31:40 -0700
Message-ID: <CAG76SjYT7UoUeG2uKchoYJS5A=L0wjrvfAWgmyxVR5AadO1WTA@mail.gmail.com>
References: <1463438015-19529-1-git-send-email-dmichail@google.com> <20160517.141025.306603458593770186.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f54.google.com ([209.85.213.54]:33561 "EHLO
	mail-vk0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751169AbcEQVbn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 17:31:43 -0400
Received: by mail-vk0-f54.google.com with SMTP id z184so37482710vkg.0
        for <netdev@vger.kernel.org>; Tue, 17 May 2016 14:31:42 -0700 (PDT)
In-Reply-To: <20160517.141025.306603458593770186.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 17, 2016 at 11:10 AM, David Miller <davem@davemloft.net> wrote:
> From: Dimitris Michailidis <dmichail@google.com>
> Date: Mon, 16 May 2016 15:33:35 -0700
>
>> The goal of netdev_add_tso_features() is to enable all TSO features but
>> it unintentionally loses NETIF_F_ALL_FOR_ALL features. This is because
>> the netdev_increment_features() it calls clears any NETIF_F_ALL_FOR_ALL
>> bits that aren't included in the incremental features and none of them
>> are included in NETIF_F_ALL_TSO. The behavior can be seen by enabling
>> tx-nocache-copy on the slaves and noticing the feature remains off at
>> the master.
>>
>> Fix this by including NETIF_F_ALL_FOR_ALL in the incremental features.
>>
>> Signed-off-by: Dave Platt <dplatt@google.com>
>> Signed-off-by: Dimitris Michailidis <dmichail@google.com>
>
> This doesn't look right to me at all.
>
> The second argument to netdev_increment_features, 'one', clearly
> states that all it is supposed to do is handle a new device being
> added which has the features mentioned in 'one'.  It makes no sense to
> arbitrarily add ALL_FOR_ALL in there, and if it is legitimate, why
> doesn't every other call site of netdev_increment_features have this
> same problem?
>
> If netdev_increment_features is doing something different either it's
> documentation is wrong or it's implementation is losing ALL_FOR_ALL
> bits erroneously.

This call to netdev_increment_features() is different from most others. Usually
netdev_increment_features() is called with features that belong to an
actual device,
with the goal of integrating that device's features into the overall
ones. In that case
we use whatever features the device has without augmenting them in any way.
If the device lacks some NETIF_F_ALL_FOR_ALL features
netdev_increment_features() rightfully turns them off in the result.

The call here is different. It is a convenience call to enable NETIF_F_ALL_TSO
bits in a netdev_features_t. netdev_increment_features(), still believing the
NETIF_F_ALL_TSO is coming from a device we are adding, does its usual clearing
of missing NETIF_F_ALL_FOR_ALL bits. But there's no device being added here
and the call doesn't intend to clear any existing bits.

I guess the issue arises from netdev_increment_features' purpose being to deal
with device additions, as its doc specifies, but it's not used for that here.
