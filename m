From: Jason Lunz <lunz@falooley.org>
Subject: Re: BCM5704 performance questions.
Date: Fri, 10 Jun 2005 14:03:21 +0000 (UTC)
Message-ID: <d8c6j9$dv$1@sea.gmane.org>
References: <42A8E0FE.3020708@candelatech.com> <1118361376.5838.20.camel@rh4>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

mchan@broadcom.com said:
> On Thu, 2005-06-09 at 17:38 -0700, Ben Greear wrote:
>
>> 
>> *  Is the BCM5704 chipset/driver really that much slower?
>> 
>
> Unfortunately, the 5704 requires the "ONE_DMA" workaround which will
> limit throughput in a PCIX 100/133 bus. If you comment out the line that
> sets the DMA_RWCTRL_ONE_DMA flag in tg3.c, you should see improved
> performance. However, you may run into some DMA issues on certain
> systems.
>
>> *  Is there some information on tuning the tg3 somewhere?
>>     (I didn't see a Documentation/networking/tg3.txt file, for instance)
>> 
>> *  Is there a way to verify the bus speed that the NIC is running at?
>>     (ethtool -d ethX gives lots of meaningless (to me) hex)
>> 
>
> tg3 probing string for each device will tell you the bus type, width,
> and speed.

The patch below from http://article.gmane.org/gmane.linux.network/18734
does this too for e1000. Lennert Buytenhek posted it a while back.

Jason


diff -urpN linux-pf/drivers/net/e1000/e1000_main.c linux-bs/drivers/net/e1000/e1000_main.c
--- linux-pf/drivers/net/e1000/e1000_main.c	Fri Apr  8 15:06:34 2005
+++ linux-bs/drivers/net/e1000/e1000_main.c	Fri Apr  8 15:29:34 2005
@@ -617,6 +617,21 @@ e1000_probe(struct pci_dev *pdev,
 	if(eeprom_data & eeprom_apme_mask)
 		adapter->wol |= E1000_WUFC_MAG;
 
+	/* print bus type/speed/width info */
+	printk(KERN_INFO "%s: e1000 (PCI%s:%s:%s) ", netdev->name,
+		((adapter->hw.bus_type == e1000_bus_type_pcix) ? "X" : ""),
+		((adapter->hw.bus_speed == e1000_bus_speed_133) ? "133MHz" :
+		 (adapter->hw.bus_speed == e1000_bus_speed_120) ? "120MHz" :
+		 (adapter->hw.bus_speed == e1000_bus_speed_100) ? "100MHz" :
+		 (adapter->hw.bus_speed == e1000_bus_speed_66) ? "66MHz" :
+		  "33MHz"),
+		((adapter->hw.bus_width == e1000_bus_width_64) ? "64-bit" :
+		  "32-bit"));
+
+	for (i = 0; i < 6; i++)
+		printk("%2.2x%c", netdev->dev_addr[i],
+			i == 5 ? '\n' : ':');
+
 	/* reset the hardware with the new settings */
 	e1000_reset(adapter);
 
