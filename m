From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 1/1] NFS: change the ip_map cache code to handle IPv6
 addresses
Date: Thu, 23 Aug 2007 11:39:32 -0400
Message-ID: <46CDAA34.1070603@oracle.com>
References: <46CD890C.2040502@ext.bull.net>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000802050604020802040108"
Cc: Mailing list NFSv4 <nfsv4@linux-nfs.org>,
	netdev ML <netdev@vger.kernel.org>
To: =?UTF-8?B?QXVyw6lsaWVuIENoYXJib24=?=
	<aurelien.charbon@ext.bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:59453 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762052AbXHWPlY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2007 11:41:24 -0400
In-Reply-To: <46CD890C.2040502@ext.bull.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000802050604020802040108
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Hi Aurélien-

Aurélien Charbon wrote:
> According to Neil's comments, I have tried to correct the mistakes of my first sending
> Thank you for these comments Neil.
> 
> This is a small part of missing pieces of IPv6 support for the server.
> It deals with the ip_map caching code part.
> 
> It changes the ip_map structure to be able to store INET6 addresses.
> It adds also the changes in address hashing, and mapping to test it with INET addresses.
> 
> Signed-off-by: Aurelien Charbon <aurelien.charbon@ext.bull.net>
> ---
> 
>  fs/nfsd/export.c               |   10 ++-
>  fs/nfsd/nfsctl.c               |   21 ++++++-
>  include/linux/sunrpc/svcauth.h |    4 -
>  include/net/ipv6.h             |   17 +++++
>  net/sunrpc/svcauth_unix.c      |  121 
> ++++++++++++++++++++++++++++-------------
>  5 files changed, 129 insertions(+), 44 deletions(-)
> 
> 
> diff -p -u -r -N linux-2.6.23-rc3/fs/nfsd/export.c 
> linux-2.6.23-rc3-IPv6-ipmap-cache/fs/nfsd/export.c
> --- linux-2.6.23-rc3/fs/nfsd/export.c    2007-08-23 13:18:16.000000000 +0200
> +++ linux-2.6.23-rc3-IPv6-ipmap-cache/fs/nfsd/export.c    2007-08-23 
> 13:51:08.000000000 +0200
> @@ -35,6 +35,7 @@
>  #include <linux/lockd/bind.h>
>  #include <linux/sunrpc/msg_prot.h>
>  #include <linux/sunrpc/gss_api.h>
> +#include <net/ipv6.h>
>  
>  #define NFSDDBG_FACILITY    NFSDDBG_EXPORT
>  
> @@ -1559,6 +1560,7 @@ exp_addclient(struct nfsctl_client *ncp)
>  {
>      struct auth_domain    *dom;
>      int            i, err;
> +    struct in6_addr addr6;
>  
>      /* First, consistency check. */
>      err = -EINVAL;
> @@ -1577,9 +1579,11 @@ exp_addclient(struct nfsctl_client *ncp)
>          goto out_unlock;
>  
>      /* Insert client into hashtable. */
> -    for (i = 0; i < ncp->cl_naddr; i++)
> -        auth_unix_add_addr(ncp->cl_addrlist[i], dom);
> -
> +    for (i = 0; i < ncp->cl_naddr; i++) {
> +        /* Mapping address */
> +        ipv6_addr_map(ncp->cl_addrlist[i], addr6);
> +        auth_unix_add_addr(addr6, dom);
> +    }
>      auth_unix_forget_old(dom);
>      auth_domain_put(dom);
>  
> diff -p -u -r -N linux-2.6.23-rc3/fs/nfsd/nfsctl.c 
> linux-2.6.23-rc3-IPv6-ipmap-cache/fs/nfsd/nfsctl.c
> --- linux-2.6.23-rc3/fs/nfsd/nfsctl.c    2007-08-23 13:18:16.000000000 +0200
> +++ linux-2.6.23-rc3-IPv6-ipmap-cache/fs/nfsd/nfsctl.c    2007-08-23 
> 13:25:28.000000000 +0200
> @@ -222,7 +222,7 @@ static ssize_t write_getfs(struct file *
>      struct auth_domain *clp;
>      int err = 0;
>      struct knfsd_fh *res;
> -
> +    struct in6_addr in6;
>      if (size < sizeof(*data))
>          return -EINVAL;
>      data = (struct nfsctl_fsparm*)buf;
> @@ -236,7 +236,14 @@ static ssize_t write_getfs(struct file *
>      res = (struct knfsd_fh*)buf;
>  
>      exp_readlock();
> -    if (!(clp = auth_unix_lookup(sin->sin_addr)))
> +
> +    /* IPv6 address mapping */
> +    in6.s6_addr32[0] = 0;
> +    in6.s6_addr32[1] = 0;
> +    in6.s6_addr32[2] = htonl(0xffff);
> +    in6.s6_addr32[3] = (uint32_t)sin->sin_addr.s_addr;
> +
> +    if (!(clp = auth_unix_lookup(in6)))
>          err = -EPERM;
>      else {
>          err = exp_rootfh(clp, data->gd_path, res, data->gd_maxlen);
> @@ -253,6 +260,7 @@ static ssize_t write_getfd(struct file *
>  {
>      struct nfsctl_fdparm *data;
>      struct sockaddr_in *sin;
> +    struct in6_addr in6;
>      struct auth_domain *clp;
>      int err = 0;
>      struct knfsd_fh fh;
> @@ -271,7 +279,14 @@ static ssize_t write_getfd(struct file *
>      res = buf;
>      sin = (struct sockaddr_in *)&data->gd_addr;
>      exp_readlock();
> -    if (!(clp = auth_unix_lookup(sin->sin_addr)))
> +
> +    /* IPv6 address mapping */
> +    in6.s6_addr32[0] = 0;
> +    in6.s6_addr32[1] = 0;
> +    in6.s6_addr32[2] = htonl(0xffff);
> +    in6.s6_addr32[3] = (uint32_t)sin->sin_addr.s_addr;

The code canonicalizes IPv4 addresses in several places.  Is there 
already a generic function defined somewhere to do this?  If not, it 
might make sense to add one.

--------------000802050604020802040108
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

YmVnaW46dmNhcmQNCmZuOkNodWNrIExldmVyDQpuOkxldmVyO0NodWNrDQpvcmc6T3JhY2xl
IENvcnBvcmF0aW9uO0NvcnBvcmF0ZSBBcmNoaXRlY3R1cmU6IExpbnV4IFByb2plY3RzIEdy
b3VwDQphZHI6OzsxMDE1IEdyYW5nZXIgQXZlbnVlO0FubiBBcmJvcjtNSTs0ODEwNDtVU0EN
CnRpdGxlOlByaW5jaXBhbCBNZW1iZXIgb2YgU3RhZmYNCnRlbDt3b3JrOisxIDI0OCA2MTQg
NTA5MQ0KeC1tb3ppbGxhLWh0bWw6RkFMU0UNCnVybDpodHRwOi8vb3NzLm9yYWNsZS5jb20v
fmNlbA0KdmVyc2lvbjoyLjENCmVuZDp2Y2FyZA0KDQo=
--------------000802050604020802040108--
