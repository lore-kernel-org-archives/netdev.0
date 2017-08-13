From: David Ahern <dsahern@gmail.com>
Subject: Re: [iproute PATCH 15/51] ipvrf: Fix error path of vrf_switch()
Date: Sun, 13 Aug 2017 10:00:45 -0600
Message-ID: <0c57206d-92c4-bfd8-8ac7-ffb03df3c1c0@gmail.com>
References: <20170812120510.28750-1-phil@nwl.cc>
 <20170812120510.28750-16-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:37549 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750928AbdHMQAr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Aug 2017 12:00:47 -0400
Received: by mail-pg0-f66.google.com with SMTP id 83so6834607pgb.4
        for <netdev@vger.kernel.org>; Sun, 13 Aug 2017 09:00:47 -0700 (PDT)
In-Reply-To: <20170812120510.28750-16-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/12/17 6:04 AM, Phil Sutter wrote:
> Apart from trying to close(-1), this also leaked memory.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>  ip/ipvrf.c | 9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/ip/ipvrf.c b/ip/ipvrf.c
> index 92e2db98ca7d7..75cc026d072b8 100644
> --- a/ip/ipvrf.c
> +++ b/ip/ipvrf.c
> @@ -373,12 +373,12 @@ static int vrf_switch(const char *name)
>  
>  	/* -1 on length to add '/' to the end */
>  	if (ipvrf_get_netns(netns, sizeof(netns) - 1) < 0)
> -		return -1;
> +		goto out;
>  
>  	if (vrf_path(vpath, sizeof(vpath)) < 0) {
>  		fprintf(stderr, "Failed to get base cgroup path: %s\n",
>  			strerror(errno));
> -		return -1;
> +		goto out;
>  	}
>  
>  	/* if path already ends in netns then don't add it again */
> @@ -429,13 +429,14 @@ static int vrf_switch(const char *name)
>  	snprintf(pid, sizeof(pid), "%d", getpid());
>  	if (write(fd, pid, strlen(pid)) < 0) {
>  		fprintf(stderr, "Failed to join cgroup\n");
> -		goto out;
> +		goto out2;
>  	}
>  
>  	rc = 0;
> +out2:
> +	close(fd);
>  out:
>  	free(mnt);
> -	close(fd);
>  
>  	return rc;
>  }
> 

Acked-by: David Ahern <dsahern@gmail.com>
