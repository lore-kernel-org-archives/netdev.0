From: Jakub Sitnicki <jkbs@redhat.com>
Subject: Re: [iproute PATCH v2 7/7] ip/tcp_metrics: Simplify process_msg a bit
Date: Wed, 22 Jun 2016 13:34:13 +0200
Message-ID: <87k2hhmp8q.fsf@frog.home>
References: <1466525921-15738-1-git-send-email-phil@nwl.cc> <1466525921-15738-8-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Stephen Hemminger <shemming@brocade.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Julien Floret <julien.floret@6wind.com>, netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:33917 "EHLO
	mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752546AbcFVMEN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 08:04:13 -0400
Received: by mail-qk0-f176.google.com with SMTP id t127so60839682qkf.1
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 05:02:41 -0700 (PDT)
In-reply-to: <1466525921-15738-8-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 21, 2016 at 06:18 PM CEST, Phil Sutter <phil@nwl.cc> wrote:
> By combining the attribute extraction and check for existence, the
> additional indentation level in the 'else' clause can be avoided.
>
> In addition to that, common actions for 'daddr' are combined since the
> function returns if neither of the branches are taken.
>
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>  ip/tcp_metrics.c | 45 ++++++++++++++++++---------------------------
>  1 file changed, 18 insertions(+), 27 deletions(-)
>
> diff --git a/ip/tcp_metrics.c b/ip/tcp_metrics.c
> index f82604f458ada..899830c127bcb 100644
> --- a/ip/tcp_metrics.c
> +++ b/ip/tcp_metrics.c
> @@ -112,47 +112,38 @@ static int process_msg(const struct sockaddr_nl *who, struct nlmsghdr *n,
>  	parse_rtattr(attrs, TCP_METRICS_ATTR_MAX, (void *) ghdr + GENL_HDRLEN,
>  		     len);
>  
> -	a = attrs[TCP_METRICS_ATTR_ADDR_IPV4];
> -	if (a) {
> +	if ((a = attrs[TCP_METRICS_ATTR_ADDR_IPV4])) {

Copy the pointer inside the branch?

Same gain on indentation while keeping checkpatch happy.

I only compile-tested the patch below.

Thanks,
Jakub

diff --git a/ip/tcp_metrics.c b/ip/tcp_metrics.c
index f82604f..ac2613a 100644
--- a/ip/tcp_metrics.c
+++ b/ip/tcp_metrics.c
@@ -112,47 +112,44 @@ static int process_msg(const struct sockaddr_nl *who, struct nlmsghdr *n,
 	parse_rtattr(attrs, TCP_METRICS_ATTR_MAX, (void *) ghdr + GENL_HDRLEN,
 		     len);
 
-	a = attrs[TCP_METRICS_ATTR_ADDR_IPV4];
-	if (a) {
+	if (attrs[TCP_METRICS_ATTR_ADDR_IPV4]) {
 		if (f.daddr.family && f.daddr.family != AF_INET)
 			return 0;
+		a = attrs[TCP_METRICS_ATTR_ADDR_IPV4];
 		memcpy(&daddr.data, RTA_DATA(a), 4);
 		daddr.bytelen = 4;
 		family = AF_INET;
 		atype = TCP_METRICS_ATTR_ADDR_IPV4;
 		dlen = RTA_PAYLOAD(a);
-	} else {
-		a = attrs[TCP_METRICS_ATTR_ADDR_IPV6];
-		if (a) {
-			if (f.daddr.family && f.daddr.family != AF_INET6)
-				return 0;
-			memcpy(&daddr.data, RTA_DATA(a), 16);
-			daddr.bytelen = 16;
-			family = AF_INET6;
-			atype = TCP_METRICS_ATTR_ADDR_IPV6;
-			dlen = RTA_PAYLOAD(a);
-		} else
+	} else if (attrs[TCP_METRICS_ATTR_ADDR_IPV6]) {
+		if (f.daddr.family && f.daddr.family != AF_INET6)
 			return 0;
+		a = attrs[TCP_METRICS_ATTR_ADDR_IPV6];
+		memcpy(&daddr.data, RTA_DATA(a), 16);
+		daddr.bytelen = 16;
+		family = AF_INET6;
+		atype = TCP_METRICS_ATTR_ADDR_IPV6;
+		dlen = RTA_PAYLOAD(a);
+	} else {
+		return 0;
 	}
 
-	a = attrs[TCP_METRICS_ATTR_SADDR_IPV4];
-	if (a) {
+	if (attrs[TCP_METRICS_ATTR_SADDR_IPV4]) {
 		if (f.saddr.family && f.saddr.family != AF_INET)
 			return 0;
+		a = attrs[TCP_METRICS_ATTR_SADDR_IPV4];
 		memcpy(&saddr.data, RTA_DATA(a), 4);
 		saddr.bytelen = 4;
 		stype = TCP_METRICS_ATTR_SADDR_IPV4;
 		slen = RTA_PAYLOAD(a);
-	} else {
+	} else if (attrs[TCP_METRICS_ATTR_SADDR_IPV6]) {
+		if (f.saddr.family && f.saddr.family != AF_INET6)
+			return 0;
 		a = attrs[TCP_METRICS_ATTR_SADDR_IPV6];
-		if (a) {
-			if (f.saddr.family && f.saddr.family != AF_INET6)
-				return 0;
-			memcpy(&saddr.data, RTA_DATA(a), 16);
-			saddr.bytelen = 16;
-			stype = TCP_METRICS_ATTR_SADDR_IPV6;
-			slen = RTA_PAYLOAD(a);
-		}
+		memcpy(&saddr.data, RTA_DATA(a), 16);
+		saddr.bytelen = 16;
+		stype = TCP_METRICS_ATTR_SADDR_IPV6;
+		slen = RTA_PAYLOAD(a);
 	}
 
 	if (f.daddr.family && f.daddr.bitlen >= 0 &&
