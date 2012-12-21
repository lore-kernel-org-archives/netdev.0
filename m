From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next V4 03/13] bridge: Validate that vlan is
 permitted on ingress
Date: Fri, 21 Dec 2012 06:48:06 +0200
Message-ID: <20121221064806.330c6e4d.shmulik.ladkani@gmail.com>
References: <1355939304-21804-1-git-send-email-vyasevic@redhat.com>
	<1355939304-21804-4-git-send-email-vyasevic@redhat.com>
	<20121220160713.30cdfc05@pixies.home.jungo.com>
	<50D331A8.3080206@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, davem@davemloft.net,
	or.gerlitz@gmail.com, jhs@mojatatu.com, mst@redhat.com,
	erdnetdev@gmail.com, jiri@resnulli.us
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f67.google.com ([74.125.82.67]:54160 "EHLO
	mail-wg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751069Ab2LUEs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2012 23:48:58 -0500
Received: by mail-wg0-f67.google.com with SMTP id dq11so775217wgb.6
        for <netdev@vger.kernel.org>; Thu, 20 Dec 2012 20:48:57 -0800 (PST)
In-Reply-To: <50D331A8.3080206@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 20 Dec 2012 10:41:28 -0500 Vlad Yasevich <vyasevic@redhat.com> wrote:
> >> +static bool br_allowed_ingress(struct net_bridge_port *p, struct sk_buff *skb)
> >> +{
> >> +	struct net_port_vlan *pve;
> >> +	u16 vid;
> >> +
> >> +	/* If there are no vlan in the permitted list, all packets are
> >> +	 * permitted.
> >> +	 */
> >> +	if (list_empty(&p->vlan_list))
> >> +		return true;
> >> +	if (!br_allowed_ingress(p, skb))
> >> +		goto drop;
> >> +
> >
> > This condition should be also encorporated upon "ingress" at the "bridge
> > master port" (that is, early at br_dev_xmit).
> > Think of the "bridge master port" as yet another port:
> > upon "ingress" (meaning, tx packets from the ip stack), we should
> > also enforce any ingress permission rules.
> >
> 
> I've tried that before and now can't think of a reason why I rejected 
> it.  I'll try to remember...

(Current code does not allow you to put the test into 'br_dev_xmit',
since br_allow_ingress expects an 'nbp' as its 1st argument, and the
"master port" is not represented as an 'nbp')

But this is a must. The "master port" shouldn't be treated differently
with respect to vlan ingress/egress membership verifications.

Take for example why egress membership verification is important:

     m
     |
+----+----+
|         |   
p1        p2

p1 expects "normal" (untagged) traffic, and should be connected with the
IP stack (master port 'm'), but not leak to p2.
Traffic of some specific service, marked with VLAN 2, arrives at p2 and
should be forwardable with p1 (keeping the tag), but should not go to
the IP stack.

p1 pvid: 1
m  pvid: 1
vlan 1 membership map:     p1 m
vlan 1 egress policy map:  U  U
vlan 2 membership map:     p1    p2
vlan 2 egress policy map:  T     T

If you don't verify membership upon egress towards IP stack (at the
"master port"), VLAN 2 packets from p2 will leak into the stack.

Regards,
Shmulik
