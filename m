From: Bjorn Helgaas <helgaas@kernel.org>
Subject: Re: [PATCH pci] pci: Add helper function to set VPD size
Date: Fri, 15 Apr 2016 13:13:14 -0500
Message-ID: <20160415181314.GB13979@localhost>
References: <1460657525-17551-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhelgaas@google.com, davem@davemloft.net,
	linux-pci@vger.kernel.org, netdev@vger.kernel.org,
	Casey Leedom <leedom@chelsio.com>,
	Steve Wise <swise@opengridcomputing.com>,
	nirranjan@chelsio.com, santosh@chelsio.com,
	Hannes Reinecke <hare@suse.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	linux-kernel@vger.kernel.org
To: Hariprasad Shenai <hariprasad@chelsio.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1460657525-17551-1-git-send-email-hariprasad@chelsio.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[+cc Hannes, Ariel, LKML]

On Thu, Apr 14, 2016 at 11:42:05PM +0530, Hariprasad Shenai wrote:
> commit 104daa71b396 ("PCI: Determine actual VPD size on first access")
> introduced a regression in cxgb4 driver and used to fail in pci probe.
> 
> The problem is stemming from the fact that the Chelsio adapters actually
> have two VPD structures stored in the VPD. An abbreviated on at Offset 0x0
> and the complete VPD at Offset 0x400. The abbreviated one only contains
> the PN, SN and EC Keywords, while the complete VPD contains those plus
> various adapter constants contained in V0, V1, etc. And it also contains
> the Base Ethernet MAC Address in the "NA" Keyword which the cxgb4 driver
> needs when it can't contact the adapter firmware. (We don't have the "NA"
> Keywork in the VPD Structure at Offset 0x0 because that's not an allowed
> VPD Keyword in the PCI-E 3.0 specification.)
> 
> With the new code, the computed size of the VPD is 0x200 and so our efforts
> to read the VPD at Offset 0x400 silently fails. We check the result of the
> read looking for a signature 0x82 byte but we're checking against random
> stack garbage.
> 
> The fix is to add a PCI helper function to set the VPD size, so the
> driver can expicitly set the exact size of the VPD.
> 
> Fixes commit 104daa71b396 ("PCI: Determine actual VPD size on first access")
> 
> Signed-off-by: Casey Leedom <leedom@chelsio.com>
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

This looks good to me.  I applied it with the following changes to my
for-linus branch for v4.6:

  - Split into two patches (PCI core and Chelsio).  I did this because
    of the concern that bnx2x might also be broken.  But I looked
    again, and I think bnx2x is fine because the driver computes the
    size the same way the PCI core does, and I think it only reads up
    to that size.  It'd be good if the bnx2x folks could verify this.

  - Renamed pci_set_size_vpd() to pci_set_vpd_size() so it reads
    better.

  - Changed pci_set_vpd_size() from ssize_t to int, since it only
    returns zero or a negative errno.  Also, t4_get_raw_vpd_params()
    puts the return value into an int.

I'll append the patches as applied at the end.

> ---
>  drivers/net/ethernet/chelsio/cxgb4/t4_hw.c | 10 +++++++
>  drivers/pci/access.c                       | 42 ++++++++++++++++++++++++++++++
>  drivers/pci/pci.h                          |  1 +
>  include/linux/pci.h                        |  1 +
>  4 files changed, 54 insertions(+)
> 
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
> index cc1736bece0f..2033159e26a5 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
> @@ -2557,6 +2557,7 @@ void t4_get_regs(struct adapter *adap, void *buf, size_t buf_size)
>  }
>  
>  #define EEPROM_STAT_ADDR   0x7bfc
> +#define VPD_SIZE           0x800
>  #define VPD_BASE           0x400
>  #define VPD_BASE_OLD       0
>  #define VPD_LEN            1024
> @@ -2594,6 +2595,15 @@ int t4_get_raw_vpd_params(struct adapter *adapter, struct vpd_params *p)
>  	if (!vpd)
>  		return -ENOMEM;
>  
> +	/* We have two VPD data structures stored in the adapter VPD area.
> +	 * By default, Linux calculates the size of the VPD area by traversing
> +	 * the first VPD area at offset 0x0, so we need to tell the OS what
> +	 * our real VPD size is.
> +	 */
> +	ret = pci_set_size_vpd(adapter->pdev, VPD_SIZE);
> +	if (ret < 0)
> +		goto out;
> +
>  	/* Card information normally starts at VPD_BASE but early cards had
>  	 * it at 0.
>  	 */
> diff --git a/drivers/pci/access.c b/drivers/pci/access.c
> index 01b9d0a00abc..e69b3877bd37 100644
> --- a/drivers/pci/access.c
> +++ b/drivers/pci/access.c
> @@ -275,6 +275,19 @@ ssize_t pci_write_vpd(struct pci_dev *dev, loff_t pos, size_t count, const void
>  }
>  EXPORT_SYMBOL(pci_write_vpd);
>  
> +/**
> + * pci_set_size_vpd - Set size of Vital Product Data space
> + * @dev:	pci device struct
> + * @len:	size of vpd space
> + */
> +ssize_t pci_set_size_vpd(struct pci_dev *dev, size_t len)
> +{
> +	if (!dev->vpd || !dev->vpd->ops)
> +		return -ENODEV;
> +	return dev->vpd->ops->set_size(dev, len);
> +}
> +EXPORT_SYMBOL(pci_set_size_vpd);
> +
>  #define PCI_VPD_MAX_SIZE (PCI_VPD_ADDR_MASK + 1)
>  
>  /**
> @@ -498,9 +511,23 @@ out:
>  	return ret ? ret : count;
>  }
>  
> +static ssize_t pci_vpd_set_size(struct pci_dev *dev, size_t len)
> +{
> +	struct pci_vpd *vpd = dev->vpd;
> +
> +	if (len == 0 || len > PCI_VPD_MAX_SIZE)
> +		return -EIO;
> +
> +	vpd->valid = 1;
> +	vpd->len = len;
> +
> +	return 0;
> +}
> +
>  static const struct pci_vpd_ops pci_vpd_ops = {
>  	.read = pci_vpd_read,
>  	.write = pci_vpd_write,
> +	.set_size = pci_vpd_set_size,
>  };
>  
>  static ssize_t pci_vpd_f0_read(struct pci_dev *dev, loff_t pos, size_t count,
> @@ -533,9 +560,24 @@ static ssize_t pci_vpd_f0_write(struct pci_dev *dev, loff_t pos, size_t count,
>  	return ret;
>  }
>  
> +static ssize_t pci_vpd_f0_set_size(struct pci_dev *dev, size_t len)
> +{
> +	struct pci_dev *tdev = pci_get_slot(dev->bus,
> +					    PCI_DEVFN(PCI_SLOT(dev->devfn), 0));
> +	ssize_t ret;
> +
> +	if (!tdev)
> +		return -ENODEV;
> +
> +	ret = pci_set_size_vpd(tdev, len);
> +	pci_dev_put(tdev);
> +	return ret;
> +}
> +
>  static const struct pci_vpd_ops pci_vpd_f0_ops = {
>  	.read = pci_vpd_f0_read,
>  	.write = pci_vpd_f0_write,
> +	.set_size = pci_vpd_f0_set_size,
>  };
>  
>  int pci_vpd_init(struct pci_dev *dev)
> diff --git a/drivers/pci/pci.h b/drivers/pci/pci.h
> index d0fb93481573..8239d186f1ed 100644
> --- a/drivers/pci/pci.h
> +++ b/drivers/pci/pci.h
> @@ -97,6 +97,7 @@ static inline bool pci_has_subordinate(struct pci_dev *pci_dev)
>  struct pci_vpd_ops {
>  	ssize_t (*read)(struct pci_dev *dev, loff_t pos, size_t count, void *buf);
>  	ssize_t (*write)(struct pci_dev *dev, loff_t pos, size_t count, const void *buf);
> +	ssize_t (*set_size)(struct pci_dev *dev, size_t len);
>  };
>  
>  struct pci_vpd {
> diff --git a/include/linux/pci.h b/include/linux/pci.h
> index 004b8133417d..1ab1b7458a8b 100644
> --- a/include/linux/pci.h
> +++ b/include/linux/pci.h
> @@ -1111,6 +1111,7 @@ void pci_unlock_rescan_remove(void);
>  /* Vital product data routines */
>  ssize_t pci_read_vpd(struct pci_dev *dev, loff_t pos, size_t count, void *buf);
>  ssize_t pci_write_vpd(struct pci_dev *dev, loff_t pos, size_t count, const void *buf);
> +ssize_t pci_set_size_vpd(struct pci_dev *dev, size_t len);
>  
>  /* Helper functions for low-level code (drivers/pci/setup-[bus,res].c) */
>  resource_size_t pcibios_retrieve_fw_addr(struct pci_dev *dev, int idx);
> -- 
> 2.3.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-pci" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

commit cb92148b58a49455f3a7204eba3aee09a8b7683c
Author: Hariprasad Shenai <hariprasad@chelsio.com>
Date:   Fri Apr 15 13:00:11 2016 -0500

    PCI: Add pci_set_vpd_size() to set VPD size
    
    After 104daa71b396 ("PCI: Determine actual VPD size on first access"), the
    PCI core computes the valid VPD size by parsing the VPD starting at offset
    0x0.  We don't attempt to read past that valid size because that causes
    some devices to crash.
    
    However, some devices do have data past that valid size.  For example,
    Chelsio adapters contain two VPD structures, and the driver needs both of
    them.
    
    Add pci_set_vpd_size().  If a driver knows it is safe to read past the end
    of the VPD data structure at offset 0, it can use pci_set_vpd_size() to
    allow access to as much data as it needs.
    
    [bhelgaas: changelog, split patches, rename to pci_set_vpd_size() and
    return int (not ssize_t)]
    Fixes: 104daa71b396 ("PCI: Determine actual VPD size on first access")
    Tested-by: Steve Wise <swise@opengridcomputing.com>
    Signed-off-by: Casey Leedom <leedom@chelsio.com>
    Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
    Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>

diff --git a/drivers/pci/access.c b/drivers/pci/access.c
index 01b9d0a..d11cdbb 100644
--- a/drivers/pci/access.c
+++ b/drivers/pci/access.c
@@ -275,6 +275,19 @@ ssize_t pci_write_vpd(struct pci_dev *dev, loff_t pos, size_t count, const void
 }
 EXPORT_SYMBOL(pci_write_vpd);
 
+/**
+ * pci_set_vpd_size - Set size of Vital Product Data space
+ * @dev:	pci device struct
+ * @len:	size of vpd space
+ */
+int pci_set_vpd_size(struct pci_dev *dev, size_t len)
+{
+	if (!dev->vpd || !dev->vpd->ops)
+		return -ENODEV;
+	return dev->vpd->ops->set_size(dev, len);
+}
+EXPORT_SYMBOL(pci_set_vpd_size);
+
 #define PCI_VPD_MAX_SIZE (PCI_VPD_ADDR_MASK + 1)
 
 /**
@@ -498,9 +511,23 @@ out:
 	return ret ? ret : count;
 }
 
+static int pci_vpd_set_size(struct pci_dev *dev, size_t len)
+{
+	struct pci_vpd *vpd = dev->vpd;
+
+	if (len == 0 || len > PCI_VPD_MAX_SIZE)
+		return -EIO;
+
+	vpd->valid = 1;
+	vpd->len = len;
+
+	return 0;
+}
+
 static const struct pci_vpd_ops pci_vpd_ops = {
 	.read = pci_vpd_read,
 	.write = pci_vpd_write,
+	.set_size = pci_vpd_set_size,
 };
 
 static ssize_t pci_vpd_f0_read(struct pci_dev *dev, loff_t pos, size_t count,
@@ -533,9 +560,24 @@ static ssize_t pci_vpd_f0_write(struct pci_dev *dev, loff_t pos, size_t count,
 	return ret;
 }
 
+static int pci_vpd_f0_set_size(struct pci_dev *dev, size_t len)
+{
+	struct pci_dev *tdev = pci_get_slot(dev->bus,
+					    PCI_DEVFN(PCI_SLOT(dev->devfn), 0));
+	int ret;
+
+	if (!tdev)
+		return -ENODEV;
+
+	ret = pci_set_vpd_size(tdev, len);
+	pci_dev_put(tdev);
+	return ret;
+}
+
 static const struct pci_vpd_ops pci_vpd_f0_ops = {
 	.read = pci_vpd_f0_read,
 	.write = pci_vpd_f0_write,
+	.set_size = pci_vpd_f0_set_size,
 };
 
 int pci_vpd_init(struct pci_dev *dev)
diff --git a/drivers/pci/pci.h b/drivers/pci/pci.h
index d0fb934..a814bbb 100644
--- a/drivers/pci/pci.h
+++ b/drivers/pci/pci.h
@@ -97,6 +97,7 @@ static inline bool pci_has_subordinate(struct pci_dev *pci_dev)
 struct pci_vpd_ops {
 	ssize_t (*read)(struct pci_dev *dev, loff_t pos, size_t count, void *buf);
 	ssize_t (*write)(struct pci_dev *dev, loff_t pos, size_t count, const void *buf);
+	int (*set_size)(struct pci_dev *dev, size_t len);
 };
 
 struct pci_vpd {
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 004b813..932ec74 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -1111,6 +1111,7 @@ void pci_unlock_rescan_remove(void);
 /* Vital product data routines */
 ssize_t pci_read_vpd(struct pci_dev *dev, loff_t pos, size_t count, void *buf);
 ssize_t pci_write_vpd(struct pci_dev *dev, loff_t pos, size_t count, const void *buf);
+int pci_set_vpd_size(struct pci_dev *dev, size_t len);
 
 /* Helper functions for low-level code (drivers/pci/setup-[bus,res].c) */
 resource_size_t pcibios_retrieve_fw_addr(struct pci_dev *dev, int idx);

commit 67e658794ca191b3221b143f2a1c10d002c40bc8
Author: Hariprasad Shenai <hariprasad@chelsio.com>
Date:   Fri Apr 15 13:00:18 2016 -0500

    cxgb4: Set VPD size so we can read both VPD structures
    
    Chelsio adapters have two VPD structures stored in the VPD:
    
      - offset 0x000: an abbreviated VPD, and
      - offset 0x400: the complete VPD.
    
    After 104daa71b396 ("PCI: Determine actual VPD size on first access"), the
    PCI core computes the valid VPD size by parsing the VPD starting at offset
    0x0.  That size only includes the abbreviated VPD structure, so reads of
    the complete VPD at 0x400 fail.
    
    Explicitly set the VPD size with pci_set_vpd_size() so the driver can read
    both VPD structures.
    
    [bhelgaas: changelog, split patches, rename to pci_set_vpd_size() and
    return int (not ssize_t)]
    Fixes: 104daa71b396 ("PCI: Determine actual VPD size on first access")
    Tested-by: Steve Wise <swise@opengridcomputing.com>
    Signed-off-by: Casey Leedom <leedom@chelsio.com>
    Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
    Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index cc1736b..c7efb11 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -2557,6 +2557,7 @@ void t4_get_regs(struct adapter *adap, void *buf, size_t buf_size)
 }
 
 #define EEPROM_STAT_ADDR   0x7bfc
+#define VPD_SIZE           0x800
 #define VPD_BASE           0x400
 #define VPD_BASE_OLD       0
 #define VPD_LEN            1024
@@ -2594,6 +2595,15 @@ int t4_get_raw_vpd_params(struct adapter *adapter, struct vpd_params *p)
 	if (!vpd)
 		return -ENOMEM;
 
+	/* We have two VPD data structures stored in the adapter VPD area.
+	 * By default, Linux calculates the size of the VPD area by traversing
+	 * the first VPD area at offset 0x0, so we need to tell the OS what
+	 * our real VPD size is.
+	 */
+	ret = pci_set_vpd_size(adapter->pdev, VPD_SIZE);
+	if (ret < 0)
+		goto out;
+
 	/* Card information normally starts at VPD_BASE but early cards had
 	 * it at 0.
 	 */
