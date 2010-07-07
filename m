From: Narendra K <Narendra_K@dell.com>
Subject: Re: [PATCH 1/2] Export firmware assigned labels of network devices to sysfs
Date: Wed, 7 Jul 2010 12:48:26 -0500
Message-ID: <20100707174826.GA1046@auslistsprd01.us.dell.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE612B27@blrx3m08.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	linux-pci@vger.kernel.org, matt_domsch@dell.com,
	jordan_hargrave@dell.com, charles_rose@dell.com,
	vijay_nijhawan@dell.com
To: greg@kroah.com
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <EDA0A4495861324DA2618B4C45DCB3EE612B27@blrx3m08.blr.amer.dell.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Greg KH [mailto:greg@kroah.com] 
> Sent: Wednesday, July 07, 2010 4:52 AM
> To: K, Narendra
> Cc: netdev@vger.kernel.org; linux-hotplug@vger.kernel.org;
> linux-pci@vger.kernel.org; Domsch, Matt; Hargrave, Jordan; Rose,
> Charles; Nijhawan, Vijay
> Subject: Re: [PATCH 1/2] Export firmware assigned labels of network
> devices to sysfs
> 
> On Tue, Jul 06, 2010 at 01:52:18PM -0500, Narendra K wrote:
> > 
> > 'device_create_file' takes 'struct device_attribute *' as a param
> which 
> > we have not used here because  'struct device_attribute' does not have
> .test
> > member which we needed in this patch.
> 
> Why do you need it?  What is calling that function?  What am I missing
> here?

The function 'pci_create_smbiosname_file' below is calling the .test method.
For every pdev the function checks if it has a SMBIOS string associated
with it or not. If there is no string (and instance) associated, then the
attributes 'label' and 'instance' are not created for that pdev.
To check for the existance of the string, the .test method is needed and
it is not available in 'struct device_attribute'. It provides 
.show and .store. We need a .show and .test. So we defined 

+struct smbios_attribute smbios_attr_label = {
+	.attr = {.name = "label", .mode = 0444, .owner = THIS_MODULE},
+	.show = smbiosname_show,
+	.test = smbios_instance_string_exist,
+};

'smbios_instance_string_exist' checks if the pdev has a 'string' and 'instance'.

+static int 
+pci_create_smbiosname_file(struct pci_dev *pdev)
+{
+	if (smbios_attr_label.test && smbios_attr_label.test(&pdev->dev, NULL, NULL)) {
+		if (sysfs_create_file(&pdev->dev.kobj, &smbios_attr_label.attr))
+			return -1;
+		if (sysfs_create_file(&pdev->dev.kobj, &smbios_attr_instance.attr))
+			return -1;
+		return 0;
+	}
+	return -1;	
+}


+int pci_create_firmware_label_files(struct pci_dev *pdev)
+{
+	if (!pci_create_smbiosname_file(pdev))

> 
> Please always run your patches through scripts/checkpatch.pl and fix up
> the issues it finds before sending it out and having everyone else point
> them out to you :)
> 
> Also, a new thread is nice at times for new versions of patches...

Thanks for the feedback. Sorry for missing this.I would address all the issues 
and post the patch in a new thread.

With regards,
Narendra K
