From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH v2 7/7] lib/ll_map: Make sure im->name is
 NULL-terminated
Date: Fri, 18 Aug 2017 09:33:28 -0700
Message-ID: <20170818093328.4d3eff55@xeon-e3>
References: <20170817170932.24659-1-phil@nwl.cc>
        <20170817170932.24659-8-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:35391 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750984AbdHRQdh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 12:33:37 -0400
Received: by mail-pg0-f48.google.com with SMTP id v189so67354485pgd.2
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 09:33:37 -0700 (PDT)
In-Reply-To: <20170817170932.24659-8-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Aug 2017 19:09:32 +0200
Phil Sutter <phil@nwl.cc> wrote:

> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>  lib/ll_map.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/lib/ll_map.c b/lib/ll_map.c
> index 4e4556c9ac80b..4d06eb69f138a 100644
> --- a/lib/ll_map.c
> +++ b/lib/ll_map.c
> @@ -120,11 +120,11 @@ int ll_remember_index(const struct sockaddr_nl *who,
>  		return 0;
>  	}
>  
> -	im = malloc(sizeof(*im));
> +	im = calloc(1, sizeof(*im));
>  	if (im == NULL)
>  		return 0;
>  	im->index = ifi->ifi_index;
> -	strcpy(im->name, ifname);
> +	strncpy(im->name, ifname, IFNAMSIZ - 1);
>  	im->type = ifi->ifi_type;
>  	im->flags = ifi->ifi_flags;
>  

This is not really necessary. kernel won't return
an ifname with a length >= IFNAMSIZ.

If you wanted to future proof it, why not use variable size allocation

--- a/lib/ll_map.c
+++ b/lib/ll_map.c
@@ -30,7 +30,7 @@ struct ll_cache {
        unsigned        flags;
        unsigned        index;
        unsigned short  type;
-       char            name[IFNAMSIZ];
+       char            name[];
 };
 
 #define IDXMAP_SIZE    1024
@@ -120,7 +120,7 @@ int ll_remember_index(const struct sockaddr_nl *who,
                return 0;
        }
 
-       im = malloc(sizeof(*im));
+       im = malloc(sizeof(*im) + strlen(ifname) + 1);
        if (im == NULL)
                return 0;
        im->index = ifi->ifi_index;
