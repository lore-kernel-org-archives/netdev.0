From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] [IPROUTE]: A workaround to make larger rto_min printed
 correctly
Date: Fri, 21 Dec 2007 17:53:52 +0900 (JST)
Message-ID: <20071221.175352.77874691.yoshfuji@linux-ipv6.org>
References: <476ACF8A.7060201@gmail.com>
	<476AD127.2020909@gmail.com>
	<d72b7ace0712201824k3754962cse377256cb5452b8a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: satoru.satoh@gmail.com, shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:44229 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753547AbXLUIxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 03:53:17 -0500
In-Reply-To: <d72b7ace0712201824k3754962cse377256cb5452b8a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <d72b7ace0712201824k3754962cse377256cb5452b8a@mail.gmail.com> (at Fri, 21 Dec 2007 11:24:54 +0900), "Satoru SATOH" <satoru.satoh@gmail.com> says:

> 2007/12/21, Jarek Poplawski <jarkao2@gmail.com>:
> > Jarek Poplawski wrote, On 12/20/2007 09:24 PM:
> > ...
> >
> > > but since it's your patch, I hope you do some additional checking
> > > if it's always like this...
> >
> >
> > ...or maybe only changing this all a little bit will make it look safer!
> >
> > Jarek P.
> 
> 
> OK, how about this?
> 
> Signed-off-by: Satoru SATOH <satoru.satoh@gmail.com>
> 
>  ip/iproute.c |   12 ++++++++----
>  1 files changed, 8 insertions(+), 4 deletions(-)
> 
> diff --git a/ip/iproute.c b/ip/iproute.c
> index f4200ae..c771b34 100644
> --- a/ip/iproute.c
> +++ b/ip/iproute.c
> @@ -510,16 +510,20 @@ int print_route(const struct sockaddr_nl *who,
> struct nlmsghdr *n, void *arg)
>  				fprintf(fp, " %u", *(unsigned*)RTA_DATA(mxrta[i]));
>  			else {
>  				unsigned val = *(unsigned*)RTA_DATA(mxrta[i]);
> +				unsigned hz1 = hz;
> +				if (hz1 > 1000)

Why don't you simply use unsigned long long (or maybe uint64_t) here?

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--- 
diff --git a/ip/iproute.c b/ip/iproute.c
index f4200ae..db9a3b6 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -509,16 +509,21 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 			    i != RTAX_RTO_MIN)
 				fprintf(fp, " %u", *(unsigned*)RTA_DATA(mxrta[i]));
 			else {
-				unsigned val = *(unsigned*)RTA_DATA(mxrta[i]);
+				unsigned long long val = *(unsigned*)RTA_DATA(mxrta[i]);
+				unsigned div = 1;
 
-				val *= 1000;
 				if (i == RTAX_RTT)
-					val /= 8;
+					div = 8;
 				else if (i == RTAX_RTTVAR)
-					val /= 4;
-				if (val >= hz)
-					fprintf(fp, " %ums", val/hz);
+					div = 4;
 				else
+					div = 1;
+
+				val = val * 1000ULL / div;
+
+				if (val >= hz) {
+					fprintf(fp, " %llums", val/hz);
+				} else
 					fprintf(fp, " %.2fms", (float)val/hz);
 			}
 		}

--yoshfuji
