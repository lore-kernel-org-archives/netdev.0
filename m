From: "Denis V. Lunev" <den@sw.ru>
Subject: Re: [PATCH] ipv4: kernel panic when only one unsecured port available
Date: Wed, 10 Oct 2007 10:54:52 +0400
Message-ID: <470C773C.2050700@sw.ru>
References: <m3bqb89yjw.fsf@bandura.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Anton Arapov <aarapov@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:55531 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751024AbXJJGxI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2007 02:53:08 -0400
In-Reply-To: <m3bqb89yjw.fsf@bandura.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This code is broken from the very beginning.

iris den # cat /proc/sys/net/ipv4/ip_local_port_range
32768   61000
iris den # echo 32768 32 >/proc/sys/net/ipv4/ip_local_port_range
iris den # cat /proc/sys/net/ipv4/ip_local_port_range
32768   32
iris den # echo 32768 61000 >/proc/sys/net/ipv4/ip_local_port_range

Regards,
	Den

Anton Arapov wrote:
> Steps to reproduce:
> Server:
>   [root@server ~]# cat /etc/exports
>   /export *(ro,insecure)
> // there is insecure ... I am using ports like "1024 to 61000"
>   [root@server ~] service nfs restart 
> 
> Client:
>   1.[root@client ~]# echo 32768 32768 > /proc/sys/net/ipv4/ip_local_port_range
>   32768   32768
> // two same numbers, for ex "32769 32769" etc.
>   2.[root@client ~]# cat /proc/sys/net/ipv4/ip_local_port_range
>   32768   32768
>   3.[root@client ~]# mount server:/export /import
>   
> Actual results:
>   Kernel always panics 
> 
> --------------------------------------------------------------------
> [PATCH] ipv4: kernel panic when only one unsecured port available
> 
>   Patch prevents division by zero. Kernel panics if only one 
> unsecured port available.
> 
> Signed-off-by: Anton Arapov <aarapov@redhat.com>
> ---
> 
>  net/ipv4/inet_connection_sock.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
> index fbe7714..00ad079 100644
> --- a/net/ipv4/inet_connection_sock.c
> +++ b/net/ipv4/inet_connection_sock.c
> @@ -80,7 +80,7 @@ int inet_csk_get_port(struct inet_hashinfo *hashinfo,
>  		int low = sysctl_local_port_range[0];
>  		int high = sysctl_local_port_range[1];
>  		int remaining = (high - low) + 1;
> -		int rover = net_random() % (high - low) + low;
> +		int rover = net_random() % remaining + low;
>  
>  		do {
>  			head = &hashinfo->bhash[inet_bhashfn(rover, hashinfo->bhash_size)];
> 

