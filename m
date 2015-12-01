From: Joe Perches <joe@perches.com>
Subject: Re: [net-next v2 04/15] i40e: remove BUG_ON from feature string
 building
Date: Tue, 01 Dec 2015 12:48:56 -0800
Message-ID: <1449002936.1593.10.camel@perches.com>
References: <1448475679-57194-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1448475679-57194-5-git-send-email-jeffrey.t.kirsher@intel.com>
	 <5655FD72.70902@cogentembedded.com> <1448476535.3021.5.camel@intel.com>
	 <1448480194.20113.48.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	John Ronciak <john.ronciak@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0129.hostedemail.com ([216.40.44.129]:60010 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755592AbbLAUtA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 15:49:00 -0500
In-Reply-To: <1448480194.20113.48.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-11-25 at 11:36 -0800, Joe Perches wrote:
> On Wed, 2015-11-25 at 10:35 -0800, Jeff Kirsher wrote:
> > On Wed, 2015-11-25 at 21:26 +0300, Sergei Shtylyov wrote:
> > > On 11/25/2015 09:21 PM, Jeff Kirsher wrote:
> > > 
> > > > From: Shannon Nelson <shannon.nelson@intel.com>
> > > > 
> > > > There's really no reason to kill the kernel thread just because
> > > > of a
> > > > little info string. This reworks the code to use snprintf's
> > > > limiting to
> > > > assure that the string is never too long, and WARN_ON to still
> > > > put out
> > > > a warning that we might want to look at the feature list
> > > > length.
> > > > 
> > > > diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c
> > > > b/drivers/net/ethernet/intel/i40e/i40e_main.c
> []
> > > >        if (pf->flags & I40E_FLAG_VEB_MODE_ENABLED)
> > > > -             buf += sprintf(buf, "VEB ");
> > > > +             i += snprintf(&buf[i], REMAIN(i), "VEPA ");
> > > 
> > >     Not "VEB "?
> > 
> > Nice catch Sergei, I will wait a till this afternoon to respin the
> > patch series, just in case there are other changes needed that our
> > validation did not catch. :-)
> 
> trivia:
> 
> If you redo these, it'd be nicer not to use " " after each
> fixed string, but use " " before each fixed string.
> 
> The final output string would be 1 byte shorter overall and
> not have an excess " " before the newline.
> 
> The declaration of i doesn't need initialization to 0:
> 
> 	i = snprintf(buf, INFO_STRING_LEN, "Features: PF-id[%d]", ...
> 
> would work.

Maybe something like this patch (net-next)

Fix I40E_FLAG_VEB_MODE_ENABLED output of VEB

Miscellanea:
o Remove unnecessary string variable
o Add space before not after fixed strings
o Use kmalloc not kzalloc
o Don't initialize i to 0, use result of first snprintf

---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 42 +++++++++++++----------------
 1 file changed, 19 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 4b7d874..145eeb5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -10240,52 +10240,48 @@ static int i40e_setup_pf_filter_control(struct i40e_pf *pf)
 static void i40e_print_features(struct i40e_pf *pf)
 {
 	struct i40e_hw *hw = &pf->hw;
-	char *buf, *string;
-	int i = 0;
+	char *buf;
+	int i;
 
-	string = kzalloc(INFO_STRING_LEN, GFP_KERNEL);
-	if (!string) {
-		dev_err(&pf->pdev->dev, "Features string allocation failed\n");
+	buf = kmalloc(INFO_STRING_LEN, GFP_KERNEL);
+	if (!buf)
 		return;
-	}
-
-	buf = string;
 
-	i += snprintf(&buf[i], REMAIN(i), "Features: PF-id[%d] ", hw->pf_id);
+	i = snprintf(buf, INFO_STRING_LEN, "Features: PF-id[%d]", hw->pf_id);
 #ifdef CONFIG_PCI_IOV
-	i += snprintf(&buf[i], REMAIN(i), "VFs: %d ", pf->num_req_vfs);
+	i += snprintf(&buf[i], REMAIN(i), " VFs: %d", pf->num_req_vfs);
 #endif
-	i += snprintf(&buf[i], REMAIN(i), "VSIs: %d QP: %d RX: %s ",
+	i += snprintf(&buf[i], REMAIN(i), " VSIs: %d QP: %d RX: %s",
 		      pf->hw.func_caps.num_vsis,
 		      pf->vsi[pf->lan_vsi]->num_queue_pairs,
 		      pf->flags & I40E_FLAG_RX_PS_ENABLED ? "PS" : "1BUF");
 
 	if (pf->flags & I40E_FLAG_RSS_ENABLED)
-		i += snprintf(&buf[i], REMAIN(i), "RSS ");
+		i += snprintf(&buf[i], REMAIN(i), " RSS");
 	if (pf->flags & I40E_FLAG_FD_ATR_ENABLED)
-		i += snprintf(&buf[i], REMAIN(i), "FD_ATR ");
+		i += snprintf(&buf[i], REMAIN(i), " FD_ATR");
 	if (pf->flags & I40E_FLAG_FD_SB_ENABLED) {
-		i += snprintf(&buf[i], REMAIN(i), "FD_SB ");
-		i += snprintf(&buf[i], REMAIN(i), "NTUPLE ");
+		i += snprintf(&buf[i], REMAIN(i), " FD_SB");
+		i += snprintf(&buf[i], REMAIN(i), " NTUPLE");
 	}
 	if (pf->flags & I40E_FLAG_DCB_CAPABLE)
-		i += snprintf(&buf[i], REMAIN(i), "DCB ");
+		i += snprintf(&buf[i], REMAIN(i), " DCB");
 #if IS_ENABLED(CONFIG_VXLAN)
-	i += snprintf(&buf[i], REMAIN(i), "VxLAN ");
+	i += snprintf(&buf[i], REMAIN(i), " VxLAN");
 #endif
 	if (pf->flags & I40E_FLAG_PTP)
-		i += snprintf(&buf[i], REMAIN(i), "PTP ");
+		i += snprintf(&buf[i], REMAIN(i), " PTP");
 #ifdef I40E_FCOE
 	if (pf->flags & I40E_FLAG_FCOE_ENABLED)
-		i += snprintf(&buf[i], REMAIN(i), "FCOE ");
+		i += snprintf(&buf[i], REMAIN(i), " FCOE");
 #endif
 	if (pf->flags & I40E_FLAG_VEB_MODE_ENABLED)
-		i += snprintf(&buf[i], REMAIN(i), "VEPA ");
+		i += snprintf(&buf[i], REMAIN(i), " VEB");
 	else
-		buf += sprintf(buf, "VEPA ");
+		i += snprintf(&buf[i], REMAIN(i), " VEPA");
 
-	dev_info(&pf->pdev->dev, "%s\n", string);
-	kfree(string);
+	dev_info(&pf->pdev->dev, "%s\n", buf);
+	kfree(buf);
 	WARN_ON(i > INFO_STRING_LEN);
 }
 
