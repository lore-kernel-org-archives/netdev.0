From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v2] ethtool: check size of user memory before copying
 strings and stats
Date: Tue, 1 Mar 2016 14:31:40 -0800
Message-ID: <CAKgT0UdDQ0_HEhOQRew20V-MYKDDWbNZRZDFwNLz47cQX03dYg@mail.gmail.com>
References: <1456871112-14103-1-git-send-email-jacob.e.keller@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	=?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jeff Garzik <jeff@garzik.org>,
	Mark Rustad <mark.d.rustad@intel.com>
To: Jacob Keller <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:35660 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751371AbcCAWbl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 17:31:41 -0500
Received: by mail-io0-f177.google.com with SMTP id g203so239720494iof.2
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 14:31:41 -0800 (PST)
In-Reply-To: <1456871112-14103-1-git-send-email-jacob.e.keller@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 1, 2016 at 2:25 PM, Jacob Keller <jacob.e.keller@intel.com> wrote:
> Since at least 2005, (oldest commit in ethtool.git), the userspace
> ethtool implementation has given the size of the memory it has allocated
> as the actual size in the ethtool data structures. We previously blindly
> ignore this and overwrite the requested size with the current size
> returned by .get_strings or .get_sset_count. This can cause problems if
> these values aren't static.
>
> Since ethtool has always given the expected size, first perform a check
> to ensure that the current size is no larger than the requested size. If
> it is, return with -ENOMEM, as we do not have enough memory to save the
> results.
>
> This protects against buffer overrun should the driver have a non-static
> number of statistics, tests, or private flags, and the value changes
> between the ethtool userspace call to .get_sset_count and the actual
> calls to populate the requested memory.
>
> Update the header files to indicate the expected behavior of userspace.
> This change shouldn't break current or previous userspace as they have
> consistently included the length correctly since as far back as we can
> check.
>
> Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
> Reported-by: Alexander Duyck <alexander.duyck@gmail.com>
> ---
>
> - v2
> * use -ENOSPC instead of -ENOMEM at the suggestion of Mark Rustad

This still has the potential to provide garbage data.  What you should
probably do at each stage is make sure the length matches with the
exact value that you would expect.

I assume you cannot have any fields shuffle on you?  What I mean by
that is that you don't want to have a setup with 4 Tx and 4 Rx rings
where you then replace it with 1 Tx and 7 Rx rings and try to populate
the same data into a setup where the strings reported are for 4 Tx and
4 Rx.  You should double check that the length can be used as a means
of identifying exactly what strings will be where.

- Alex
