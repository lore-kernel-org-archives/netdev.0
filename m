From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH 0/3] cxgb3 driver update
Date: Thu, 23 Aug 2007 15:03:07 -0700
Message-ID: <46CE041B.8030403@chelsio.com>
References: <46CD2AA8.9070507@chelsio.com> <20070823070216.GI21089@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>
To: Al Viro <viro@ftp.linux.org.uk>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932488AbXHWWDg@vger.kernel.org>
In-Reply-To: <20070823070216.GI21089@ftp.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Al,

> Speaking of cxgb3, could you explain what the hell is
> static int do_term(struct t3cdev *dev, struct sk_buff *skb)
> {
>         unsigned int hwtid = ntohl(skb->priority) >> 8 & 0xfffff;
> doing?  AFAIK, skb->priority is not net-endian...
>

the RDMA connection id is saved in the skb's priority field for TERM 
messages
because it is not in the CPL message that comes up from the hardware.
Yet the RDMA driver needs it, so sge.c::process_responses() overloads
the skb's priority and csum with these values.


>
> Another odd place is
> int t3_seeprom_write(struct adapter *adapter, u32 addr, u32 data)
> {  
>         u16 val;
>         int attempts = EEPROM_MAX_POLL;
>         unsigned int base = adapter->params.pci.vpd_cap_addr;
>
>         if ((addr >= EEPROMSIZE && addr != EEPROM_STAT_ADDR) || (addr 
> & 3))  
>                 return -EINVAL;
>
>         pci_write_config_dword(adapter->pdev, base + PCI_VPD_DATA,
>                                cpu_to_le32(data));
> with callers like
> int t3_seeprom_wp(struct adapter *adapter, int enable)
> {
>         return t3_seeprom_write(adapter, EEPROM_STAT_ADDR, enable ? 
> 0xc : 0);
>
> IOW, you really get little-endian values passed to 
> pci_write_config_dword()
> and it expects a host-endian as the last argument...
>

It looks like a bug. Thanks for spotting this.

Cheers,
Divy
