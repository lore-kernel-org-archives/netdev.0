From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH net-next-2.6 v7 1/5] sctp: Add Auto-ASCONF support
Date: Tue, 26 Apr 2011 16:43:52 +0800
Message-ID: <4DB685C8.4070507@cn.fujitsu.com>
References: <2418F0AB-37A2-4B85-8723-32D92A48B7DA@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: Michio Honda <micchie@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51596 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751107Ab1DZIoH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Apr 2011 04:44:07 -0400
In-Reply-To: <2418F0AB-37A2-4B85-8723-32D92A48B7DA@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> SCTP reconfigure the IP addresses in the association by using ASCONF chunks as mentioned in RFC5061.  
> For example, we can start to use the newly configured IP address in the existing association.  
> ASCONF operation is invoked in two ways: 
> First is done by the application to call sctp_bindx() system call.  
> Second is automatic operation in the SCTP stack with address events in the host computer (called auto_asconf) .  
> The former is already implemented, and this patch implement the latter.  
>
> Signed-off-by: Michio Honda <micchie@sfc.wide.ad.jp>
> ---
> diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
> index 7e8e34c..872ffa0 100644
> --- a/include/net/sctp/sctp.h
> +++ b/include/net/sctp/sctp.h
> @@ -121,6 +121,8 @@ extern int sctp_copy_local_addr_list(struct sctp_bind_addr *,
>  				     int flags);
>  extern struct sctp_pf *sctp_get_pf_specific(sa_family_t family);
>  extern int sctp_register_pf(struct sctp_pf *, sa_family_t);
> +void sctp_addr_wq_mgmt(struct sctp_sockaddr_entry *, int);
> +void sctp_free_addr_wq(void);
>  
>

...

> +void sctp_free_addr_wq()

static void sctp_free_addr_wq(void)

> +{
> +	struct sctp_sockaddr_entry *addrw = NULL;
> +	struct sctp_sockaddr_entry *temp = NULL;
> +
> +	spin_lock_bh(&sctp_addr_wq_lock);
> +	del_timer(&sctp_addr_wq_timer);
> +	list_for_each_entry_safe(addrw, temp, &sctp_addr_waitq, list) {
> +		list_del(&addrw->list);
> +		kfree(addrw);
> +	}
> +	spin_unlock_bh(&sctp_addr_wq_lock);
> +}
> +
...
