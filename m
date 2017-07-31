From: Paul Moore <pmoore@redhat.com>
Subject: Re: [PATCH] Cipso: cipso_v4_optptr enter infinite loop
Date: Mon, 31 Jul 2017 16:13:57 -0400
Message-ID: <CAGH-KguiiVTyxHp0Z3Z==6b5n2h3Lm4SmU=ruydMpGgctdhYSw@mail.gmail.com>
References: <1501471381-12808-1-git-send-email-yujuan.qi@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Casey Schaufler <casey@schaufler-ca.com>,
        netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
        linux-kernel@vger.kernel.org, Ryder Lee <ryder.lee@mediatek.com>
To: Yujuan Qi <yujuan.qi@mediatek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1501471381-12808-1-git-send-email-yujuan.qi@mediatek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 30, 2017 at 11:23 PM, Yujuan Qi <yujuan.qi@mediatek.com> wrote:
> From: "yujuan.qi" <yujuan.qi@mediatek.com>
>
> in for(),if((optlen > 0) && (optptr[1] == 0)), enter infinite loop.
>
> Test: receive a packet which the ip length > 20 and the first byte of ip option is 0, produce this issue
>
> Signed-off-by: yujuan.qi <yujuan.qi@mediatek.com>
> ---
>  net/ipv4/cipso_ipv4.c | 12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)

Considering I gave you the code below I should probably ack it, right? ;)

Acked-by: Paul Moore <paul@paul-moore.com>

> diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
> index ae20616..0d1e07d 100644
> --- a/net/ipv4/cipso_ipv4.c
> +++ b/net/ipv4/cipso_ipv4.c
> @@ -1523,9 +1523,17 @@ unsigned char *cipso_v4_optptr(const struct sk_buff *skb)
>         int taglen;
>
>         for (optlen = iph->ihl*4 - sizeof(struct iphdr); optlen > 0; ) {
> -               if (optptr[0] == IPOPT_CIPSO)
> +               switch (optptr[0]) {
> +               case IPOPT_CIPSO:
>                         return optptr;
> -               taglen = optptr[1];
> +               case IPOPT_END:
> +                       return NULL;
> +               case IPOPT_NOOP:
> +                       taglen = 1;
> +                       break;
> +               default:
> +                       taglen = optptr[1];
> +               }
>                 optlen -= taglen;
>                 optptr += taglen;
>         }

-- 
paul moore
security @ redhat
