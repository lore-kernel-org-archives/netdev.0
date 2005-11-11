From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 1/7] s390: synthax checking for VIPA addresses fixed
Date: Fri, 11 Nov 2005 08:24:36 -0500
Message-ID: <43749B94.5010200@pobox.com>
References: <20051110124902.GA7936@pavlic>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750737AbVKKNYm@vger.kernel.org>
To: Frank Pavlic <fpavlic@de.ibm.com>
In-Reply-To: <20051110124902.GA7936@pavlic>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Frank Pavlic wrote:
> [patch 1/7] s390: synthax checking for VIPA addresses fixed
> 
> From: Peter Tiedemann <ptiedem@de.ibm.com>
> 	- synthax checking for VIPA addresses fixed
> 
> Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
> 
> diffstat:
>  qeth.h     |   65 ++++++++++++++++++++++++++++++++++++++++++++++++-------------
>  qeth_sys.c |    6 ++---
>  2 files changed, 55 insertions(+), 16 deletions(-)
> 
> 
> diff -Naupr orig/drivers/s390/net/qeth.h patched-linux/drivers/s390/net/qeth.h
> --- orig/drivers/s390/net/qeth.h	2005-11-09 20:06:57.000000000 +0100
> +++ patched-linux/drivers/s390/net/qeth.h	2005-11-09 20:11:20.000000000 +0100
> @@ -8,6 +8,7 @@
>  #include <linux/trdevice.h>
>  #include <linux/etherdevice.h>
>  #include <linux/if_vlan.h>
> +#include <linux/ctype.h>
>  
>  #include <net/ipv6.h>
>  #include <linux/in6.h>
> @@ -24,7 +25,7 @@
>  
>  #include "qeth_mpc.h"
>  
> -#define VERSION_QETH_H 		"$Revision: 1.142 $"
> +#define VERSION_QETH_H 		"$Revision: 1.151 $"
>  
>  #ifdef CONFIG_QETH_IPV6
>  #define QETH_VERSION_IPV6 	":IPv6"
> @@ -1074,6 +1075,26 @@ qeth_get_qdio_q_format(struct qeth_card 
>  	}
>  }
>  
> +static inline int
> +qeth_isdigit(char * buf)
> +{
> +	while (*buf) {
> +		if (!isdigit(*buf++))
> +			return 0;
> +	}
> +	return 1;
> +}
> +
> +static inline int
> +qeth_isxdigit(char * buf)
> +{
> +	while (*buf) {
> +		if (!isxdigit(*buf++))
> +			return 0;
> +	}
> +	return 1;
> +}
> +
>  static inline void
>  qeth_ipaddr4_to_string(const __u8 *addr, char *buf)
>  {
> @@ -1090,18 +1111,27 @@ qeth_string_to_ipaddr4(const char *buf, 
>  	int i;
>  
>  	start = buf;
> -	for (i = 0; i < 3; i++) {
> -		if (!(end = strchr(start, '.')))
> +	for (i = 0; i < 4; i++) {
> +		if (i == 3) {
> +			end = strchr(start,0xa);
> +			if (end)
> +				len = end - start;
> +			else		
> +				len = strlen(start);
> +		}
> +		else {
> +			end = strchr(start, '.');
> +			len = end - start;
> +		}
> +		if ((len <= 0) || (len > 3))
>  			return -EINVAL;
> -		len = end - start;
>  		memset(abuf, 0, 4);
>  		strncpy(abuf, start, len);
> +		if (!qeth_isdigit(abuf))
> +			return -EINVAL;
>  		addr[i] = simple_strtoul(abuf, &tmp, 10);
>  		start = end + 1;
>  	}
> -	memset(abuf, 0, 4);
> -	strcpy(abuf, start);
> -	addr[3] = simple_strtoul(abuf, &tmp, 10);
>  	return 0;
>  }
>  
> @@ -1128,18 +1158,27 @@ qeth_string_to_ipaddr6(const char *buf, 
>  
>  	tmp_addr = (u16 *)addr;
>  	start = buf;
> -	for (i = 0; i < 7; i++) {
> -		if (!(end = strchr(start, ':')))
> +	for (i = 0; i < 8; i++) {
> +		if (i == 7) {
> +			end = strchr(start,0xa);
> +			if (end)
> +				len = end - start;
> +			else
> +				len = strlen(start);
> +		}
> +		else {
> +			end = strchr(start, ':');
> +			len = end - start;
> +		}
> +		if ((len <= 0) || (len > 4))
>  			return -EINVAL;
> -		len = end - start;
>  		memset(abuf, 0, 5);
>  		strncpy(abuf, start, len);
> +		if (!qeth_isxdigit(abuf))
> +			return -EINVAL;
>  		tmp_addr[i] = simple_strtoul(abuf, &tmp, 16);
>  		start = end + 1;

OK for now, but please submit a patch that updates this code to use 
sscanf().

	Jeff
