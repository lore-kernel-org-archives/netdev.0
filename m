From: Ulf Samuelsson <ulf.samuelsson@ericsson.com>
Subject: Re: [PATCH V2 0/1] neighbour: Support broadcast ARP in neighbor PROPE
 state
Date: Mon, 16 Mar 2015 13:39:47 +0100
Message-ID: <5506CF13.5070501@ericsson.com>
References: <1426143501-30827-1-git-send-email-Yanjun.Zhu@windriver.com> <20150312.152247.1607789216159086520.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <brian.haley@hp.com>, <alexandre.dietsch@windriver.com>,
	<clinton.slabbert@windriver.com>, <kuznet@ms2.inr.ac.ru>,
	<jmorris@namei.org>, <kaber@trash.net>, <netdev@vger.kernel.org>
To: David Miller <davem@redhat.com>, <Yanjun.Zhu@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg22.ericsson.net ([193.180.251.48]:56586 "EHLO
	sesbmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430AbbCPMkA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 08:40:00 -0400
In-Reply-To: <20150312.152247.1607789216159086520.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/12/2015 08:22 PM, David Miller wrote:
> Like Yoshifuji and others I agree that:
>
> 1) You can get working behavior by adjusting existing sysctls.
>
> 2) IPV4 ARP and IPV6 NDISC are not different in this regard.
>
> I'm really tired of all of these ARP hacks being submitted recently,
> and I want people to think more deeply about what they are proposing
> first.
Which sysctls are you referring to?

As I can see it, there are three sysctls that control this.

ucast_solicit.
mcast_solicit
app_solicit.

If you think any other sysctl is useful here, which one?

 From Documentation/networking/ip-sysctl.txt.
+++++++++++++
app_solicit - INTEGER
     The maximum number of probes to send to the user space ARP daemon
     via netlink before dropping back to multicast probes (see
     mcast_solicit).  Defaults to 0.
----------------------------
so that ain't it.
If you disagree, what should the Documentation look like?

=============================================
 From net/core/neighbour.c(timer_handler):

     if ((neigh->nud_state & (NUD_INCOMPLETE | NUD_PROBE)) &&
         atomic_read(&neigh->probes) >= neigh_max_probes(neigh)) {
         neigh->nud_state = NUD_FAILED;
         notify = 1;
         neigh_invalidate(neigh);
         goto out;
     }

 From net/core/neighbour.c(neigh_max_probes):
static __inline__ int neigh_max_probes(struct neighbour *n)
{
     struct neigh_parms *p = n->parms;
     int max_probes = NEIGH_VAR(p, UCAST_PROBES) + NEIGH_VAR(p, APP_PROBES);
     if (!(n->nud_state & NUD_PROBE))
         max_probes += NEIGH_VAR(p, MCAST_PROBES);
     return max_probes;
}
=============================================


If we simplify this when we are in NUD_PROBE state we see:

=============================================
     if (atomic_read(&neigh->probes) >= NEIGH_VAR(p, UCAST_PROBES) + 
NEIGH_VAR(p, APP_PROBES)) {
         neigh->nud_state = NUD_FAILED;
         notify = 1;
         neigh_invalidate(neigh);
         goto out;
     }
=============================================

Since APP_PROBES is 0, and according to documentation has nothing to do 
with Broadcast:

=============================================
     if (atomic_read(&neigh->probes) >= NEIGH_VAR(p, UCAST_PROBES)) {
         neigh->nud_state = NUD_FAILED;
         notify = 1;
         neigh_invalidate(neigh);
         goto out;
     }
=============================================

so we will send out "ucast_solicit" unikcast probes, and then we will 
enter FAILED state.
mcast_solicit is ignored when in NUD_PROBE state.

"mcast_solicit" is only used when in NUD_INCOMPLETE state, and 
broadcasts will never
be sent out by the stack for an entry, once it is in NUD_REACHABLE for 
the first time.

I would be happy, if you can show me that I have misunderstood something.

Best Regards,
Ulf Samuelsson
