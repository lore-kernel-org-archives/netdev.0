From: Joe Perches <joe@perches.com>
Subject: Re: [RFC 19/19] checkpatch: warn for use of old PCI pool API
Date: Wed, 08 Feb 2017 11:53:29 -0800
Message-ID: <1486583609.27834.21.camel@perches.com>
References: <20170208163457.28853-1-romain.perier@collabora.com>
         <20170208163457.28853-20-romain.perier@collabora.com>
         <20170208185550.GS16878@collabora.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: Dan Williams <dan.j.williams@intel.com>,
        Doug Ledford <dledford@redhat.com>,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        jeffrey.t.kirsher@intel.com,
        "David S. Miller" <davem@davemloft.net>, stas.yakovlev@gmail.com,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        Felipe Balbi <balbi@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org, linux-scsi@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Peter Senna Tschudin <peter.senna@collabora.co.uk>
To: Peter Senna Tschudin <peter.senna@collabora.com>,
        Romain Perier <romain.perier@collabora.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0108.hostedemail.com ([216.40.44.108]:39439 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751052AbdBHT6T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 14:58:19 -0500
In-Reply-To: <20170208185550.GS16878@collabora.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-02-08 at 19:55 +0100, Peter Senna Tschudin wrote:
> On Wed, Feb 08, 2017 at 05:34:57PM +0100, Romain Perier wrote:
> > pci_pool_*() functions should be replaced by the corresponding functions
> > in the DMA pool API. This adds support to check for use of these pci
> > functions and display a warning when it is the case.
> 
> Don't know if relevant, but did not catch the struct. Other than that
> works fine.
> 
> > 
> > Signed-off-by: Romain Perier <romain.perier@collabora.com>
> > ---
> >  scripts/checkpatch.pl | 5 +++++
> >  1 file changed, 5 insertions(+)
> > 
> > diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
> > index 8e96af5..026920e 100755
> > --- a/scripts/checkpatch.pl
> > +++ b/scripts/checkpatch.pl
> > @@ -6058,6 +6058,11 @@ sub process {
> >  			WARN("USE_DEVICE_INITCALL",
> >  			     "please use device_initcall() or more appropriate function instead of __initcall() (see include/linux/init.h)\n" . $herecurr);
> >  		}
> > +# check for old PCI api pci_pool_*(), use dma_pool_*() instead
> > +		if ($line =~ /\bpci_pool_.+\(/) {
> > +			WARN("USE_PCI_POOL",
> > +			     "please use the dma pool api or more appropriate function instead of the old pci pool api\n" . $herecurr);
> > +		}
> >  
> >  # check for various structs that are normally const (ops, kgdb, device_tree)
> >  		if ($line !~ /\bconst\b/ &&
> > -- 
> > 2.9.3
> > 

Did this patch get to lkml?

Perhaps this would be more complete:

 scripts/checkpatch.pl | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index 8e96af53611c..600f81cc1ec1 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -6059,6 +6059,15 @@ sub process {
 			     "please use device_initcall() or more appropriate function instead of __initcall() (see include/linux/init.h)\n" . $herecurr);
 		}
 
+# check for old PCI api pci_pool_*(), use dma_pool_*() instead
+		if ($line =~ /\bpci_pool(?:_(?:create|destroy|alloc|zalloc|free)|)\b/) {
+			if (WARN("USE_DMA_POOL",
+				 "please use the dma pool api or more appropriate function instead of the old pci pool api\n" . $herecurr) &&
+			    $fix) {
+				while ($fixed[$fixlinenr] =~ s/\bpci_pool(_(?:create|destroy|alloc|zalloc|free)|)\b/dma_pool$1/) {}
+			}
+		}
+
 # check for various structs that are normally const (ops, kgdb, device_tree)
 		if ($line !~ /\bconst\b/ &&
 		    $line =~ /\bstruct\s+($const_structs)\b/) {
