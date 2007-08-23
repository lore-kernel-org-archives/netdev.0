From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: [PATCH 0/3] cxgb3 driver update
Date: Thu, 23 Aug 2007 08:02:16 +0100
Message-ID: <20070823070216.GI21089@ftp.linux.org.uk>
References: <46CD2AA8.9070507@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:37860 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150AbXHWHCU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2007 03:02:20 -0400
Content-Disposition: inline
In-Reply-To: <46CD2AA8.9070507@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 22, 2007 at 11:35:20PM -0700, Divy Le Ray wrote:
> Hi Jeff,
> 
> I'm submitting three more patches for inclusion in netdev#upstream.
> These patches are built over the series I resent yesterday night.
> The patch numbering reflects the stacking.
> 
> Here is a brief description:
> -   avoid false positives in the xgmac hang workaround
> -   Properly set the CQ_ERR bit in RDMA CQ contexts.
> -   Update CQ context operations time out values

Speaking of cxgb3, could you explain what the hell is
static int do_term(struct t3cdev *dev, struct sk_buff *skb)
{
        unsigned int hwtid = ntohl(skb->priority) >> 8 & 0xfffff;
doing?  AFAIK, skb->priority is not net-endian...

Another odd place is
int t3_seeprom_write(struct adapter *adapter, u32 addr, u32 data)
{   
        u16 val;
        int attempts = EEPROM_MAX_POLL;
        unsigned int base = adapter->params.pci.vpd_cap_addr;

        if ((addr >= EEPROMSIZE && addr != EEPROM_STAT_ADDR) || (addr & 3))   
                return -EINVAL;

        pci_write_config_dword(adapter->pdev, base + PCI_VPD_DATA,
                               cpu_to_le32(data));
with callers like
int t3_seeprom_wp(struct adapter *adapter, int enable)
{
        return t3_seeprom_write(adapter, EEPROM_STAT_ADDR, enable ? 0xc : 0);

IOW, you really get little-endian values passed to pci_write_config_dword()
and it expects a host-endian as the last argument...
