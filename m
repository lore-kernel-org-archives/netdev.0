From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2] ip link: Show devices by link type
Date: Tue, 02 Dec 2014 16:55:44 -0800
Message-ID: <547E5F90.2060105@cumulusnetworks.com>
References: <1417370335-15772-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:39214 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750980AbaLCAzt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 19:55:49 -0500
In-Reply-To: <1417370335-15772-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/30/14, 9:58 AM, Vadim Kochan wrote:
> Added new option 'type' to 'ip link show'
> command which allows to filter devices by
> link type name:
>
>      ip link show type bridge
>      ip link show type vlan
>
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> ---
>   ip/ipaddress.c        | 24 ++++++++++++++++++++++++
>   ip/iplink.c           |  2 +-
>   man/man8/ip-link.8.in | 20 +++++++++++++++++++-
>   3 files changed, 44 insertions(+), 2 deletions(-)
>
> diff --git a/ip/ipaddress.c b/ip/ipaddress.c
> index 4d99324..a2f7a83 100644
> --- a/ip/ipaddress.c
> +++ b/ip/ipaddress.c
> @@ -57,6 +57,7 @@ static struct
>   	int flushe;
>   	int group;
>   	int master;
> +	char *link_kind;
The name can be just "kind", given all the others dont use the link prefix
>   } filter;
>   
>   static int do_link;
> @@ -189,6 +190,18 @@ static void print_linkmode(FILE *f, struct rtattr *tb)
>   		fprintf(f, "mode %s ", link_modes[mode]);
>   }
>   
> +static char *parse_link_kind(struct rtattr *tb)
> +{
> +	struct rtattr *linkinfo[IFLA_INFO_MAX+1];
> +
> +	parse_rtattr_nested(linkinfo, IFLA_INFO_MAX, tb);
> +
> +	if (linkinfo[IFLA_INFO_KIND])
> +		return RTA_DATA(linkinfo[IFLA_INFO_KIND]);
> +
> +	return "";
> +}
> +
>   static void print_linktype(FILE *fp, struct rtattr *tb)
>   {
>   	struct rtattr *linkinfo[IFLA_INFO_MAX+1];
> @@ -551,6 +564,14 @@ int print_linkinfo(const struct sockaddr_nl *who,
>   	else if (filter.master > 0)
>   		return -1;
>   
> +	if (filter.link_kind && tb[IFLA_LINKINFO]) {
> +		char *link_kind = parse_link_kind(tb[IFLA_LINKINFO]);
> +		if (strcmp(link_kind, filter.link_kind)) {
> +			return -1;
> +		}
you can skip the braces
> +	} else if (filter.link_kind)

you have if (filter.link_kind) twice, you can use a single if without 
the else.
> +		return -1;
> +
>   	if (n->nlmsg_type == RTM_DELLINK)
>   		fprintf(fp, "Deleted ");
>   
> @@ -1293,6 +1314,9 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
>   			if (!ifindex)
>   				invarg("Device does not exist\n", *argv);
>   			filter.master = ifindex;
> +		} else if (do_link && strcmp(*argv, "type") == 0) {
> +			NEXT_ARG();
> +			filter.link_kind = *argv;
>   		} else {
>   			if (strcmp(*argv, "dev") == 0) {
>   				NEXT_ARG();
> diff --git a/ip/iplink.c b/ip/iplink.c
> index ce6eb3e..f9a75d5 100644
> --- a/ip/iplink.c
> +++ b/ip/iplink.c
> @@ -82,7 +82,7 @@ void iplink_usage(void)
>   	fprintf(stderr, "			  [ master DEVICE ]\n");
>   	fprintf(stderr, "			  [ nomaster ]\n");
>   	fprintf(stderr, "			  [ addrgenmode { eui64 | none } ]\n");
> -	fprintf(stderr, "       ip link show [ DEVICE | group GROUP ] [up] [master DEV]\n");
> +	fprintf(stderr, "       ip link show [ DEVICE | group GROUP ] [up] [master DEV] [type TYPE]\n");
>   
>   	if (iplink_have_newlink()) {
>   		fprintf(stderr, "       ip link help [ TYPE ]\n");
> diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
> index 9d4e3da..4233291 100644
> --- a/man/man8/ip-link.8.in
> +++ b/man/man8/ip-link.8.in
> @@ -148,7 +148,9 @@ ip-link \- network device configuration
>   .IR GROUP " | "
>   .BR up " | "
>   .B master
> -.IR DEVICE " ]"
> +.IR DEVICE " | "
> +.B type
> +.IR TYPE " ]"
>   
>   .ti -8
>   .B ip link help
> @@ -688,6 +690,12 @@ only display running interfaces.
>   .I DEVICE
>   specifies the master device which enslaves devices to show.
>   
> +.TP
> +.BI type " TYPE "
> +.I TYPE
> +specifies the link type of devices to show.
> +
> +.TP
>   The show command has additional formatting options:
>   
>   .TP
> @@ -719,6 +727,16 @@ ip link show
>   Shows the state of all network interfaces on the system.
>   .RE
>   .PP
> +ip link show type bridge
> +.RS 4
> +Shows the bridge devices.
> +.RE
> +.PP
> +ip link show type vlan
> +.RS 4
> +Shows the vlan devices.
> +.RE
> +.PP
>   ip link set dev ppp0 mtu 1400
>   .RS 4
>   Change the MTU the ppp0 device.
