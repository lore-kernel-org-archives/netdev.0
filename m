From: Luiz Augusto von Dentz <luiz.dentz@gmail.com>
Subject: Re: [PATCH] bluetooth: 6lowpan: fix use after free in chan_suspend/resume
Date: Fri, 31 Mar 2017 11:33:37 +0300
Message-ID: <CABBYNZ+=W6kvxrmaTWktNTtc76hoDgYuZOK9QF5QNd+5+MSjNA@mail.gmail.com>
References: <20170329061018.4243-1-michael.scott@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Marcel Holtmann <marcel@holtmann.org>,
        Gustavo Padovan <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Jukka Rissanen <jukka.rissanen@linux.intel.com>,
        "linux-bluetooth@vger.kernel.org" <linux-bluetooth@vger.kernel.org>,
        linux-wpan@vger.kernel.org,
        "open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Michael Scott <michael.scott@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170329061018.4243-1-michael.scott@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Michael,

On Wed, Mar 29, 2017 at 9:10 AM, Michael Scott <michael.scott@linaro.org> wrote:
> A status field in the skb_cb struct was storing a channel status
> based on channel suspend/resume events.  This stored status was
> then used to return EAGAIN if there were packet sending issues
> in snd_pkt().
>
> The issue is that the skb has been freed by the time the callback
> to 6lowpan's suspend/resume was called.  So, this generates a
> "use after free" issue that was noticed while running kernel tests
> with KASAN debug enabled.
>
> Let's eliminate the status field entirely as we can use the channel
> tx_credits to indicate whether we should return EAGAIN when handling
> packets.
>
> Signed-off-by: Michael Scott <michael.scott@linaro.org>
> ---
>  net/bluetooth/6lowpan.c | 21 +++------------------
>  1 file changed, 3 insertions(+), 18 deletions(-)
>
> diff --git a/net/bluetooth/6lowpan.c b/net/bluetooth/6lowpan.c
> index d491529332f4..e27be3ca0a0c 100644
> --- a/net/bluetooth/6lowpan.c
> +++ b/net/bluetooth/6lowpan.c
> @@ -38,7 +38,6 @@ struct skb_cb {
>         struct in6_addr addr;
>         struct in6_addr gw;
>         struct l2cap_chan *chan;
> -       int status;
>  };
>  #define lowpan_cb(skb) ((struct skb_cb *)((skb)->cb))
>
> @@ -528,7 +527,7 @@ static int send_pkt(struct l2cap_chan *chan, struct sk_buff *skb,
>         }
>
>         if (!err)
> -               err = lowpan_cb(skb)->status;
> +               err = (!chan->tx_credits ? -EAGAIN : 0);
>
>         if (err < 0) {
>                 if (err == -EAGAIN)
> @@ -964,26 +963,12 @@ static struct sk_buff *chan_alloc_skb_cb(struct l2cap_chan *chan,
>
>  static void chan_suspend_cb(struct l2cap_chan *chan)
>  {
> -       struct sk_buff *skb = chan->data;
> -
> -       BT_DBG("chan %p conn %p skb %p", chan, chan->conn, skb);
> -
> -       if (!skb)
> -               return;
> -
> -       lowpan_cb(skb)->status = -EAGAIN;
> +       BT_DBG("chan %p suspend", chan);
>  }
>
>  static void chan_resume_cb(struct l2cap_chan *chan)
>  {
> -       struct sk_buff *skb = chan->data;
> -
> -       BT_DBG("chan %p conn %p skb %p", chan, chan->conn, skb);
> -
> -       if (!skb)
> -               return;
> -
> -       lowpan_cb(skb)->status = 0;
> +       BT_DBG("chan %p resume", chan);
>  }
>
>  static long chan_get_sndtimeo_cb(struct l2cap_chan *chan)
> --
> 2.11.0

It should be possible to queue the packets on l2cap_chan_send, Im not
sure why we have this suspend logic in the first place so perhaps
Jukka can shed some light here.



-- 
Luiz Augusto von Dentz
