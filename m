From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next 6/8] iproute2: Add support for the RTA_VIA
 attribute
Date: Mon, 6 Apr 2015 19:27:14 -0400
Message-ID: <20150406232713.GR1051@gospo>
References: <87bnjwspek.fsf@x220.int.ebiederm.org>
 <c3ad7d77783046d38e5b23b5e1fe0f71@BRMWP-EXMB11.corp.brocade.com>
 <20150315123337.2694183a@urahara>
 <87lhiyoxnw.fsf@x220.int.ebiederm.org>
 <87bnjuoxe8.fsf_-_@x220.int.ebiederm.org>
 <87d24animx.fsf_-_@x220.int.ebiederm.org>
 <552310E6.5060503@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Stephen Hemminger <shemming@brocade.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Vivek Venkatraman <vivek@cumulusnetworks.com>,
	rshearma@brocade.com
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:32933 "EHLO
	mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752834AbbDFX1D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2015 19:27:03 -0400
Received: by qkx62 with SMTP id 62so34784856qkx.0
        for <netdev@vger.kernel.org>; Mon, 06 Apr 2015 16:27:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <552310E6.5060503@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 06, 2015 at 04:04:06PM -0700, roopa wrote:
> On 3/15/15, 12:52 PM, Eric W. Biederman wrote:
> >Add support for the RTA_VIA attribute that specifies an address family
> >as well as an address for the next hop gateway.
> >
> >To make it easy to pass this reorder inet_prefix so that it's tail
> >is a proper RTA_VIA attribute.
> >
> >Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> >---
> >  include/linux/rtnetlink.h |  7 +++++
> >  include/utils.h           |  7 +++--
> >  ip/iproute.c              | 76 +++++++++++++++++++++++++++++++++++++++++------
> >  man/man8/ip-route.8.in    | 18 +++++++----
> >  4 files changed, 90 insertions(+), 18 deletions(-)
> >
> >diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
> >index 3eb78105399b..03e4c8df8e60 100644
> >--- a/include/linux/rtnetlink.h
> >+++ b/include/linux/rtnetlink.h
> >@@ -303,6 +303,7 @@ enum rtattr_type_t {
> >  	RTA_TABLE,
> >  	RTA_MARK,
> >  	RTA_MFC_STATS,
> >+	RTA_VIA,
> 
> eric, if its not too late, what do you think about renaming RTA_VIA
> attribute to
> RTA_NEWGATEWAY (similar to your new RTA_NEWDST attribute to specify a label
> dst) ?. RTA_VIA is fine too.
> This is indeed a new way to specify a gateway (and can/will be used by RFC
> 5549 in the future).
> 
> If there is interest in renaming it to RTA_NEWGATEWAY (or any other name,
> cant think of anything better right now),
> I will be happy to submit a follow-on patch.

FWIW, I actually do not mind the name RTA_VIA.  I was planning to
replace use of RTA_GATEWAY in iproute2 and just usa RTA_VIA for all
nexthops regardless of the address family of the dest route or nexthop
and would allow easy creation of the infrastructure needed to support
RFC5549 -- obviously while keeping backwards compatibility in the
kernel.

This was what my orignal set did (not submitted to netdev, but discussed
with others at netconf) and it was much cleaner code-wise (but not ideal
as I overloaded the use of RTA_GATEWAY and that was not pleasing to me
or others).


> 
> Thanks!.
> 
> >  	__RTA_MAX
> >  };
> >@@ -344,6 +345,12 @@ struct rtnexthop {
> >  #define RTNH_SPACE(len)	RTNH_ALIGN(RTNH_LENGTH(len))
> >  #define RTNH_DATA(rtnh)   ((struct rtattr*)(((char*)(rtnh)) + RTNH_LENGTH(0)))
> >+/* RTA_VIA */
> >+struct rtvia {
> >+	__kernel_sa_family_t	rtvia_family;
> >+	__u8			rtvia_addr[0];
> >+};
> >+
> >  /* RTM_CACHEINFO */
> >  struct rta_cacheinfo {
> >diff --git a/include/utils.h b/include/utils.h
> >index 99dde4c5a667..6bbcc10756d3 100644
> >--- a/include/utils.h
> >+++ b/include/utils.h
> >@@ -50,10 +50,11 @@ extern void incomplete_command(void) __attribute__((noreturn));
> >  typedef struct
> >  {
> >-	__u8 family;
> >-	__u8 bytelen;
> >+	__u16 flags;
> >+	__u16 bytelen;
> >  	__s16 bitlen;
> >-	__u32 flags;
> >+	/* These next two fields match rtvia */
> >+	__u16 family;
> >  	__u32 data[8];
> >  } inet_prefix;
> >diff --git a/ip/iproute.c b/ip/iproute.c
> >index 79d0760a34f6..c6ee411fdd56 100644
> >--- a/ip/iproute.c
> >+++ b/ip/iproute.c
> >@@ -75,7 +75,8 @@ static void usage(void)
> >  	fprintf(stderr, "             [ table TABLE_ID ] [ proto RTPROTO ]\n");
> >  	fprintf(stderr, "             [ scope SCOPE ] [ metric METRIC ]\n");
> >  	fprintf(stderr, "INFO_SPEC := NH OPTIONS FLAGS [ nexthop NH ]...\n");
> >-	fprintf(stderr, "NH := [ via ADDRESS ] [ dev STRING ] [ weight NUMBER ] NHFLAGS\n");
> >+	fprintf(stderr, "NH := [ via [ FAMILY ] ADDRESS ] [ dev STRING ] [ weight NUMBER ] NHFLAGS\n");
> >+	fprintf(stderr, "FAMILY := [ inet | inet6 | ipx | dnet | bridge | link ]");
> >  	fprintf(stderr, "OPTIONS := FLAGS [ mtu NUMBER ] [ advmss NUMBER ]\n");
> >  	fprintf(stderr, "           [ rtt TIME ] [ rttvar TIME ] [ reordering NUMBER ]\n");
> >  	fprintf(stderr, "           [ window NUMBER] [ cwnd NUMBER ] [ initcwnd NUMBER ]\n");
> >@@ -185,8 +186,15 @@ static int filter_nlmsg(struct nlmsghdr *n, struct rtattr **tb, int host_len)
> >  	    (r->rtm_family != filter.msrc.family ||
> >  	     (filter.msrc.bitlen >= 0 && filter.msrc.bitlen < r->rtm_src_len)))
> >  		return 0;
> >-	if (filter.rvia.family && r->rtm_family != filter.rvia.family)
> >-		return 0;
> >+	if (filter.rvia.family) {
> >+		int family = r->rtm_family;
> >+		if (tb[RTA_VIA]) {
> >+			struct rtvia *via = RTA_DATA(tb[RTA_VIA]);
> >+			family = via->rtvia_family;
> >+		}
> >+		if (family != filter.rvia.family)
> >+			return 0;
> >+	}
> >  	if (filter.rprefsrc.family && r->rtm_family != filter.rprefsrc.family)
> >  		return 0;
> >@@ -205,6 +213,12 @@ static int filter_nlmsg(struct nlmsghdr *n, struct rtattr **tb, int host_len)
> >  		via.family = r->rtm_family;
> >  		if (tb[RTA_GATEWAY])
> >  			memcpy(&via.data, RTA_DATA(tb[RTA_GATEWAY]), host_len/8);
> >+		if (tb[RTA_VIA]) {
> >+			size_t len = RTA_PAYLOAD(tb[RTA_VIA]) - 2;
> >+			struct rtvia *rtvia = RTA_DATA(tb[RTA_VIA]);
> >+			via.family = rtvia->rtvia_family;
> >+			memcpy(&via.data, rtvia->rtvia_addr, len);
> >+		}
> >  	}
> >  	if (filter.rprefsrc.bitlen>0) {
> >  		memset(&prefsrc, 0, sizeof(prefsrc));
> >@@ -386,6 +400,14 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
> >  				    RTA_DATA(tb[RTA_GATEWAY]),
> >  				    abuf, sizeof(abuf)));
> >  	}
> >+	if (tb[RTA_VIA]) {
> >+		size_t len = RTA_PAYLOAD(tb[RTA_VIA]) - 2;
> >+		struct rtvia *via = RTA_DATA(tb[RTA_VIA]);
> >+		fprintf(fp, "via %s %s ",
> >+			family_name(via->rtvia_family),
> >+			format_host(via->rtvia_family, len, via->rtvia_addr,
> >+				    abuf, sizeof(abuf)));
> >+	}
> >  	if (tb[RTA_OIF] && filter.oifmask != -1)
> >  		fprintf(fp, "dev %s ", ll_index_to_name(*(int*)RTA_DATA(tb[RTA_OIF])));
> >@@ -601,6 +623,14 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
> >  							    RTA_DATA(tb[RTA_GATEWAY]),
> >  							    abuf, sizeof(abuf)));
> >  				}
> >+				if (tb[RTA_VIA]) {
> >+					size_t len = RTA_PAYLOAD(tb[RTA_VIA]) - 2;
> >+					struct rtvia *via = RTA_DATA(tb[RTA_VIA]);
> >+					fprintf(fp, "via %s %s ",
> >+						family_name(via->rtvia_family),
> >+						format_host(via->rtvia_family, len, via->rtvia_addr,
> >+							    abuf, sizeof(abuf)));
> >+				}
> >  				if (tb[RTA_FLOW]) {
> >  					__u32 to = rta_getattr_u32(tb[RTA_FLOW]);
> >  					__u32 from = to>>16;
> >@@ -648,12 +678,23 @@ static int parse_one_nh(struct rtmsg *r, struct rtattr *rta,
> >  	while (++argv, --argc > 0) {
> >  		if (strcmp(*argv, "via") == 0) {
> >  			inet_prefix addr;
> >+			int family;
> >  			NEXT_ARG();
> >-			get_addr(&addr, *argv, r->rtm_family);
> >+			family = read_family(*argv);
> >+			if (family == AF_UNSPEC)
> >+				family = r->rtm_family;
> >+			else
> >+				NEXT_ARG();
> >+			get_addr(&addr, *argv, family);
> >  			if (r->rtm_family == AF_UNSPEC)
> >  				r->rtm_family = addr.family;
> >-			rta_addattr_l(rta, 4096, RTA_GATEWAY, &addr.data, addr.bytelen);
> >-			rtnh->rtnh_len += sizeof(struct rtattr) + addr.bytelen;
> >+			if (addr.family == r->rtm_family) {
> >+				rta_addattr_l(rta, 4096, RTA_GATEWAY, &addr.data, addr.bytelen);
> >+				rtnh->rtnh_len += sizeof(struct rtattr) + addr.bytelen;
> >+			} else {
> >+				rta_addattr_l(rta, 4096, RTA_VIA, &addr.family, addr.bytelen+2);
> >+				rtnh->rtnh_len += sizeof(struct rtattr) + addr.bytelen+2;
> >+			}
> >  		} else if (strcmp(*argv, "dev") == 0) {
> >  			NEXT_ARG();
> >  			if ((rtnh->rtnh_ifindex = ll_name_to_index(*argv)) == 0) {
> >@@ -761,12 +802,21 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
> >  			addattr_l(&req.n, sizeof(req), RTA_PREFSRC, &addr.data, addr.bytelen);
> >  		} else if (strcmp(*argv, "via") == 0) {
> >  			inet_prefix addr;
> >+			int family;
> >  			gw_ok = 1;
> >  			NEXT_ARG();
> >-			get_addr(&addr, *argv, req.r.rtm_family);
> >+			family = read_family(*argv);
> >+			if (family == AF_UNSPEC)
> >+				family = req.r.rtm_family;
> >+			else
> >+				NEXT_ARG();
> >+			get_addr(&addr, *argv, family);
> >  			if (req.r.rtm_family == AF_UNSPEC)
> >  				req.r.rtm_family = addr.family;
> >-			addattr_l(&req.n, sizeof(req), RTA_GATEWAY, &addr.data, addr.bytelen);
> >+			if (addr.family == req.r.rtm_family)
> >+				addattr_l(&req.n, sizeof(req), RTA_GATEWAY, &addr.data, addr.bytelen);
> >+			else
> >+				addattr_l(&req.n, sizeof(req), RTA_VIA, &addr.family, addr.bytelen+2);
> >  		} else if (strcmp(*argv, "from") == 0) {
> >  			inet_prefix addr;
> >  			NEXT_ARG();
> >@@ -1251,8 +1301,14 @@ static int iproute_list_flush_or_save(int argc, char **argv, int action)
> >  			get_unsigned(&mark, *argv, 0);
> >  			filter.markmask = -1;
> >  		} else if (strcmp(*argv, "via") == 0) {
> >+			int family;
> >  			NEXT_ARG();
> >-			get_prefix(&filter.rvia, *argv, do_ipv6);
> >+			family = read_family(*argv);
> >+			if (family == AF_UNSPEC)
> >+				family = do_ipv6;
> >+			else
> >+				NEXT_ARG();
> >+			get_prefix(&filter.rvia, *argv, family);
> >  		} else if (strcmp(*argv, "src") == 0) {
> >  			NEXT_ARG();
> >  			get_prefix(&filter.rprefsrc, *argv, do_ipv6);
> >@@ -1554,6 +1610,8 @@ static int iproute_get(int argc, char **argv)
> >  			tb[RTA_OIF]->rta_type = 0;
> >  		if (tb[RTA_GATEWAY])
> >  			tb[RTA_GATEWAY]->rta_type = 0;
> >+		if (tb[RTA_VIA])
> >+			tb[RTA_VIA]->rta_type = 0;
> >  		if (!idev && tb[RTA_IIF])
> >  			tb[RTA_IIF]->rta_type = 0;
> >  		req.n.nlmsg_flags = NLM_F_REQUEST;
> >diff --git a/man/man8/ip-route.8.in b/man/man8/ip-route.8.in
> >index 2b1583d5a30c..906cfea0cd6b 100644
> >--- a/man/man8/ip-route.8.in
> >+++ b/man/man8/ip-route.8.in
> >@@ -81,13 +81,18 @@ replace " } "
> >  .ti -8
> >  .IR NH " := [ "
> >  .B  via
> >-.IR ADDRESS " ] [ "
> >+[
> >+.IR FAMILY " ] " ADDRESS " ] [ "
> >  .B  dev
> >  .IR STRING " ] [ "
> >  .B  weight
> >  .IR NUMBER " ] " NHFLAGS
> >  .ti -8
> >+.IR FAMILY " := [ "
> >+.BR inet " | " inet6 " | " ipx " | " dnet " | " bridge " | " link " ]"
> >+
> >+.ti -8
> >  .IR OPTIONS " := " FLAGS " [ "
> >  .B  mtu
> >  .IR NUMBER " ] [ "
> >@@ -333,9 +338,10 @@ table by default.
> >  the output device name.
> >  .TP
> >-.BI via " ADDRESS"
> >-the address of the nexthop router.  Actually, the sense of this field
> >-depends on the route type.  For normal
> >+.BI via " [ FAMILY ] ADDRESS"
> >+the address of the nexthop router, in the address family FAMILY.
> >+Actually, the sense of this field depends on the route type.  For
> >+normal
> >  .B unicast
> >  routes it is either the true next hop router or, if it is a direct
> >  route installed in BSD compatibility mode, it can be a local address
> >@@ -472,7 +478,7 @@ is a complex value with its own syntax similar to the top level
> >  argument lists:
> >  .in +8
> >-.BI via " ADDRESS"
> >+.BI via " [ FAMILY ] ADDRESS"
> >  - is the nexthop router.
> >  .sp
> >@@ -669,7 +675,7 @@ only list routes of this type.
> >  only list routes going via this device.
> >  .TP
> >-.BI via " PREFIX"
> >+.BI via " [ FAMILY ] PREFIX"
> >  only list routes going via the nexthop routers selected by
> >  .IR PREFIX "."
> 
