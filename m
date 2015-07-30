From: Petri Gynther <pgynther@google.com>
Subject: Re: [PATCH net-next 1/4] net: bcmgenet: Add netconsole support
Date: Thu, 30 Jul 2015 15:43:17 -0700
Message-ID: <CAGXr9JE3R_h=JnZvfu91aVhAkn8A56mekGY2k_vyRE0ei5vuBA@mail.gmail.com>
References: <1438284939-2750-1-git-send-email-f.fainelli@gmail.com>
	<1438284939-2750-2-git-send-email-f.fainelli@gmail.com>
	<CAGXr9JECxcM3gaWh=k4g8c7mNvVyDD_1=80rg_FLXcedC0RHzQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jaedon Shin <jaedon.shin@gmail.com>,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com, mathieu@codeaurora.org,
	jonasj76@gmail.com, andrey.volkov@nexvision.fr,
	Chris.Packham@alliedtelesis.co.nz, alexander.h.duyck@redhat.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:32993 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752017AbbG3WnS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 18:43:18 -0400
Received: by wicmv11 with SMTP id mv11so37635869wic.0
        for <netdev@vger.kernel.org>; Thu, 30 Jul 2015 15:43:17 -0700 (PDT)
In-Reply-To: <CAGXr9JECxcM3gaWh=k4g8c7mNvVyDD_1=80rg_FLXcedC0RHzQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 30, 2015 at 2:04 PM, Petri Gynther <pgynther@google.com> wrote:
> On Thu, Jul 30, 2015 at 12:35 PM, Florian Fainelli <f.fainelli@gmail.com>
> wrote:
>>
>> Implement a poll controller for netconsole which invokes the RX
>> interrupt handler to poll for incoming packets, and cleans up all TX
>> queues.
>>
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---
>>  drivers/net/ethernet/broadcom/genet/bcmgenet.c | 13 +++++++++++++
>>  1 file changed, 13 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
>> b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
>> index c6f2d396edf0..544160f39c1b 100644
>> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
>> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
>> @@ -2388,6 +2388,16 @@ static irqreturn_t bcmgenet_wol_isr(int irq, void
>> *dev_id)
>>         return IRQ_HANDLED;
>>  }
>>
>> +#ifdef CONFIG_NET_POLL_CONTROLLER
>> +static void bcmgenet_poll_controller(struct net_device *dev)
>> +{
>> +       struct bcmgenet_priv *priv = netdev_priv(dev);
>> +
>> +       bcmgenet_isr0(priv->irq0, priv);
>
>
> Need to add here:
>     bcmgenet_isr1(priv->irq1, priv);
>
> for handling Rx + Tx priority queues.
>
>>
>> +       bcmgenet_tx_reclaim_all(dev);

Do you need the above call to bcmgenet_tx_reclaim_all()?

bcmgenet_isr0() and bcmgenet_isr1() will schedule NAPI handlers for
all Rx and Tx queues that need it.

>> +}
>> +#endif
>> +
>>  static void bcmgenet_umac_reset(struct bcmgenet_priv *priv)
>>  {
>>         u32 reg;
>> @@ -2939,6 +2949,9 @@ static const struct net_device_ops
>> bcmgenet_netdev_ops = {
>>         .ndo_set_mac_address    = bcmgenet_set_mac_addr,
>>         .ndo_do_ioctl           = bcmgenet_ioctl,
>>         .ndo_set_features       = bcmgenet_set_features,
>> +#ifdef CONFIG_NET_POLL_CONTROLLER
>> +       .ndo_poll_controller    = bcmgenet_poll_controller,
>> +#endif
>>  };
>>
>>  /* Array of GENET hardware parameters/characteristics */
>> --
>> 2.1.0
>>
>
