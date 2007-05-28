From: Samuel Ortiz <samuel@sortiz.org>
Subject: Re: Generic netlink interface help
Date: Mon, 28 May 2007 04:42:47 +0300
Message-ID: <20070528014247.GC4264@sortiz.org>
References: <20070524085956.GP7089@enneenne.com> <84po8XY4.1179999810.5490870.samuel@sortiz.org> <20070527173959.GU21180@enneenne.com>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Rodolfo Giometti <giometti@enneenne.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 30.mail-out.ovh.net ([213.186.62.213]:42755 "HELO
	30.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753718AbXE1Bte (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 May 2007 21:49:34 -0400
Content-Disposition: inline
In-Reply-To: <20070527173959.GU21180@enneenne.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Rodolfo,

On Sun, May 27, 2007 at 07:39:59PM +0200, Rodolfo Giometti wrote:
> On Thu, May 24, 2007 at 09:43:30AM -0000, Samuel Ortiz wrote:
> 
> > You could look at Johannes Berg 802.11 generic netlink implementation for
> > a good example (net/wireless/nl80211.c in John Linville's tree):
> > http://git.kernel.org/?p=linux/kernel/git/linville/wireless-dev.git;a=blob;f=net/wireless/nl80211.c;h=d6a44a386c2b86b81514b08d3c9b324dd2c7d229;hb=HEAD
> 
> Looking at that code I suppose that if I want send/receive "struct
> pps_netlink_msg" to/from the kernel I have to define:
> 
> static struct genl_family pps_gnl_family = {
>         .id      = GENL_ID_GENERATE,    /* don't bother with a hardcoded ID */
>         .name    = "PPS",
>         .hdrsize = 0,                   /* no private header */
>         .version = PPS_FAMILY_VER,
>         .maxattr = 1,
> };
> 
> static struct nla_policy pps_genl_policy[1] = {
>         [0] = {
>                 .type = NLA_BINARY,
>                 .len = sizeof(struct pps_netlink_msg),
>         },
> };
> 
> static struct genl_ops pps_gnl_ops = {
>         .cmd     = 0x1,
>         .policy  = pps_genl_policy,
>         .doit    = pps_genl_data_ready,
> };
> 
> Then the pps_genl_data_ready() should do:
> 
> static int pps_genl_data_ready(struct sk_buff *skb, struct genl_info *info)
> {
>         struct pps_netlink_msg *msg = nla_data(info->attrs[0]);
>         int cmd, source;
>         unsigned long timeout;
>         int ret;
> 
>         if (!msg)
>                 return -EINVAL;
> 
> 	/* Do the job and put the answer into
> 	   msg struct itself... */
> 
> 	genlmsg_unicast(skb, info->snd_pid);
> 
>         return 0;
> }
> 
> Is that right?
At first glance, this could work yes.
However, it seems you're trying to encapsulate your pps_netlink_msg into
a generic netlink message which itself is already encapsulated into a
netlink message, and then multiplex all your PPS commands on
ppl_genl_data_ready(). IMHO, you should have your different PPS commands
declared as a genl_ops array, and then have a specific doit routine per PPS
command. This would make your code cleaner and more secure (see the
"Operation Granularity" section at
http://linux-net.osdl.org/index.php/Generic_Netlink_HOWTO).

Cheers,
Samuel.


