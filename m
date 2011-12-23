From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [net-next 7/9] ixgbe: add support functions for gathering thermal data sensor
Date: Fri, 23 Dec 2011 14:01:07 +0100
Message-ID: <20111223130107.GA27206@electric-eye.fr.zoreil.com>
References: <1324631357-31789-1-git-send-email-jeffrey.t.kirsher@intel.com> <1324631357-31789-8-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Don Skidmore <donald.c.skidmore@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:46383 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756849Ab1LWNJT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 08:09:19 -0500
Content-Disposition: inline
In-Reply-To: <1324631357-31789-8-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher <jeffrey.t.kirsher@intel.com> :
> From: Don Skidmore <donald.c.skidmore@intel.com>
> 
> Some 82599 adapters contain thermal data that we can get to via
> an i2c interface.  These functions provide support to get at that
> data.  A following patch will export this data.
> 
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Tested-by: Stephen Ko <stephen.s.ko@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_common.c |  150 +++++++++++++++++++++++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_common.h |   13 ++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_type.h   |   38 ++++++
>  3 files changed, 201 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
> index a3aa633..05aa156 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
> @@ -3526,3 +3526,153 @@ void ixgbe_clear_tx_pending(struct ixgbe_hw *hw)
>  	IXGBE_WRITE_REG(hw, IXGBE_GCR_EXT, gcr_ext);
>  	IXGBE_WRITE_REG(hw, IXGBE_HLREG0, hlreg0);
>  }
> +
> +static const u8 ixgbe_emc_temp_data[4] = {
> +	IXGBE_EMC_INTERNAL_DATA,
> +	IXGBE_EMC_DIODE1_DATA,
> +	IXGBE_EMC_DIODE2_DATA,
> +	IXGBE_EMC_DIODE3_DATA
> +};
> +static const u8 ixgbe_emc_therm_limit[4] = {
> +	IXGBE_EMC_INTERNAL_THERM_LIMIT,
> +	IXGBE_EMC_DIODE1_THERM_LIMIT,
> +	IXGBE_EMC_DIODE2_THERM_LIMIT,
> +	IXGBE_EMC_DIODE3_THERM_LIMIT
> +};
> +
> +/**
> + *  ixgbe_get_thermal_sensor_data - Gathers thermal sensor data
> + *  @hw: pointer to hardware structure
> + *  @data: pointer to the thermal sensor data structure
> + *
> + *  Returns the thermal sensor data structure
> + **/
> +s32 ixgbe_get_thermal_sensor_data_generic(struct ixgbe_hw *hw)
> +{
> +	s32 status = 0;
> +	u16 ets_offset;
> +	u16 ets_cfg;
> +	u16 ets_sensor;
> +	u8  num_sensors;
> +	u8  sensor_index;
> +	u8  sensor_location;
> +	u8  i;
> +	struct ixgbe_thermal_sensor_data *data = &hw->mac.thermal_sensor_data;
> +
> +	/* Only support thermal sensors attached to 82599 physical port 0 */
> +	if ((hw->mac.type != ixgbe_mac_82599EB) ||
> +	     (IXGBE_READ_REG(hw, IXGBE_STATUS) & IXGBE_STATUS_LAN_ID_1)) {
> +		status = IXGBE_NOT_IMPLEMENTED;

While defined, IXGBE_NOT_IMPLEMENTED is currently unused in both davem-next
and the remaining patches of this series. Can't you remove it completely and
use a standard error code, say -EOPNOTSUPP ?

> +		goto out;
> +	}
> +
> +	status = hw->eeprom.ops.read(hw, IXGBE_ETS_CFG, &ets_offset);
> +	if (status)
> +		goto out;
> +
> +	if ((ets_offset == 0x0000) || (ets_offset == 0xFFFF)) {
> +		status = IXGBE_NOT_IMPLEMENTED;
> +		goto out;
> +	}
> +
> +	status = hw->eeprom.ops.read(hw, ets_offset, &ets_cfg);
> +	if (status)
> +		goto out;
> +
> +	if (((ets_cfg & IXGBE_ETS_TYPE_MASK) >> IXGBE_ETS_TYPE_SHIFT)
> +	    != IXGBE_ETS_TYPE_EMC) {
            ^^ -> should appear in the previous line

> +		status = IXGBE_NOT_IMPLEMENTED;
> +		goto out;
> +	}
> +
> +	num_sensors = (ets_cfg & IXGBE_ETS_NUM_SENSORS_MASK);
> +	if (num_sensors > IXGBE_MAX_SENSORS)
> +		num_sensors = IXGBE_MAX_SENSORS;

ets_cfg is not used beyond this point and most of this code is duplicated
in ixgbe_init_thermal_sensor_thresh_generic.

You may refactor the code with xyz_get_ets_offset() and xyz_get_num_sensors()
methods, add some eth_type local variable and avoid the duplication while
keeping the lines short.

> +
> +	for (i = 0; i < num_sensors; i++) {

sensor_index and sensor_location should be declared here.

> +		status = hw->eeprom.ops.read(hw, (ets_offset + 1 + i),
> +					     &ets_sensor);
> +		if (status)
> +			goto out;
> +
> +		sensor_index = ((ets_sensor & IXGBE_ETS_DATA_INDEX_MASK) >>
> +				IXGBE_ETS_DATA_INDEX_SHIFT);
> +		sensor_location = ((ets_sensor & IXGBE_ETS_DATA_LOC_MASK) >>
> +				   IXGBE_ETS_DATA_LOC_SHIFT);
> +
> +		if (sensor_location != 0) {
> +			status = hw->phy.ops.read_i2c_byte(hw,
> +					ixgbe_emc_temp_data[sensor_index],
> +					IXGBE_I2C_THERMAL_SENSOR_ADDR,
> +					&data->sensor[i].temp);
> +		if (status)
> +			goto out;
> +		}

Broken indentation.

> +	}
> +out:
> +	return status;
> +}
> +
> +/**
> + * ixgbe_init_thermal_sensor_thresh_generic - Inits thermal sensor thresholds
> + * @hw: pointer to hardware structure
> + *
> + * Inits the thermal sensor thresholds according to the NVM map
> + * and save off the threshold and location values into mac.thermal_sensor_data
> + **/
> +s32 ixgbe_init_thermal_sensor_thresh_generic(struct ixgbe_hw *hw)
> +{
> +	s32 status = 0;
> +	u16 ets_offset;
> +	u16 ets_cfg;
> +	u16 ets_sensor;
> +	u8  low_thresh_delta;
> +	u8  num_sensors;
> +	u8  sensor_index;
> +	u8  sensor_location;
> +	u8  therm_limit;
> +	u8  i;
> +	struct ixgbe_thermal_sensor_data *data = &hw->mac.thermal_sensor_data;
> +
> +	memset(data, 0, sizeof(struct ixgbe_thermal_sensor_data));
> +
> +	/* Only support thermal sensors attached to 82599 physical port 0 */
> +	if ((hw->mac.type != ixgbe_mac_82599EB) ||
> +	    (IXGBE_READ_REG(hw, IXGBE_STATUS) & IXGBE_STATUS_LAN_ID_1))
> +		return IXGBE_NOT_IMPLEMENTED;
> +
> +	hw->eeprom.ops.read(hw, IXGBE_ETS_CFG, &ets_offset);
> +	if ((ets_offset == 0x0000) || (ets_offset == 0xFFFF))
> +		return IXGBE_NOT_IMPLEMENTED;
> +
> +	hw->eeprom.ops.read(hw, ets_offset, &ets_cfg);
> +	if (((ets_cfg & IXGBE_ETS_TYPE_MASK) >> IXGBE_ETS_TYPE_SHIFT)
> +	    != IXGBE_ETS_TYPE_EMC)
            ^^ sic

> +		return IXGBE_NOT_IMPLEMENTED;
> +
> +	low_thresh_delta = ((ets_cfg & IXGBE_ETS_LTHRES_DELTA_MASK) >>
> +			     IXGBE_ETS_LTHRES_DELTA_SHIFT);
> +	num_sensors = (ets_cfg & IXGBE_ETS_NUM_SENSORS_MASK);
> +
> +	for (i = 0; i < num_sensors; i++) {
> +		hw->eeprom.ops.read(hw, (ets_offset + 1 + i), &ets_sensor);
> +		sensor_index = ((ets_sensor & IXGBE_ETS_DATA_INDEX_MASK) >>
> +				IXGBE_ETS_DATA_INDEX_SHIFT);
> +		sensor_location = ((ets_sensor & IXGBE_ETS_DATA_LOC_MASK) >>
> +				   IXGBE_ETS_DATA_LOC_SHIFT);
> +		therm_limit = ets_sensor & IXGBE_ETS_DATA_HTHRESH_MASK;
> +
> +		hw->phy.ops.write_i2c_byte(hw,
> +			ixgbe_emc_therm_limit[sensor_index],
> +			IXGBE_I2C_THERMAL_SENSOR_ADDR, therm_limit);
> +
> +		if ((i < IXGBE_MAX_SENSORS) && (sensor_location != 0)) {

The patch would be easier to review if num_sensors was capped as in
ixgbe_get_thermal_sensor_data_generic...

> +			data->sensor[i].location = sensor_location;
> +			data->sensor[i].caution_thresh = therm_limit;
> +			data->sensor[i].max_op_thresh = therm_limit -
> +							low_thresh_delta;

... and the code would gain an extra tab level, thus avoiding the line
break if there was a 'continue' statement when sensor_location fails the
test.

-- 
Ueimor
