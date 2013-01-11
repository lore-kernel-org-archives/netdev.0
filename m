From: "Freddy" <freddy@asix.com.tw>
Subject: RE: [PATCH] ax88179_178a: ASIX AX88179_178A USB 3.0/2.0 to gigabit ethernet adapter driver
Date: Fri, 11 Jan 2013 17:30:19 +0800
Message-ID: <00af01cdefde$46ecbab0$d4c63010$@asix.com.tw>
References: <1357867046-22918-1-git-send-email-freddy@asix.com.tw> <CACVXFVMdgx1we67poF5yU5pAYRYoA9Ao1EJqQgGBaaORuARFQQ@mail.gmail.com> <50EFCAE6.9070306@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Ming Lei'" <ming.lei@canonical.com>, <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>, <louis@asix.com.tw>,
	<netdev@vger.kernel.org>, <linux-usb@vger.kernel.org>
To: "'Christian Riesch'" <christian.riesch@omicron.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50EFCAE6.9070306@omicron.at>
Content-Language: zh-tw
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

>> +static int ax88179_read_cmd(struct usbnet *dev, u8 cmd, u16 value, u16
index,
>> +                           u16 size, void *data) {
>> +       int ret;
>> +       ret = usbnet_read_cmd(dev, cmd,
>> +                              USB_DIR_IN | USB_TYPE_VENDOR |
USB_RECIP_DEVICE,
>> +                              value, index, data, size);
>> +
>> +       if (ret != size && ret >= 0)
>> +               return -EINVAL;
>> +       return ret;
>> +}
>> +
>> +static int ax88179_write_cmd(struct usbnet *dev, u8 cmd, u16 value, u16
index,
>> +                            u16 size, void *data) {
>> +       return usbnet_write_cmd(dev, cmd, USB_DIR_OUT | USB_TYPE_VENDOR
>> +                               | USB_RECIP_DEVICE, value, index, 
>> +data, size); }
>> +
>> +static void
>> +ax88179_write_cmd_async(struct usbnet *dev, u8 cmd, u16 value, u16
index,
>> +                                   u16 size, void *data) {
>> +       usbnet_write_cmd_async(dev, cmd,
>> +                              USB_DIR_OUT | USB_TYPE_VENDOR |
USB_RECIP_DEVICE,
>> +                              value, index, data, size); }
>> +

ax88179_read_cmd, ax88179_write_cmd, and ax88179_write_cmd_async duplicate
code from asix_common.c.

Do you mean that I should merge this driver into asix_common and
asix_devices, or just reuse the functions that had been implemented?

[...]

>> +static int ax88179_get_eeprom(struct net_device *net,
>> +                             struct ethtool_eeprom *eeprom, u8 
>> +*data) {
>> +       struct usbnet *dev = netdev_priv(net);
>> +       u16 *ebuf = (u16 *)data;
>> +       int i;
>> +
>> +       /* Crude hack to ensure that we don't overwrite memory
>> +        * if an odd length is supplied

Have a look at asix_get_eeprom() in asix_common.c for a better
implementation. There is also code for programming the eeprom
(asix_set_eeprom in asix_common.c), can this be used for the AX88179/178A as
well?

Thanks, I will check whether the eeprom access functions in asix_common.c
can be used in the driver or not.

Regards, Freddy

>> +        */
>> +       if (eeprom->len % 2)
>> +               return -EINVAL;
>> +
>> +       /* ax8817x returns 2 bytes from eeprom on read */
>> +       for (i = 0; i < eeprom->len / 2; i++) {
>> +               if (ax88179_read_cmd(dev, AX_ACCESS_EEPROM,
>> +                       eeprom->offset + i, 1, 2, &ebuf[i]) < 0)
>> +                       return -EINVAL;
>> +       }
>> +       return 0;
>> +}
>> +
