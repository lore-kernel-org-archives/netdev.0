From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [RFC 1/2] PCI-Express Non-Transparent Bridge Support
Date: Sat, 14 Jul 2012 10:10:15 -0700
Message-ID: <20120714171015.GB25775@kroah.com>
References: <1342215900-3358-1-git-send-email-jon.mason@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org, Dave Jiang <dave.jiang@intel.com>
To: Jon Mason <jon.mason@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1342215900-3358-1-git-send-email-jon.mason@intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 13, 2012 at 02:44:59PM -0700, Jon Mason wrote:
> +static int max_num_cbs = 2;
> +module_param(max_num_cbs, uint, 0644);
> +MODULE_PARM_DESC(max_num_cbs, "Maximum number of NTB transport connections");
> +
> +static bool no_msix;
> +module_param(no_msix, bool, 0644);
> +MODULE_PARM_DESC(no_msix, "Do not allow MSI-X interrupts to be selected");

How would a user, or a distro, know to set these options?  Why are they
even options at all?


> +struct ntb_device {
> +	struct pci_dev *pdev;
> +	struct msix_entry *msix_entries;
> +	void __iomem *reg_base;
> +	struct ntb_mw mw[NTB_NUM_MW];
> +	struct {
> +		unsigned int max_spads;
> +		unsigned int max_db_bits;
> +		unsigned int msix_cnt;
> +	} limits;
> +	struct {
> +		void __iomem *pdb;
> +		void __iomem *pdb_mask;
> +		void __iomem *sdb;
> +		void __iomem *sbar2_xlat;
> +		void __iomem *sbar4_xlat;
> +		void __iomem *spad_write;
> +		void __iomem *spad_read;
> +		void __iomem *lnk_cntl;
> +		void __iomem *lnk_stat;
> +		void __iomem *spci_cmd;
> +	} reg_ofs;
> +	void *ntb_transport;
> +	void (*event_cb)(void *handle, unsigned int event);

Shouldn't the event be an enum?

> +	struct ntb_db_cb *db_cb;
> +	unsigned char hw_type;
> +	unsigned char conn_type;
> +	unsigned char dev_type;
> +	unsigned char num_msix;
> +	unsigned char bits_per_vector;
> +	unsigned char max_cbs;
> +	unsigned char link_status;
> +	struct delayed_work hb_timer;
> +	unsigned long last_ts;
> +};

Why isn't this either a 'struct device' itself, or why isn't the 'struct
pci_device' embedded within it?  What controls the lifetime of this
device?  Why doesn't it show up in sysfs?  Don't you want it to show up
in the global device tree?

> +static DEFINE_PCI_DEVICE_TABLE(ntb_pci_tbl) = {
> +	{PCI_VDEVICE(INTEL, PCI_DEVICE_ID_INTEL_NTB_B2B_BWD)},
> +	{PCI_VDEVICE(INTEL, PCI_DEVICE_ID_INTEL_NTB_B2B_JSF)},
> +	{PCI_VDEVICE(INTEL, PCI_DEVICE_ID_INTEL_NTB_CLASSIC_JSF)},
> +	{PCI_VDEVICE(INTEL, PCI_DEVICE_ID_INTEL_NTB_RP_JSF)},
> +	{PCI_VDEVICE(INTEL, PCI_DEVICE_ID_INTEL_NTB_RP_SNB)},
> +	{PCI_VDEVICE(INTEL, PCI_DEVICE_ID_INTEL_NTB_B2B_SNB)},
> +	{PCI_VDEVICE(INTEL, PCI_DEVICE_ID_INTEL_NTB_CLASSIC_SNB)},
> +	{0}
> +};
> +MODULE_DEVICE_TABLE(pci, ntb_pci_tbl);
> +
> +static struct ntb_device *ntbdev;

You can really only have just one of these in the whole system?  Is that
wise?  Why isn't it dynamic and tied to the pci device itself as a
child?

thanks,

greg k-h
