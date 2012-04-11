From: Stuart Hodgson <smhodgson@solarflare.com>
Subject: Re: [RFC PATCH 2/2] net: ethtool: Add capability to retrieve plug-in
 module EEPROM
Date: Wed, 11 Apr 2012 18:41:00 +0100
Message-ID: <4F85C22C.30707@solarflare.com>
References: <4F71FE15.7060708@solarflare.com> <1333390698.2623.47.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1333390698.2623.47.camel@bwh-desktop.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/04/12 19:18, Ben Hutchings wrote:
> On Tue, 2012-03-27 at 18:51 +0100, Stuart Hodgson wrote:
>> Implementation in sfc driver to return the plugin module eeprom
>>
>> Currently allows for SFP+ eeprom to be returned using the ethtool API.
>> This can be extended in future to handle different eeprom formats
>> and sizes.
>>
>> Signed-off-by: Stuart Hodgson<smhodgson@solarflare.com>
>> ---
>>    drivers/net/ethernet/sfc/ethtool.c    |   36 +++++++++++
>>    drivers/net/ethernet/sfc/mcdi_phy.c   |  105
>> +++++++++++++++++++++++++++++++++
>>    drivers/net/ethernet/sfc/net_driver.h |    5 ++
>>    3 files changed, 146 insertions(+), 0 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/sfc/ethtool.c
>> b/drivers/net/ethernet/sfc/ethtool.c
>> index f22f45f..e77895f 100644
>> --- a/drivers/net/ethernet/sfc/ethtool.c
>> +++ b/drivers/net/ethernet/sfc/ethtool.c
>> @@ -1108,6 +1108,40 @@ static int efx_ethtool_set_rxfh_indir(struct
>> net_device *net_dev,
>>        return 0;
>>    }
>>
>> +static int efx_ethtool_get_module_eeprom(struct net_device *net_dev,
>> +                     struct ethtool_eeprom *ee,
>> +                     u8 *data)
>> +{
>> +    struct efx_nic *efx = netdev_priv(net_dev);
>> +    int ret;
>> +
>> +    if (!efx->phy_op ||
>> +        !efx->phy_op->get_module_eeprom)
>
> No need to break that line.
>
> [...]
>> --- a/drivers/net/ethernet/sfc/mcdi_phy.c
>> +++ b/drivers/net/ethernet/sfc/mcdi_phy.c
>> @@ -304,6 +304,17 @@ static u32 mcdi_to_ethtool_media(u32 media)
>>        }
>>    }
>>
>> +static u32 mcdi_to_module_eeprom_len(u32 media)
>> +{
>> +    switch (media) {
>> +    case MC_CMD_MEDIA_SFP_PLUS:
>> +        return SFF_8079_LEN;
>> +    case MC_CMD_MEDIA_XFP:
>
> Why split out XFP if we're not going to treat it any differently?
>
>> +    default:
>> +        return 0;
>> +    }
>> +}
>> +
>>    static int efx_mcdi_phy_probe(struct efx_nic *efx)
>>    {
>>        struct efx_mcdi_phy_data *phy_data;
>> @@ -739,6 +750,98 @@ static const char *efx_mcdi_phy_test_name(struct
>> efx_nic *efx,
>>        return NULL;
>>    }
>>
>> +#define SFP_PAGE_SIZE    128
>> +#define NUM_PAGES    2
>
> SFP_NUM_PAGES?
>
>> +#define OFF_TO_BUFF(x)    (x + MC_CMD_GET_PHY_MEDIA_INFO_OUT_DATA_OFST)
>
> This is not really worth defining for just the one use.
>
>> +static int efx_mcdi_phy_get_module_eeprom(struct efx_nic *efx,
>> +                      struct ethtool_eeprom *ee, u8 *data)
>> +{
>> +    u8 outbuf[MC_CMD_GET_PHY_MEDIA_INFO_OUT_LENMAX];
>> +    u8 inbuf[MC_CMD_GET_PHY_MEDIA_INFO_IN_LEN];
>> +    size_t outlen;
>> +    int rc;
>> +    int payload_len;
>> +    int copied = 0;
>> +    int space_remaining = ee->len;
>> +    int page;
>> +    int page_off;
>> +    int to_copy;
>
> None of payload_len..to_copy should be signed.
>
>> +    u8 *user_data = data;
>> +
>> +    if (!data || !ee)
>> +        return -EINVAL;
>
> Neither of these is allowed to be NULL; don't bother checking.
>
>> +    if (ee->offset>  (SFP_PAGE_SIZE * NUM_PAGES)) {
>> +        rc = -EINVAL;
>> +        goto fail;
>> +    }
>> +
>> +    page_off = (ee->offset % SFP_PAGE_SIZE);
>> +    page = (ee->offset>  SFP_PAGE_SIZE) ? 1 : 0;
>
> Why not ee->offset / SFP_PAGE_SIZE?
>
>> +    while (space_remaining&&  (page<  NUM_PAGES)) {
>> +
>> +        MCDI_SET_DWORD(inbuf, GET_PHY_MEDIA_INFO_IN_PAGE, page);
>> +
>> +        rc = efx_mcdi_rpc(efx, MC_CMD_GET_PHY_MEDIA_INFO,
>> +                  inbuf, sizeof(inbuf),
>> +                  outbuf, sizeof(outbuf),
>> +&outlen);
>> +
>> +        if (rc)
>> +            goto fail;
>> +
>> +        /* Copy as much as we can into data */
>> +        if (outlen<  MC_CMD_GET_PHY_MEDIA_INFO_OUT_LENMIN ||
>> +            outlen>  MC_CMD_GET_PHY_MEDIA_INFO_OUT_LENMAX) {
>> +            rc = -EIO;
>> +            goto fail;
>> +        }
>> +
>> +        payload_len = MCDI_DWORD(outbuf,
>> +                     GET_PHY_MEDIA_INFO_OUT_DATALEN);
>> +
>> +        to_copy = (space_remaining<  payload_len) ?
>> +                space_remaining : payload_len;
>> +
>> +        to_copy -= page_off;
>
> page_off is the number of bytes we need to discard from payload_len, but
> we don't want do discard that from space_remaining.  I think the last
> two statements should be changed to:
>
> 	payload_len -= page_off;
> 	to_copy = (space_remaining<  payload_len) ?
> 		space_remaining : payload_len;
>

I am pretty sure that these two pieces of code are the same

>> +        memcpy(user_data,
>> +               (outbuf + OFF_TO_BUFF(page_off)),
>> +               to_copy);
>> +
>> +        space_remaining -= to_copy;
>> +        user_data += to_copy;
>> +        copied += to_copy;
>> +        page_off = 0;
>> +        page++;
>> +    }
>> +
>> +    ee->len = copied;
>> +
>> +    return 0;
>> +fail:
>> +    return rc;
>
> Nothing to clean up here, so you might as well return errors directly.
>
>> +}
>> +
>> +static int efx_mcdi_phy_get_module_info(struct efx_nic *efx,
>> +                    struct ethtool_modinfo *modinfo)
>> +{
>> +    /* This will return a length of the eeprom
>> +     * type of the module that was detected during the probe,
>> +     * if not modules inserted then phy_data will be NULL */
>> +    struct efx_mcdi_phy_data *phy_cfg;
>> +
>> +    if (!efx || !efx->phy_data)
>> +        return -EOPNOTSUPP;
>
> efx certainly can't be NULL here and I don't believe efx->phy_data can
> either.  (None of the other MCDI PHY operations check it.)
>
>> +    phy_cfg = efx->phy_data;
>> +    modinfo->eeprom_len = mcdi_to_module_eeprom_len(phy_cfg->media);
>> +    modinfo->type = SFF_8079;
> [...]
>
> I don't think this makes sense.  If we're fixing the type as SFF_8079
> then why are we calling a function to get the length?
>
> Ben.
>

What about adding an mcdi_to_module_eeprom_type in the same manner
as mcdi_to_module_eeprom_len and the other mapping functions?

Stu
