From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] scm: Don't use struct ucred in NETLINK_CB and
 struct scm_cookie.
Date: Fri, 07 Sep 2012 17:07:26 +0200
Message-ID: <1347030446.2484.771.camel@edumazet-glaptop>
References: <87haralb0u.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"Serge E. Hallyn" <serge@hallyn.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:42424 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751394Ab2IGPHc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2012 11:07:32 -0400
Received: by bkwj10 with SMTP id j10so1436797bkw.19
        for <netdev@vger.kernel.org>; Fri, 07 Sep 2012 08:07:30 -0700 (PDT)
In-Reply-To: <87haralb0u.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-06 at 21:20 -0700, Eric W. Biederman wrote:
> Passing uids and gids on NETLINK_CB from a process in one user
> namespace to a process in another user namespace can result in the
> wrong uid or gid being presented to userspace.  Avoid that problem by
> passing kuids and kgids instead.
> 
> - define struct scm_creds for use in scm_cookie and netlink_skb_parms
>   that holds uid and gid information in kuid_t and kgid_t.
> 
> - Modify scm_set_cred to fill out scm_creds by heand instead of using
>   cred_to_ucred to fill out struct ucred.  This conversion ensures
>   userspace does not get incorrect uid or gid values to look at.
> 
> - Modify scm_recv to convert from struct scm_creds to struct ucred
>   before copying credential values to userspace.
> 
> - Modify __scm_send to populate struct scm_creds on in the scm_cookie,
>   instead of just copying struct ucred from userspace.
> 
> - Modify netlink_sendmsg to copy scm_creds instead of struct ucred
>   into the NETLINK_CB.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>


> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index 7cb7867..6473267 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -1398,7 +1398,7 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
>  
>  	NETLINK_CB(skb).pid	= nlk->pid;
>  	NETLINK_CB(skb).dst_group = dst_group;
> -	memcpy(NETLINK_CREDS(skb), &siocb->scm->creds, sizeof(struct ucred));
> +	NETLINK_CB(skb).creds	= siocb->scm->creds;
>  
>  	err = -EFAULT;
>  	if (memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len)) {

Seems fine to me, but I am not sure why you kept NETLINK_CREDS()
defined/used once.
