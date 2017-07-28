From: Paul Moore <pmoore@redhat.com>
Subject: Re: [PATCH] Cipso: cipso_v4_optptr enter infinite loop
Date: Fri, 28 Jul 2017 11:12:43 -0400
Message-ID: <CAGH-KgtXtM1q2h8k--Gi7buYfdXsuXh1ZbJcSF_eL71kPdfBPA@mail.gmail.com>
References: <1501241408-19129-1-git-send-email-yujuan.qi@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Casey Schaufler <casey@schaufler-ca.com>,
        netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
        linux-kernel@vger.kernel.org, Ryder Lee <ryder.lee@mediatek.com>
To: Yujuan Qi <yujuan.qi@mediatek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1501241408-19129-1-git-send-email-yujuan.qi@mediatek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 28, 2017 at 7:30 AM, Yujuan Qi <yujuan.qi@mediatek.com> wrote:
> From: "yujuan.qi" <yujuan.qi@mediatek.com>
>
> in for(),if((optlen > 0) && (optptr[1] == 0)), enter infinite loop.
>
> Test: receive a packet which the ip length > 20 and the first byte of ip option is 0, produce this issue
>
> Signed-off-by: yujuan.qi <yujuan.qi@mediatek.com>
> ---
>  net/ipv4/cipso_ipv4.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
> index ae20616..b3d97c7 100644
> --- a/net/ipv4/cipso_ipv4.c
> +++ b/net/ipv4/cipso_ipv4.c
> @@ -1528,6 +1528,8 @@ unsigned char *cipso_v4_optptr(const struct sk_buff *skb)
>                 taglen = optptr[1];
>                 optlen -= taglen;
>                 optptr += taglen;
> +               if (!taglen)
> +                       break;
>         }
>
>         return NULL;

Thanks for catching this and submitting a patch.  Unfortunately
checking taglen/optptr[1] isn't going to help with the NOP and EOL
options as they are single byte options.  I think a for-loop like the
following, or something similar, is probably the better solution:

  for (optlen = iph->ihl*4 - sizeof(struct iphdr); optlen > 0; ) {
         switch (optptr[0]) {
         case IPOPT_CIPSO:
                 return optptr;
         case IPOPT_END:
                 return NULL;
         case IPOPT_NOOP:
                 taglen = 1;
                 break;
         default:
                 taglen = optptr[1];
         }
         optlen -= taglen;
         optptr += taglen;
  }

-- 
paul moore
security @ redhat
