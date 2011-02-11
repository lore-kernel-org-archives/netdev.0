From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch iproute2 2/4] implement slave management operations
Date: Fri, 11 Feb 2011 16:27:05 +0100
Message-ID: <20110211152704.GE2763@psychotron.brq.redhat.com>
References: <20110211152125.GA2763@psychotron.brq.redhat.com>
 <20110211152214.GB2763@psychotron.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kaber@trash.net, fubar@us.ibm.com,
	netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9814 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754076Ab1BKP1k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Feb 2011 10:27:40 -0500
Content-Disposition: inline
In-Reply-To: <20110211152214.GB2763@psychotron.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen,

I did not include include/linux/if_link.h changes here as I saw in
history it's been done in the same way. If they are needed I can repost.

Thanks, Jirka

Fri, Feb 11, 2011 at 04:22:15PM CET, jpirko@redhat.com wrote:
>
>Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>---
> ip/ipaddress.c |   22 ++++++++++++++++++++++
> ip/iplink.c    |   16 ++++++++++++++++
> 2 files changed, 38 insertions(+), 0 deletions(-)
>
>diff --git a/ip/ipaddress.c b/ip/ipaddress.c
>index a775ecd..7446b81 100644
>--- a/ip/ipaddress.c
>+++ b/ip/ipaddress.c
>@@ -216,6 +216,18 @@ static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
> 		fprintf(fp, ", tx rate %d (Mbps)", vf_tx_rate->rate);
> }
> 
>+static void print_slave_info(FILE *fp, struct rtattr *sl)
>+{
>+	SPRINT_BUF(b1);
>+
>+	if (sl->rta_type != IFLA_SLAVE_DEV) {
>+		fprintf(stderr, "BUG: rta type is %d\n", sl->rta_type);
>+		return;
>+	}
>+
>+	fprintf(fp, " %s", ll_idx_n2a(*(int*)RTA_DATA(sl), b1));
>+}
>+
> int print_linkinfo(const struct sockaddr_nl *who,
> 		   struct nlmsghdr *n, void *arg)
> {
>@@ -420,6 +432,16 @@ int print_linkinfo(const struct sockaddr_nl *who,
> 			print_vfinfo(fp, i);
> 	}
> 
>+	if (tb[IFLA_SLAVE_LIST]) {
>+		struct rtattr *i, *slave_list = tb[IFLA_SLAVE_LIST];
>+		int rem = RTA_PAYLOAD(slave_list);
>+		fprintf(fp, "\n    slaves:");
>+		for (i = RTA_DATA(slave_list);
>+		     RTA_OK(i, rem);
>+		     i = RTA_NEXT(i, rem))
>+			print_slave_info(fp, i);
>+	}
>+
> 	fprintf(fp, "\n");
> 	fflush(fp);
> 	return 0;
>diff --git a/ip/iplink.c b/ip/iplink.c
>index cb2c4f5..02c48a2 100644
>--- a/ip/iplink.c
>+++ b/ip/iplink.c
>@@ -71,6 +71,7 @@ void iplink_usage(void)
> 	fprintf(stderr, "	                  [ vf NUM [ mac LLADDR ]\n");
> 	fprintf(stderr, "				   [ vlan VLANID [ qos VLAN-QOS ] ]\n");
> 	fprintf(stderr, "				   [ rate TXRATE ] ] \n");
>+	fprintf(stderr, "			  [ slave [ { add | del } ] DEVICE ]\n");
> 	fprintf(stderr, "       ip link show [ DEVICE ]\n");
> 
> 	if (iplink_have_newlink()) {
>@@ -361,6 +362,21 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
> 			if (len < 0)
> 				return -1;
> 			addattr_nest_end(&req->n, vflist);
>+		} else if (matches(*argv, "slave") == 0) {
>+			int type;
>+			int ifindex;
>+			NEXT_ARG();
>+			if (strcmp(*argv, "add") == 0)
>+				type = IFLA_SLAVE_ADD;
>+			else if (strcmp(*argv, "del") == 0)
>+				type = IFLA_SLAVE_DEL;
>+			else
>+				invarg("Invalid slave action\n", *argv);
>+			NEXT_ARG();
>+			ifindex = ll_name_to_index(*argv);
>+			if (!ifindex)
>+				invarg("Invalid slave device\n", *argv);
>+			addattr_l(&req->n, sizeof(*req), type, &ifindex, 4);
> #ifdef IFF_DYNAMIC
> 		} else if (matches(*argv, "dynamic") == 0) {
> 			NEXT_ARG();
>-- 
>1.7.3.4
>
