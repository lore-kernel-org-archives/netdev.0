From: juliusv@google.com (Julius Volz)
Subject: Re: [PATCHv3 2/2] IPVS: Add genetlink interface implementation
Date: Thu, 14 Aug 2008 12:27:19 +0200
Message-ID: <20080814102719.GB8046@google.com>
References: <1218120219-1117-1-git-send-email-juliusv@google.com> <1218120219-1117-3-git-send-email-juliusv@google.com> <20080808112937.GA32458@google.com> <alpine.LNX.1.10.0808132326310.12259@titan.stealer.net> <20080814093201.GA8046@google.com> <alpine.LNX.1.10.0808141144240.12259@titan.stealer.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
	horms@verge.net.au, kaber@trash.net, davem@davemloft.net,
	tgraf@suug.ch, vbusam@google.com
To: Sven Wegener <sven.wegener@stealer.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:19954 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754090AbYHNK1w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 06:27:52 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LNX.1.10.0808141144240.12259@titan.stealer.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 14, 2008 at 12:04:50PM +0200, Sven Wegener wrote:
> On Thu, 14 Aug 2008, Julius Volz wrote:
> 
> > On Wed, Aug 13, 2008 at 11:51:06PM +0200, Sven Wegener wrote:
> > > On Fri, 8 Aug 2008, Julius Volz wrote:
> > > > +static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
> > > > +{
> > > > +	struct sk_buff *msg;
> > > > +	void *reply;
> > > > +	int ret, cmd, reply_cmd;
> > > > +
> > > > +	mutex_lock(&__ip_vs_mutex);
> > > > +
> > > > +	cmd = info->genlhdr->cmd;
> > > > +
> > > > +	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> > > > +	if (!msg) {
> > > > +		ret = -ENOMEM;
> > > > +		goto out_err;
> > > 
> > > Here you want out...
> > > 
> > > > +	}
> > > > +
> > > > +	if (cmd == IPVS_CMD_GET_SERVICE)
> > > > +		reply_cmd = IPVS_CMD_NEW_SERVICE;
> > > > +	else if (cmd == IPVS_CMD_GET_INFO)
> > > > +		reply_cmd = IPVS_CMD_SET_INFO;
> > > > +	else if (cmd == IPVS_CMD_GET_CONFIG)
> > > > +		reply_cmd = IPVS_CMD_SET_CONFIG;
> > > > +	else {
> > > > +		IP_VS_ERR("unknown Generic Netlink command\n");
> > > > +		ret = -EINVAL;
> > > > +		goto out;
> > > 
> > > ..and here you want out_error, to not leak msg.
> > 
> > Ouch, thanks! Fixed this and locked the mutex later. I also removed the
> > "if (msg)" from out_err, as it becomes unneeded now. Here's the updated
> > patch:
> 
> You missed the static on the register and unregister functions down at the 
> bottom. :) Also see my comments to your change regarding the above issue 
> down here.

Hrm, yes!

> > +static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
> > +{
> > +	struct sk_buff *msg;
> > +	void *reply;
> > +	int ret, cmd, reply_cmd;
> > +
> > +	cmd = info->genlhdr->cmd;
> > +
> > +	if (cmd == IPVS_CMD_GET_SERVICE)
> > +		reply_cmd = IPVS_CMD_NEW_SERVICE;
> > +	else if (cmd == IPVS_CMD_GET_INFO)
> > +		reply_cmd = IPVS_CMD_SET_INFO;
> > +	else if (cmd == IPVS_CMD_GET_CONFIG)
> > +		reply_cmd = IPVS_CMD_SET_CONFIG;
> > +	else {
> > +		IP_VS_ERR("unknown Generic Netlink command\n");
> > +		ret = -EINVAL;
> > +		goto out;
> > +	}
> > +
> > +	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> > +	if (!msg) {
> > +		ret = -ENOMEM;
> > +		goto out;
> > +	}
> > +
> > +	reply = genlmsg_put_reply(msg, info, &ip_vs_genl_family, 0, reply_cmd);
> > +	if (reply == NULL)
> > +		goto nla_put_failure;
> 
> These gotos now unlock a not locked mutex down in the error path.

What did they put into my water supply :-/ Thanks!

> 
> > +
> > +	mutex_lock(&__ip_vs_mutex);
> 
> Is there a reason not using mutex_lock_interruptible() like the sockopt 
> interface does? I wondered in your earlier patch, but didn't really 
> bother.

Not an expert here. I saw mutex_lock_interruptible() being used in the
old sockopt interface, but returning -ERESTARTSYS on interruption. Can I
do something similar to this from a genetlink function or what is the
right way? I was unsure, so I stuck to mutex_lock()...

Julius
