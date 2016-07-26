From: Robert Foss <robert.foss@collabora.com>
Subject: Re: [PATCH 1/3] net: asix: Add in_pm parameter
Date: Tue, 26 Jul 2016 17:14:43 -0400
Message-ID: <f7abc257-54ff-c453-6e7f-34a4103bf7a7@collabora.com>
References: <1469468424-22685-1-git-send-email-robert.foss@collabora.com>
 <CANEJEGsU97GQ9SzmXGJjdSd_fbTptttHJZb1g_GvNjwEgEzqHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Mark_Craske@mentor.com,
	Dean_Jenkins@mentor.com, Vincent Palatin <vpalatin@chromium.org>,
	ivecera@redhat.com, linux@davidrobins.net,
	WK TSAI <wk.tsai@nvidia.com>, changchias@gmail.com,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	enric.balletbo@collabora.com, tomeu.vizoso@collabora.com
To: Grant Grundler <grundler@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANEJEGsU97GQ9SzmXGJjdSd_fbTptttHJZb1g_GvNjwEgEzqHg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> From: Grant Grundler <grundler@chromium.org>
>
> For the record, I believe I am not the author of these patches.
>
> I believe the original author is
>     Signed-off-by: Freddy Xin <freddy@asix.com.tw>
>
> as recorded in the following code reviews (and testing) that I was
> responsible for:
>     https://chromium-review.googlesource.com/#/q/owner:%22Grant+Grundler%22+status:merged+asix+in_pm
>
> And I would certainly be happy to see this code go upstream and
> expected ASIX would submit this change upstream.
Thanks for the feedback (for this patch and the other ones)!
I'm preparing a v2 and will submit it withing a day or two.

>
>> In order to R/W registers in suspend/resume functions, in_pm flags are
>> added to some functions to determine whether the nopm version of usb
>> functions is called.
>
> FTR, current  drivers/net/usb/ax88179_178a.c uses "in_pm" as well.
Ah! Would you like that to be noted in the commit message?
>
>> Save BMCR and ANAR PHY registers in suspend function and restore them
>> in resume function.
>>
>> Reset HW in resume function to ensure the PHY works correctly.
>>
>> Signed-off-by: Grant Grundler <grundler@chromium.org>
>
> BTW, I have two additional changes for AX88772x support sitting in my
> "needs more work" queue (for quite a while already):
>    https://chromium-review.googlesource.com/#/c/229620/
>    "asix: autoneg will set WRITE_MEDIUM reg"
>
>    https://chromium-review.googlesource.com/#/c/231162/
>    "net: asix: see 802.3 spec for phy reset"
>
> I would certainly approve if _anyone_ picked these up, tested them,
> and then submitted them to netdev.
Unfortunately I am without appropriate hardware at the moment.

>
> cheers,
> grant
>
>> ---
>>  drivers/net/usb/asix.h         |  40 +++--
>>  drivers/net/usb/asix_common.c  | 180 +++++++++++++++-----
>>  drivers/net/usb/asix_devices.c | 373 ++++++++++++++++++++++++++++++++---------
>>  drivers/net/usb/ax88172a.c     |  29 ++--
>>  4 files changed, 472 insertions(+), 150 deletions(-)
>>
>> diff --git a/drivers/net/usb/asix.h b/drivers/net/usb/asix.h
>> index a2d3ea6..d109242 100644
>> --- a/drivers/net/usb/asix.h
>> +++ b/drivers/net/usb/asix.h
>> @@ -46,6 +46,7 @@
>>  #define AX_CMD_SET_SW_MII              0x06
>>  #define AX_CMD_READ_MII_REG            0x07
>>  #define AX_CMD_WRITE_MII_REG           0x08
>> +#define AX_CMD_STATMNGSTS_REG          0x09
>>  #define AX_CMD_SET_HW_MII              0x0a
>>  #define AX_CMD_READ_EEPROM             0x0b
>>  #define AX_CMD_WRITE_EEPROM            0x0c
>> @@ -71,6 +72,17 @@
>>  #define AX_CMD_SW_RESET                        0x20
>>  #define AX_CMD_SW_PHY_STATUS           0x21
>>  #define AX_CMD_SW_PHY_SELECT           0x22
>> +#define AX_QCTCTRL                     0x2A
>> +
>> +#define AX_CHIPCODE_MASK               0x70
>> +#define AX_AX88772_CHIPCODE            0x00
>> +#define AX_AX88772A_CHIPCODE           0x10
>> +#define AX_AX88772B_CHIPCODE           0x20
>> +#define AX_HOST_EN                     0x01
>> +
>> +#define AX_PHYSEL_PSEL                 0x01
>> +#define AX_PHYSEL_SSMII                        0
>> +#define AX_PHYSEL_SSEN                 0x10
>>
>>  #define AX_PHY_SELECT_MASK             (BIT(3) | BIT(2))
>>  #define AX_PHY_SELECT_INTERNAL         0
>> @@ -173,6 +185,10 @@ struct asix_rx_fixup_info {
>>  };
>>
>>  struct asix_common_private {
>> +       void (*resume)(struct usbnet *dev);
>> +       void (*suspend)(struct usbnet *dev);
>> +       u16 presvd_phy_advertise;
>> +       u16 presvd_phy_bmcr;
>>         struct asix_rx_fixup_info rx_fixup_info;
>>  };
>>
>> @@ -182,10 +198,10 @@ extern const struct driver_info ax88172a_info;
>>  #define FLAG_EEPROM_MAC                (1UL << 0)  /* init device MAC from eeprom */
>>
>>  int asix_read_cmd(struct usbnet *dev, u8 cmd, u16 value, u16 index,
>> -                 u16 size, void *data);
>> +                 u16 size, void *data, int in_pm);
>>
>>  int asix_write_cmd(struct usbnet *dev, u8 cmd, u16 value, u16 index,
>> -                  u16 size, void *data);
>> +                  u16 size, void *data, int in_pm);
>>
>>  void asix_write_cmd_async(struct usbnet *dev, u8 cmd, u16 value,
>>                           u16 index, u16 size, void *data);
>> @@ -197,27 +213,31 @@ int asix_rx_fixup_common(struct usbnet *dev, struct sk_buff *skb);
>>  struct sk_buff *asix_tx_fixup(struct usbnet *dev, struct sk_buff *skb,
>>                               gfp_t flags);
>>
>> -int asix_set_sw_mii(struct usbnet *dev);
>> -int asix_set_hw_mii(struct usbnet *dev);
>> +int asix_set_sw_mii(struct usbnet *dev, int in_pm);
>> +int asix_set_hw_mii(struct usbnet *dev, int in_pm);
>>
>>  int asix_read_phy_addr(struct usbnet *dev, int internal);
>>  int asix_get_phy_addr(struct usbnet *dev);
>>
>> -int asix_sw_reset(struct usbnet *dev, u8 flags);
>> +int asix_sw_reset(struct usbnet *dev, u8 flags, int in_pm);
>>
>> -u16 asix_read_rx_ctl(struct usbnet *dev);
>> -int asix_write_rx_ctl(struct usbnet *dev, u16 mode);
>> +u16 asix_read_rx_ctl(struct usbnet *dev, int in_pm);
>> +int asix_write_rx_ctl(struct usbnet *dev, u16 mode, int in_pm);
>>
>> -u16 asix_read_medium_status(struct usbnet *dev);
>> -int asix_write_medium_mode(struct usbnet *dev, u16 mode);
>> +u16 asix_read_medium_status(struct usbnet *dev, int in_pm);
>> +int asix_write_medium_mode(struct usbnet *dev, u16 mode, int in_pm);
>>
>> -int asix_write_gpio(struct usbnet *dev, u16 value, int sleep);
>> +int asix_write_gpio(struct usbnet *dev, u16 value, int sleep, int in_pm);
>>
>>  void asix_set_multicast(struct net_device *net);
>>
>>  int asix_mdio_read(struct net_device *netdev, int phy_id, int loc);
>>  void asix_mdio_write(struct net_device *netdev, int phy_id, int loc, int val);
>>
>> +int asix_mdio_read_nopm(struct net_device *netdev, int phy_id, int loc);
>> +void asix_mdio_write_nopm(struct net_device *netdev, int phy_id, int loc,
>> +                         int val);
>> +
>>  void asix_get_wol(struct net_device *net, struct ethtool_wolinfo *wolinfo);
>>  int asix_set_wol(struct net_device *net, struct ethtool_wolinfo *wolinfo);
>>
>> diff --git a/drivers/net/usb/asix_common.c b/drivers/net/usb/asix_common.c
>> index bd9acff..f0ccf76 100644
>> --- a/drivers/net/usb/asix_common.c
>> +++ b/drivers/net/usb/asix_common.c
>> @@ -22,24 +22,49 @@
>>  #include "asix.h"
>>
>>  int asix_read_cmd(struct usbnet *dev, u8 cmd, u16 value, u16 index,
>> -                 u16 size, void *data)
>> +                 u16 size, void *data, int in_pm)
>>  {
>>         int ret;
>> -       ret = usbnet_read_cmd(dev, cmd,
>> -                              USB_DIR_IN | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
>> -                              value, index, data, size);
>> +       int (*fn)(struct usbnet *, u8, u8, u16, u16, void *, u16);
>> +
>> +       BUG_ON(!dev);
>> +
>> +       if (!in_pm)
>> +               fn = usbnet_read_cmd;
>> +       else
>> +               fn = usbnet_read_cmd_nopm;
>> +
>> +       ret = fn(dev, cmd, USB_DIR_IN | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
>> +                value, index, data, size);
>> +
>> +       if (unlikely(ret < 0))
>> +               netdev_warn(dev->net, "Failed to read reg index 0x%04x: %d\n",
>> +                           index, ret);
>>
>> -       if (ret != size && ret >= 0)
>> -               return -EINVAL;
>>         return ret;
>>  }
>>
>>  int asix_write_cmd(struct usbnet *dev, u8 cmd, u16 value, u16 index,
>> -                  u16 size, void *data)
>> +                  u16 size, void *data, int in_pm)
>>  {
>> -       return usbnet_write_cmd(dev, cmd,
>> -                               USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
>> -                               value, index, data, size);
>> +       int ret;
>> +       int (*fn)(struct usbnet *, u8, u8, u16, u16, const void *, u16);
>> +
>> +       BUG_ON(!dev);
>> +
>> +       if (!in_pm)
>> +               fn = usbnet_write_cmd;
>> +       else
>> +               fn = usbnet_write_cmd_nopm;
>> +
>> +       ret = fn(dev, cmd, USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
>> +                value, index, data, size);
>> +
>> +       if (unlikely(ret < 0))
>> +               netdev_warn(dev->net, "Failed to write reg index 0x%04x: %d\n",
>> +                           index, ret);
>> +
>> +       return ret;
>>  }
>>
>>  void asix_write_cmd_async(struct usbnet *dev, u8 cmd, u16 value, u16 index,
>> @@ -225,19 +250,20 @@ struct sk_buff *asix_tx_fixup(struct usbnet *dev, struct sk_buff *skb,
>>         return skb;
>>  }
>>
>> -int asix_set_sw_mii(struct usbnet *dev)
>> +int asix_set_sw_mii(struct usbnet *dev, int in_pm)
>>  {
>>         int ret;
>> -       ret = asix_write_cmd(dev, AX_CMD_SET_SW_MII, 0x0000, 0, 0, NULL);
>> +       ret = asix_write_cmd(dev, AX_CMD_SET_SW_MII, 0x0000, 0, 0, NULL, in_pm);
>> +
>>         if (ret < 0)
>>                 netdev_err(dev->net, "Failed to enable software MII access\n");
>>         return ret;
>>  }
>>
>> -int asix_set_hw_mii(struct usbnet *dev)
>> +int asix_set_hw_mii(struct usbnet *dev, int in_pm)
>>  {
>>         int ret;
>> -       ret = asix_write_cmd(dev, AX_CMD_SET_HW_MII, 0x0000, 0, 0, NULL);
>> +       ret = asix_write_cmd(dev, AX_CMD_SET_HW_MII, 0x0000, 0, 0, NULL, in_pm);
>>         if (ret < 0)
>>                 netdev_err(dev->net, "Failed to enable hardware MII access\n");
>>         return ret;
>> @@ -247,7 +273,7 @@ int asix_read_phy_addr(struct usbnet *dev, int internal)
>>  {
>>         int offset = (internal ? 1 : 0);
>>         u8 buf[2];
>> -       int ret = asix_read_cmd(dev, AX_CMD_READ_PHY_ID, 0, 0, 2, buf);
>> +       int ret = asix_read_cmd(dev, AX_CMD_READ_PHY_ID, 0, 0, 2, buf, 0);
>>
>>         netdev_dbg(dev->net, "asix_get_phy_addr()\n");
>>
>> @@ -270,21 +296,21 @@ int asix_get_phy_addr(struct usbnet *dev)
>>  }
>>
>>
>> -int asix_sw_reset(struct usbnet *dev, u8 flags)
>> +int asix_sw_reset(struct usbnet *dev, u8 flags, int in_pm)
>>  {
>>         int ret;
>>
>> -        ret = asix_write_cmd(dev, AX_CMD_SW_RESET, flags, 0, 0, NULL);
>> +       ret = asix_write_cmd(dev, AX_CMD_SW_RESET, flags, 0, 0, NULL, in_pm);
>>         if (ret < 0)
>>                 netdev_err(dev->net, "Failed to send software reset: %02x\n", ret);
>>
>>         return ret;
>>  }
>>
>> -u16 asix_read_rx_ctl(struct usbnet *dev)
>> +u16 asix_read_rx_ctl(struct usbnet *dev, int in_pm)
>>  {
>>         __le16 v;
>> -       int ret = asix_read_cmd(dev, AX_CMD_READ_RX_CTL, 0, 0, 2, &v);
>> +       int ret = asix_read_cmd(dev, AX_CMD_READ_RX_CTL, 0, 0, 2, &v, in_pm);
>>
>>         if (ret < 0) {
>>                 netdev_err(dev->net, "Error reading RX_CTL register: %02x\n", ret);
>> @@ -295,12 +321,12 @@ out:
>>         return ret;
>>  }
>>
>> -int asix_write_rx_ctl(struct usbnet *dev, u16 mode)
>> +int asix_write_rx_ctl(struct usbnet *dev, u16 mode, int in_pm)
>>  {
>>         int ret;
>>
>>         netdev_dbg(dev->net, "asix_write_rx_ctl() - mode = 0x%04x\n", mode);
>> -       ret = asix_write_cmd(dev, AX_CMD_WRITE_RX_CTL, mode, 0, 0, NULL);
>> +       ret = asix_write_cmd(dev, AX_CMD_WRITE_RX_CTL, mode, 0, 0, NULL, in_pm);
>>         if (ret < 0)
>>                 netdev_err(dev->net, "Failed to write RX_CTL mode to 0x%04x: %02x\n",
>>                            mode, ret);
>> @@ -308,10 +334,11 @@ int asix_write_rx_ctl(struct usbnet *dev, u16 mode)
>>         return ret;
>>  }
>>
>> -u16 asix_read_medium_status(struct usbnet *dev)
>> +u16 asix_read_medium_status(struct usbnet *dev, int in_pm)
>>  {
>>         __le16 v;
>> -       int ret = asix_read_cmd(dev, AX_CMD_READ_MEDIUM_STATUS, 0, 0, 2, &v);
>> +       int ret = asix_read_cmd(dev, AX_CMD_READ_MEDIUM_STATUS,
>> +                               0, 0, 2, &v, in_pm);
>>
>>         if (ret < 0) {
>>                 netdev_err(dev->net, "Error reading Medium Status register: %02x\n",
>> @@ -323,12 +350,13 @@ u16 asix_read_medium_status(struct usbnet *dev)
>>
>>  }
>>
>> -int asix_write_medium_mode(struct usbnet *dev, u16 mode)
>> +int asix_write_medium_mode(struct usbnet *dev, u16 mode, int in_pm)
>>  {
>>         int ret;
>>
>>         netdev_dbg(dev->net, "asix_write_medium_mode() - mode = 0x%04x\n", mode);
>> -       ret = asix_write_cmd(dev, AX_CMD_WRITE_MEDIUM_MODE, mode, 0, 0, NULL);
>> +       ret = asix_write_cmd(dev, AX_CMD_WRITE_MEDIUM_MODE,
>> +                            mode, 0, 0, NULL, in_pm);
>>         if (ret < 0)
>>                 netdev_err(dev->net, "Failed to write Medium Mode mode to 0x%04x: %02x\n",
>>                            mode, ret);
>> @@ -336,12 +364,12 @@ int asix_write_medium_mode(struct usbnet *dev, u16 mode)
>>         return ret;
>>  }
>>
>> -int asix_write_gpio(struct usbnet *dev, u16 value, int sleep)
>> +int asix_write_gpio(struct usbnet *dev, u16 value, int sleep, int in_pm)
>>  {
>>         int ret;
>>
>>         netdev_dbg(dev->net, "asix_write_gpio() - value = 0x%04x\n", value);
>> -       ret = asix_write_cmd(dev, AX_CMD_WRITE_GPIOS, value, 0, 0, NULL);
>> +       ret = asix_write_cmd(dev, AX_CMD_WRITE_GPIOS, value, 0, 0, NULL, in_pm);
>>         if (ret < 0)
>>                 netdev_err(dev->net, "Failed to write GPIO value 0x%04x: %02x\n",
>>                            value, ret);
>> @@ -398,16 +426,23 @@ int asix_mdio_read(struct net_device *netdev, int phy_id, int loc)
>>  {
>>         struct usbnet *dev = netdev_priv(netdev);
>>         __le16 res;
>> +       u8 smsr;
>> +       int i = 0;
>>
>>         mutex_lock(&dev->phy_mutex);
>> -       asix_set_sw_mii(dev);
>> +       do {
>> +               asix_set_sw_mii(dev, 0);
>> +               usleep_range(1000, 1100);
>> +               asix_read_cmd(dev, AX_CMD_STATMNGSTS_REG, 0, 0, 1, &smsr, 0);
>> +       } while (!(smsr & AX_HOST_EN) && (i++ < 30));
>> +
>>         asix_read_cmd(dev, AX_CMD_READ_MII_REG, phy_id,
>> -                               (__u16)loc, 2, &res);
>> -       asix_set_hw_mii(dev);
>> +                               (__u16)loc, 2, &res, 0);
>> +       asix_set_hw_mii(dev, 0);
>>         mutex_unlock(&dev->phy_mutex);
>>
>>         netdev_dbg(dev->net, "asix_mdio_read() phy_id=0x%02x, loc=0x%02x, returns=0x%04x\n",
>> -                  phy_id, loc, le16_to_cpu(res));
>> +                       phy_id, loc, le16_to_cpu(res));
>>
>>         return le16_to_cpu(res);
>>  }
>> @@ -416,13 +451,71 @@ void asix_mdio_write(struct net_device *netdev, int phy_id, int loc, int val)
>>  {
>>         struct usbnet *dev = netdev_priv(netdev);
>>         __le16 res = cpu_to_le16(val);
>> +       u8 smsr;
>> +       int i = 0;
>>
>>         netdev_dbg(dev->net, "asix_mdio_write() phy_id=0x%02x, loc=0x%02x, val=0x%04x\n",
>> -                  phy_id, loc, val);
>> +                       phy_id, loc, val);
>> +
>> +       mutex_lock(&dev->phy_mutex);
>> +       do {
>> +               asix_set_sw_mii(dev, 0);
>> +               usleep_range(1000, 1100);
>> +               asix_read_cmd(dev, AX_CMD_STATMNGSTS_REG, 0, 0, 1, &smsr, 0);
>> +       } while (!(smsr & AX_HOST_EN) && (i++ < 30));
>> +
>> +       asix_write_cmd(dev, AX_CMD_WRITE_MII_REG, phy_id,
>> +                      (__u16)loc, 2, &res, 0);
>> +       asix_set_hw_mii(dev, 0);
>> +       mutex_unlock(&dev->phy_mutex);
>> +}
>> +
>> +int asix_mdio_read_nopm(struct net_device *netdev, int phy_id, int loc)
>> +{
>> +       struct usbnet *dev = netdev_priv(netdev);
>> +       __le16 res;
>> +       u8 smsr;
>> +       int i = 0;
>> +
>> +       mutex_lock(&dev->phy_mutex);
>> +       do {
>> +               asix_set_sw_mii(dev, 1);
>> +               usleep_range(1000, 1100);
>> +               asix_read_cmd(dev, AX_CMD_STATMNGSTS_REG, 0, 0, 1, &smsr, 1);
>> +       } while (!(smsr & AX_HOST_EN) && (i++ < 30));
>> +
>> +       asix_read_cmd(dev, AX_CMD_READ_MII_REG, phy_id,
>> +                     (__u16)loc, 2, &res, 1);
>> +       asix_set_hw_mii(dev, 1);
>> +       mutex_unlock(&dev->phy_mutex);
>> +
>> +       netdev_dbg(dev->net, "asix_mdio_read_nopm() phy_id=0x%02x, loc=0x%02x, returns=0x%04x\n",
>> +                       phy_id, loc, le16_to_cpu(res));
>> +
>> +       return le16_to_cpu(res);
>> +}
>> +
>> +void
>> +asix_mdio_write_nopm(struct net_device *netdev, int phy_id, int loc, int val)
>> +{
>> +       struct usbnet *dev = netdev_priv(netdev);
>> +       __le16 res = cpu_to_le16(val);
>> +       u8 smsr;
>> +       int i = 0;
>> +
>> +       netdev_dbg(dev->net, "asix_mdio_write() phy_id=0x%02x, loc=0x%02x, val=0x%04x\n",
>> +                       phy_id, loc, val);
>> +
>>         mutex_lock(&dev->phy_mutex);
>> -       asix_set_sw_mii(dev);
>> -       asix_write_cmd(dev, AX_CMD_WRITE_MII_REG, phy_id, (__u16)loc, 2, &res);
>> -       asix_set_hw_mii(dev);
>> +       do {
>> +               asix_set_sw_mii(dev, 1);
>> +               usleep_range(1000, 1100);
>> +               asix_read_cmd(dev, AX_CMD_STATMNGSTS_REG, 0, 0, 1, &smsr, 1);
>> +       } while (!(smsr & AX_HOST_EN) && (i++ < 30));
>> +
>> +       asix_write_cmd(dev, AX_CMD_WRITE_MII_REG, phy_id,
>> +                      (__u16)loc, 2, &res, 1);
>> +       asix_set_hw_mii(dev, 1);
>>         mutex_unlock(&dev->phy_mutex);
>>  }
>>
>> @@ -431,7 +524,8 @@ void asix_get_wol(struct net_device *net, struct ethtool_wolinfo *wolinfo)
>>         struct usbnet *dev = netdev_priv(net);
>>         u8 opt;
>>
>> -       if (asix_read_cmd(dev, AX_CMD_READ_MONITOR_MODE, 0, 0, 1, &opt) < 0) {
>> +       if (asix_read_cmd(dev, AX_CMD_READ_MONITOR_MODE,
>> +                         0, 0, 1, &opt, 0) < 0) {
>>                 wolinfo->supported = 0;
>>                 wolinfo->wolopts = 0;
>>                 return;
>> @@ -455,7 +549,7 @@ int asix_set_wol(struct net_device *net, struct ethtool_wolinfo *wolinfo)
>>                 opt |= AX_MONITOR_MAGIC;
>>
>>         if (asix_write_cmd(dev, AX_CMD_WRITE_MONITOR_MODE,
>> -                             opt, 0, 0, NULL) < 0)
>> +                             opt, 0, 0, NULL, 0) < 0)
>>                 return -EINVAL;
>>
>>         return 0;
>> @@ -490,7 +584,7 @@ int asix_get_eeprom(struct net_device *net, struct ethtool_eeprom *eeprom,
>>         /* ax8817x returns 2 bytes from eeprom on read */
>>         for (i = first_word; i <= last_word; i++) {
>>                 if (asix_read_cmd(dev, AX_CMD_READ_EEPROM, i, 0, 2,
>> -                                 &(eeprom_buff[i - first_word])) < 0) {
>> +                                 &eeprom_buff[i - first_word], 0) < 0) {
>>                         kfree(eeprom_buff);
>>                         return -EIO;
>>                 }
>> @@ -531,7 +625,7 @@ int asix_set_eeprom(struct net_device *net, struct ethtool_eeprom *eeprom,
>>            the EEPROM */
>>         if (eeprom->offset & 1) {
>>                 ret = asix_read_cmd(dev, AX_CMD_READ_EEPROM, first_word, 0, 2,
>> -                                   &(eeprom_buff[0]));
>> +                                   &eeprom_buff[0], 0);
>>                 if (ret < 0) {
>>                         netdev_err(net, "Failed to read EEPROM at offset 0x%02x.\n", first_word);
>>                         goto free;
>> @@ -540,7 +634,7 @@ int asix_set_eeprom(struct net_device *net, struct ethtool_eeprom *eeprom,
>>
>>         if ((eeprom->offset + eeprom->len) & 1) {
>>                 ret = asix_read_cmd(dev, AX_CMD_READ_EEPROM, last_word, 0, 2,
>> -                                   &(eeprom_buff[last_word - first_word]));
>> +                                   &eeprom_buff[last_word - first_word], 0);
>>                 if (ret < 0) {
>>                         netdev_err(net, "Failed to read EEPROM at offset 0x%02x.\n", last_word);
>>                         goto free;
>> @@ -550,7 +644,7 @@ int asix_set_eeprom(struct net_device *net, struct ethtool_eeprom *eeprom,
>>         memcpy((u8 *)eeprom_buff + (eeprom->offset & 1), data, eeprom->len);
>>
>>         /* write data to EEPROM */
>> -       ret = asix_write_cmd(dev, AX_CMD_WRITE_ENABLE, 0x0000, 0, 0, NULL);
>> +       ret = asix_write_cmd(dev, AX_CMD_WRITE_ENABLE, 0x0000, 0, 0, NULL, 0);
>>         if (ret < 0) {
>>                 netdev_err(net, "Failed to enable EEPROM write\n");
>>                 goto free;
>> @@ -561,7 +655,7 @@ int asix_set_eeprom(struct net_device *net, struct ethtool_eeprom *eeprom,
>>                 netdev_dbg(net, "write to EEPROM at offset 0x%02x, data 0x%04x\n",
>>                            i, eeprom_buff[i - first_word]);
>>                 ret = asix_write_cmd(dev, AX_CMD_WRITE_EEPROM, i,
>> -                                    eeprom_buff[i - first_word], 0, NULL);
>> +                                    eeprom_buff[i - first_word], 0, NULL, 0);
>>                 if (ret < 0) {
>>                         netdev_err(net, "Failed to write EEPROM at offset 0x%02x.\n",
>>                                    i);
>> @@ -570,7 +664,7 @@ int asix_set_eeprom(struct net_device *net, struct ethtool_eeprom *eeprom,
>>                 msleep(20);
>>         }
>>
>> -       ret = asix_write_cmd(dev, AX_CMD_WRITE_DISABLE, 0x0000, 0, 0, NULL);
>> +       ret = asix_write_cmd(dev, AX_CMD_WRITE_DISABLE, 0x0000, 0, 0, NULL, 0);
>>         if (ret < 0) {
>>                 netdev_err(net, "Failed to disable EEPROM write\n");
>>                 goto free;
>> diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devices.c
>> index 5cabefc..aaa4290 100644
>> --- a/drivers/net/usb/asix_devices.c
>> +++ b/drivers/net/usb/asix_devices.c
>> @@ -184,7 +184,7 @@ static int ax88172_link_reset(struct usbnet *dev)
>>         netdev_dbg(dev->net, "ax88172_link_reset() speed: %u duplex: %d setting mode to 0x%04x\n",
>>                    ethtool_cmd_speed(&ecmd), ecmd.duplex, mode);
>>
>> -       asix_write_medium_mode(dev, mode);
>> +       asix_write_medium_mode(dev, mode, 0);
>>
>>         return 0;
>>  }
>> @@ -213,18 +213,19 @@ static int ax88172_bind(struct usbnet *dev, struct usb_interface *intf)
>>         /* Toggle the GPIOs in a manufacturer/model specific way */
>>         for (i = 2; i >= 0; i--) {
>>                 ret = asix_write_cmd(dev, AX_CMD_WRITE_GPIOS,
>> -                               (gpio_bits >> (i * 8)) & 0xff, 0, 0, NULL);
>> +                               (gpio_bits >> (i * 8)) & 0xff, 0, 0, NULL, 0);
>>                 if (ret < 0)
>>                         goto out;
>>                 msleep(5);
>>         }
>>
>> -       ret = asix_write_rx_ctl(dev, 0x80);
>> +       ret = asix_write_rx_ctl(dev, 0x80, 0);
>>         if (ret < 0)
>>                 goto out;
>>
>>         /* Get the MAC address */
>> -       ret = asix_read_cmd(dev, AX88172_CMD_READ_NODE_ID, 0, 0, ETH_ALEN, buf);
>> +       ret = asix_read_cmd(dev, AX88172_CMD_READ_NODE_ID,
>> +                           0, 0, ETH_ALEN, buf, 0);
>>         if (ret < 0) {
>>                 netdev_dbg(dev->net, "read AX_CMD_READ_NODE_ID failed: %d\n",
>>                            ret);
>> @@ -290,7 +291,7 @@ static int ax88772_link_reset(struct usbnet *dev)
>>         netdev_dbg(dev->net, "ax88772_link_reset() speed: %u duplex: %d setting mode to 0x%04x\n",
>>                    ethtool_cmd_speed(&ecmd), ecmd.duplex, mode);
>>
>> -       asix_write_medium_mode(dev, mode);
>> +       asix_write_medium_mode(dev, mode, 0);
>>
>>         return 0;
>>  }
>> @@ -298,78 +299,192 @@ static int ax88772_link_reset(struct usbnet *dev)
>>  static int ax88772_reset(struct usbnet *dev)
>>  {
>>         struct asix_data *data = (struct asix_data *)&dev->data;
>> +       int ret;
>> +
>> +       /* Rewrite MAC address */
>> +       ether_addr_copy(data->mac_addr, dev->net->dev_addr);
>> +       ret = asix_write_cmd(dev, AX_CMD_WRITE_NODE_ID, 0, 0,
>> +                            ETH_ALEN, data->mac_addr, 0);
>> +       if (ret < 0)
>> +               goto out;
>> +
>> +       /* Set RX_CTL to default values with 2k buffer, and enable cactus */
>> +       ret = asix_write_rx_ctl(dev, AX_DEFAULT_RX_CTL, 0);
>> +       if (ret < 0)
>> +               goto out;
>> +
>> +       asix_write_medium_mode(dev, AX88772_MEDIUM_DEFAULT, 0);
>> +       if (ret < 0)
>> +               goto out;
>> +
>> +       return 0;
>> +
>> +out:
>> +       return ret;
>> +}
>> +
>> +static int ax88772_hw_reset(struct usbnet *dev, int in_pm)
>> +{
>> +       struct asix_data *data = (struct asix_data *)&dev->data;
>>         int ret, embd_phy;
>>         u16 rx_ctl;
>>
>> -       ret = asix_write_gpio(dev,
>> -                       AX_GPIO_RSE | AX_GPIO_GPO_2 | AX_GPIO_GPO2EN, 5);
>> +       ret = asix_write_gpio(dev, AX_GPIO_RSE | AX_GPIO_GPO_2 |
>> +                             AX_GPIO_GPO2EN, 5, in_pm);
>>         if (ret < 0)
>>                 goto out;
>>
>> -       embd_phy = ((asix_get_phy_addr(dev) & 0x1f) == 0x10 ? 1 : 0);
>> +       embd_phy = ((dev->mii.phy_id & 0x1f) == 0x10 ? 1 : 0);
>>
>> -       ret = asix_write_cmd(dev, AX_CMD_SW_PHY_SELECT, embd_phy, 0, 0, NULL);
>> +       ret = asix_write_cmd(dev, AX_CMD_SW_PHY_SELECT, embd_phy,
>> +                            0, 0, NULL, in_pm);
>>         if (ret < 0) {
>>                 netdev_dbg(dev->net, "Select PHY #1 failed: %d\n", ret);
>>                 goto out;
>>         }
>>
>> -       ret = asix_sw_reset(dev, AX_SWRESET_IPPD | AX_SWRESET_PRL);
>> -       if (ret < 0)
>> -               goto out;
>> +       if (embd_phy) {
>> +               ret = asix_sw_reset(dev, AX_SWRESET_IPPD, in_pm);
>> +               if (ret < 0)
>> +                       goto out;
>>
>> -       msleep(150);
>> +               usleep_range(10000, 11000);
>>
>> -       ret = asix_sw_reset(dev, AX_SWRESET_CLEAR);
>> -       if (ret < 0)
>> -               goto out;
>> +               ret = asix_sw_reset(dev, AX_SWRESET_CLEAR, in_pm);
>> +               if (ret < 0)
>> +                       goto out;
>>
>> -       msleep(150);
>> +               msleep(60);
>>
>> -       if (embd_phy) {
>> -               ret = asix_sw_reset(dev, AX_SWRESET_IPRL);
>> +               ret = asix_sw_reset(dev, AX_SWRESET_IPRL | AX_SWRESET_PRL,
>> +                                   in_pm);
>>                 if (ret < 0)
>>                         goto out;
>>         } else {
>> -               ret = asix_sw_reset(dev, AX_SWRESET_PRTE);
>> +               ret = asix_sw_reset(dev, AX_SWRESET_IPPD | AX_SWRESET_PRL,
>> +                                   in_pm);
>>                 if (ret < 0)
>>                         goto out;
>>         }
>>
>>         msleep(150);
>> -       rx_ctl = asix_read_rx_ctl(dev);
>> -       netdev_dbg(dev->net, "RX_CTL is 0x%04x after software reset\n", rx_ctl);
>> -       ret = asix_write_rx_ctl(dev, 0x0000);
>> +
>> +       if (in_pm && (!asix_mdio_read_nopm(dev->net, dev->mii.phy_id,
>> +                                          MII_PHYSID1))){
>> +               ret = -EIO;
>> +               goto out;
>> +       }
>> +
>> +       ret = asix_write_rx_ctl(dev, AX_DEFAULT_RX_CTL, in_pm);
>> +       if (ret < 0)
>> +               goto out;
>> +
>> +       ret = asix_write_medium_mode(dev, AX88772_MEDIUM_DEFAULT, in_pm);
>>         if (ret < 0)
>>                 goto out;
>>
>> -       rx_ctl = asix_read_rx_ctl(dev);
>> -       netdev_dbg(dev->net, "RX_CTL is 0x%04x setting to 0x0000\n", rx_ctl);
>> +       ret = asix_write_cmd(dev, AX_CMD_WRITE_IPG0,
>> +                            AX88772_IPG0_DEFAULT | AX88772_IPG1_DEFAULT,
>> +                            AX88772_IPG2_DEFAULT, 0, NULL, in_pm);
>> +       if (ret < 0) {
>> +               netdev_dbg(dev->net, "Write IPG,IPG1,IPG2 failed: %d\n", ret);
>> +               goto out;
>> +       }
>>
>> -       ret = asix_sw_reset(dev, AX_SWRESET_PRL);
>> +       /* Rewrite MAC address */
>> +       ether_addr_copy(data->mac_addr, dev->net->dev_addr);
>> +       ret = asix_write_cmd(dev, AX_CMD_WRITE_NODE_ID, 0, 0,
>> +                            ETH_ALEN, data->mac_addr, in_pm);
>>         if (ret < 0)
>>                 goto out;
>>
>> -       msleep(150);
>> +       /* Set RX_CTL to default values with 2k buffer, and enable cactus */
>> +       ret = asix_write_rx_ctl(dev, AX_DEFAULT_RX_CTL, in_pm);
>> +       if (ret < 0)
>> +               goto out;
>> +
>> +       rx_ctl = asix_read_rx_ctl(dev, in_pm);
>> +       netdev_dbg(dev->net, "RX_CTL is 0x%04x after all initializations\n",
>> +                  rx_ctl);
>> +
>> +       rx_ctl = asix_read_medium_status(dev, in_pm);
>> +       netdev_dbg(dev->net,
>> +                  "Medium Status is 0x%04x after all initializations\n",
>> +                  rx_ctl);
>> +
>> +       return 0;
>> +
>> +out:
>> +       return ret;
>> +}
>> +
>> +static int ax88772a_hw_reset(struct usbnet *dev, int in_pm)
>> +{
>> +       struct asix_data *data = (struct asix_data *)&dev->data;
>> +       int ret, embd_phy;
>> +       u16 rx_ctl;
>> +       u8 chipcode = 0;
>>
>> -       ret = asix_sw_reset(dev, AX_SWRESET_IPRL | AX_SWRESET_PRL);
>> +       ret = asix_write_gpio(dev, AX_GPIO_RSE, 5, in_pm);
>>         if (ret < 0)
>>                 goto out;
>>
>> -       msleep(150);
>> +       embd_phy = ((dev->mii.phy_id & 0x1f) == 0x10 ? 1 : 0);
>>
>> -       asix_mdio_write(dev->net, dev->mii.phy_id, MII_BMCR, BMCR_RESET);
>> -       asix_mdio_write(dev->net, dev->mii.phy_id, MII_ADVERTISE,
>> -                       ADVERTISE_ALL | ADVERTISE_CSMA);
>> -       mii_nway_restart(&dev->mii);
>> +       ret = asix_write_cmd(dev, AX_CMD_SW_PHY_SELECT, embd_phy |
>> +                            AX_PHYSEL_SSEN, 0, 0, NULL, in_pm);
>> +       if (ret < 0) {
>> +               netdev_dbg(dev->net, "Select PHY #1 failed: %d\n", ret);
>> +               goto out;
>> +       }
>> +       usleep_range(10000, 11000);
>>
>> -       ret = asix_write_medium_mode(dev, AX88772_MEDIUM_DEFAULT);
>> +       ret = asix_sw_reset(dev, AX_SWRESET_IPPD | AX_SWRESET_IPRL, in_pm);
>>         if (ret < 0)
>>                 goto out;
>>
>> +       usleep_range(10000, 11000);
>> +
>> +       ret = asix_sw_reset(dev, AX_SWRESET_IPRL, in_pm);
>> +       if (ret < 0)
>> +               goto out;
>> +
>> +       msleep(160);
>> +
>> +       ret = asix_sw_reset(dev, AX_SWRESET_CLEAR, in_pm);
>> +       if (ret < 0)
>> +               goto out;
>> +
>> +       ret = asix_sw_reset(dev, AX_SWRESET_IPRL, in_pm);
>> +       if (ret < 0)
>> +               goto out;
>> +
>> +       msleep(200);
>> +
>> +       if (in_pm && (!asix_mdio_read_nopm(dev->net, dev->mii.phy_id,
>> +                                          MII_PHYSID1))) {
>> +               ret = -1;
>> +               goto out;
>> +       }
>> +
>> +       ret = asix_read_cmd(dev, AX_CMD_STATMNGSTS_REG, 0,
>> +                           0, 1, &chipcode, in_pm);
>> +       if (ret < 0)
>> +               goto out;
>> +
>> +       if ((chipcode & AX_CHIPCODE_MASK) == AX_AX88772B_CHIPCODE) {
>> +               ret = asix_write_cmd(dev, AX_QCTCTRL, 0x8000, 0x8001,
>> +                                    0, NULL, in_pm);
>> +               if (ret < 0) {
>> +                       netdev_dbg(dev->net, "Write BQ setting failed: %d\n",
>> +                                  ret);
>> +                       goto out;
>> +               }
>> +       }
>> +
>>         ret = asix_write_cmd(dev, AX_CMD_WRITE_IPG0,
>>                                 AX88772_IPG0_DEFAULT | AX88772_IPG1_DEFAULT,
>> -                               AX88772_IPG2_DEFAULT, 0, NULL);
>> +                               AX88772_IPG2_DEFAULT, 0, NULL, in_pm);
>>         if (ret < 0) {
>>                 netdev_dbg(dev->net, "Write IPG,IPG1,IPG2 failed: %d\n", ret);
>>                 goto out;
>> @@ -378,20 +493,29 @@ static int ax88772_reset(struct usbnet *dev)
>>         /* Rewrite MAC address */
>>         memcpy(data->mac_addr, dev->net->dev_addr, ETH_ALEN);
>>         ret = asix_write_cmd(dev, AX_CMD_WRITE_NODE_ID, 0, 0, ETH_ALEN,
>> -                                                       data->mac_addr);
>> +                                                       data->mac_addr, in_pm);
>> +       if (ret < 0)
>> +               goto out;
>> +
>> +       /* Set RX_CTL to default values with 2k buffer, and enable cactus */
>> +       ret = asix_write_rx_ctl(dev, AX_DEFAULT_RX_CTL, in_pm);
>>         if (ret < 0)
>>                 goto out;
>>
>> +       ret = asix_write_medium_mode(dev, AX88772_MEDIUM_DEFAULT, in_pm);
>> +       if (ret < 0)
>> +               return ret;
>> +
>>         /* Set RX_CTL to default values with 2k buffer, and enable cactus */
>> -       ret = asix_write_rx_ctl(dev, AX_DEFAULT_RX_CTL);
>> +       ret = asix_write_rx_ctl(dev, AX_DEFAULT_RX_CTL, in_pm);
>>         if (ret < 0)
>>                 goto out;
>>
>> -       rx_ctl = asix_read_rx_ctl(dev);
>> +       rx_ctl = asix_read_rx_ctl(dev, in_pm);
>>         netdev_dbg(dev->net, "RX_CTL is 0x%04x after all initializations\n",
>>                    rx_ctl);
>>
>> -       rx_ctl = asix_read_medium_status(dev);
>> +       rx_ctl = asix_read_medium_status(dev, in_pm);
>>         netdev_dbg(dev->net,
>>                    "Medium Status is 0x%04x after all initializations\n",
>>                    rx_ctl);
>> @@ -400,7 +524,6 @@ static int ax88772_reset(struct usbnet *dev)
>>
>>  out:
>>         return ret;
>> -
>>  }
>>
>>  static const struct net_device_ops ax88772_netdev_ops = {
>> @@ -415,11 +538,87 @@ static const struct net_device_ops ax88772_netdev_ops = {
>>         .ndo_set_rx_mode        = asix_set_multicast,
>>  };
>>
>> +static void ax88772_suspend(struct usbnet *dev)
>> +{
>> +       struct asix_common_private *priv = dev->driver_priv;
>> +
>> +       /* Preserve BMCR for restoring */
>> +       priv->presvd_phy_bmcr =
>> +               asix_mdio_read_nopm(dev->net, dev->mii.phy_id, MII_BMCR);
>> +
>> +       /* Preserve ANAR for restoring */
>> +       priv->presvd_phy_advertise =
>> +               asix_mdio_read_nopm(dev->net, dev->mii.phy_id, MII_ADVERTISE);
>> +}
>> +
>> +static int asix_suspend(struct usb_interface *intf, pm_message_t message)
>> +{
>> +       struct usbnet *dev = usb_get_intfdata(intf);
>> +       struct asix_common_private *priv = dev->driver_priv;
>> +
>> +       if (priv->suspend)
>> +               priv->suspend(dev);
>> +
>> +       return usbnet_suspend(intf, message);
>> +}
>> +
>> +static void ax88772_restore_phy(struct usbnet *dev)
>> +{
>> +       struct asix_common_private *priv = dev->driver_priv;
>> +
>> +       if (priv->presvd_phy_advertise) {
>> +               /* Restore Advertisement control reg */
>> +               asix_mdio_write_nopm(dev->net, dev->mii.phy_id, MII_ADVERTISE,
>> +                                    priv->presvd_phy_advertise);
>> +
>> +               /* Restore BMCR */
>> +               asix_mdio_write_nopm(dev->net, dev->mii.phy_id, MII_BMCR,
>> +                                    priv->presvd_phy_bmcr);
>> +
>> +               priv->presvd_phy_advertise = 0;
>> +               priv->presvd_phy_bmcr = 0;
>> +       }
>> +}
>> +
>> +static void ax88772_resume(struct usbnet *dev)
>> +{
>> +       int i;
>> +
>> +       for (i = 0; i < 3; i++)
>> +               if (!ax88772_hw_reset(dev, 1))
>> +                       break;
>> +       ax88772_restore_phy(dev);
>> +}
>> +
>> +static void ax88772a_resume(struct usbnet *dev)
>> +{
>> +       int i;
>> +
>> +       for (i = 0; i < 3; i++) {
>> +               if (!ax88772a_hw_reset(dev, 1))
>> +                       break;
>> +       }
>> +
>> +       ax88772_restore_phy(dev);
>> +}
>> +
>> +static int asix_resume(struct usb_interface *intf)
>> +{
>> +       struct usbnet *dev = usb_get_intfdata(intf);
>> +       struct asix_common_private *priv = dev->driver_priv;
>> +
>> +       if (priv->resume)
>> +               priv->resume(dev);
>> +
>> +       return usbnet_resume(intf);
>> +}
>> +
>>  static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
>>  {
>> -       int ret, embd_phy, i;
>> -       u8 buf[ETH_ALEN];
>> +       int ret, i;
>> +       u8 buf[ETH_ALEN], chipcode = 0;
>>         u32 phyid;
>> +       struct asix_common_private *priv;
>>
>>         usbnet_get_endpoints(dev,intf);
>>
>> @@ -427,13 +626,13 @@ static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
>>         if (dev->driver_info->data & FLAG_EEPROM_MAC) {
>>                 for (i = 0; i < (ETH_ALEN >> 1); i++) {
>>                         ret = asix_read_cmd(dev, AX_CMD_READ_EEPROM, 0x04 + i,
>> -                                       0, 2, buf + i * 2);
>> +                                           0, 2, buf + i * 2, 0);
>>                         if (ret < 0)
>>                                 break;
>>                 }
>>         } else {
>>                 ret = asix_read_cmd(dev, AX_CMD_READ_NODE_ID,
>> -                               0, 0, ETH_ALEN, buf);
>> +                               0, 0, ETH_ALEN, buf, 0);
>>         }
>>
>>         if (ret < 0) {
>> @@ -456,16 +655,11 @@ static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
>>         dev->net->needed_headroom = 4; /* cf asix_tx_fixup() */
>>         dev->net->needed_tailroom = 4; /* cf asix_tx_fixup() */
>>
>> -       embd_phy = ((dev->mii.phy_id & 0x1f) == 0x10 ? 1 : 0);
>> +       asix_read_cmd(dev, AX_CMD_STATMNGSTS_REG, 0, 0, 1, &chipcode, 0);
>> +       chipcode &= AX_CHIPCODE_MASK;
>>
>> -       /* Reset the PHY to normal operation mode */
>> -       ret = asix_write_cmd(dev, AX_CMD_SW_PHY_SELECT, embd_phy, 0, 0, NULL);
>> -       if (ret < 0) {
>> -               netdev_dbg(dev->net, "Select PHY #1 failed: %d\n", ret);
>> -               return ret;
>> -       }
>> -
>> -       ax88772_reset(dev);
>> +       (chipcode == AX_AX88772_CHIPCODE) ? ax88772_hw_reset(dev, 0) :
>> +                                           ax88772a_hw_reset(dev, 0);
>>
>>         /* Read PHYID register *AFTER* the PHY was reset properly */
>>         phyid = asix_get_phyid(dev);
>> @@ -482,6 +676,18 @@ static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
>>         if (!dev->driver_priv)
>>                 return -ENOMEM;
>>
>> +       priv = dev->driver_priv;
>> +
>> +       priv->presvd_phy_bmcr = 0;
>> +       priv->presvd_phy_advertise = 0;
>> +       if (chipcode == AX_AX88772_CHIPCODE) {
>> +               priv->resume = ax88772_resume;
>> +               priv->suspend = ax88772_suspend;
>> +       } else {
>> +               priv->resume = ax88772a_resume;
>> +               priv->suspend = ax88772_suspend;
>> +       }
>> +
>>         return 0;
>>  }
>>
>> @@ -593,12 +799,12 @@ static int ax88178_reset(struct usbnet *dev)
>>         int gpio0 = 0;
>>         u32 phyid;
>>
>> -       asix_read_cmd(dev, AX_CMD_READ_GPIOS, 0, 0, 1, &status);
>> +       asix_read_cmd(dev, AX_CMD_READ_GPIOS, 0, 0, 1, &status, 0);
>>         netdev_dbg(dev->net, "GPIO Status: 0x%04x\n", status);
>>
>> -       asix_write_cmd(dev, AX_CMD_WRITE_ENABLE, 0, 0, 0, NULL);
>> -       asix_read_cmd(dev, AX_CMD_READ_EEPROM, 0x0017, 0, 2, &eeprom);
>> -       asix_write_cmd(dev, AX_CMD_WRITE_DISABLE, 0, 0, 0, NULL);
>> +       asix_write_cmd(dev, AX_CMD_WRITE_ENABLE, 0, 0, 0, NULL, 0);
>> +       asix_read_cmd(dev, AX_CMD_READ_EEPROM, 0x0017, 0, 2, &eeprom, 0);
>> +       asix_write_cmd(dev, AX_CMD_WRITE_DISABLE, 0, 0, 0, NULL, 0);
>>
>>         netdev_dbg(dev->net, "EEPROM index 0x17 is 0x%04x\n", eeprom);
>>
>> @@ -614,15 +820,16 @@ static int ax88178_reset(struct usbnet *dev)
>>         netdev_dbg(dev->net, "GPIO0: %d, PhyMode: %d\n", gpio0, data->phymode);
>>
>>         /* Power up external GigaPHY through AX88178 GPIO pin */
>> -       asix_write_gpio(dev, AX_GPIO_RSE | AX_GPIO_GPO_1 | AX_GPIO_GPO1EN, 40);
>> +       asix_write_gpio(dev, AX_GPIO_RSE | AX_GPIO_GPO_1 |
>> +                       AX_GPIO_GPO1EN, 40, 0);
>>         if ((le16_to_cpu(eeprom) >> 8) != 1) {
>> -               asix_write_gpio(dev, 0x003c, 30);
>> -               asix_write_gpio(dev, 0x001c, 300);
>> -               asix_write_gpio(dev, 0x003c, 30);
>> +               asix_write_gpio(dev, 0x003c, 30, 0);
>> +               asix_write_gpio(dev, 0x001c, 300, 0);
>> +               asix_write_gpio(dev, 0x003c, 30, 0);
>>         } else {
>>                 netdev_dbg(dev->net, "gpio phymode == 1 path\n");
>> -               asix_write_gpio(dev, AX_GPIO_GPO1EN, 30);
>> -               asix_write_gpio(dev, AX_GPIO_GPO1EN | AX_GPIO_GPO_1, 30);
>> +               asix_write_gpio(dev, AX_GPIO_GPO1EN, 30, 0);
>> +               asix_write_gpio(dev, AX_GPIO_GPO1EN | AX_GPIO_GPO_1, 30, 0);
>>         }
>>
>>         /* Read PHYID register *AFTER* powering up PHY */
>> @@ -630,15 +837,15 @@ static int ax88178_reset(struct usbnet *dev)
>>         netdev_dbg(dev->net, "PHYID=0x%08x\n", phyid);
>>
>>         /* Set AX88178 to enable MII/GMII/RGMII interface for external PHY */
>> -       asix_write_cmd(dev, AX_CMD_SW_PHY_SELECT, 0, 0, 0, NULL);
>> +       asix_write_cmd(dev, AX_CMD_SW_PHY_SELECT, 0, 0, 0, NULL, 0);
>>
>> -       asix_sw_reset(dev, 0);
>> +       asix_sw_reset(dev, 0, 0);
>>         msleep(150);
>>
>> -       asix_sw_reset(dev, AX_SWRESET_PRL | AX_SWRESET_IPPD);
>> +       asix_sw_reset(dev, AX_SWRESET_PRL | AX_SWRESET_IPPD, 0);
>>         msleep(150);
>>
>> -       asix_write_rx_ctl(dev, 0);
>> +       asix_write_rx_ctl(dev, 0, 0);
>>
>>         if (data->phymode == PHY_MODE_MARVELL) {
>>                 marvell_phy_init(dev);
>> @@ -655,18 +862,18 @@ static int ax88178_reset(struct usbnet *dev)
>>
>>         mii_nway_restart(&dev->mii);
>>
>> -       ret = asix_write_medium_mode(dev, AX88178_MEDIUM_DEFAULT);
>> +       ret = asix_write_medium_mode(dev, AX88178_MEDIUM_DEFAULT, 0);
>>         if (ret < 0)
>>                 return ret;
>>
>>         /* Rewrite MAC address */
>>         memcpy(data->mac_addr, dev->net->dev_addr, ETH_ALEN);
>>         ret = asix_write_cmd(dev, AX_CMD_WRITE_NODE_ID, 0, 0, ETH_ALEN,
>> -                                                       data->mac_addr);
>> +                                                       data->mac_addr, 0);
>>         if (ret < 0)
>>                 return ret;
>>
>> -       ret = asix_write_rx_ctl(dev, AX_DEFAULT_RX_CTL);
>> +       ret = asix_write_rx_ctl(dev, AX_DEFAULT_RX_CTL, 0);
>>         if (ret < 0)
>>                 return ret;
>>
>> @@ -704,7 +911,7 @@ static int ax88178_link_reset(struct usbnet *dev)
>>         netdev_dbg(dev->net, "ax88178_link_reset() speed: %u duplex: %d setting mode to 0x%04x\n",
>>                    speed, ecmd.duplex, mode);
>>
>> -       asix_write_medium_mode(dev, mode);
>> +       asix_write_medium_mode(dev, mode, 0);
>>
>>         if (data->phymode == PHY_MODE_MARVELL && data->ledmode)
>>                 marvell_led_status(dev, speed);
>> @@ -733,15 +940,15 @@ static void ax88178_set_mfb(struct usbnet *dev)
>>                 mfb = AX_RX_CTL_MFB_16384;
>>         }
>>
>> -       rxctl = asix_read_rx_ctl(dev);
>> -       asix_write_rx_ctl(dev, (rxctl & ~AX_RX_CTL_MFB_16384) | mfb);
>> +       rxctl = asix_read_rx_ctl(dev, 0);
>> +       asix_write_rx_ctl(dev, (rxctl & ~AX_RX_CTL_MFB_16384) | mfb, 0);
>>
>> -       medium = asix_read_medium_status(dev);
>> +       medium = asix_read_medium_status(dev, 0);
>>         if (dev->net->mtu > 1500)
>>                 medium |= AX_MEDIUM_JFE;
>>         else
>>                 medium &= ~AX_MEDIUM_JFE;
>> -       asix_write_medium_mode(dev, medium);
>> +       asix_write_medium_mode(dev, medium, 0);
>>
>>         if (dev->rx_urb_size > old_rx_urb_size)
>>                 usbnet_unlink_rx_urbs(dev);
>> @@ -790,7 +997,7 @@ static int ax88178_bind(struct usbnet *dev, struct usb_interface *intf)
>>         usbnet_get_endpoints(dev,intf);
>>
>>         /* Get the MAC address */
>> -       ret = asix_read_cmd(dev, AX_CMD_READ_NODE_ID, 0, 0, ETH_ALEN, buf);
>> +       ret = asix_read_cmd(dev, AX_CMD_READ_NODE_ID, 0, 0, ETH_ALEN, buf, 0);
>>         if (ret < 0) {
>>                 netdev_dbg(dev->net, "Failed to read MAC address: %d\n", ret);
>>                 return ret;
>> @@ -811,10 +1018,10 @@ static int ax88178_bind(struct usbnet *dev, struct usb_interface *intf)
>>         dev->net->ethtool_ops = &ax88178_ethtool_ops;
>>
>>         /* Blink LEDS so users know driver saw dongle */
>> -       asix_sw_reset(dev, 0);
>> +       asix_sw_reset(dev, 0, 0);
>>         msleep(150);
>>
>> -       asix_sw_reset(dev, AX_SWRESET_PRL | AX_SWRESET_IPPD);
>> +       asix_sw_reset(dev, AX_SWRESET_PRL | AX_SWRESET_IPPD, 0);
>>         msleep(150);
>>
>>         /* Asix framing packs multiple eth frames into a 2K usb bulk transfer */
>> @@ -877,7 +1084,7 @@ static const struct driver_info ax88772_info = {
>>         .unbind = ax88772_unbind,
>>         .status = asix_status,
>>         .link_reset = ax88772_link_reset,
>> -       .reset = ax88772_link_reset,
>> +       .reset = ax88772_reset,
>>         .flags = FLAG_ETHER | FLAG_FRAMING_AX | FLAG_LINK_INTR | FLAG_MULTI_PACKET,
>>         .rx_fixup = asix_rx_fixup_common,
>>         .tx_fixup = asix_tx_fixup,
>> @@ -1005,7 +1212,7 @@ static const struct usb_device_id products [] = {
>>  }, {
>>         // Lenovo U2L100P 10/100
>>         USB_DEVICE (0x17ef, 0x7203),
>> -       .driver_info = (unsigned long) &ax88772_info,
>> +       .driver_info = (unsigned long)&ax88772b_info,
>>  }, {
>>         // ASIX AX88772B 10/100
>>         USB_DEVICE (0x0b95, 0x772b),
>> @@ -1073,7 +1280,7 @@ static const struct usb_device_id products [] = {
>>  }, {
>>         // Asus USB Ethernet Adapter
>>         USB_DEVICE (0x0b95, 0x7e2b),
>> -       .driver_info = (unsigned long) &ax88772_info,
>> +       .driver_info = (unsigned long)&ax88772b_info,
>>  }, {
>>         /* ASIX 88172a demo board */
>>         USB_DEVICE(0x0b95, 0x172a),
>> @@ -1095,8 +1302,8 @@ static struct usb_driver asix_driver = {
>>         .name =         DRIVER_NAME,
>>         .id_table =     products,
>>         .probe =        usbnet_probe,
>> -       .suspend =      usbnet_suspend,
>> -       .resume =       usbnet_resume,
>> +       .suspend =      asix_suspend,
>> +       .resume =       asix_resume,
>>         .disconnect =   usbnet_disconnect,
>>         .supports_autosuspend = 1,
>>         .disable_hub_initiated_lpm = 1,
>> diff --git a/drivers/net/usb/ax88172a.c b/drivers/net/usb/ax88172a.c
>> index 5f18fcb..c2394f1 100644
>> --- a/drivers/net/usb/ax88172a.c
>> +++ b/drivers/net/usb/ax88172a.c
>> @@ -81,7 +81,7 @@ static void ax88172a_adjust_link(struct net_device *netdev)
>>         }
>>
>>         if (mode != priv->oldmode) {
>> -               asix_write_medium_mode(dev, mode);
>> +               asix_write_medium_mode(dev, mode, 0);
>>                 priv->oldmode = mode;
>>                 netdev_dbg(netdev, "speed %u duplex %d, setting mode to 0x%04x\n",
>>                            phydev->speed, phydev->duplex, mode);
>> @@ -205,18 +205,19 @@ static int ax88172a_reset_phy(struct usbnet *dev, int embd_phy)
>>  {
>>         int ret;
>>
>> -       ret = asix_sw_reset(dev, AX_SWRESET_IPPD);
>> +       ret = asix_sw_reset(dev, AX_SWRESET_IPPD, 0);
>>         if (ret < 0)
>>                 goto err;
>>
>>         msleep(150);
>> -       ret = asix_sw_reset(dev, AX_SWRESET_CLEAR);
>> +       ret = asix_sw_reset(dev, AX_SWRESET_CLEAR, 0);
>>         if (ret < 0)
>>                 goto err;
>>
>>         msleep(150);
>>
>> -       ret = asix_sw_reset(dev, embd_phy ? AX_SWRESET_IPRL : AX_SWRESET_IPPD);
>> +       ret = asix_sw_reset(dev, embd_phy ? AX_SWRESET_IPRL : AX_SWRESET_IPPD,
>> +                           0);
>>         if (ret < 0)
>>                 goto err;
>>
>> @@ -242,7 +243,7 @@ static int ax88172a_bind(struct usbnet *dev, struct usb_interface *intf)
>>         dev->driver_priv = priv;
>>
>>         /* Get the MAC address */
>> -       ret = asix_read_cmd(dev, AX_CMD_READ_NODE_ID, 0, 0, ETH_ALEN, buf);
>> +       ret = asix_read_cmd(dev, AX_CMD_READ_NODE_ID, 0, 0, ETH_ALEN, buf, 0);
>>         if (ret < 0) {
>>                 netdev_err(dev->net, "Failed to read MAC address: %d\n", ret);
>>                 goto free;
>> @@ -253,7 +254,7 @@ static int ax88172a_bind(struct usbnet *dev, struct usb_interface *intf)
>>         dev->net->ethtool_ops = &ax88172a_ethtool_ops;
>>
>>         /* are we using the internal or the external phy? */
>> -       ret = asix_read_cmd(dev, AX_CMD_SW_PHY_STATUS, 0, 0, 1, buf);
>> +       ret = asix_read_cmd(dev, AX_CMD_SW_PHY_STATUS, 0, 0, 1, buf, 0);
>>         if (ret < 0) {
>>                 netdev_err(dev->net, "Failed to read software interface selection register: %d\n",
>>                            ret);
>> @@ -332,20 +333,20 @@ static int ax88172a_reset(struct usbnet *dev)
>>         ax88172a_reset_phy(dev, priv->use_embdphy);
>>
>>         msleep(150);
>> -       rx_ctl = asix_read_rx_ctl(dev);
>> +       rx_ctl = asix_read_rx_ctl(dev, 0);
>>         netdev_dbg(dev->net, "RX_CTL is 0x%04x after software reset\n", rx_ctl);
>> -       ret = asix_write_rx_ctl(dev, 0x0000);
>> +       ret = asix_write_rx_ctl(dev, 0x0000, 0);
>>         if (ret < 0)
>>                 goto out;
>>
>> -       rx_ctl = asix_read_rx_ctl(dev);
>> +       rx_ctl = asix_read_rx_ctl(dev, 0);
>>         netdev_dbg(dev->net, "RX_CTL is 0x%04x setting to 0x0000\n", rx_ctl);
>>
>>         msleep(150);
>>
>>         ret = asix_write_cmd(dev, AX_CMD_WRITE_IPG0,
>>                              AX88772_IPG0_DEFAULT | AX88772_IPG1_DEFAULT,
>> -                            AX88772_IPG2_DEFAULT, 0, NULL);
>> +                            AX88772_IPG2_DEFAULT, 0, NULL, 0);
>>         if (ret < 0) {
>>                 netdev_err(dev->net, "Write IPG,IPG1,IPG2 failed: %d\n", ret);
>>                 goto out;
>> @@ -354,20 +355,20 @@ static int ax88172a_reset(struct usbnet *dev)
>>         /* Rewrite MAC address */
>>         memcpy(data->mac_addr, dev->net->dev_addr, ETH_ALEN);
>>         ret = asix_write_cmd(dev, AX_CMD_WRITE_NODE_ID, 0, 0, ETH_ALEN,
>> -                            data->mac_addr);
>> +                            data->mac_addr, 0);
>>         if (ret < 0)
>>                 goto out;
>>
>>         /* Set RX_CTL to default values with 2k buffer, and enable cactus */
>> -       ret = asix_write_rx_ctl(dev, AX_DEFAULT_RX_CTL);
>> +       ret = asix_write_rx_ctl(dev, AX_DEFAULT_RX_CTL, 0);
>>         if (ret < 0)
>>                 goto out;
>>
>> -       rx_ctl = asix_read_rx_ctl(dev);
>> +       rx_ctl = asix_read_rx_ctl(dev, 0);
>>         netdev_dbg(dev->net, "RX_CTL is 0x%04x after all initializations\n",
>>                    rx_ctl);
>>
>> -       rx_ctl = asix_read_medium_status(dev);
>> +       rx_ctl = asix_read_medium_status(dev, 0);
>>         netdev_dbg(dev->net, "Medium Status is 0x%04x after all initializations\n",
>>                    rx_ctl);
>>
>> --
>> 2.7.4
>>
