From: Hannes Reinecke <hare-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH 2/2] qedf: Add QLogic FastLinQ offload FCoE
 driver framework.
Date: Wed, 18 Jan 2017 17:24:46 +0100
Message-ID: <dfc1c653-7ef5-215d-2192-3c341992356d@suse.de>
References: <1484596437-27637-1-git-send-email-chad.dupuis@cavium.com>
 <1484596437-27637-3-git-send-email-chad.dupuis@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Cc: fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yuval.mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org,
 linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, QLogic-Storage-Upstream-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org
To: "Dupuis, Chad" <chad.dupuis-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>, martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Return-path: <fcoe-devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org>
In-Reply-To: <1484596437-27637-3-git-send-email-chad.dupuis-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://lists.open-fcoe.org/mailman/options/fcoe-devel>,
 <mailto:fcoe-devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-fcoe.org/pipermail/fcoe-devel/>
List-Post: <mailto:fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org>
List-Help: <mailto:fcoe-devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=help>
List-Subscribe: <http://lists.open-fcoe.org/mailman/listinfo/fcoe-devel>,
 <mailto:fcoe-devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=subscribe>
Errors-To: fcoe-devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
Sender: "fcoe-devel" <fcoe-devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 01/16/2017 08:53 PM, Dupuis, Chad wrote:
> From: "Dupuis, Chad" <chad.dupuis-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> =

> The QLogic FastLinQ Driver for FCoE (qedf) is the FCoE specific module fo=
r 41000
> Series Converged Network Adapters by QLogic. This patch consists of follo=
wing
> changes:
> =

> - MAINTAINERS Makefile and Kconfig changes for qedf
> - PCI driver registration
> - libfc/fcoe host level initialization
> - SCSI host template initialization and callbacks
> - Debugfs and log level infrastructure
> - Link handling
> - Firmware interface structures
> - QED core module initialization
> - Light L2 interface callbacks
> - I/O request initialization
> - Firmware I/O completion handling
> - Firmware ELS request/response handling
> - FIP request/response handled by the driver itself
> =

> Signed-off-by: Nilesh Javali <nilesh.javali-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Manish Rangankar <manish.rangankar-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Saurav Kashyap <saurav.kashyap-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Arun Easi <arun.easi-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Chad Dupuis <chad.dupuis-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>

[ .. ]

> +/* Main thread to process skb's from light-L2 interface */
> +static int qedf_ll2_recv_thread(void *arg)
> +{
> +	struct qedf_ctx *qedf =3D (struct qedf_ctx *)arg;
> +	struct qedf_skb_work *work, *work_tmp;
> +	unsigned long flags;
> +
> +	set_user_nice(current, -20);
> +	set_current_state(TASK_INTERRUPTIBLE);
> +
> +	while (!kthread_should_stop()) {
> +		schedule();
> +		if (!list_empty(&qedf->ll2_skb_list)) {
> +			list_for_each_entry_safe(work, work_tmp,
> +			    &qedf->ll2_skb_list, list) {
> +			spin_lock_irqsave(&qedf->ll2_lock, flags);
> +				list_del(&work->list);
> +				spin_unlock_irqrestore(&qedf->ll2_lock, flags);
> +				qedf_ll2_process_skb(qedf, work->skb);
> +				kfree(work);
> +			}
> +		}
> +		__set_current_state(TASK_INTERRUPTIBLE);
> +	}
> +
> +	__set_current_state(TASK_RUNNING);
> +	return 0;
> +}
> +
Please: don't.

The RT folks are trying to get rid of kthreads altogether as it's a
nightmare to get it to work with cpu hotplugging.
Please convert to workqueues.

Cheers,

Hannes
-- =

Dr. Hannes Reinecke		   Teamlead Storage & Networking
hare-l3A5Bk7waGM@public.gmane.org			               +49 911 74053 688
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 N=FCrnberg
GF: F. Imend=F6rffer, J. Smithard, J. Guild, D. Upmanyu, G. Norton
HRB 21284 (AG N=FCrnberg)
