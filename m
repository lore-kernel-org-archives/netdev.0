From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/2] NetXen: Added ethtool support for user level tools
Date: Tue, 30 Jan 2007 22:13:01 +0100
Message-ID: <20070130211301.GA3252@electric-eye.fr.zoreil.com>
References: <200701301518.l0UFIvXY005794@dut39.unminc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, brazilnut@us.ibm.com, jeff@garzik.org,
	netxenproj@linsyssoft.com, rob@netxen.com, sanjeev@netxen.com,
	wendyx@us.ibm.com
To: "Amit S. Kale" <amitkale@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:37908 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751519AbXA3VRe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jan 2007 16:17:34 -0500
Content-Disposition: inline
In-Reply-To: <200701301518.l0UFIvXY005794@dut39.unminc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Amit S. Kale <amitkale@netxen.com> :
[...]
> diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
> index 3404461..49b3b4c 100644
> --- a/drivers/net/netxen/netxen_nic_ethtool.c
> +++ b/drivers/net/netxen/netxen_nic_ethtool.c
[...]
>  static void
> @@ -445,13 +436,78 @@ netxen_nic_get_eeprom(struct net_device 
>  		return -EINVAL;
>  
>  	eeprom->magic = (port->pdev)->vendor | ((port->pdev)->device << 16);
> -	for (offset = 0; offset < eeprom->len; offset++)
> -		if (netxen_rom_fast_read
> -		    (adapter, (8 * offset) + 8, (int *)eeprom->data) == -1)
> -			return -EIO;
> +	offset = eeprom->offset;
> +
> +	if (netxen_rom_fast_read_words
> +		(adapter, offset, bytes, eeprom->len) == -1){
> +		return -EIO;
> +	}

At your option, you can:

	rc = netxen_rom_fast_read_words(adapter, offset, bytes, eeprom->len);
	if (rc == -1)
		return -EIO;

or directly return a sensible error status code from
netxen_rom_fast_read_words.

>  	return 0;
>  }
>  
> +static int
> +netxen_nic_set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
> +			u8 * bytes)
> +{
> +	struct netxen_port *port = netdev_priv(dev);
> +	struct netxen_adapter *adapter = port->adapter;
> +	int offset = eeprom->offset;
> +	static int first_write = 1;

You could probably revert the operation and save an initialization.

> +	int ret;
> +	static int ready_to_flash = 0;
> +
> +	if(first_write == 1){
         ^^                ^^
> +		netxen_flash_unlock(adapter);
> +		printk("%s: flash unlocked. \n", netxen_nic_driver_name);

Missing KERN_XYZ

> +		if ((ret = netxen_flash_erase_secondary(adapter)) 
> +			!= FLASH_SUCCESS) {

		ret = netxen_flash_erase_secondary(adapter);
		if (ret != FLASH_SUCCESS) {
			...

> +			printk("%s: Flash erase failed.\n", 

Missing KERN_XYZ

> +				netxen_nic_driver_name);
> +			return(ret);

return is not a function

> +		}
> +		printk("%s: secondary flash erased successfully.\n", 
> +			netxen_nic_driver_name);

Missing KERN_XYZ

> +		first_write = 0;
> +		return 0;
> +	}
> +
> +	if(offset == BOOTLD_START){
> +		if ((ret = netxen_flash_erase_primary(adapter)) 
> +			!= FLASH_SUCCESS) {
> +			printk("%s: Flash erase failed.\n", 

Missing KERN_XYZ

> +				netxen_nic_driver_name);
> +			return ret;
> +		}
> +		if((ret = netxen_rom_se(adapter, USER_START)) != FLASH_SUCCESS)
                 ^^
> +			return ret;
> +		if((ret = netxen_rom_se(adapter, FIXED_START)) != FLASH_SUCCESS)
                 ^^
> +			return ret;
> +		printk("%s: primary flash erased successfully\n", 

Missing KERN_XYZ

> +			netxen_nic_driver_name);
> +		udelay (500);
> +
> +		if((ret = netxen_backup_crbinit(adapter)) != FLASH_SUCCESS){
                 ^^
> +			printk("%s: CRBinit backup failed.\n", 

Missing KERN_XYZ

> +				netxen_nic_driver_name);
> +			return ret;
> +		}
> +		printk("%s: CRBinit backup done.\n", netxen_nic_driver_name);

Missing KERN_XYZ

> +		ready_to_flash = 1;
> +		udelay (500);
> +	}
> +
> +	if(!ready_to_flash){
         ^^
> +		printk("%s: Invalid write sequence, returning...\n",

Missing KERN_XYZ

> +			netxen_nic_driver_name);
> +		return -EINVAL;

ready_to_flash could have returned it.

> +	}
> +
> +	udelay (500);
> +
> +	return netxen_rom_fast_write_words(adapter, offset, bytes, eeprom->len);
> +}
> +
>  static void
>  netxen_nic_get_ringparam(struct net_device *dev, struct ethtool_ringparam *ring)
>  {
> @@ -721,6 +777,7 @@ struct ethtool_ops netxen_nic_ethtool_op
>  	.get_link = netxen_nic_get_link,
>  	.get_eeprom_len = netxen_nic_get_eeprom_len,
>  	.get_eeprom = netxen_nic_get_eeprom,
> +	.set_eeprom = netxen_nic_set_eeprom,
>  	.get_ringparam = netxen_nic_get_ringparam,
>  	.get_pauseparam = netxen_nic_get_pauseparam,
>  	.set_pauseparam = netxen_nic_set_pauseparam,
> diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
> index c3e41f3..069436f 100644
> --- a/drivers/net/netxen/netxen_nic_init.c
> +++ b/drivers/net/netxen/netxen_nic_init.c
> @@ -391,6 +391,7 @@ static inline int do_rom_fast_write(stru
>  	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ABYTE_CNT, 3);
>  	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_INSTR_OPCODE,
>  			     M25P_INSTR_PP);
> +	udelay(100);
>  	if (netxen_wait_rom_done(adapter)) {
>  		netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ABYTE_CNT, 0);
>  		return -1;
> @@ -399,12 +400,13 @@ static inline int do_rom_fast_write(stru
>  	return netxen_rom_wip_poll(adapter);
>  }
>  
> +
>  static inline int
>  do_rom_fast_read(struct netxen_adapter *adapter, int addr, int *valp)
>  {
>  	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ADDRESS, addr);
>  	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ABYTE_CNT, 3);
> -	udelay(100);		/* prevent bursting on CRB */
> +	udelay(70);		/* prevent bursting on CRB */
>  	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_DUMMY_BYTE_CNT, 0);
>  	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_INSTR_OPCODE, 0xb);
>  	if (netxen_wait_rom_done(adapter)) {
> @@ -413,13 +415,45 @@ do_rom_fast_read(struct netxen_adapter *
>  	}
>  	/* reset abyte_cnt and dummy_byte_cnt */
>  	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ABYTE_CNT, 0);
> -	udelay(100);		/* prevent bursting on CRB */
> +	udelay(70);		/* prevent bursting on CRB */
>  	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_DUMMY_BYTE_CNT, 0);
>  
>  	*valp = netxen_nic_reg_read(adapter, NETXEN_ROMUSB_ROM_RDATA);
>  	return 0;
>  }
>  
> +static inline int 
> +do_rom_fast_read_words(struct netxen_adapter *adapter, int addr,
> +			u8 *bytes, size_t size)
> +{
> +	int addridx = addr;
> +	int ret = 0;
> +
> +	while (addridx < (addr + size)) {
> +		ret = do_rom_fast_read(adapter, addridx, (int *)bytes);
> +		if(ret != 0)
                 ^^
> +			break;
> +		bytes += 4;
> +		addridx += 4;

It could be the third statement of a good ole 'for' loop.

> +	}
> +	return ret;
> +}
> +
> +int
> +netxen_rom_fast_read_words (struct netxen_adapter *adapter, int addr, u8 *bytes, 
> +			size_t size)
> +{
> +	int ret;

Line feed please.

> +	if (rom_lock(adapter) != 0) {
> +		return -1;

	rc = rom_lock(adapter);
	if (rc < 0)
		return rc;

> +	}
> +
> +	ret = do_rom_fast_read_words(adapter, addr, bytes, size);
> +
> +	netxen_rom_unlock(adapter);
> +	return ret;
> +}
> +
>  int netxen_rom_fast_read(struct netxen_adapter *adapter, int addr, int *valp)
>  {
>  	int ret;
> @@ -443,20 +477,189 @@ int netxen_rom_fast_write(struct netxen_
>  	netxen_rom_unlock(adapter);
>  	return ret;
>  }
> +
> +static inline int do_rom_fast_write_words(struct netxen_adapter *adapter, 
> +						int addr, u8 *bytes, size_t size)
> +{
> +	int addridx = addr;
> +	int data1;
> +	int data;
> +	int ret = 0;
> +	int timeout = 0;

Some of those variables could have a smaller scope.

> +
> +	while (addridx < (addr + size)) {
> +		data = *(u32*)bytes;
> +
> +		ret = do_rom_fast_write(adapter, addridx, data);
> +		if(ret == -1){
                 ^^
> +			printk("do_rom_fast_write returned error \n");

Missing KERN_XYZ

> +			return ret;
> +			
> +		}
> +		timeout = 0;
> +
> +		while(1){
                       ^^
> +			do_rom_fast_read(adapter, addridx, &data1);
> +
> +			if(data1 == data){
> +				break;
> +			}

			if (data1 == data)
				break;

> +
> +			if(timeout++ >= 300) {
                         ^^
> +				printk("netxen_nic: Data write didn't succeed"
> +					" at address %x\n", addridx);

Missing KERN_XYZ (KERN_INFO as ret is not updated to something < 0 ?).

> +				break;
> +			}
> +		}
> +
> +		bytes += 4;
> +		addridx += 4;
> +	}
> +
> +	return ret;
> +}
> +
> +int netxen_rom_fast_write_words(struct netxen_adapter *adapter, int addr, 
> +					u8 *bytes, size_t size)
> +{
> +	int ret = 0;
> +
> +	if (rom_lock(adapter) != 0) {
> +		return -EAGAIN;
> +	}

See above.

> +
> +	ret = do_rom_fast_write_words(adapter, addr, bytes, size);
> +	netxen_rom_unlock(adapter);
> +	return ret;
> +}
> +
> +int netxen_rom_wrsr(struct netxen_adapter *adapter, int data)
> +{
> +	if (netxen_rom_wren(adapter)){
> +		return -1;
> +	}

No curly braces around single line statements.

> +	netxen_crb_writelit_adapter(adapter, NETXEN_ROMUSB_ROM_WDATA, data);
> +	netxen_crb_writelit_adapter(adapter, NETXEN_ROMUSB_ROM_INSTR_OPCODE, 0x1);
> +
> +	if (netxen_wait_rom_done(adapter)) {
> +		return -1;
> +	}
> +	return netxen_rom_wip_poll(adapter);
> +}
> +
> +int netxen_rom_rdsr(struct netxen_adapter *adapter)
> +{
> +	int ret;
> +
> +	if (rom_lock(adapter) != 0){
> +		return -1;
> +	}
> +	ret = netxen_do_rom_rdsr(adapter);
> +	netxen_rom_unlock(adapter);
> +	return ret;
> +}
> +
> +int netxen_backup_crbinit(struct netxen_adapter *adapter)
> +{
> +	int ret = FLASH_SUCCESS;
> +	int val;
> +	char *buffer = kmalloc(FLASH_SECTOR_SIZE, GFP_KERNEL);

Unchecked kmalloc.

> +
> +	/* unlock sector 63 */
> +	val = netxen_rom_rdsr(adapter);
> +	val = val & 0xe3;
> +	ret = netxen_rom_wrsr(adapter, val);
> +	if(ret != FLASH_SUCCESS){
         ^^                    ^^
> +		kfree(buffer);
> +		return -1;
> +	}
> +	ret = netxen_rom_wip_poll(adapter);
> +	if(ret != FLASH_SUCCESS){
         ^^                    ^^
> +		kfree(buffer);
> +		return -1;
> +	}
> +	/* copy  sector 0 to sector 63 */
> +
> +	if (netxen_rom_fast_read_words
> +		(adapter, CRBINIT_START, buffer, FLASH_SECTOR_SIZE) == -1){
> +		printk("get_eeprom() fails...\n");
> +		kfree(buffer);
> +		return -EIO;
> +	}
> +
> +	ret = netxen_rom_fast_write_words(adapter, FIXED_START, buffer,
> +					   FLASH_SECTOR_SIZE);
> +	if(ret != FLASH_SUCCESS){
         ^^                    ^^
> +		kfree(buffer);
> +		return -1;
> +	}

I would use a big 'goto out_kfree' everywhere.

> +
> +	/* lock sector 63 */
> +	val = netxen_rom_rdsr(adapter);
> +	if (!(val & 0x8)) {
> +		val |= (0x1 << 2);
> +		/* lock sector 63 */
> +		if (netxen_rom_wrsr(adapter, val) == 0) {

I assume that it is fine to not update 'ret' if none of the two 'if'
branches is taken, right ?

> +			ret = netxen_rom_wip_poll(adapter);
> +			if(ret != FLASH_SUCCESS){
                         ^^                    ^^
> +				kfree(buffer);
> +				return -1;
> +			}
> +			/* lock SR writes */
> +			val = val | 0x80;

Why is val updated ? It is not used after this point.

> +			ret = netxen_rom_wip_poll(adapter);
> +			if(ret != FLASH_SUCCESS){
                         ^^                    ^^
> +				kfree(buffer);
> +				return -1;
> +			}
> +		}
> +	}

out_kfree:

> +	kfree(buffer);
> +	return ret;
> +}
> +
>  int netxen_do_rom_se(struct netxen_adapter *adapter, int addr)
>  {
> -	netxen_rom_wren(adapter);
> +	if(netxen_rom_wren(adapter) != 0)
> +		return -1;
>  	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ADDRESS, addr);
> +	udelay(200);
>  	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ABYTE_CNT, 3);
> +	udelay(200);
>  	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_INSTR_OPCODE,
> -			     M25P_INSTR_SE);
> +				M25P_INSTR_SE);
> +	udelay(200);
>  	if (netxen_wait_rom_done(adapter)) {
>  		netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ABYTE_CNT, 0);
>  		return -1;
>  	}
> +
>  	return netxen_rom_wip_poll(adapter);
>  }
>  
> +void check_erased_flash(struct netxen_adapter *adapter, int addr)
> +{
> +	int i;
> +	int val;
> +	int count = 0, erased_errors =0;
                                     ^^
> +	int range;
> +
> +	if(addr == 0x3e8000)
> +		range = 0x3f0000;	
> +	else range = addr + FLASH_SECTOR_SIZE;

	if (addr == 0x3e8000)
		range = 0x3f0000;	
	else
		range = addr + FLASH_SECTOR_SIZE;
or:
	range = (addr == 0x3e8000) ? 0x3f0000 : addr + FLASH_SECTOR_SIZE;
> +	
> +	for(i = addr; i < range; i+=4){
          ^^                     i += 4) {
> +		netxen_rom_fast_read(adapter, i, &val);
> +		if(val != 0xffffffff)
                 ^^
> +			erased_errors++;
> +		count++;
> +	}
> +
> +	if(erased_errors)
         ^^
> +		printk("0x%x out of 0x%x words fail to be erased "

Missing KERN_XYZ

> +			"for sector address: %x\n", erased_errors, count, addr);
> +
> +}

Line feed here.

>  int netxen_rom_se(struct netxen_adapter *adapter, int addr)
>  {
>  	int ret = 0;
> @@ -465,6 +668,63 @@ int netxen_rom_se(struct netxen_adapter 
>  	}
>  	ret = netxen_do_rom_se(adapter, addr);
>  	netxen_rom_unlock(adapter);
> +	schedule();



> +	check_erased_flash(adapter, addr);
> +	return ret;
> +}
> +
> +int
> +netxen_flash_erase_sections(struct netxen_adapter *adapter, int start, int end)
> +{
> +	int ret = FLASH_SUCCESS;
> +	int i;

Line feed here.

> +	for (i = start; i < end; i++) {
> +		ret = netxen_rom_se(adapter, i*FLASH_SECTOR_SIZE);
> +		if (ret)
> +			break;
> +		if (netxen_rom_wip_poll(adapter) != 0) {
> +			ret = -1;
> +			break;
> +		}
> +	}
> +	return(ret);

return is not a function.

> +}
> +
> +int
> +netxen_flash_erase_secondary(struct netxen_adapter *adapter)
> +{
> +	int ret = FLASH_SUCCESS;
> +	int start, end;
> +
> +	start = SECONDARY_START/FLASH_SECTOR_SIZE;
> +	end   = USER_START/FLASH_SECTOR_SIZE;
> +	netxen_flash_erase_sections(adapter, start, end);
> +
> +	return(ret);

return is not a function.

> +}
> +
> +int
> +netxen_flash_erase_primary(struct netxen_adapter *adapter)
> +{
> +	int ret = FLASH_SUCCESS;
> +	int start, end;
> +
> +	start = PRIMARY_START/FLASH_SECTOR_SIZE;
> +	end   = SECONDARY_START/FLASH_SECTOR_SIZE;
> +	ret = netxen_flash_erase_sections(adapter, start, end);
> +
> +	return(ret);

return is not a function.

> +}
> +
> +int netxen_flash_unlock(struct netxen_adapter *adapter)
> +{
> +	int ret = 0;
> +
> +	if (netxen_rom_wrsr(adapter, 0) != 0)
> +		ret = -1;
> +	if (netxen_rom_wren(adapter) != 0)
> +		ret = -1;

You should propagate the error code from the lower layers.

-- 
Ueimor
