From: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
Subject: Re: [PATCH v2 3/4] net: ethernet: nb8800: Fix RGMII TX clock delay
 setup
Date: Fri, 21 Jul 2017 15:43:02 +0200
Message-ID: <53fbf5e1-8d37-9734-be3f-77128ada9dfb@sigmadesigns.com>
References: <2617d673-ef81-5e7f-4730-ed3aa3f1c2c6@sigmadesigns.com>
 <5a68bec8-0b1d-bcfe-65fb-b10399ec75be@sigmadesigns.com>
 <yw1xy3riosag.fsf@mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: 8BIT
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Martin Blumenstingl <martin.blumenstingl@gmail.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        Timur Tabi <timur@codeaurora.org>,
        Daniel Mack <zonque@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>,
        "David S. Miller" <davem@davemloft.net>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>,
        Mason <slash.tmp@free.fr>
To: Mans Rullgard <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us-smtp-delivery-107.mimecast.com ([63.128.21.107]:60428 "EHLO
        us-smtp-delivery-107.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753406AbdGUNnJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2017 09:43:09 -0400
In-Reply-To: <yw1xy3riosag.fsf@mansr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/07/2017 15:04, Måns Rullgård wrote:

> Marc Gonzalez wrote:
> 
>> According to commit e5f3a4a56ce2a707b2fb8ce37e4414dcac89c672
>> ("Documentation: devicetree: clarify usage of the RGMII phy-modes")
>> there are 4 RGMII modes to handle:
>>
>> "rgmii" (RX and TX delays are added by the MAC when required)
>> "rgmii-id" (RGMII with internal RX and TX delays provided by the PHY,
>> 	the MAC should not add the RX or TX delays in this case)
>> "rgmii-rxid" (RGMII with internal RX delay provided by the PHY,
>> 	the MAC should not add an RX delay in this case)
>> "rgmii-txid" (RGMII with internal TX delay provided by the PHY,
>> 	the MAC should not add an TX delay in this case)
>>
>> Add TX delay in the MAC only for rgmii and rgmii-rxid.
>>
>> Signed-off-by: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
>> ---
>>  drivers/net/ethernet/aurora/nb8800.c | 6 ++++--
>>  1 file changed, 4 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
>> index ded041dbafe7..f3ed320eb4ad 100644
>> --- a/drivers/net/ethernet/aurora/nb8800.c
>> +++ b/drivers/net/ethernet/aurora/nb8800.c
>> @@ -1268,11 +1268,13 @@ static int nb8800_tangox_init(struct net_device *dev)
>>  		break;
>>
>>  	case PHY_INTERFACE_MODE_RGMII:
>> -		pad_mode = PAD_MODE_RGMII;
>> +	case PHY_INTERFACE_MODE_RGMII_RXID:
>> +		pad_mode = PAD_MODE_RGMII | PAD_MODE_GTX_CLK_DELAY;
>>  		break;
>>
>> +	case PHY_INTERFACE_MODE_RGMII_ID:
>>  	case PHY_INTERFACE_MODE_RGMII_TXID:
>> -		pad_mode = PAD_MODE_RGMII | PAD_MODE_GTX_CLK_DELAY;
>> +		pad_mode = PAD_MODE_RGMII;
>>  		break;
>>
>>  	default:
> 
> I still don't like this.  Having both the MAC and PHY drivers react to
> the phy-connection-type property is bound to cause trouble somewhere.
> 
> The only way out of the current mess is to define new properties for
> both MAC and PHY that override the existing ones if present.

Do you mean defining 4 new bindings and their corresponding
phy_interface_t enum values? For example:

"rgmii-v2"
"rgmii-id-v2"
"rgmii-rxid-v2"
"rgmii-txid-v2"

	PHY_INTERFACE_MODE_RGMII_V2,
	PHY_INTERFACE_MODE_RGMII_ID_V2,
	PHY_INTERFACE_MODE_RGMII_RXID_V2,
	PHY_INTERFACE_MODE_RGMII_TXID_V2,

And then handling these new enums in the at803x and nb8800 drivers?

FWIW, PAD_MODE_GTX_CLK_DELAY is broken in tango5 (doesn't add any
delay). I'm considering removing MAC-side TX delay altogether.

Regards.
