From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 1/2] iproute2: add libgenl files
Date: Tue, 11 Sep 2012 00:54:00 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1209110021150.2010@ja.ssi.bg>
References: <1347097705-2906-1-git-send-email-ja@ssi.bg> <1347097705-2906-2-git-send-email-ja@ssi.bg> <20120910095518.59ddae61@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:35205 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752088Ab2IJVuK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2012 17:50:10 -0400
In-Reply-To: <20120910095518.59ddae61@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 10 Sep 2012, Stephen Hemminger wrote:

> On Sat,  8 Sep 2012 12:48:24 +0300
> Julian Anastasov <ja@ssi.bg> wrote:
> 
> > +
> > +#define GENL_INIT_REQUEST(req, family, hdrsize, ver, cmd_, flags)	\
> > +	do {								\
> > +		memset(&req, 0, sizeof(req));				\
> > +		req.n.nlmsg_type = family;				\
> > +		req.n.nlmsg_flags = flags;				\
> > +		req.n.nlmsg_len = NLMSG_LENGTH(GENL_HDRLEN + hdrsize);	\
> > +		req.g.cmd = cmd_;					\
> > +		req.g.version = ver;					\
> > +	} while (0)
> > +
> 
> Why not an inline function, macro code is error prone.

	The problem is that we define every request with
its own structure in GENL_DEFINE_REQUEST. We can use init
func instead of macro only if we define some base structure,
for example:

struct genl_header_base {
	struct nlmsghdr		n;
	struct genlmsghdr	g;
};

	But then we will have new prefix when accessing
request fields (b.): b.n... and b.g... It will go to all places
that use addattr_*, eg. addattr_l(&req.b.n, sizeof(req), ...)
and such places can be many if there are many attributes.

#define GENL_DEFINE_REQUEST(req, hdrsize, bufsiz)			\
struct {								\
	struct genl_header_base	b;					\
	char			buf[NLMSG_ALIGN(hdrsize) + bufsiz];	\
} req

int genl_init_request(struct genl_header_base *b,
	b_size, family, hdrsize, ver, cmd_, flags)

	Do you prefer this new variant? There will be many
places like req.n that will be changed like req.b.n.

	I'll rename libgenl_ to genl_ when we decide what
to do with the request structure.

Regards

--
Julian Anastasov <ja@ssi.bg>
