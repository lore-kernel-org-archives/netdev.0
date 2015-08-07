From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: [PATCH 2/2] net, thunder, bgx: Add support for ACPI binding.
Date: Fri, 7 Aug 2015 11:14:47 -0700
Message-ID: <55C4F597.50103@caviumnetworks.com>
References: <1438907590-29649-1-git-send-email-ddaney.cavm@gmail.com> <1438907590-29649-3-git-send-email-ddaney.cavm@gmail.com> <20150807145414.GA5468@xora-haswell.xora.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Daney <ddaney.cavm@gmail.com>, <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>, <linux-mips@linux-mips.org>,
	Robert Richter <rrichter@cavium.com>,
	"Tomasz Nowicki" <tomasz.nowicki@linaro.org>,
	Sunil Goutham <sgoutham@cavium.com>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-acpi@vger.kernel.org>,
	"David Daney" <david.daney@cavium.com>
To: Graeme Gregory <gg@slimlogic.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150807145414.GA5468@xora-haswell.xora.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/07/2015 07:54 AM, Graeme Gregory wrote:
> On Thu, Aug 06, 2015 at 05:33:10PM -0700, David Daney wrote:
>> From: David Daney <david.daney@cavium.com>
>>
>> Find out which PHYs belong to which BGX instance in the ACPI way.
>>
>> Set the MAC address of the device as provided by ACPI tables. This is
>> similar to the implementation for devicetree in
>> of_get_mac_address(). The table is searched for the device property
>> entries "mac-address", "local-mac-address" and "address" in that
>> order. The address is provided in a u64 variable and must contain a
>> valid 6 bytes-len mac addr.
>>
>> Based on code from: Narinder Dhillon <ndhillon@cavium.com>
>>                      Tomasz Nowicki <tomasz.nowicki@linaro.org>
>>                      Robert Richter <rrichter@cavium.com>
>>
>> Signed-off-by: Tomasz Nowicki <tomasz.nowicki@linaro.org>
>> Signed-off-by: Robert Richter <rrichter@cavium.com>
>> Signed-off-by: David Daney <david.daney@cavium.com>
>> ---
>>   drivers/net/ethernet/cavium/thunder/thunder_bgx.c | 137 +++++++++++++++++++++-
>>   1 file changed, 135 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
>> index 615b2af..2056583 100644
>> --- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
>> +++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
[...]
>> +
>> +static int acpi_get_mac_address(struct acpi_device *adev, u8 *dst)
>> +{
>> +	const union acpi_object *prop;
>> +	u64 mac_val;
>> +	u8 mac[ETH_ALEN];
>> +	int i, j;
>> +	int ret;
>> +
>> +	for (i = 0; i < ARRAY_SIZE(addr_propnames); i++) {
>> +		ret = acpi_dev_get_property(adev, addr_propnames[i],
>> +					    ACPI_TYPE_INTEGER, &prop);
>
> Shouldn't this be trying to use device_property_read_* API and making
> the DT/ACPI path the same where possible?
>

Ideally, something like you suggest would be possible.  However, there 
are a couple of problems trying to do it in the kernel as it exists today:

1) There is no 'struct device *' here, so device_property_read_* is not 
applicable.

2) There is no standard ACPI binding for MAC addresses, so it is 
impossible to create a hypothetical fw_get_mac_address(), which would be 
analogous to of_get_mac_address().

Other e-mail threads have suggested that the path to an elegant solution 
is to inter-mix a bunch of calls to acpi_dev_get_property*() and 
fwnode_property_read*() as to use these more generic 
fwnode_property_read*() functions whereever possible.  I rejected this 
approach as it seems cleaner to me to consistently use a single set of APIs.

Thanks,
David Daney



> Graeme
>
>> +		if (ret)
>> +			continue;
>> +
>> +		mac_val = prop->integer.value;
>> +
>> +		if (mac_val & (~0ULL << 48))
>> +			continue;	/* more than 6 bytes */
>> +
>> +		for (j = 0; j < ARRAY_SIZE(mac); j++)
>> +			mac[j] = (u8)(mac_val >> (8 * j));
>> +		if (!is_valid_ether_addr(mac))
>> +			continue;
>> +
>> +		memcpy(dst, mac, ETH_ALEN);
>> +
>> +		return 0;
>> +	}
>> +
>> +	return ret ? ret : -EINVAL;
>> +}
>> +
>> +static acpi_status bgx_acpi_register_phy(acpi_handle handle,
>> +					 u32 lvl, void *context, void **rv)
>> +{
>> +	struct acpi_reference_args args;
>> +	const union acpi_object *prop;
>> +	struct bgx *bgx = context;
>> +	struct acpi_device *adev;
>> +	struct device *phy_dev;
>> +	u32 phy_id;
>> +
>> +	if (acpi_bus_get_device(handle, &adev))
>> +		goto out;
>> +
>> +	SET_NETDEV_DEV(&bgx->lmac[bgx->lmac_count].netdev, &bgx->pdev->dev);
>> +
>> +	acpi_get_mac_address(adev, bgx->lmac[bgx->lmac_count].mac);
>> +
>> +	bgx->lmac[bgx->lmac_count].lmacid = bgx->lmac_count;
>> +
>> +	if (acpi_dev_get_property_reference(adev, "phy-handle", 0, &args))
>> +		goto out;
>> +
>> +	if (acpi_dev_get_property(args.adev, "phy-channel", ACPI_TYPE_INTEGER, &prop))
>> +		goto out;
>> +
>> +	phy_id = prop->integer.value;
>> +
>> +	phy_dev = bus_find_device(&mdio_bus_type, NULL, (void *)&phy_id,
>> +				  bgx_match_phy_id);
>> +	if (!phy_dev)
>> +		goto out;
>> +
>> +	bgx->lmac[bgx->lmac_count].phydev = to_phy_device(phy_dev);
>> +out:
>> +	bgx->lmac_count++;
>> +	return AE_OK;
>> +}
>> +
>> +static acpi_status bgx_acpi_match_id(acpi_handle handle, u32 lvl,
>> +				     void *context, void **ret_val)
>> +{
>> +	struct acpi_buffer string = { ACPI_ALLOCATE_BUFFER, NULL };
>> +	struct bgx *bgx = context;
>> +	char bgx_sel[5];
>> +
>> +	snprintf(bgx_sel, 5, "BGX%d", bgx->bgx_id);
>> +	if (ACPI_FAILURE(acpi_get_name(handle, ACPI_SINGLE_NAME, &string))) {
>> +		pr_warn("Invalid link device\n");
>> +		return AE_OK;
>> +	}
>> +
>> +	if (strncmp(string.pointer, bgx_sel, 4))
>> +		return AE_OK;
>> +
>> +	acpi_walk_namespace(ACPI_TYPE_DEVICE, handle, 1,
>> +			    bgx_acpi_register_phy, NULL, bgx, NULL);
>> +
>> +	kfree(string.pointer);
>> +	return AE_CTRL_TERMINATE;
>> +}
>> +
>> +static int bgx_init_acpi_phy(struct bgx *bgx)
>> +{
>> +	acpi_get_devices(NULL, bgx_acpi_match_id, bgx, (void **)NULL);
>> +	return 0;
>> +}
>> +
>> +#else
>> +
>> +static int bgx_init_acpi_phy(struct bgx *bgx)
>> +{
>> +	return -ENODEV;
>> +}
>> +
>> +#endif /* CONFIG_ACPI */
>> +
>>   #if IS_ENABLED(CONFIG_OF_MDIO)
>>
>>   static int bgx_init_of_phy(struct bgx *bgx)
>> @@ -882,7 +1010,12 @@ static int bgx_init_of_phy(struct bgx *bgx)
>>
>>   static int bgx_init_phy(struct bgx *bgx)
>>   {
>> -	return bgx_init_of_phy(bgx);
>> +	int err = bgx_init_of_phy(bgx);
>> +
>> +	if (err != -ENODEV)
>> +		return err;
>> +
>> +	return bgx_init_acpi_phy(bgx);
>>   }
>>
>>   static int bgx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>> --
>> 1.9.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-acpi" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
