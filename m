From: Hannes Reinecke <hare@suse.com>
Subject: Re: [RFC v2 5/6] mptsas: use async probe
Date: Fri, 05 Sep 2014 09:23:28 +0200
Message-ID: <540964F0.8070809@suse.com>
References: <1409899047-13045-1-git-send-email-mcgrof@do-not-panic.com> <1409899047-13045-6-git-send-email-mcgrof@do-not-panic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, oleg@redhat.com,
	akpm@linux-foundation.org, penguin-kernel@i-love.sakura.ne.jp,
	joseph.salisbury@canonical.com, bpoirier@suse.de,
	santosh@chelsio.com, "Luis R. Rodriguez" <mcgrof@suse.com>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
	Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>,
	Sreekanth Reddy <sreekanth.reddy@avagotech.com>,
	Abhijit Mahajan <abhijit.mahajan@avagotech.com>,
	Hariprasad S <hariprasad@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>,
	MPT-FusionLinux.pdl@avagotech.com, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	gregkh@linuxfoundation.org, dmitry.torokhov@gmail.com,
	falcon@meizu.com, tiwai@suse.de, tj@kernel.org,
	arjan@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:42524 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751924AbaIEHXe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2014 03:23:34 -0400
In-Reply-To: <1409899047-13045-6-git-send-email-mcgrof@do-not-panic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/05/2014 08:37 AM, Luis R. Rodriguez wrote:
> From: "Luis R. Rodriguez" <mcgrof@suse.com>
> 
> Its reported that mptsas can at times take over 30 seconds
> to recognize SCSI storage devices [0], this is done on the
> driver's probe path. Use the the new asynch probe to
> circumvent systemd from killing this driver.
> 
> [0] https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1276705
> 
> Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Joseph Salisbury <joseph.salisbury@canonical.com>
> Cc: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
> Cc: Tim Gardner <tim.gardner@canonical.com>
> Cc: Pierre Fersing <pierre-fersing@pierref.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Oleg Nesterov <oleg@redhat.com>
> Cc: Benjamin Poirier <bpoirier@suse.de>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>
> Cc: Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>
> Cc: Sreekanth Reddy <sreekanth.reddy@avagotech.com>
> Cc: Abhijit Mahajan <abhijit.mahajan@avagotech.com>
> Cc: Hariprasad S <hariprasad@chelsio.com>
> Cc: Santosh Rastapur <santosh@chelsio.com>
> Cc: Casey Leedom <leedom@chelsio.com>
> Cc: MPT-FusionLinux.pdl@avagotech.com
> Cc: linux-scsi@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: netdev@vger.kernel.org
> Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>
> ---
>  drivers/message/fusion/mptsas.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/message/fusion/mptsas.c b/drivers/message/fusion/mptsas.c
> index 0707fa2..6dfee95 100644
> --- a/drivers/message/fusion/mptsas.c
> +++ b/drivers/message/fusion/mptsas.c
> @@ -5385,6 +5385,7 @@ static struct pci_driver mptsas_driver = {
>  	.suspend	= mptscsih_suspend,
>  	.resume		= mptscsih_resume,
>  #endif
> +	.driver.async_probe = true,
>  };
>  
>  static int __init
> 
This is the wrong appoach.
First of all, the mptsas, mpt2sas, and mpt3sas all share the same
driver layout, so any issue happeing with this driver will most
likely affect the others, too.
Secondly the driver is event-based anyway, so we should be moving
the initialisation to the already existing event handler:

diff --git a/drivers/message/fusion/mptsas.c
b/drivers/message/fusion/mptsas.c
index 0707fa2..6f41e2c 100644
--- a/drivers/message/fusion/mptsas.c
+++ b/drivers/message/fusion/mptsas.c
@@ -5305,7 +5305,7 @@ mptsas_probe(struct pci_dev *pdev, const
struct pci_device_id *id)
        /* older firmware doesn't support expander events */
        if ((ioc->facts.HeaderVersion >> 8) < 0xE)
                ioc->old_sas_discovery_protocal = 1;
-       mptsas_scan_sas_topology(ioc);
+       mptsas_queue_rescan(ioc);
        mptsas_fw_event_on(ioc);
        return 0;
