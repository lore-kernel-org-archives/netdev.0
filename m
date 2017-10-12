From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] ravb: Consolidate clock handling
Date: Thu, 12 Oct 2017 14:20:45 +0200
Message-ID: <CAMuHMdUpvrWpyiAo2qT=5JWHU+jpbDgV8LuvF0-+pC825XQMeg@mail.gmail.com>
References: <1507796693-14268-1-git-send-email-geert+renesas@glider.be> <20171012095508.vjpqvq37474qp2cb@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Geert Uytterhoeven <geert+renesas@glider.be>,
        "David S . Miller" <davem@davemloft.net>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        =?UTF-8?Q?Niklas_S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>
To: Simon Horman <horms@verge.net.au>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20171012095508.vjpqvq37474qp2cb@verge.net.au>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Simon,

On Thu, Oct 12, 2017 at 11:55 AM, Simon Horman <horms@verge.net.au> wrote:
> On Thu, Oct 12, 2017 at 10:24:53AM +0200, Geert Uytterhoeven wrote:
>> The module clock is used for two purposes:
>>   - Wake-on-LAN (WoL), which is optional,
>>   - gPTP Timer Increment (GTI) configuration, which is mandatory.
>>
>> As the clock is needed for GTI configuration anyway, WoL is always
>> available.  Hence remove duplication and repeated obtaining of the clock
>> by making GTI use the stored clock for WoL use.
>
> Hi Geert,
>
> I understand from the statements above that the clock must be present,
> but I'm most sure that I understand why that means that WoL is always
> available.

That refers to the part below: WoL was considered available iff the clock
is available.

@@ -2073,10 +2058,11 @@ static int ravb_probe(struct platform_device *pdev)

        priv->chip_id = chip_id;

-       /* Get clock, if not found that's OK but Wake-On-Lan is unavailable */
        priv->clk = devm_clk_get(&pdev->dev, NULL);
-       if (IS_ERR(priv->clk))
-               priv->clk = NULL;
+       if (IS_ERR(priv->clk)) {
+               error = PTR_ERR(priv->clk);
+               goto out_release;
+       }

But the clock must always be available, else GTI configuration
would fail, and ravb initialization would return with an error.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
