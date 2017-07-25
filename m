From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next 10/10] bnxt_en: add support for port_attr_get
 and and get_phys_port_name
Date: Mon, 24 Jul 2017 21:45:21 -0700
Message-ID: <20170724214521.75bf5857@cakuba.netronome.com>
References: <1500914069-15724-1-git-send-email-michael.chan@broadcom.com>
        <1500914069-15724-11-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        Sathya Perla <sathya.perla@broadcom.com>
To: Michael Chan <michael.chan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.11]:16215 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750811AbdGYEp2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Jul 2017 00:45:28 -0400
In-Reply-To: <1500914069-15724-11-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 24 Jul 2017 12:34:29 -0400, Michael Chan wrote:
> From: Sathya Perla <sathya.perla@broadcom.com>
> 
> This patch adds support for the switchdev_port_attr_get() and
> ndo_get_phys_port_name() methods for the PF and the VF-reps.
> Using this support a user application can deduce that the PF
> (when in the ESWITCH_SWDEV mode) and it's VF-reps form a switch.
> 
> Signed-off-by: Sathya Perla <sathya.perla@broadcom.com>
> Signed-off-by: Michael Chan <michael.chan@broadcom.com>
> ---
>  drivers/net/ethernet/broadcom/bnxt/bnxt.c     | 57 +++++++++++++++++++++++++++
>  drivers/net/ethernet/broadcom/bnxt/bnxt.h     |  2 +
>  drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c | 31 ++++++++++++++-
>  3 files changed, 89 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
> index f262fe6..82cbe18 100644
> --- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
> +++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
> @@ -7546,6 +7546,61 @@ static int bnxt_bridge_setlink(struct net_device *dev, struct nlmsghdr *nlh,
>  	return rc;
>  }
>  
> +static int bnxt_get_phys_port_name(struct net_device *dev, char *buf,
> +				   size_t len)
> +{
> +	struct bnxt *bp = netdev_priv(dev);
> +	int rc;
> +
> +	/* The PF and it's VF-reps only support the switchdev framework */
> +	if (!BNXT_PF(bp))
> +		return -EOPNOTSUPP;
> +
> +	/* The switch-id that the pf belongs to is exported by
> +	 * the switchdev ndo. This name is just to distinguish from the
> +	 * vf-rep ports.
> +	 */
> +	rc = snprintf(buf, len, "pf%d", bp->pf.port_id);

This is worrisome.  What do you mean by PF?  In my experience, since
for years PFs had one-to-one association with physical ports people use
the terms interchangeably.  This causes a lot of headaches in proper
eswitch modelling.

I'm not sure whether this is a HW limitation or engineers trying to
make things "easy for users" but most VF-representor patchsets we've
seen on netdev don't include PF representors.  NICs have 3 types of
ports - PFs, VFs and external ports/MACs.  For some reason there is a
tendency to keep pretending PF and physical port is the same entity,
which among other things makes it impossible to install VF->PF rules
(as in from VF to the host, not to the network).

Most high performance NIC vendors also have multi-PF NICs, even though
those are not deployed by wider public.  If we keep pretending PF is
the external port, those will get very awkward to model.  This is a bit
of a pet peeve of mine :)

If this bnxt_get_phys_port_name() relates to the external port, please
change your implementation to comply with
Documentation/networking/switchdev.txt, in particular:

> Suggested naming convention is "swXpYsZ", where X is the switch name or ID, Y
> is the port name or ID, and Z is the sub-port name or ID.  For example, sw1p1s0
> would be sub-port 0 on port 1 on switch 1.

So for physical ports the convention is p<port_id>, and in case of
breakout p<port_id>s<subport_id>.

> +static int bnxt_vf_rep_get_phys_port_name(struct net_device *dev, char *buf,
> +					  size_t len)
> +{
> +	struct bnxt_vf_rep *vf_rep = netdev_priv(dev);
> +	int rc;
> +
> +	rc = snprintf(buf, len, "vfr%d", vf_rep->vf_idx);

This is even worse.  We already have two naming conventions in the
kernel, mlx5 uses "%d" for legacy reasons.  nfp uses pf%dvf%d for vfs,
which is better for two reasons: (a) it works with multi-PF devices;
(b) naming something representor from switchdev perspective is
pointless, you're not calling the external port netdev a physical port
representor, even though it has the exact same relation to the port as
with VFs (i.e. egressing traffic on the netdev will cause the switch
to send to the given port).
