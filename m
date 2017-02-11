From: yuan linyu <cugyly@163.com>
Subject: Re: [PATH v2 net-next] net: remove member 'max' of struct
 scm_fp_list
Date: Sat, 11 Feb 2017 10:47:59 +0800
Message-ID: <1486781279.3122.1.camel@163.com>
References: <1486780603-2888-1-git-send-email-cugyly@163.com>
Reply-To: cugyly@163.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-15.163.com ([220.181.12.15]:34210 "EHLO m12-15.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751888AbdBKCsU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 10 Feb 2017 21:48:20 -0500
In-Reply-To: <1486780603-2888-1-git-send-email-cugyly@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi,
yes, my misunderstanding.

it's error when use after dup.

can we do a full size(SCM_MAX_FD) dup?
 

On 六, 2017-02-11 at 10:36 +0800, yuan linyu wrote:
> From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> 
> 'max' only used at three places in scm.c,
> 1. in scm_fp_copy(), fpl->max = SCM_MAX_FD;
> 2. in scm_fp_copy(), if (fpl->count + num > fpl->max)
> 3. in scm_fp_dup(), new_fpl->max = new_fpl->count;
> at place 2, fpl->max can be replaced with SCM_MAX_FD.
> no other place read this 'max' again, so it can be removed.
> 
> Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> ---
> v1->v2:
>     update commit log to describe correct reason to remove 'max'
> 
>  include/net/scm.h |  3 +--
>  net/core/scm.c    | 20 +++++---------------
>  2 files changed, 6 insertions(+), 17 deletions(-)
> 
> diff --git a/include/net/scm.h b/include/net/scm.h
> index 59fa93c..1301227 100644
> --- a/include/net/scm.h
> +++ b/include/net/scm.h
> @@ -19,8 +19,7 @@ struct scm_creds {
>  };
>  
>  struct scm_fp_list {
> -	short			count;
> -	short			max;
> +	unsigned int	count;
>  	struct user_struct	*user;
>  	struct file		*fp[SCM_MAX_FD];
>  };
> diff --git a/net/core/scm.c b/net/core/scm.c
> index b6d8368..53679517 100644
> --- a/net/core/scm.c
> +++ b/net/core/scm.c
> @@ -69,15 +69,7 @@ static int scm_fp_copy(struct cmsghdr *cmsg, struct scm_fp_list **fplp)
>  	int *fdp = (int*)CMSG_DATA(cmsg);
>  	struct scm_fp_list *fpl = *fplp;
>  	struct file **fpp;
> -	int i, num;
> -
> -	num = (cmsg->cmsg_len - sizeof(struct cmsghdr))/sizeof(int);
> -
> -	if (num <= 0)
> -		return 0;
> -
> -	if (num > SCM_MAX_FD)
> -		return -EINVAL;
> +	unsigned int i, num;
>  
>  	if (!fpl)
>  	{
> @@ -86,18 +78,17 @@ static int scm_fp_copy(struct cmsghdr *cmsg, struct scm_fp_list **fplp)
>  			return -ENOMEM;
>  		*fplp = fpl;
>  		fpl->count = 0;
> -		fpl->max = SCM_MAX_FD;
>  		fpl->user = NULL;
>  	}
> -	fpp = &fpl->fp[fpl->count];
>  
> -	if (fpl->count + num > fpl->max)
> +	num = (cmsg->cmsg_len - sizeof(struct cmsghdr))/sizeof(int);
> +	if (fpl->count + num > SCM_MAX_FD)
>  		return -EINVAL;
>  
>  	/*
>  	 *	Verify the descriptors and increment the usage count.
>  	 */
> -
> +	fpp = &fpl->fp[fpl->count];
>  	for (i=0; i< num; i++)
>  	{
>  		int fd = fdp[i];
> @@ -112,7 +103,7 @@ static int scm_fp_copy(struct cmsghdr *cmsg, struct scm_fp_list **fplp)
>  	if (!fpl->user)
>  		fpl->user = get_uid(current_user());
>  
> -	return num;
> +	return 0;
>  }
>  
>  void __scm_destroy(struct scm_cookie *scm)
> @@ -341,7 +332,6 @@ struct scm_fp_list *scm_fp_dup(struct scm_fp_list *fpl)
>  	if (new_fpl) {
>  		for (i = 0; i < fpl->count; i++)
>  			get_file(fpl->fp[i]);
> -		new_fpl->max = new_fpl->count;
>  		new_fpl->user = get_uid(fpl->user);
>  	}
>  	return new_fpl;
