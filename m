From: Ben Greear <greearb@candelatech.com>
Subject: Re: [iproute2] iproute2:  Fix filtering related to flushing IP addresses.
Date: Fri, 20 Aug 2010 10:49:59 -0700
Message-ID: <4C6EC047.1030308@candelatech.com>
References: <1281978008-6383-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:41419 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751734Ab0HTRuA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Aug 2010 13:50:00 -0400
In-Reply-To: <1281978008-6383-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/16/2010 10:00 AM, Ben Greear wrote:
> The old 'ip addr flush' logic had several flaws:

Stephen, any chance this can be accepted upstream?

Thanks,
Ben

>
> * It reversed logic for primary v/s secondary flags
>    (though, it sort of worked right anyway)
>
> * The code tried to remove secondaries and then primaries,
>    but in practice, it always removed one primary per loop,
>    which not at all efficient.
>
> * The filter logic in the core would run only the first
>    filter in most cases.
>
> * If you used '-s -s', the ifa_flags member would be
>    modified, which could make future filters fail
>    to function fine.
>
> This patch attempts to fix all of these issues.
>
> Tested-by: Brian Haley<brian.haley@hp.com>
> Signed-off-by: Ben Greear<greearb@candelatech.com>
> ---
> :100644 100644 3a411b1... 19b3d6e... M	ip/ipaddress.c
> :100644 100644 cfeb894... ee4f045... M	lib/libnetlink.c
>   ip/ipaddress.c   |   34 +++++++++++++++++++++++-----------
>   lib/libnetlink.c |   23 ++++++++++++++++-------
>   2 files changed, 39 insertions(+), 18 deletions(-)
>
> diff --git a/ip/ipaddress.c b/ip/ipaddress.c
> index 3a411b1..19b3d6e 100644
> --- a/ip/ipaddress.c
> +++ b/ip/ipaddress.c
> @@ -453,6 +453,8 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
>   	struct ifaddrmsg *ifa = NLMSG_DATA(n);
>   	int len = n->nlmsg_len;
>   	int deprecated = 0;
> +	/* Use local copy of ifa_flags to not interfere with filtering code */
> +	unsigned int ifa_flags;
>   	struct rtattr * rta_tb[IFA_MAX+1];
>   	char abuf[256];
>   	SPRINT_BUF(b1);
> @@ -572,40 +574,41 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
>   				    abuf, sizeof(abuf)));
>   	}
>   	fprintf(fp, "scope %s ", rtnl_rtscope_n2a(ifa->ifa_scope, b1, sizeof(b1)));
> +	ifa_flags = ifa->ifa_flags;
>   	if (ifa->ifa_flags&IFA_F_SECONDARY) {
> -		ifa->ifa_flags&= ~IFA_F_SECONDARY;
> +		ifa_flags&= ~IFA_F_SECONDARY;
>   		if (ifa->ifa_family == AF_INET6)
>   			fprintf(fp, "temporary ");
>   		else
>   			fprintf(fp, "secondary ");
>   	}
>   	if (ifa->ifa_flags&IFA_F_TENTATIVE) {
> -		ifa->ifa_flags&= ~IFA_F_TENTATIVE;
> +		ifa_flags&= ~IFA_F_TENTATIVE;
>   		fprintf(fp, "tentative ");
>   	}
>   	if (ifa->ifa_flags&IFA_F_DEPRECATED) {
> -		ifa->ifa_flags&= ~IFA_F_DEPRECATED;
> +		ifa_flags&= ~IFA_F_DEPRECATED;
>   		deprecated = 1;
>   		fprintf(fp, "deprecated ");
>   	}
>   	if (ifa->ifa_flags&IFA_F_HOMEADDRESS) {
> -		ifa->ifa_flags&= ~IFA_F_HOMEADDRESS;
> +		ifa_flags&= ~IFA_F_HOMEADDRESS;
>   		fprintf(fp, "home ");
>   	}
>   	if (ifa->ifa_flags&IFA_F_NODAD) {
> -		ifa->ifa_flags&= ~IFA_F_NODAD;
> +		ifa_flags&= ~IFA_F_NODAD;
>   		fprintf(fp, "nodad ");
>   	}
>   	if (!(ifa->ifa_flags&IFA_F_PERMANENT)) {
>   		fprintf(fp, "dynamic ");
>   	} else
> -		ifa->ifa_flags&= ~IFA_F_PERMANENT;
> +		ifa_flags&= ~IFA_F_PERMANENT;
>   	if (ifa->ifa_flags&IFA_F_DADFAILED) {
> -		ifa->ifa_flags&= ~IFA_F_DADFAILED;
> +		ifa_flags&= ~IFA_F_DADFAILED;
>   		fprintf(fp, "dadfailed ");
>   	}
> -	if (ifa->ifa_flags)
> -		fprintf(fp, "flags %02x ", ifa->ifa_flags);
> +	if (ifa_flags)
> +		fprintf(fp, "flags %02x ", ifa_flags);
>   	if (rta_tb[IFA_LABEL])
>   		fprintf(fp, "%s", (char*)RTA_DATA(rta_tb[IFA_LABEL]));
>   	if (rta_tb[IFA_CACHEINFO]) {
> @@ -638,7 +641,7 @@ int print_addrinfo_primary(const struct sockaddr_nl *who, struct nlmsghdr *n,
>   {
>   	struct ifaddrmsg *ifa = NLMSG_DATA(n);
>
> -	if (!ifa->ifa_flags&  IFA_F_SECONDARY)
> +	if (ifa->ifa_flags&  IFA_F_SECONDARY)
>   		return 0;
>
>   	return print_addrinfo(who, n, arg);
> @@ -649,7 +652,7 @@ int print_addrinfo_secondary(const struct sockaddr_nl *who, struct nlmsghdr *n,
>   {
>   	struct ifaddrmsg *ifa = NLMSG_DATA(n);
>
> -	if (ifa->ifa_flags&  IFA_F_SECONDARY)
> +	if (!(ifa->ifa_flags&  IFA_F_SECONDARY))
>   		return 0;
>
>   	return print_addrinfo(who, n, arg);
> @@ -849,6 +852,7 @@ static int ipaddr_list_or_flush(int argc, char **argv, int flush)
>   				exit(1);
>   			}
>   			if (filter.flushed == 0) {
> +flush_done:
>   				if (show_stats) {
>   					if (round == 0)
>   						printf("Nothing to flush.\n");
> @@ -866,6 +870,14 @@ static int ipaddr_list_or_flush(int argc, char **argv, int flush)
>   				printf("\n*** Round %d, deleting %d addresses ***\n", round, filter.flushed);
>   				fflush(stdout);
>   			}
> +
> +			/* If we are flushing, and specifying primary, then we
> +			 * want to flush only a single round.  Otherwise, we'll
> +			 * start flushing secondaries that were promoted to
> +			 * primaries.
> +			 */
> +			if (!(filter.flags&  IFA_F_SECONDARY)&&  (filter.flagmask&  IFA_F_SECONDARY))
> +				goto flush_done;
>   		}
>   		fprintf(stderr, "*** Flush remains incomplete after %d rounds. ***\n", MAX_ROUNDS); fflush(stderr);
>   		return 1;
> diff --git a/lib/libnetlink.c b/lib/libnetlink.c
> index cfeb894..ee4f045 100644
> --- a/lib/libnetlink.c
> +++ b/lib/libnetlink.c
> @@ -189,6 +189,8 @@ int rtnl_dump_filter_l(struct rtnl_handle *rth,
>   	while (1) {
>   		int status;
>   		const struct rtnl_dump_filter_arg *a;
> +		int found_done = 0;
> +		int msglen = 0;
>
>   		iov.iov_len = sizeof(buf);
>   		status = recvmsg(rth->fd,&msg, 0);
> @@ -208,8 +210,9 @@ int rtnl_dump_filter_l(struct rtnl_handle *rth,
>
>   		for (a = arg; a->filter; a++) {
>   			struct nlmsghdr *h = (struct nlmsghdr*)buf;
> +			msglen = status;
>
> -			while (NLMSG_OK(h, status)) {
> +			while (NLMSG_OK(h, msglen)) {
>   				int err;
>
>   				if (nladdr.nl_pid != 0 ||
> @@ -224,8 +227,10 @@ int rtnl_dump_filter_l(struct rtnl_handle *rth,
>   					goto skip_it;
>   				}
>
> -				if (h->nlmsg_type == NLMSG_DONE)
> -					return 0;
> +				if (h->nlmsg_type == NLMSG_DONE) {
> +					found_done = 1;
> +					break; /* process next filter */
> +				}
>   				if (h->nlmsg_type == NLMSG_ERROR) {
>   					struct nlmsgerr *err = (struct nlmsgerr*)NLMSG_DATA(h);
>   					if (h->nlmsg_len<  NLMSG_LENGTH(sizeof(struct nlmsgerr))) {
> @@ -242,15 +247,19 @@ int rtnl_dump_filter_l(struct rtnl_handle *rth,
>   					return err;
>
>   skip_it:
> -				h = NLMSG_NEXT(h, status);
> +				h = NLMSG_NEXT(h, msglen);
>   			}
> -		} while (0);
> +		}
> +
> +		if (found_done)
> +			return 0;
> +
>   		if (msg.msg_flags&  MSG_TRUNC) {
>   			fprintf(stderr, "Message truncated\n");
>   			continue;
>   		}
> -		if (status) {
> -			fprintf(stderr, "!!!Remnant of size %d\n", status);
> +		if (msglen) {
> +			fprintf(stderr, "!!!Remnant of size %d\n", msglen);
>   			exit(1);
>   		}
>   	}


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

