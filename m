From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 1/7] mlx4: Added interrupts test support
Date: Thu, 01 Oct 2009 20:32:08 -0700
Message-ID: <adaeipmqxmv.fsf@cisco.com>
References: <4AC4BD9A.2050101@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:32872 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752254AbZJBDcG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 23:32:06 -0400
In-Reply-To: <4AC4BD9A.2050101@mellanox.co.il> (Yevgeny Petrilin's message of
	"Thu, 01 Oct 2009 16:32:58 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This feels like a pretty risky thing to do while the device might be
handling all sorts of other traffic at the same time.  Are you sure
there are no races you expose here?  Have you actually seen cases where
the interrupt test during initialization works but then this test
catches a problem?  (My experience has been that if any MSI-X interrupts
work from a device, then they'll all work)

 > +/* A test that verifies that we can accept interrupts on all
 > + * the irq vectors of the device.
 > + * Interrupts are checked using the NOP command.
 > + */
 > +int mlx4_test_interrupts(struct mlx4_dev *dev)
 > +{
 > +	struct mlx4_priv *priv = mlx4_priv(dev);
 > +	int i;
 > +	int err;
 > +
 > +	err = mlx4_NOP(dev);
 > +	/* When not in MSI_X, there is only one irq to check */
 > +	if (!(dev->flags & MLX4_FLAG_MSI_X))
 > +		return err;
 > +
 > +	/* A loop over all completion vectors, for each vector we will check
 > +	 * whether it works by mapping command completions to that vector
 > +	 * and performing a NOP command
 > +	 */
 > +	for (i = 0; !err && (i < dev->caps.num_comp_vectors); ++i) {
 > +		/* Temporary use polling for command completions */

you want the adverb form here: "Temporarily"

 > +		mlx4_cmd_use_polling(dev);
 > +
 > +		/* Map the new eq to handle all asyncronous events */

"asynchronous"

 > +		err = mlx4_MAP_EQ(dev, MLX4_ASYNC_EVENT_MASK, 0,
 > +				  priv->eq_table.eq[i].eqn);
 > +		if (err) {
 > +			mlx4_warn(dev, "Failed mapping eq for interrupt test\n");
 > +			mlx4_cmd_use_events(dev);
 > +			break;
 > +		}
 > +
 > +		/* Go back to using events */
 > +		mlx4_cmd_use_events(dev);
 > +		err = mlx4_NOP(dev);

You could simplify the code a bit by moving the mlx4_cmd_use_events() to
before where you test err, ie:

		err = mlx4_MAP_EQ(...);
		mlx4_cmd_user_events(dev);
		if (err)
			mlx4_warn(dev, ...)
		else
			err = mlx4_NOP(dev);

 > +	}
 > +
 > +	/* Return to default */
 > +	mlx4_MAP_EQ(dev, MLX4_ASYNC_EVENT_MASK, 0,
 > +		    priv->eq_table.eq[dev->caps.num_comp_vectors].eqn);
 > +	return err;
 > +}
