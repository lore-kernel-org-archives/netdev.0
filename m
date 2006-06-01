From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Refactor Netlink connector?
Date: Thu, 1 Jun 2006 12:45:06 +0200
Message-ID: <20060601104506.GF7844@postel.suug.ch>
References: <Pine.LNX.4.64.0605261552570.4856@d.namei> <20060527134629.GA16306@2ka.mipt.ru> <Pine.LNX.4.64.0605271223390.12872@d.namei> <Pine.LNX.4.64.0605271303050.13104@d.namei> <20060531030046.GC7844@postel.suug.ch> <1149078055.5462.55.camel@jzny2> <20060531130649.GD7844@postel.suug.ch> <1149081752.5462.98.camel@jzny2> <Pine.LNX.4.64.0605311141320.4964@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:190 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1750842AbWFAKoq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2006 06:44:46 -0400
To: James Morris <jmorris@namei.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0605311141320.4964@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* James Morris <jmorris@namei.org> 2006-05-31 11:42
> On Wed, 31 May 2006, jamal wrote:
> 
> > To also answer your other email:
> > Look at  security/selinux/nlmsgtab.c for example for NETLINK_ROUTE
> > and compare with NETLINK_GENERIC to see the hole. I was suggesting if
> > we started by just adding checks for NETLINK_GENERIC first in those
> > tables (currently lacking), that would be a good start.
> 
> They're currently mediated as a generic netlink socket type at a higher 
> level: they're not unmediated, just not fine grained enough to know what 
> kind of message is being sent.

It shouldn't be hard to split what is implemented in nlmsg_route_perms[]
for NETLINK_ROUTE into the definitions of the generic netlink
operations, could look like this:

struct genl_ops some_op = {
	[...]
	.perm	 = NETLINK_GENERIC_SOCKET__NLMSG_READ,
};

int genl_lookup_perm(u16 nlmsg_type, u8 cmd)
{
	struct genl_family *family;
	struct genl_ops *ops;

	family = genl_family_find_byid(nlmsg_type);
	ops = genl_get_cmd(cmd, family);

	return ops->perm;
}

int genl_peek_cmd(struct nlmsghdr *nlh)
{
	struct genlmsghdr *hdr = nlmsg_data(nlh);

	if (nlh->nlmsglen < nlmsg_msg_sizeo(GENL_HDRLEN))
		return -EINVAL;

	return hdr->cmd;
}


selinux_lookup() must take struct nlmsghdr as an additional argument

	case SECCLASS_NETLINK_GENERIC_SOCKET:
		cmd = genl_peek_cmd(nlh)
		*perm = genl_lookup_perm(nlmsg_type, cmd);
		break;
