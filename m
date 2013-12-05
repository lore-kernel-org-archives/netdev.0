From: Hangbin Liu <liuhangbin@gmail.com>
Subject: Re: [PATCH] vti: remove GRE_KEY flag for vti tunnel
Date: Thu, 5 Dec 2013 17:47:41 +0800
Message-ID: <20131205094741.GR1258@localhost.localdomain>
References: <1386146917-2951-1-git-send-email-liuhangbin@gmail.com>
 <529F2430.9050906@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Saurabh Mohan <saurabh.mohan@vyatta.com>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Christophe Gouault <christophe.gouault@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:35422 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751926Ab3LEJrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 04:47:46 -0500
Received: by mail-pb0-f52.google.com with SMTP id uo5so25455846pbc.39
        for <netdev@vger.kernel.org>; Thu, 05 Dec 2013 01:47:46 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <529F2430.9050906@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 04, 2013 at 01:46:40PM +0100, Christophe Gouault wrote:
> Hello Hangbin,
> 
> vti interfaces precisely need an o_key to be configured (it must be set
> to the mark of ipsec policies attached to this interface). Consequently,
> this flag must not be removed.

I saw the o_key was used here, do you mean this? I'm not clearly understand
xfrm4_policy_check(), does it really need GRE_KEY? or any value is ok?

static int vti_rcv(struct sk_buff *skb)
{
        struct ip_tunnel *tunnel;
        const struct iphdr *iph = ip_hdr(skb);
        struct net *net = dev_net(skb->dev);
        struct ip_tunnel_net *itn = net_generic(net, vti_net_id);

        tunnel = ip_tunnel_lookup(itn, skb->dev->ifindex, TUNNEL_NO_KEY,
                                  iph->saddr, iph->daddr, 0);
        if (tunnel != NULL) {
                struct pcpu_tstats *tstats;
                u32 oldmark = skb->mark;
                int ret;


                /* temporarily mark the skb with the tunnel o_key, to
                 * only match policies with this mark.
                 */
                skb->mark = be32_to_cpu(tunnel->parms.o_key);
                ret = xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb);
                skb->mark = oldmark;


> 
> Best Regards,
> Christophe
> 
> On 12/04/2013 09:48 AM, Hangbin Liu wrote:
> >vti tunnel use IPPROTO_IPIP instead of IPPROTO_GRE, and keys are not allowed
> >with ipip tunnel. So there is no reason to set GRE_KEY flag for vti.
> >
> >Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
> >---
> >  net/ipv4/ip_vti.c | 6 ++----
> >  1 file changed, 2 insertions(+), 4 deletions(-)
> >
> >diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
> >index 52b802a..58c4e6a 100644
> >--- a/net/ipv4/ip_vti.c
> >+++ b/net/ipv4/ip_vti.c
> >@@ -185,10 +185,8 @@ vti_tunnel_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
> >  	if (err)
> >  		return err;
> >
> >-	if (cmd != SIOCDELTUNNEL) {
> >-		p.i_flags |= GRE_KEY | VTI_ISVTI;
> >-		p.o_flags |= GRE_KEY;
> >-	}
> >+	if (cmd != SIOCDELTUNNEL)
> >+		p.i_flags |= VTI_ISVTI;
> >
> >  	if (copy_to_user(ifr->ifr_ifru.ifru_data, &p, sizeof(p)))
> >  		return -EFAULT;
> >

-- 

Thanks & Best Regards
Hangbin Liu <liuhangbin@gmail.com>
