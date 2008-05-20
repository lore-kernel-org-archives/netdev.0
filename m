From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 6/8] bonding: Send more than one gratuitous ARP when
 slave takes over
Date: Tue, 20 May 2008 14:54:18 -0700
Message-ID: <20080520145418.35865dd6.akpm@linux-foundation.org>
References: <12110838143907-git-send-email-fubar@us.ibm.com>
	<12110838151824-git-send-email-fubar@us.ibm.com>
	<12110838151104-git-send-email-fubar@us.ibm.com>
	<12110838162313-git-send-email-fubar@us.ibm.com>
	<1211083816660-git-send-email-fubar@us.ibm.com>
	<1211083817934-git-send-email-fubar@us.ibm.com>
	<1211083818228-git-send-email-fubar@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, monis@voltaire.com
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51608 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1763761AbYETVyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 17:54:50 -0400
In-Reply-To: <1211083818228-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 17 May 2008 21:10:12 -0700
Jay Vosburgh <fubar@us.ibm.com> wrote:

> From: Moni Shoua <monis@voltaire.com>
> 
> With IPoIB, reception of gratuitous ARP by neighboring hosts
> is essential for a successful change of slaves in case of failure.
> Otherwise, they won't learn about the HW address change and need
> to wait a long time until the neighboring system gives up and sends
> an ARP request to learn the new HW address.  This patch decreases
> the chance for a lost of a gratuitous ARP packet by sending it more
> than once. The number retries is configurable and can be set with a
> module param.
> 
> ...
>
> +static ssize_t bonding_store_n_grat_arp(struct device *d,
> +				    struct device_attribute *attr,
> +				    const char *buf, size_t count)
> +{
> +	int new_value, ret = count;
> +	struct bonding *bond = to_bond(d);
> +
> +	if (sscanf(buf, "%d", &new_value) != 1) {

This will treat input such as "42foo" as valid, which is somewhat messy
of us.  A better approach is to use strict_strto*(), which will reject
such invalid input.


> +		printk(KERN_ERR DRV_NAME
> +		       ": %s: no num_grat_arp value specified.\n",
> +		       bond->dev->name);
> +		ret = -EINVAL;
> +		goto out;
> +	}
> +	if (new_value < 0 || new_value > 255) {
> +		printk(KERN_ERR DRV_NAME
> +		       ": %s: Invalid num_grat_arp value %d not in range 0-255; rejected.\n",
> +		       bond->dev->name, new_value);
> +		ret = -EINVAL;
> +		goto out;
> +	} else {
> +		bond->params.num_grat_arp = new_value;
> +	}
> +out:
> +	return ret;
> +}
> +static DEVICE_ATTR(num_grat_arp, S_IRUGO | S_IWUSR, bonding_show_n_grat_arp, bonding_store_n_grat_arp);

Strange that the code jumps through 80-column hoops in some places, but
not in others.

