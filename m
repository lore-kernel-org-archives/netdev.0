From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 0/4] mlx5: Create build configuration options
Date: Sat, 28 Jan 2017 09:19:06 -0800
Message-ID: <CALx6S34_k+uaCZAOR8=pOzisaQ0eryyZX=ABxk+Pnwx-vrj0VQ@mail.gmail.com>
References: <20170126233241.2268449-1-tom@herbertland.com> <CALzJLG9QpKfA3eDgQkz5MF0FFgkL91BditedDRZkOxx-ayGQSQ@mail.gmail.com>
 <CALx6S355U1g+OyEM9mC12TRtYZqwOciT=+OpsKXPwkuX-Xq0LQ@mail.gmail.com> <CALzJLG8dh0TZPotrk-Xp6SZ=2UnjY2-C3TEQNxXDER5H8iwiQw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:33073 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751171AbdA1RTh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Jan 2017 12:19:37 -0500
Received: by mail-qk0-f195.google.com with SMTP id 11so13157401qkl.0
        for <netdev@vger.kernel.org>; Sat, 28 Jan 2017 09:19:07 -0800 (PST)
In-Reply-To: <CALzJLG8dh0TZPotrk-Xp6SZ=2UnjY2-C3TEQNxXDER5H8iwiQw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 28, 2017 at 3:38 AM, Saeed Mahameed
<saeedm@dev.mellanox.co.il> wrote:
> On Fri, Jan 27, 2017 at 8:13 PM, Tom Herbert <tom@herbertland.com> wrote:
>> On Fri, Jan 27, 2017 at 9:58 AM, Saeed Mahameed
>> <saeedm@dev.mellanox.co.il> wrote:
>>> On Fri, Jan 27, 2017 at 1:32 AM, Tom Herbert <tom@herbertland.com> wrote:
>>>> This patchset creates configuration options for sriov, vxlan, eswitch,
>>>> and tc features in the mlx5 driver. The purpose of this is to allow not
>>>> building these features. These features are optional advanced features
>>>> that are not required for a core Ethernet driver. A user can disable
>>>> these features which resuces the amount of code in the driver. Disabling
>>>> these features (and DCB) reduces the size of mlx5_core.o by about 16%.
>>>> This is also can reduce the complexity of backport and rebases since
>>>> user would no longer need to worry about dependencies with the rest of
>>>> the kernel that features which might not be of any interest to a user
>>>> may bring in.
>>>>
>>>> Tested: Build and ran the driver with all features enabled (the default)
>>>> and with none enabled (including DCB). Did not see any issues. I did
>>>> not explicity test operation of ayy of features in the list.
>>>>
>>>
>>> Basically I am not against this kind of change, infact i am with it,
>>> although I would have done some restructuring in the driver before i
>>> did such change ;), filling the code with ifdefs is not a neat thing.
>>>
>> If you wish, please take this as an RFC and feel free to structure the
>> code the right way. I think the intent is clear enough and looks like
>> davem isn't going to allow the directory restructuring so something
>> like this seems to be the best course of action now.
>>
>
> Right.
>
>>> I agree this will simplify backporting and provide some kind of
>>> feature separation inside the driver.
>>> But this will also increase the testing matrix we need to cover and
>>> increase the likelihood of kbuild breaks by an order of magnitude.
>>>
>> The testing matrix already exploded with the proliferation of
>> supported features. If anything this reduces the test matrix problem.
>> For instance, if we make a change to the core driver and functionality
>> properly isolated there is a much better chance that this won't affect
>> peripheral functionality and vice versa. It is just not feasible for
>> us to test every combination of NIC features for every change being
>> made.
>>
>
> Yes for isolated features, but for base functionality, we need to test
> it with all new device specific kconfig combinations on every patch!

Sorry, but that is the price you need to pay for a feature rich device.

On the subject of testing, I don't really see any indication in these
patches on how patches are being tested. Also, there are patches that
fix things without any mention of how to repro the problems. It is
critical that we know IPv6 is tested as much or more than IPv4 (just
last week with hit yet another IPv6-only issue in an another upstream
driver that should have been caught with a simple load test-- this
really is not acceptable any more!). Please add a description of how
patches were tested to commit logs.

Tom

> since a misplaced code inside or outside the correct ifdef
> can easily go unnoticed and break functionality.
>
>>> One more thing, do we really need a device specific flag per feature
>>> per vendor per device?  can't we just use the same kconfig flag for
>>> all drivers and if there is a more generic system wide flag that
>>> covers the same feature
>>> can't we just use it, for instance instead of
>>> CONFIG_<DRIVER_NAME>_SRIOV why not use already existing CONFIG_PCI_IOV
>>> for all drivers ?
>>>
>> That sounds good to me. We already have CONFIG_RFS_ACCEL and others
>> that do that.
>>
>> Tom
>>
>>> Saeed.
>>>
>>>>
>>>>
>>>> Tom Herbert (4):
>>>>   mlx5: Make building eswitch configurable
>>>>   mlx5: Make building SR-IOV configurable
>>>>   mlx5: Make building tc hardware offload configurable
>>>>   mlx5: Make building vxlan hardware offload configurable
>>>>
>>>>  drivers/net/ethernet/mellanox/mlx5/core/Kconfig   |  35 ++++++
>>>>  drivers/net/ethernet/mellanox/mlx5/core/Makefile  |  16 ++-
>>>>  drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 129 ++++++++++++++++------
>>>>  drivers/net/ethernet/mellanox/mlx5/core/en_tc.c   |  39 +++++--
>>>>  drivers/net/ethernet/mellanox/mlx5/core/eq.c      |   4 +-
>>>>  drivers/net/ethernet/mellanox/mlx5/core/lag.c     |   2 +
>>>>  drivers/net/ethernet/mellanox/mlx5/core/main.c    |  32 ++++--
>>>>  drivers/net/ethernet/mellanox/mlx5/core/sriov.c   |   6 +-
>>>>  8 files changed, 205 insertions(+), 58 deletions(-)
>>>>
>>>> --
>>>> 2.9.3
>>>>
