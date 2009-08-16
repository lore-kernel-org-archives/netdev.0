From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Revert netlink ABI change to gnet_stats_basic
Date: Sun, 16 Aug 2009 14:33:48 +0200
Message-ID: <4A87FCAC.5070705@gmail.com>
References: <1250002683-28554-1-git-send-email-mspang@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Michael Spang <mspang@csclub.uwaterloo.ca>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752079AbZHPMeG@vger.kernel.org>
In-Reply-To: <1250002683-28554-1-git-send-email-mspang@csclub.uwaterloo.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Spang a =E9crit :
> In 5e140dfc1fe87eae27846f193086724806b33c7d "net: reorder struct Qdis=
c
> for better SMP performance" the definition of struct gnet_stats_basic
> changed incompatibly, and as copies of this struct may be shipped to
> userland via netlink. This reverts back to the old ABI.

So userland expects to get exactly 16 bytes instead of 12 ?

iproute2 has no problem :

void print_tcstats2_attr(FILE *fp, struct rtattr *rta, char *prefix, st=
ruct rtattr **xstats)
{
        SPRINT_BUF(b1);
        struct rtattr *tbs[TCA_STATS_MAX + 1];

        parse_rtattr_nested(tbs, TCA_STATS_MAX, rta);

        if (tbs[TCA_STATS_BASIC]) {
                struct gnet_stats_basic bs =3D {0};
                memcpy(&bs, RTA_DATA(tbs[TCA_STATS_BASIC]), MIN(RTA_PAY=
LOAD(tbs[TCA_STATS_BASIC]), sizeof(bs)));
                fprintf(fp, "%sSent %llu bytes %u pkt",
                        prefix, (unsigned long long) bs.bytes, bs.packe=
ts);
        }


What exactly broke after patch was pushed ?

It would be better to fix gnet_stats_copy_basic() if necessary...


>=20
> Signed-off-by: Michael Spang <mspang@csclub.uwaterloo.ca>
> ---
>  include/linux/gen_stats.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/include/linux/gen_stats.h b/include/linux/gen_stats.h
> index 0ffa41d..13f4e74 100644
> --- a/include/linux/gen_stats.h
> +++ b/include/linux/gen_stats.h
> @@ -22,7 +22,7 @@ struct gnet_stats_basic
>  {
>  	__u64	bytes;
>  	__u32	packets;
> -} __attribute__ ((packed));
> +};
> =20
>  /**
>   * struct gnet_stats_rate_est - rate estimator
