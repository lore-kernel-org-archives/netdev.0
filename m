From: "Hay, Joshua A" <joshua.a.hay@intel.com>
Subject: RE: [net-next 06/10] ixgbe: eliminate Smatch warnings in
 ixgbe_debugfs.c
Date: Tue, 27 Nov 2012 01:06:17 +0000
Message-ID: <4329753313F5A742A09953EE6CC1B3CE28C7D984@ORSMSX108.amr.corp.intel.com>
References: <1353494856-12344-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1353494856-12344-7-git-send-email-jeffrey.t.kirsher@intel.com>
 <20121121110409.GG6186@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Dan Carpenter <dan.carpenter@oracle.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:34852 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757623Ab2K0BGT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 20:06:19 -0500
In-Reply-To: <20121121110409.GG6186@mwanda>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The return value will be changed to len to preserve error codes returned from simple_write_to_buffer.

However, changing the logic preceding this return breaks these functions.  If simple_write_to_buffer returns a positive value, other actions are performed with this value.  With this patch, the function will return immediately with that value instead.  This will effectively break the ixgbe_debugfs write operations.

So ultimately, the change should be: 
> +	len = simple_write_to_buffer(ixgbe_dbg_reg_ops_buf,
> +				     sizeof(ixgbe_dbg_reg_ops_buf)-1,
> +				     ppos,
> +				     buffer,
> +				     count);
> +	if (len < 0)
> +		return -EFAULT;
	
	if (len < 0)
		return len;

Thanks,
Josh Hay

-----Original Message-----
From: Dan Carpenter [mailto:dan.carpenter@oracle.com] 
Sent: Wednesday, November 21, 2012 3:04 AM
To: Kirsher, Jeffrey T
Cc: davem@davemloft.net; Hay, Joshua A; netdev@vger.kernel.org; gospo@redhat.com; sassmann@redhat.com
Subject: Re: [net-next 06/10] ixgbe: eliminate Smatch warnings in ixgbe_debugfs.c

On Wed, Nov 21, 2012 at 02:47:32AM -0800, Jeff Kirsher wrote:
> +	len = simple_write_to_buffer(ixgbe_dbg_reg_ops_buf,
> +				     sizeof(ixgbe_dbg_reg_ops_buf)-1,
> +				     ppos,
> +				     buffer,
> +				     count);
> +	if (len < 0)
> +		return -EFAULT;

Any negative return is bad.

	if (len)
		return len;

> +
> +	ixgbe_dbg_reg_ops_buf[len] = '\0';
>  
>  	if (strncmp(ixgbe_dbg_reg_ops_buf, "write", 5) == 0) {
>  		u32 reg, value;
> @@ -187,15 +196,15 @@ static ssize_t ixgbe_dbg_netdev_ops_write(struct file *filp,
>  	if (count >= sizeof(ixgbe_dbg_netdev_ops_buf))
>  		return -ENOSPC;
>  
> -	bytes_not_copied = copy_from_user(ixgbe_dbg_netdev_ops_buf,
> -					  buffer, count);
> -	if (bytes_not_copied < 0)
> -		return bytes_not_copied;
> -	else if (bytes_not_copied < count)
> -		count -= bytes_not_copied;
> -	else
> -		return -ENOSPC;
> -	ixgbe_dbg_netdev_ops_buf[count] = '\0';
> +	len = simple_write_to_buffer(ixgbe_dbg_netdev_ops_buf,
> +				     sizeof(ixgbe_dbg_netdev_ops_buf)-1,
> +				     ppos,
> +				     buffer,
> +				     count);
> +	if (len < 0)
> +		return -EFAULT;

Same.

> +
> +	ixgbe_dbg_netdev_ops_buf[len] = '\0';

regards,
dan carpenter
