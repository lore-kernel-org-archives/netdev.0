From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [patch net-next v2 00/20] net: sched: convert cls ndo_setup_tc
 offload calls to per-block callbacks
Date: Tue, 24 Oct 2017 09:01:34 -0700
Message-ID: <CAKgT0Ud0RJLZ6mz9Ysb9A7PdkcwBYt2+ASvLZQxMGPK2BwvqKw@mail.gmail.com>
References: <20171019135048.4306-1-jiri@resnulli.us> <20171021.030446.967534081159629805.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>, mlxsw@mellanox.com,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Michael Chan <michael.chan@broadcom.com>,
        Ganesh Goudar <ganeshgr@chelsio.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>, idosch@mellanox.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Simon Horman <simon.horman@netronome.com>,
        pieter.jansenvanvuuren@netronome.com, john.hurley@netronome.
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:48601 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751683AbdJXQBf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 12:01:35 -0400
Received: by mail-qk0-f196.google.com with SMTP id d67so26909241qkg.5
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2017 09:01:35 -0700 (PDT)
In-Reply-To: <20171021.030446.967534081159629805.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 20, 2017 at 7:04 PM, David Miller <davem@davemloft.net> wrote:
> From: Jiri Pirko <jiri@resnulli.us>
> Date: Thu, 19 Oct 2017 15:50:28 +0200
>
>> This patchset is a bit bigger, but most of the patches are doing the
>> same changes in multiple classifiers and drivers. I could do some
>> squashes, but I think it is better split.
>>
>> This is another dependency on the way to shared block implementation.
>> The goal is to remove use of tp->q in classifiers code.
>>
>> Also, this provides drivers possibility to track binding of blocks to
>> qdiscs. Legacy drivers which do not support shared block offloading.
>> register one callback per binding. That maintains the current
>> functionality we have with ndo_setup_tc. Drivers which support block
>> sharing offload register one callback per block which safes overhead.
>>
>> Patches 1-4 introduce the binding notifications and per-block callbacks
>> Patches 5-8 add block callbacks calls to classifiers
>> Patches 9-17 do convert from ndo_setup_tc calls to block callbacks for
>>              classifier offloads in drivers
>> Patches 18-20 do cleanup
>
> Series applied.

We are getting internal reports of regressions being seen with this
patch set applied. Specifically the issues below have been pointed out
to me. My understanding is that these issues are all being reported on
ixgbe:

1.       To offload filter into HW, the hw-tc-offload feature flag has
to be turned on before creating the ingress qdisc.

Previously, this could also be turned on after the qdisc was created
and the filters could still be offloaded. Looks like this is because,
previously the offload flag was checked as a part of filter
integration in the classifier, and now it is checked as part of qdisc
creation (ingress_init). So, if no offload capability is advertised at
ingress qdisc creation time then hardware will not be asked to offload
filters later if the flag is enabled.

2.       Deleting the ingress qdisc fails to remove filters added in
HW. Filters in SW gets deleted.

We haven=E2=80=99t exactly root-caused this, the changes being extensive, b=
ut
our guess is again something wrong with the offload check or similar
while unregistering the block callback (tcf_block_cb_unregister) and
further to the classifier (CLS_U32/CLS_FLOWER etc.) with the
DESTROY/REMOVE command.

3.       Deleting u32 filters using handle fails to remove filter from
HW, filter in SW gets deleted.

Probably similar reasons, also we see some u32 specific patches as
well for remove nodes.

We are still digging into this further, but wanted to put this out
there so we can address the issues before we go much further down this
path.

Thanks.

- Alex
