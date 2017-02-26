From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] iproute2: show network device dependency tree
Date: Sun, 26 Feb 2017 08:56:33 +0100
Message-ID: <20170226075633.GA1788@nanopsycho>
References: <20170225165900.10129-1-zaboj.campula@post.cz>
 <20170225173927.GA2479@nanopsycho>
 <1488054142.3856.15.camel@post.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Zaboj Campula <zaboj.campula@post.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33739 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750970AbdBZH5u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 26 Feb 2017 02:57:50 -0500
Received: by mail-wm0-f68.google.com with SMTP id v77so8843225wmv.0
        for <netdev@vger.kernel.org>; Sat, 25 Feb 2017 23:56:35 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1488054142.3856.15.camel@post.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Feb 25, 2017 at 09:22:22PM CET, zaboj.campula@post.cz wrote:
>On Sat, 2017-02-25 at 18:39 +0100, Jiri Pirko wrote:
>> > Sat, Feb 25, 2017 at 05:59:00PM CET, zaboj.campula@post.cz wrote:
>> > Add the argument '-tree' to ip-link to show network devices dependency tree.
>> > 
>> > Example:
>> > 
>> > $ ip -tree link
>> > eth0
>> >    bond0
>> > eth1
>> >    bond0
>> > eth2
>> >    bond1
>> > eth3
>> >    bond1
>> 
>> 
>> Hmm, what is this good for? I'm probably missing something...
>
>I consider this kind of output useful when troubleshooting a complex
>configuration with many interfaces. It may show relations among
>interfaces.

Did you see https://github.com/jbenc/plotnetcfg ?


>
>
>> 
>> 
>> 
>> > 
>> > > > Signed-off-by: Zaboj Campula <zaboj.campula@post.cz>
>> > ---
>> > include/utils.h |  1 +
>> > ip/ip.c         |  5 ++-
>> > ip/ipaddress.c  | 97 ++++++++++++++++++++++++++++++++++++++++++++++++---------
>> > 3 files changed, 87 insertions(+), 16 deletions(-)
>> > 
>> > diff --git a/include/utils.h b/include/utils.h
>> > index 22369e0..f1acf4d 100644
>> > --- a/include/utils.h
>> > +++ b/include/utils.h
>> > @@ -20,6 +20,7 @@ extern int show_raw;
>> > extern int resolve_hosts;
>> > extern int oneline;
>> > extern int brief;
>> > +extern int tree;;
>> > extern int timestamp;
>> > extern int timestamp_short;
>> > extern const char * _SL_;
>> > diff --git a/ip/ip.c b/ip/ip.c
>> > index 07050b0..29747a5 100644
>> > --- a/ip/ip.c
>> > +++ b/ip/ip.c
>> > @@ -33,6 +33,7 @@ int show_details;
>> > int resolve_hosts;
>> > int oneline;
>> > int brief;
>> > +int tree;
>> > int timestamp;
>> > const char *_SL_;
>> > int force;
>> > @@ -57,7 +58,7 @@ static void usage(void)
>> > "                    -h[uman-readable] | -iec |\n"
>> > "                    -f[amily] { inet | inet6 | ipx | dnet | mpls | bridge | link } |\n"
>> > "                    -4 | -6 | -I | -D | -B | -0 |\n"
>> > -"                    -l[oops] { maximum-addr-flush-attempts } | -br[ief] |\n"
>> > +"                    -l[oops] { maximum-addr-flush-attempts } | -br[ief] | -tr[ee] |\n"
>> > "                    -o[neline] | -t[imestamp] | -ts[hort] | -b[atch] [filename] |\n"
>> > "                    -rc[vbuf] [size] | -n[etns] name | -a[ll] | -c[olor]}\n");
>> > 	exit(-1);
>> > @@ -257,6 +258,8 @@ int main(int argc, char **argv)
>> > > > 			batch_file = argv[1];
>> > > > 		} else if (matches(opt, "-brief") == 0) {
>> > > > 			++brief;
>> > > > +		} else if (matches(opt, "-tree") == 0) {
>> > > > +			++tree;
>> > > > 		} else if (matches(opt, "-rcvbuf") == 0) {
>> > > > 			unsigned int size;
>> > 
>> > diff --git a/ip/ipaddress.c b/ip/ipaddress.c
>> > index 242c6ea..5ebcb1a 100644
>> > --- a/ip/ipaddress.c
>> > +++ b/ip/ipaddress.c
>> > @@ -1534,6 +1534,69 @@ static int iplink_filter_req(struct nlmsghdr *nlh, int reqlen)
>> > 	return 0;
>> > }
>> > 
>> > +static int has_master(struct nlmsg_chain *linfo, int index)
>> > +{
>> > > > +	struct nlmsg_list *l;
>> > > > +	struct rtattr *tb[IFLA_MAX+1];
>> > > > +	int len;
>> > > > +	for (l = linfo->head; l; l = l->next) {
>> > > > +		struct ifinfomsg *ifi = NLMSG_DATA(&l->h);
>> > > > +		len = l->h.nlmsg_len;
>> > > > +		len -= NLMSG_LENGTH(sizeof(*ifi));
>> > > > +		parse_rtattr(tb, IFLA_MAX, IFLA_RTA(ifi), len);
>> > > > +		if (tb[IFLA_MASTER] && *(int *)RTA_DATA(tb[IFLA_MASTER]) == index)
>> > > > +			return 1;
>> > > > +	}
>> > > > +	return 0;
>> > +}
>> > +
>> > +static struct nlmsg_list *get_master(struct nlmsg_chain *linfo, struct rtattr **tb)
>> > +{
>> > > > +	struct nlmsg_list *l;
>> > > > +	if (tb[IFLA_MASTER]) {
>> > > > +		int master = *(int *)RTA_DATA(tb[IFLA_MASTER]);
>> > > > +		for (l = linfo->head; l; l = l->next) {
>> > > > +			struct ifinfomsg *ifi = NLMSG_DATA(&l->h);
>> > > > +			if (ifi->ifi_index == master)
>> > > > +				return l;
>> > > > +		}
>> > > > +	}
>> > > > +	return NULL;
>> > +}
>> > +
>> > +static void print_dev_tree_item(struct nlmsg_chain *linfo, struct nlmsg_list *l, int indent) {
>> > > > +	char *name;
>> > > > +	int len;
>> > > > +	struct ifinfomsg *ifi = NLMSG_DATA(&l->h);
>> > > > +	struct rtattr *tb[IFLA_MAX+1];
>> > > > +	len = l->h.nlmsg_len;
>> > > > +	len -= NLMSG_LENGTH(sizeof(*ifi));
>> > > > +	parse_rtattr(tb, IFLA_MAX, IFLA_RTA(ifi), len);
>> > > > +	name = (char *)(tb[IFLA_IFNAME] ? rta_getattr_str(tb[IFLA_IFNAME]) : "<nil>");
>> > +
>> > > > +	printf("%*s%s\n", indent * 4, "", name);
>> > +
>> > > > +	struct nlmsg_list *master = get_master(linfo, tb);
>> > > > +	if (master) {
>> > > > +		if (indent > 8) {
>> > > > +			printf("%*s...\n", (indent + 1) * 4, "");
>> > > > +		} else {
>> > > > +			print_dev_tree_item(linfo, master, indent + 1);
>> > > > +		}
>> > > > +	}
>> > +}
>> > +
>> > +static void print_devtree(struct nlmsg_chain *linfo)
>> > +{
>> > > > +	struct nlmsg_list *l;
>> > > > +	for (l = linfo->head; l; l = l->next) {
>> > > > +		struct ifinfomsg *ifi = NLMSG_DATA(&l->h);
>> > > > +		if (!has_master(linfo, ifi->ifi_index)) {
>> > > > +			print_dev_tree_item(linfo, l, 0);
>> > > > +		}
>> > > > +	}
>> > +}
>> > +
>> > static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
>> > {
>> > 	struct nlmsg_chain linfo = { NULL, NULL};
>> > @@ -1742,23 +1805,27 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
>> > > > 		ipaddr_filter(&linfo, &ainfo);
>> > 	}
>> > 
>> > > > -	for (l = linfo.head; l; l = l->next) {
>> > > > -		int res = 0;
>> > > > -		struct ifinfomsg *ifi = NLMSG_DATA(&l->h);
>> > -
>> > > > -		if (brief) {
>> > > > -			if (print_linkinfo_brief(NULL, &l->h, stdout) == 0)
>> > > > +	if (tree) {
>> > > > +		print_devtree(&linfo);
>> > > > +	} else {
>> > > > +		for (l = linfo.head; l; l = l->next) {
>> > > > +			int res = 0;
>> > > > +			struct ifinfomsg *ifi = NLMSG_DATA(&l->h);
>> > +
>> > > > +			 if (brief) {
>> > > > +				if (print_linkinfo_brief(NULL, &l->h, stdout) == 0)
>> > > > +					if (filter.family != AF_PACKET)
>> > > > +						print_selected_addrinfo(ifi,
>> > > > +									ainfo.head,
>> > > > +									stdout);
>> > > > +			} else if (no_link ||
>> > > > +				 (res = print_linkinfo(NULL, &l->h, stdout)) >= 0) {
>> > > > 				if (filter.family != AF_PACKET)
>> > > > 					print_selected_addrinfo(ifi,
>> > > > -								ainfo.head,
>> > > > -								stdout);
>> > > > -		} else if (no_link ||
>> > > > -			 (res = print_linkinfo(NULL, &l->h, stdout)) >= 0) {
>> > > > -			if (filter.family != AF_PACKET)
>> > > > -				print_selected_addrinfo(ifi,
>> > > > -							ainfo.head, stdout);
>> > > > -			if (res > 0 && !do_link && show_stats)
>> > > > -				print_link_stats(stdout, &l->h);
>> > > > +								ainfo.head, stdout);
>> > > > +				if (res > 0 && !do_link && show_stats)
>> > > > +					print_link_stats(stdout, &l->h);
>> > > > +			}
>> > > > 		}
>> > 	}
>> > 	fflush(stdout);
>> > -- 
>> > 2.9.3
>> > 
