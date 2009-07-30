From: Mike Christie <michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org>
Subject: Re: [PATCH] iscsi: Use GFP_ATOMIC in iscsi_offload_mesg().
Date: Wed, 29 Jul 2009 20:40:50 -0500
Message-ID: <4A70FA22.7010706@cs.wisc.edu>
References: <C27F8246C663564A84BB7AB343977242178EE780E1@IRVEXCHCCR01.corp.ad.broadcom.com> <4A70058F.50403@cs.wisc.edu> <1248893392.16148.262.camel@HP1>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, "James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org" <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Return-path: <grbounce-FC1hwAUAAAA0O9VQcsxVj1UPjHD9r3x_=glio-open-iscsi=m.gmane.org-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <1248893392.16148.262.camel@HP1>
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Post: <mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <mailto:open-iscsi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://googlegroups.com/group/open-iscsi/subscribe>,
	<mailto:open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org


On 07/29/2009 01:49 PM, Michael Chan wrote:
> Changing to GFP_ATOMIC because the only caller in cnic/bnx2i may
> be calling this function while holding spin_lock.
>
> This problem was discovered by Mike Christie.
>
> Signed-off-by: Michael Chan<mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> ---
>   drivers/scsi/scsi_transport_iscsi.c |    4 ++--
>   1 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/scsi/scsi_transport_iscsi.c b/drivers/scsi/scsi_transport_iscsi.c
> index 783e33c..b47240c 100644
> --- a/drivers/scsi/scsi_transport_iscsi.c
> +++ b/drivers/scsi/scsi_transport_iscsi.c
> @@ -990,7 +990,7 @@ int iscsi_offload_mesg(struct Scsi_Host *shost,
>   	struct iscsi_uevent *ev;
>   	int len = NLMSG_SPACE(sizeof(*ev) + data_size);
>
> -	skb = alloc_skb(len, GFP_NOIO);
> +	skb = alloc_skb(len, GFP_ATOMIC);
>   	if (!skb) {
>   		printk(KERN_ERR "can not deliver iscsi offload message:OOM\n");
>   		return -ENOMEM;
> @@ -1012,7 +1012,7 @@ int iscsi_offload_mesg(struct Scsi_Host *shost,
>
>   	memcpy((char *)ev + sizeof(*ev), data, data_size);
>
> -	return iscsi_multicast_skb(skb, ISCSI_NL_GRP_UIP, GFP_NOIO);
> +	return iscsi_multicast_skb(skb, ISCSI_NL_GRP_UIP, GFP_ATOMIC);
>   }
>   EXPORT_SYMBOL_GPL(iscsi_offload_mesg);
>

Using GFP_NOIO and changing the locking is my preference normally,  but 
if the locking changes are going to be a problem, then this is ok with 
me since we can fail allocations in other parts of the code.

Acked-by: Mike Christie <michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org>

Dave Miller probably wants to take this in his tree since it fixes a bug 
with this patch
http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=commit;h=6d7760a88c25057c2c2243e5dfe2d731064bd31d
