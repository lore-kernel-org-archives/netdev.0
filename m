From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next V1 09/10] net/mlx5: Fix global UAR mapping
Date: Mon, 29 Feb 2016 21:41:27 +0200
Message-ID: <CALzJLG-bMd-0CiLHrACCV++ESnKMm8Hke4-C1rS88yPf4oB0hQ@mail.gmail.com>
References: <1456672151-11749-1-git-send-email-saeedm@mellanox.com>
	<1456672151-11749-10-git-send-email-saeedm@mellanox.com>
	<20160228.232804.1263072658789063316.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>, moshel@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f196.google.com ([209.85.161.196]:35364 "EHLO
	mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752142AbcB2Tlw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 14:41:52 -0500
Received: by mail-yw0-f196.google.com with SMTP id u200so8205676ywf.2
        for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 11:41:27 -0800 (PST)
In-Reply-To: <20160228.232804.1263072658789063316.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> Well anyone can see that from the code.
>
> You have to explain why.

In a simple words as partially explained in the commit message we want
to have both mappings (NC and WC) available so upper layer can decide
which to choose e.g. for SQs/QPs in some cases (Small Packets) and
only when WC is supported we would like to write TX descriptors (WQEs)
using ConnectX BlueFlame feature via WC mapping and if WC is not
supported the TX descriptors would be posted in the usual way
(doorbell) via NC mapping.
this would give a latency boost for small packets.

The problem is when posting BlueFlame buffers when the mapping is not
WC i.e via NC mapping the latency will get worst than writing using
the usual way (doorbell).

so this is why we use ARCH_HAS_IOREMAP_WC to give a hint to upper
layer whether to use BlueFlame writes (WC) or doorbell writes (NC).

>
> And BTW, ARCH_HAS_IOREMAP_WC doesn't even tell you if the platform
> will actually give you a write-combining mapping.

We did some research after your comment and we are considering
removing ARCH_HAS_IOREMAP_WC from the code, we will update the patches
soon.

>
> So if it's the driver operates properly if a non-WC mapping is used
> for uar->bf_map, then get rid of this CPP test altogether PLEASE!
>
> Otherwise your driver is buggy, because ARCH_HAS_IOREMAP_WC only says
> whether the default implementation of ioremap_wc() needs to be
> provided by include/asm-generic/iomap.h It does not guarantee that a
> write-combining mapping will be provided.
>
> I really can't think of any reason why you absolutely require a
> WC mapping, and the CPP test just makes your driver look more
> ugly than it needs to me.

WC mapping is required in order to know if BlueFlame writes would give
a better latency or not.

>
> So can you please explain what the hell is happening here and why you
> are doing things this way rather than just reading the code to me?

I hope the above explains what we are trying to do here, I know it is
not perfect, but as you know the kernel IO mapping API doesn't tell if
the WC mapping was successful or not, so we used the CPP test.
but after your comment we understood it is not perfect, and we are
looking into it.

Thanks
