From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH][V3] e1000: avoid null pointer
 dereference on invalid stat type
Date: Fri, 22 Sep 2017 11:09:16 -0700
Message-ID: <CAKgT0Ucvfg_p=uMsDLe2DYA-KLcf+7WieOsOx4pP6R5pe8rm-Q@mail.gmail.com>
References: <20170922171348.17630-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Netdev <netdev@vger.kernel.org>, kernel-janitors@vger.kernel.org,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170922171348.17630-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 22, 2017 at 10:13 AM, Colin King <colin.king@canonical.com> wrote:
> From: Colin Ian King <colin.king@canonical.com>
>
> Currently if the stat type is invalid then data[i] is being set
> either by dereferencing a null pointer p, or it is reading from
> an incorrect previous location if we had a valid stat type
> previously.  Fix this by skipping over the read of p on an invalid
> stat type.
>
> Detected by CoverityScan, CID#113385 ("Explicit null dereferenced")
>
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Looks good to me.

Reviewed-by: Alexander Duyck <alexander.h.duyck@intel.com>

> ---
>  drivers/net/ethernet/intel/e1000/e1000_ethtool.c | 9 ++++-----
>  1 file changed, 4 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
> index ec8aa4562cc9..3b3983a1ffbb 100644
> --- a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
> +++ b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
> @@ -1824,11 +1824,12 @@ static void e1000_get_ethtool_stats(struct net_device *netdev,
>  {
>         struct e1000_adapter *adapter = netdev_priv(netdev);
>         int i;
> -       char *p = NULL;
>         const struct e1000_stats *stat = e1000_gstrings_stats;
>
>         e1000_update_stats(adapter);
> -       for (i = 0; i < E1000_GLOBAL_STATS_LEN; i++) {
> +       for (i = 0; i < E1000_GLOBAL_STATS_LEN; i++, stat++) {
> +               char *p;
> +
>                 switch (stat->type) {
>                 case NETDEV_STATS:
>                         p = (char *)netdev + stat->stat_offset;
> @@ -1839,15 +1840,13 @@ static void e1000_get_ethtool_stats(struct net_device *netdev,
>                 default:
>                         WARN_ONCE(1, "Invalid E1000 stat type: %u index %d\n",
>                                   stat->type, i);
> -                       break;
> +                       continue;
>                 }
>
>                 if (stat->sizeof_stat == sizeof(u64))
>                         data[i] = *(u64 *)p;
>                 else
>                         data[i] = *(u32 *)p;
> -
> -               stat++;
>         }
>  /* BUG_ON(i != E1000_STATS_LEN); */
>  }
> --
> 2.14.1
>
> _______________________________________________
> Intel-wired-lan mailing list
> Intel-wired-lan@osuosl.org
> https://lists.osuosl.org/mailman/listinfo/intel-wired-lan
