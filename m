From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [PATCH] pktgen: reduce stack usage
Date: Mon, 21 Feb 2005 08:12:48 -0800
Message-ID: <421A0880.5070205@osdl.org>
References: <20050218134219.3f079110.rddunlap@osdl.org>	<20050218221121.GA22845@electric-eye.fr.zoreil.com>	<42166E3F.2050304@osdl.org> <16921.60572.951532.31861@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, robert.olsson@its.uu.se,
        netdev <netdev@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16921.60572.951532.31861@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Robert Olsson wrote:
> Randy.Dunlap writes:
> 
>  > I don't see any simultaneous uses of the 2 buffers, so here's the
>  > union version of the patch (attached this time), although it only
>  > saves 4 bytes... so maybe the compiler had already realized that
>  > usage.  Either one accomplishes a large stack reduction, but the
> 
>  Hello!
> 
>  Here is version with just one buffer.

Yep, even better:  few changes + using sizeof.

> How did you calculate the saving?

objdump the .o file before and after changes.  Look at how much
temp space is allocated by "sub  const,%esp"  (on x86).  E.g.:
      9e8:	81 ec 24 01 00 00    	sub    $0x124,%esp


> 					   --ro
> 
> 
> 
> --- net/core/pktgen.c.050221	2005-02-21 14:02:40.000000000 +0100
> +++ net/core/pktgen.c	2005-02-21 15:02:44.000000000 +0100
> @@ -151,7 +151,7 @@
>  #include <asm/timex.h>
>  
>  
> -#define VERSION  "pktgen v2.57: Packet Generator for packet performance testing.\n"
> +#define VERSION  "pktgen v2.58: Packet Generator for packet performance testing.\n"
>  
>  /* #define PG_DEBUG(a) a */
>  #define PG_DEBUG(a) 
> @@ -811,6 +811,7 @@
>          struct pktgen_dev *pkt_dev = (struct pktgen_dev*)(data);
>          char* pg_result = NULL;
>          int tmp = 0;
> +	char buf[128];
>          
>          pg_result = &(pkt_dev->result[0]);
>          
> @@ -1071,7 +1072,6 @@
>  		return count;
>  	}
>  	if (!strcmp(name, "dst_min") || !strcmp(name, "dst")) {
> -                char buf[IP_NAME_SZ];
>  		len = strn_len(&user_buffer[i], sizeof(pkt_dev->dst_min) - 1);
>                  if (len < 0) { return len; }
>  
> @@ -1091,7 +1091,6 @@
>  		return count;
>  	}
>  	if (!strcmp(name, "dst_max")) {
> -                char buf[IP_NAME_SZ];
>  		len = strn_len(&user_buffer[i], sizeof(pkt_dev->dst_max) - 1);
>                  if (len < 0) { return len; }
>  
> @@ -1112,9 +1111,7 @@
>  		return count;
>  	}
>  	if (!strcmp(name, "dst6")) {
> -                char buf[128];
> -
> -		len = strn_len(&user_buffer[i], 128 - 1);
> +		len = strn_len(&user_buffer[i], sizeof(buf) - 1);
>                  if (len < 0) return len; 
>  
>  		pkt_dev->flags |= F_IPV6;
> @@ -1136,9 +1133,7 @@
>  		return count;
>  	}
>  	if (!strcmp(name, "dst6_min")) {
> -                char buf[128];
> -
> -		len = strn_len(&user_buffer[i], 128 - 1);
> +		len = strn_len(&user_buffer[i], sizeof(buf) - 1);
>                  if (len < 0) return len; 
>  
>  		pkt_dev->flags |= F_IPV6;
> @@ -1159,9 +1154,7 @@
>  		return count;
>  	}
>  	if (!strcmp(name, "dst6_max")) {
> -                char buf[128];
> -
> -		len = strn_len(&user_buffer[i], 128 - 1);
> +		len = strn_len(&user_buffer[i], sizeof(buf) - 1);
>                  if (len < 0) return len; 
>  
>  		pkt_dev->flags |= F_IPV6;
> @@ -1181,9 +1174,7 @@
>  		return count;
>  	}
>  	if (!strcmp(name, "src6")) {
> -                char buf[128];
> -
> -		len = strn_len(&user_buffer[i], 128 - 1);
> +		len = strn_len(&user_buffer[i], sizeof(buf) - 1);
>                  if (len < 0) return len; 
>  
>  		pkt_dev->flags |= F_IPV6;
> @@ -1205,7 +1196,6 @@
>  		return count;
>  	}
>  	if (!strcmp(name, "src_min")) {
> -                char buf[IP_NAME_SZ];
>  		len = strn_len(&user_buffer[i], sizeof(pkt_dev->src_min) - 1);
>                  if (len < 0) { return len; }
>                  if (copy_from_user(buf, &user_buffer[i], len))
> @@ -1224,7 +1214,6 @@
>  		return count;
>  	}
>  	if (!strcmp(name, "src_max")) {
> -                char buf[IP_NAME_SZ];
>  		len = strn_len(&user_buffer[i], sizeof(pkt_dev->src_max) - 1);
>                  if (len < 0) { return len; }
>                  if (copy_from_user(buf, &user_buffer[i], len))


-- 
~Randy
