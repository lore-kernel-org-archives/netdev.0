From: Dan Williams <dcbw@redhat.com>
Subject: Re: [patch] libertas: fix write past end of array in mesh_id_get()
Date: Thu, 10 Mar 2011 11:02:02 -0600
Message-ID: <1299776524.17443.14.camel@dcbw.foobar.com>
References: <20110310152326.GA2008@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: javier@cozybit.com, "John W. Linville" <linville@tuxdriver.com>,
	libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28303 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751606Ab1CJRAv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Mar 2011 12:00:51 -0500
In-Reply-To: <20110310152326.GA2008@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-03-10 at 18:23 +0300, Dan Carpenter wrote:
> defs.meshie.val.mesh_id is 32 chars long.  It's not supposed to be NUL
> terminated.  This code puts a terminator on the end to make it easier to
> print to sysfs.  The problem is that if the mesh_id fills the entire
> buffer the original code puts the terminator one spot past the end.
> 
> The way the original code was written, there was a check to make sure
> that maxlen was less than PAGE_SIZE.  Since we know that maxlen is at
> most 34 chars, I just removed the check.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Acked-by: Dan Williams <dcbw@redhat.com>

> diff --git a/drivers/net/wireless/libertas/mesh.c b/drivers/net/wireless/libertas/mesh.c
> index acf3bf6..9d097b9 100644
> --- a/drivers/net/wireless/libertas/mesh.c
> +++ b/drivers/net/wireless/libertas/mesh.c
> @@ -918,7 +918,6 @@ static ssize_t mesh_id_get(struct device *dev, struct device_attribute *attr,
>  			   char *buf)
>  {
>  	struct mrvl_mesh_defaults defs;
> -	int maxlen;
>  	int ret;
>  
>  	ret = mesh_get_default_parameters(dev, &defs);
> @@ -931,13 +930,11 @@ static ssize_t mesh_id_get(struct device *dev, struct device_attribute *attr,
>  		defs.meshie.val.mesh_id_len = IEEE80211_MAX_SSID_LEN;
>  	}
>  
> -	/* SSID not null terminated: reserve room for \0 + \n */
> -	maxlen = defs.meshie.val.mesh_id_len + 2;
> -	maxlen = (PAGE_SIZE > maxlen) ? maxlen : PAGE_SIZE;
> +	memcpy(buf, defs.meshie.val.mesh_id, defs.meshie.val.mesh_id_len);
> +	buf[defs.meshie.val.mesh_id_len] = '\n';
> +	buf[defs.meshie.val.mesh_id_len + 1] = '\0';
>  
> -	defs.meshie.val.mesh_id[defs.meshie.val.mesh_id_len] = '\0';
> -
> -	return snprintf(buf, maxlen, "%s\n", defs.meshie.val.mesh_id);
> +	return defs.meshie.val.mesh_id_len + 1;
>  }
>  
>  /**
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


