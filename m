From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: Re: [PATCH 1/1] iproute2 bridge: bring to par with brctl show macs
Date: Tue, 27 May 2014 08:59:52 -0700
Message-ID: <27A51C19-553E-4BA0-A8B2-F4251FABA5F4@cumulusnetworks.com>
References: <1401024151-8774-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>,
	Vlad Yasevich <vyasevic@redhat.com>, john.r.fastabend@intel.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:41991 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751777AbaE0QAE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 12:00:04 -0400
In-Reply-To: <1401024151-8774-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On May 25, 2014, at 6:22 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> Example usage with bridge sw1 with two entries (port sw1-p1)
> 
> root@jhs-1:iprtmay24# ./bridge/bridge fdb help
> Usage: bridge fdb { add | append | del | replace } ADDR dev DEV
> {self|master} [ temp ]
>              [router] [ dst IPADDR] [ vlan VID ]
>              [ port PORT] [ vni VNI ] [via DEV]
>       bridge fdb {show} [ br BRDEV ] [ brport DEV ]
> root@jhs-1:iprtmay24#
> root@jhs-1:iprtmay24#
> root@jhs-1:iprtmay24# bridge fdb show
> 33:33:00:00:00:01 dev bond0 self permanent
> 33:33:00:00:00:01 dev dummy0 self permanent
> 33:33:00:00:00:01 dev ifb0 self permanent
> 33:33:00:00:00:01 dev ifb1 self permanent
> 33:33:00:00:00:01 dev eth0 self permanent
> 01:00:5e:00:00:01 dev eth0 self permanent
> 33:33:ff:22:01:01 dev eth0 self permanent
> 33:33:00:00:00:01 dev eth1 self permanent
> 33:33:00:00:00:01 dev gretap0 self permanent
> 6e:9a:af:54:70:ff dev sw1-p1 vlan 0 permanent
> 00:17:42:8a:b4:05 dev sw1-p1 vlan 0 permanent
> 33:33:00:00:00:01 dev sw1-p1 self permanent
> root@moja-1:iprtmay24#
> root@moja-1:iprtmay24# bridge fdb show br sw1
> 6e:9a:af:54:70:ff dev sw1-p1 vlan 0 permanent
> 00:17:42:8a:b4:05 dev sw1-p1 vlan 0 permanent
> 
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
> ---
> bridge/fdb.c |   29 ++++++++++++++++++++++++-----
> 1 file changed, 24 insertions(+), 5 deletions(-)
> 
> diff --git a/bridge/fdb.c b/bridge/fdb.c
> index 9b720e3..01a2d71 100644
> --- a/bridge/fdb.c
> +++ b/bridge/fdb.c
> @@ -33,7 +33,7 @@ static void usage(void)
> 	fprintf(stderr, "Usage: bridge fdb { add | append | del | replace } ADDR dev DEV {self|master} [ temp ]\n"
> 		        "              [router] [ dst IPADDR] [ vlan VID ]\n"
> 		        "              [ port PORT] [ vni VNI ] [via DEV]\n");
> -	fprintf(stderr, "       bridge fdb {show} [ dev DEV ]\n");
> +	fprintf(stderr, "       bridge fdb {show} [ br BRDEV ] [ brport DEV ]\n");
> 	exit(-1);
> }
> 
> @@ -157,18 +157,35 @@ int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
> 
> static int fdb_show(int argc, char **argv)
> {
> +	struct ndmsg ndm = { };
> 	char *filter_dev = NULL;
> +	char *br = NULL;
> +
> +	ndm.ndm_family = PF_BRIDGE;
> +	ndm.ndm_state = NUD_NOARP;
> 
> 	while (argc > 0) {
> -		if (strcmp(*argv, "dev") == 0) {
> +		if ((strcmp(*argv, "brport") == 0) || strcmp(*argv, "dev") == 0) {
> 			NEXT_ARG();
> -			if (filter_dev)
> -				duparg("dev", *argv);
> 			filter_dev = *argv;
> +		} else if (strcmp(*argv, "br") == 0) {
> +			NEXT_ARG();
> +			br = *argv;
> +		} else {
> +			if (matches(*argv, "help") == 0)
> +				usage();
> 		}
> 		argc--; argv++;
> 	}
> 
> +	if (br) {
> +		ndm.ndm_ifindex = ll_name_to_index(br);

Seems you could use your new kernel filter for brports also, when br is not specified.  If both br and brport is specified, then use filter in user-space, otherwise use filter in kernel on br or brport ifindex.

> +		if (ndm.ndm_ifindex == 0) {
> +			fprintf(stderr, "Cannot find bridge device \"%s\"\n", br);
> +			return -1;
> +		}
> +	}
> +
> 	if (filter_dev) {
> 		filter_index = if_nametoindex(filter_dev);
> 		if (filter_index == 0) {
> @@ -176,13 +193,15 @@ static int fdb_show(int argc, char **argv)
> 				filter_dev);
> 			return -1;
> 		}
> +
> 	}
> 
> -	if (rtnl_wilddump_request(&rth, PF_BRIDGE, RTM_GETNEIGH) < 0) {
> +	if (rtnl_dump_request(&rth, RTM_GETNEIGH, &ndm, sizeof(struct ndmsg)) < 0) {
> 		perror("Cannot send dump request");
> 		exit(1);
> 	}
> 
> +
> 	if (rtnl_dump_filter(&rth, print_fdb, stdout) < 0) {
> 		fprintf(stderr, "Dump terminated\n");
> 		exit(1);
> -- 
> 1.7.9.5
> 


-scott
