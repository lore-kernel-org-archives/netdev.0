From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH] usbnet: ax88179_178a: Add support for writing the EEPROM
Date: Wed, 24 Aug 2016 16:30:39 +0200
Message-ID: <1472049039.11480.10.camel@suse.com>
References: <20160824135231.21782-1-alban.bedel@avionic-design.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, Freddy Xin <freddy@asix.com.tw>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Alban Bedel <alban.bedel@avionic-design.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160824135231.21782-1-alban.bedel@avionic-design.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-08-24 at 15:52 +0200, Alban Bedel wrote:
> Implement the .set_eeprom callback to allow setting the MAC address
> as well as a few other parameters. Note that the EEPROM must have a
> correct PID/VID checksum set otherwise the SROM is used and reads
> return the SROM content.
> 
> Signed-off-by: Alban Bedel <alban.bedel@avionic-design.de>
> ---
>  drivers/net/usb/ax88179_178a.c | 57
> ++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 57 insertions(+)
> 
> diff --git a/drivers/net/usb/ax88179_178a.c
> b/drivers/net/usb/ax88179_178a.c
> index e6338c16081a..e6a986303dad 100644
> --- a/drivers/net/usb/ax88179_178a.c
> +++ b/drivers/net/usb/ax88179_178a.c
> @@ -28,6 +28,7 @@
>  
>  #define AX88179_PHY_ID                         0x03
>  #define AX_EEPROM_LEN                          0x100
> +#define AX_EEPROM_BLOCK                                0x40u
>  #define AX88179_EEPROM_MAGIC                   0x17900b95
>  #define AX_MCAST_FLTSIZE                       8
>  #define AX_MAX_MCAST                           64
> @@ -43,6 +44,7 @@
>  #define AX_ACCESS_PHY                          0x02
>  #define AX_ACCESS_EEPROM                       0x04
>  #define AX_ACCESS_EFUS                         0x05
> +#define AX_RELOAD_EEPROM                       0x06
>  #define AX_PAUSE_WATERLVL_HIGH                 0x54
>  #define AX_PAUSE_WATERLVL_LOW                  0x55
>  
> @@ -620,6 +622,60 @@ ax88179_get_eeprom(struct net_device *net, struct
> ethtool_eeprom *eeprom,
>         return 0;
>  }
>  
> +static int
> +ax88179_set_eeprom(struct net_device *net, struct ethtool_eeprom
> *eeprom,
> +                  u8 *data)
> +{
> +       struct usbnet *dev = netdev_priv(net);
> +       unsigned int offset = eeprom->offset;
> +       unsigned int len = eeprom->len;
> +       int i, err = 0;
> +       u8 *block;
> +
> +       /* The EEPROM data must be aligned on blocks of 64 bytes */
> +       if ((offset % AX_EEPROM_BLOCK) || (len % AX_EEPROM_BLOCK)) {
> +               offset = eeprom->offset / AX_EEPROM_BLOCK *
> AX_EEPROM_BLOCK;
> +               len = eeprom->len + eeprom->offset - offset;
> +               len = DIV_ROUND_UP(len, AX_EEPROM_BLOCK) *
> AX_EEPROM_BLOCK;
> +
> +               block = kmalloc(len, GFP_KERNEL);
> +               if (!block)
> +                       return -ENOMEM;
> +
> +               /* Copy the current data, we could skip some but KISS
> */
> +               for (i = 0; i < len; i += AX_EEPROM_BLOCK) {
> +                       err = __ax88179_read_cmd(dev,
> AX_ACCESS_EEPROM,
> +                                                (offset + i) >> 1,
> +                                                AX_EEPROM_BLOCK >> 1,
> +                                                AX_EEPROM_BLOCK,
> +                                                &block[i], 0);
> +                       if (err < 0) {
> +                               kfree(block);
> +                               return err;
> +                       }
> +               }
> +               memcpy(block + eeprom->offset - offset, data,
> eeprom->len);
> +       } else {
> +               block = data;
> +       }
> +
> +       for (i = 0; err >= 0 && i < len; i += AX_EEPROM_BLOCK) {
> +               err = ax88179_write_cmd(dev, AX_ACCESS_EEPROM,
> +                                       (offset + i) >> 1,
> +                                       AX_EEPROM_BLOCK >> 1,
> +                                       AX_EEPROM_BLOCK, &block[i]);
> +       }
> +
> +       if (block != data)
> +               kfree(block);

And if block == dta, what frees the memory?

	Regards
		Oliver
