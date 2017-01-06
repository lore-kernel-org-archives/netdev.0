From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH iproute2 2/3] ip vrf: Improve cgroup2 error messages
Date: Fri, 6 Jan 2017 12:45:20 +0300
Message-ID: <f9858cd0-277b-02cd-35dc-ffc24862f736@cogentembedded.com>
References: <1483662143-15242-1-git-send-email-dsa@cumulusnetworks.com>
 <1483662143-15242-3-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org,
        stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:33557 "EHLO
        mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034961AbdAFJp2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 04:45:28 -0500
Received: by mail-lf0-f48.google.com with SMTP id k86so51298032lfi.0
        for <netdev@vger.kernel.org>; Fri, 06 Jan 2017 01:45:28 -0800 (PST)
In-Reply-To: <1483662143-15242-3-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 1/6/2017 3:22 AM, David Ahern wrote:

> Currently, if a non-root user attempts to run ip vrf exec a non-helpful
> error is returned:
>
> $ ip vrf exec mgmt bash
> Failed to mount cgroup2. Are CGROUPS enabled in your kernel?
>
> Only show the CGROUPS kernel hint for the ENODEV error and for the
> rest show the strerror for the errno. So now:
>
> $ ip/ip vrf exec mgmt bash
> Failed to mount cgroup2: Operation not permitted
>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>  lib/fs.c | 14 +++++++++++---
>  1 file changed, 11 insertions(+), 3 deletions(-)
>
> diff --git a/lib/fs.c b/lib/fs.c
> index 644bb486ae8e..12a4657a0bc9 100644
> --- a/lib/fs.c
> +++ b/lib/fs.c
> @@ -80,13 +80,21 @@ char *find_cgroup2_mount(void)
>
>  	if (mount("none", mnt, CGROUP2_FS_NAME, 0, NULL)) {
>  		/* EBUSY means already mounted */
> -		if (errno != EBUSY) {
> +		if (errno == EBUSY)
> +			goto out;
> +
> +		if (errno == ENODEV) {
>  			fprintf(stderr,
>  				"Failed to mount cgroup2. Are CGROUPS enabled in your kernel?\n");
> -			free(mnt);
> -			return NULL;
> +		} else {
> +			fprintf(stderr,
> +				"Failed to mount cgroup2: %s\n",
> +				strerror(errno));
>  		}

    How about a *switch* instead?

> +		free(mnt);
> +		return NULL;
>  	}
> +out:
>  	return mnt;
>  }
>

MBR, Sergei
