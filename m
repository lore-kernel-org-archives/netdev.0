From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 6/8] openvswitch: Allow update of dp with
 OVS_DP_CMD_NEW if NLM_F_REPLACE is set
Date: Wed, 27 Nov 2013 22:32:20 +0000
Message-ID: <20131127223220.GA26084@casper.infradead.org>
References: <cover.1385137618.git.tgraf@suug.ch>
 <2b77b94f043dbed36a08dcc0a876830d6ad1a97a.1385137618.git.tgraf@suug.ch>
 <CAEP_g=8=dzm7NS5zx4-+wY+AXZLpym7JGQO9YTAgdTPm9v1mpQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>,
	Daniel Borkmann <dborkman@redhat.com>, ffusco@redhat.com,
	fleitner@redhat.com, Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:48665 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757299Ab3K0WcZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Nov 2013 17:32:25 -0500
Content-Disposition: inline
In-Reply-To: <CAEP_g=8=dzm7NS5zx4-+wY+AXZLpym7JGQO9YTAgdTPm9v1mpQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/13 at 01:23pm, Jesse Gross wrote:
> On Fri, Nov 22, 2013 at 8:56 AM, Thomas Graf <tgraf@suug.ch> wrote:
> > diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
> > index 95d4424..3f1fb87 100644
> > --- a/net/openvswitch/datapath.c
> > +++ b/net/openvswitch/datapath.c
> 
> I'm a little worried that this introduces some quirks to the interface. Such as:
> 
> > @@ -1190,6 +1185,7 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
> >         struct vport *vport;
> >         struct ovs_net *ovs_net;
> >         int err, i;
> > +       bool allocated = false;
> >
> >         err = -EINVAL;
> >         if (!a[OVS_DP_ATTR_NAME] || !a[OVS_DP_ATTR_UPCALL_PID])
> 
> This requires that DP_CMD_SET supply an OVS_DP_ATTR_UPCALL_PID
> although I don't think that it's really necessary. In fact, we used to
> completely ignore that field on SET since it's really only useful on
> datapath creation and can otherwise be done more naturally through the
> vport interface.

It's a theoretical exercise since nobody is using OVS_DP_CMD_SET
but I agree, it should be optional in the update path. I'll update
the patch.

> > @@ -1197,11 +1193,26 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
> >
> >         ovs_lock();
> >
> > +       dp = lookup_datapath(sock_net(skb->sk), info->userhdr, info->attrs);
> > +       if (!IS_ERR(dp)) {
> > +               if (info->nlhdr->nlmsg_flags & NLM_F_REPLACE)
> > +                       goto update;
> 
> Conversely, this won't respect the UPCALL_PID field, which I would
> expect it to since I think NLM_F_REPLACE should be roughly equivalent
> to a delete and create. I believe that's the only field that is
> missing although it seems easy to have the same problem as others are
> added in the future.

It's up to us to define that.

What the patch proposes is what OVS has been doing already: Try to
find a datapath with matching name and reuse it. Otherwise create
a new data path. Disregard UPCALL_PID.

As you state above, the upcall pid can be modified through the vport
interface which in my opinion is the correct way to modify it if
needed.

I have no problem with adding upcall pid overwrite logic to the
NLM_F_REPLACE path but it _changes_ the existing semantics in
terms of "opening" a datapath.
