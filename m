From: Shannon Nelson <shannon.nelson@intel.com>
Subject: Re: [RFC 1/2] net/ethtool: Add new coalescing parameter for queue
Date: Tue, 8 Dec 2015 10:02:55 -0800
Message-ID: <CAP-MU4OHMz8DaMwvF7=0ZgMCFdW0_85KH5O5ke55-X6Ox1Vw2Q@mail.gmail.com>
References: <1449549750-12448-1-git-send-email-kan.liang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	bwh@kernel.org, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	andi@firstfloor.org, f.fainelli@gmail.com,
	alexander.duyck@gmail.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	mitch.a.williams@intel.com, ogerlitz@mellanox.com,
	edumazet@google.com, jiri@mellanox.com, sfeldma@gmail.com,
	gospo@cumulusnetworks.com, sasha.levin@oracle.com,
	dsahern@gmail.com, tj@kernel.org, cascardo@redhat.com,
	corbet@lwn.net
To: kan.liang@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f194.google.com ([209.85.213.194]:36858 "EHLO
	mail-ig0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751351AbbLHSC4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 13:02:56 -0500
Received: by igcgq6 with SMTP id gq6so3052041igc.3
        for <netdev@vger.kernel.org>; Tue, 08 Dec 2015 10:02:55 -0800 (PST)
In-Reply-To: <1449549750-12448-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 7, 2015 at 8:42 PM,  <kan.liang@intel.com> wrote:
> From: Kan Liang <kan.liang@intel.com>
>
> Intrdouce "queue" option for coalesce getting and setting.

s/Intrdouce/Introduce/

> For coalesce getting, only the coalescing parameters from specific
> queue will be passed to user space.
> For coalesce setting, the coalescing parameters will only be applied to
> specific queue.
> If the queue is set to -1, the coalescing parameters will apply to all
> queues.
>
> Signed-off-by: Kan Liang <kan.liang@intel.com>
> ---
>  include/uapi/linux/ethtool.h | 2 ++
>  net/core/ethtool.c           | 6 ++++++
>  2 files changed, 8 insertions(+)
>
> diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
> index cd16291..f4fc18b 100644
> --- a/include/uapi/linux/ethtool.h
> +++ b/include/uapi/linux/ethtool.h
> @@ -384,6 +384,7 @@ struct ethtool_modinfo {
>   *     a TX interrupt, when the packet rate is above @pkt_rate_high.
>   * @rate_sample_interval: How often to do adaptive coalescing packet rate
>   *     sampling, measured in seconds.  Must not be zero.
> + * @queue: The specific queue which coalescing parameters apply to.
>   *
>   * Each pair of (usecs, max_frames) fields specifies that interrupts
>   * should be coalesced until
> @@ -434,6 +435,7 @@ struct ethtool_coalesce {
>         __u32   tx_coalesce_usecs_high;
>         __u32   tx_max_coalesced_frames_high;
>         __u32   rate_sample_interval;
> +       __s32   queue;
>  };
>
>  /**
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index 29edf74..fa8ab7a 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -1123,10 +1123,16 @@ static noinline_for_stack int ethtool_get_coalesce(struct net_device *dev,
>                                                    void __user *useraddr)
>  {
>         struct ethtool_coalesce coalesce = { .cmd = ETHTOOL_GCOALESCE };
> +       struct ethtool_coalesce tmp = { .queue = -1 };
>
>         if (!dev->ethtool_ops->get_coalesce)
>                 return -EOPNOTSUPP;
>
> +       if (copy_from_user(&tmp, useraddr, sizeof(coalesce)))
> +               return -EFAULT;
> +
> +       coalesce.queue = tmp.queue;
> +

Is this going to do what you expect when you have an older ethtool
program?  It seems to me that the older ethtool program will have the
original coalesce struct without the new queue field, so when you do
the copy_from_user(), you will get fewer bytes than what you asked
for, and the remaining bytes will get set to '0'.  I think this means
tmp.queue will be '0', not the default '-1', so the info returned will
always be for queue 0, not "all the queues".

For that matter, if you've set different coalesce values on various
queues, what does asking for '-1' or "all the queues" mean and how
should it return info? Shouldn't all the specific queues be shown?  Or
do we now have to do an ethtool command for each and every queue?

sln
