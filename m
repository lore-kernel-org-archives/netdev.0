From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next v4 05/24] rocker: use swdev get/set attr for
 bridge port flags
Date: Wed, 15 Apr 2015 14:25:44 +0900
Message-ID: <20150415052542.GA5891@vergenet.net>
References: <1428905838-14920-1-git-send-email-sfeldma@gmail.com>
 <1428905838-14920-6-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com, andrew@lunn.ch
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:33100 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932202AbbDOFZ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 01:25:57 -0400
Received: by pdbnk13 with SMTP id nk13so38764147pdb.0
        for <netdev@vger.kernel.org>; Tue, 14 Apr 2015 22:25:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1428905838-14920-6-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Scott,

On Sun, Apr 12, 2015 at 11:16:59PM -0700, sfeldma@gmail.com wrote:
> From: Scott Feldman <sfeldma@gmail.com>
> 
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> ---
>  drivers/net/ethernet/rocker/rocker.c |   31 +++++++++++++++++++++++++++++--
>  1 file changed, 29 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
> index 80c7f6f..9bd4fc6 100644
> --- a/drivers/net/ethernet/rocker/rocker.c
> +++ b/drivers/net/ethernet/rocker/rocker.c

[snip]

> @@ -4349,6 +4354,23 @@ static void rocker_port_trans_abort(struct rocker_port *rocker_port)
>  	}
>  }
>  
> +static int rocker_port_brport_flags_set(struct rocker_port *rocker_port,
> +					unsigned long brport_flags)
> +{
> +	unsigned long orig_flags;
> +	int err = 0;
> +
> +	orig_flags = rocker_port->brport_flags;
> +	rocker_port->brport_flags = brport_flags;
> +	if ((orig_flags ^ rocker_port->brport_flags) & BR_LEARNING)
> +		err = rocker_port_set_learning(rocker_port);

My understanding is that the two-phase set scheme that this
patch-set proposes allows failure, e.g. due resource constraints,
during the prepare phase but that failure in the commit phase
indicates a hardware or driver bug.

It seems to me that this patch doesn't follow the above scheme because
I see the following call-chain:

	rocker_port_set_learning()
	-> rocker_cmd_exec()
	   -> rocker_wait_create()
	      -> kmalloc()

I am probably missing something but it does seem to me that the above is
called in both the prepare and commit phases and that kalloc() may fail in
ether case, the latter case being the problem I see.

> +
> +	if (rocker_port->trans == SWDEV_TRANS_PREPARE)
> +		rocker_port->brport_flags = orig_flags;
> +
> +	return err;
> +}
> +
>  static int rocker_port_attr_set(struct net_device *dev, struct swdev_attr *attr)
>  {
>  	struct rocker_port *rocker_port = netdev_priv(dev);
> @@ -4363,12 +4385,18 @@ static int rocker_port_attr_set(struct net_device *dev, struct swdev_attr *attr)
>  	case SWDEV_TRANS_ABORT:
>  		rocker_port_trans_abort(rocker_port);
>  		return 0;
> +	default:
> +		break;
>  	}
>  
>  	switch (attr->id) {
>  	case SWDEV_ATTR_PORT_STP_STATE:
>  		err = rocker_port_stp_update(rocker_port, attr->stp_state);
>  		break;
> +	case SWDEV_ATTR_PORT_BRIDGE_FLAGS:
> +		err = rocker_port_brport_flags_set(rocker_port,
> +						   attr->brport_flags);
> +		break;
>  	default:
>  		err = -EOPNOTSUPP;
>  		break;
> @@ -4772,8 +4800,7 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)

[snip]
