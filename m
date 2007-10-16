From: Patrick McHardy <kaber@trash.net>
Subject: Re: Resend: [IPROUTE2 PATCH] Interface group as new ip link option
Date: Tue, 16 Oct 2007 11:11:29 +0200
Message-ID: <47148041.1020607@trash.net>
References: <ifgroup.20071015.1192520046.panther@balabit.hu> <1192525384222-git-send-email-panther@balabit.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Laszlo Attila Toth <panther@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35204 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757330AbXJPJLq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 05:11:46 -0400
In-Reply-To: <1192525384222-git-send-email-panther@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Laszlo Attila Toth wrote:
> +static int set_group(const char *dev, int ifgroup)
> +{
> +	struct {
> +		struct nlmsghdr 	n;
> +		struct ifinfomsg 	ifi;
> +		char   			buf[256];
> +	} req;
> +	struct rtnl_handle rth;
> +	
> +	memset(&req, 0, sizeof(req));
> +	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(req.ifi));
> +	req.n.nlmsg_flags = NLM_F_REQUEST;
> +	req.n.nlmsg_type = RTM_SETLINK;
> +	
> +	req.ifi.ifi_index = -1;
> +	
> +	addattr_l(&req.n, sizeof(req), IFLA_IFNAME, dev, strlen(dev)+1);
> +	addattr_l(&req.n, sizeof(req), IFLA_IFGROUP, &ifgroup, sizeof(ifgroup));
> +	if (rtnl_open(&rth, 0) < 0)
> +		exit(1);
> +	if (rtnl_talk(&rth, &req.n, 0, 0, NULL, NULL, NULL) < 0)
> +		return -1;
> +	rtnl_close(&rth);
> +	return 0;
> +}
> +
>  static int get_address(const char *dev, int *htype)
>  {
>  	struct ifreq ifr;
> @@ -545,6 +582,7 @@ static int do_set(int argc, char **argv)
>  	__u32 mask = 0;
>  	__u32 flags = 0;
>  	int qlen = -1;
> +	__u32 group = 0;
>  	int mtu = -1;
>  	char *newaddr = NULL;
>  	char *newbrd = NULL;
> @@ -577,6 +615,13 @@ static int do_set(int argc, char **argv)
>  				duparg("txqueuelen", *argv);
>  			if (get_integer(&qlen,  *argv, 0))
>  				invarg("Invalid \"txqueuelen\" value\n", *argv);
> +		} else if (matches(*argv, "group") == 0) {
> +			NEXT_ARG();
> +			if (group != 0)
> +				duparg("group", *argv);
> +
> +			if (rtnl_ifgroup_a2n(&group, *argv) || group == 0)
> +				invarg("\"group\" value is invalid\n", *argv);
>  		} else if (strcmp(*argv, "mtu") == 0) {
>  			NEXT_ARG();
>  			if (mtu != -1)
> @@ -696,6 +741,10 @@ static int do_set(int argc, char **argv)
>  				return -1;
>  		}
>  	}
> +	if (group) {
> +		if (set_group(dev, group) < 0)
> +			return -1;
> +	}


This part looks useless, for new kernels iproute always uses netlink
to configure things and old kernels don't support this feature. So
there's no need to support it in the ioctl-based configuration path.
