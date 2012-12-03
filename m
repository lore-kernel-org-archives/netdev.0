From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] ixgbe: Use is_valid_ether_addr
Date: Mon, 03 Dec 2012 09:47:11 -0800
Message-ID: <1354556831.3524.0.camel@joe-AO722>
References: <1350750159.10791.3.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1350750159.10791.3.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2012-10-20 at 09:22 -0700, Joe Perches wrote:
> Use the normal kernel test instead of a module specific one.

ping?

> Signed-off-by: Joe Perches <joe@perches.com>
> ---
> found when doing that larger style conversion,
> might as well submit it.
> 
>  drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c  |  2 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 27 +------------------------
>  drivers/net/ethernet/intel/ixgbe/ixgbe_common.h |  1 -
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |  2 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_type.h   |  9 ---------
>  drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c   |  2 +-
>  6 files changed, 4 insertions(+), 39 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
> index 1077cb2..89fe00d 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
> @@ -1022,7 +1022,7 @@ mac_reset_top:
>  	hw->mac.ops.get_san_mac_addr(hw, hw->mac.san_addr);
>  
>  	/* Add the SAN MAC address to the RAR only if it's a valid address */
> -	if (ixgbe_validate_mac_addr(hw->mac.san_addr) == 0) {
> +	if (is_valid_ether_addr(hw->mac.san_addr)) {
>  		hw->mac.ops.set_rar(hw, hw->mac.num_rar_entries - 1,
>  		                    hw->mac.san_addr, 0, IXGBE_RAH_AV);
>  
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
> index dbf37e4..2d8f76d 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
> @@ -1762,30 +1762,6 @@ s32 ixgbe_update_eeprom_checksum_generic(struct ixgbe_hw *hw)
>  }
>  
>  /**
> - *  ixgbe_validate_mac_addr - Validate MAC address
> - *  @mac_addr: pointer to MAC address.
> - *
> - *  Tests a MAC address to ensure it is a valid Individual Address
> - **/
> -s32 ixgbe_validate_mac_addr(u8 *mac_addr)
> -{
> -	s32 status = 0;
> -
> -	/* Make sure it is not a multicast address */
> -	if (IXGBE_IS_MULTICAST(mac_addr))
> -		status = IXGBE_ERR_INVALID_MAC_ADDR;
> -	/* Not a broadcast address */
> -	else if (IXGBE_IS_BROADCAST(mac_addr))
> -		status = IXGBE_ERR_INVALID_MAC_ADDR;
> -	/* Reject the zero address */
> -	else if (mac_addr[0] == 0 && mac_addr[1] == 0 && mac_addr[2] == 0 &&
> -	         mac_addr[3] == 0 && mac_addr[4] == 0 && mac_addr[5] == 0)
> -		status = IXGBE_ERR_INVALID_MAC_ADDR;
> -
> -	return status;
> -}
> -
> -/**
>   *  ixgbe_set_rar_generic - Set Rx address register
>   *  @hw: pointer to hardware structure
>   *  @index: Receive address register to write
> @@ -1889,8 +1865,7 @@ s32 ixgbe_init_rx_addrs_generic(struct ixgbe_hw *hw)
>  	 * to the permanent address.
>  	 * Otherwise, use the permanent address from the eeprom.
>  	 */
> -	if (ixgbe_validate_mac_addr(hw->mac.addr) ==
> -	    IXGBE_ERR_INVALID_MAC_ADDR) {
> +	if (!is_valid_ether_addr(hw->mac.addr)) {
>  		/* Get the MAC address from the RAR0 for later reference */
>  		hw->mac.ops.get_mac_addr(hw, hw->mac.addr);
>  
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
> index d813d11..f49ca84 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
> @@ -80,7 +80,6 @@ s32 ixgbe_enable_rx_dma_generic(struct ixgbe_hw *hw, u32 regval);
>  s32 ixgbe_fc_enable_generic(struct ixgbe_hw *hw);
>  void ixgbe_fc_autoneg(struct ixgbe_hw *hw);
>  
> -s32 ixgbe_validate_mac_addr(u8 *mac_addr);
>  s32 ixgbe_acquire_swfw_sync(struct ixgbe_hw *hw, u16 mask);
>  void ixgbe_release_swfw_sync(struct ixgbe_hw *hw, u16 mask);
>  s32 ixgbe_get_san_mac_addr_generic(struct ixgbe_hw *hw, u8 *san_mac_addr);
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index e2a6691..3bb3485 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -7345,7 +7345,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
>  	memcpy(netdev->dev_addr, hw->mac.perm_addr, netdev->addr_len);
>  	memcpy(netdev->perm_addr, hw->mac.perm_addr, netdev->addr_len);
>  
> -	if (ixgbe_validate_mac_addr(netdev->perm_addr)) {
> +	if (!is_valid_ether_addr(netdev->perm_addr)) {
>  		e_dev_err("invalid MAC address\n");
>  		err = -EIO;
>  		goto err_sw_init;
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
> index 0722f33..9ddac64 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
> @@ -1833,15 +1833,6 @@ enum {
>  /* Number of 100 microseconds we wait for PCI Express master disable */
>  #define IXGBE_PCI_MASTER_DISABLE_TIMEOUT 800
>  
> -/* Check whether address is multicast.  This is little-endian specific check.*/
> -#define IXGBE_IS_MULTICAST(Address) \
> -                (bool)(((u8 *)(Address))[0] & ((u8)0x01))
> -
> -/* Check whether an address is broadcast. */
> -#define IXGBE_IS_BROADCAST(Address)                      \
> -                ((((u8 *)(Address))[0] == ((u8)0xff)) && \
> -                (((u8 *)(Address))[1] == ((u8)0xff)))
> -
>  /* RAH */
>  #define IXGBE_RAH_VIND_MASK     0x003C0000
>  #define IXGBE_RAH_VIND_SHIFT    18
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
> index de4da52..c73b929 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
> @@ -152,7 +152,7 @@ mac_reset_top:
>  	hw->mac.ops.get_san_mac_addr(hw, hw->mac.san_addr);
>  
>  	/* Add the SAN MAC address to the RAR only if it's a valid address */
> -	if (ixgbe_validate_mac_addr(hw->mac.san_addr) == 0) {
> +	if (is_valid_ether_addr(hw->mac.san_addr)) {
>  		hw->mac.ops.set_rar(hw, hw->mac.num_rar_entries - 1,
>  		                    hw->mac.san_addr, 0, IXGBE_RAH_AV);
>  
> 
