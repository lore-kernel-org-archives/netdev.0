From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v4 01/24] switchdev: introduce get/set attrs ops
Date: Tue, 14 Apr 2015 00:02:12 -0700
Message-ID: <CAE4R7bAJWKxpTTwN+A1fwQgtiVdcKsYvh6e=5TZxLXg=weiv-Q@mail.gmail.com>
References: <1428905838-14920-1-git-send-email-sfeldma@gmail.com>
	<1428905838-14920-2-git-send-email-sfeldma@gmail.com>
	<20150413104324.GA2090@nanopsycho.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
	"Arad, Ronen" <ronen.arad@intel.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:34888 "EHLO
	mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751692AbbDNHCN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 03:02:13 -0400
Received: by qkhg7 with SMTP id g7so2103904qkh.2
        for <netdev@vger.kernel.org>; Tue, 14 Apr 2015 00:02:12 -0700 (PDT)
In-Reply-To: <20150413104324.GA2090@nanopsycho.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 13, 2015 at 3:43 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Mon, Apr 13, 2015 at 08:16:55AM CEST, sfeldma@gmail.com wrote:
>>From: Scott Feldman <sfeldma@gmail.com>
>>
>>Add two new swdev ops for get/set switch port attributes.  Most swdev
>>interactions on a port are gets or sets on port attributes, so rather than
>>adding ops for each attribute, let's define clean get/set ops for all
>>attributes, and then we can have clear, consistent rules on how attributes
>>propagate on stacked devs.
>>
>>Add the basic algorithms for get/set attr ops.  Use the same recusive algo to
>>walk lower devs we've used for STP updates, for example.  For get, compare attr
>>value for each lower dev and only return success if attr values match across
>>all lower devs.  For sets, set the same attr value for all lower devs.  We'll
>>use a two-phase prepare-commit transaction model for sets.  In the first phase,
>>the driver(s) are asked if attr set is OK.  If all OK, the commit attr set in
>>second phase.  A driver would NACK the prepare phase if it can't set the attr
>>due to lack of resources or support, within it's control.  RTNL lock must be
>>held across both phases because we'll recurse all lower devs first in prepare
>>phase, and then recurse all lower devs again in commit phase.  If any lower dev
>>fails the prepare phase, we need to abort the transaction for all lower devs.
>>
>>If lower dev recusion isn't desired, allow a flag SWDEV_F_NO_RECURSE to
>>indicate get/set only work on port (lowest) device.
>>
>>Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>
> ...
>
>>+
>>+struct swdev_attr_set_defer {
>
> how about
> PREFIX_port_attr_set_work ?
>
>>+      struct work_struct work;
>>+      struct net *net;
>>+      int ifindex;
>>+      struct swdev_attr attr;
>>+};
>>+
>>+static void swdev_port_attr_set_defer_work(struct work_struct *work)
>
> PREFIX_port_attr_set_work ?

done in v5

>>+{
>>+      struct swdev_attr_set_defer *aw =
>>+              container_of(work, struct swdev_attr_set_defer, work);
>>+      struct net_device *dev;
>>+      int err;
>>+
>>+      rtnl_lock();
>>+      dev = __dev_get_by_index(aw->net, aw->ifindex);
>>+      if (dev) {
>>+              err = swdev_port_attr_set(dev, &aw->attr);
>>+              WARN(err, "%s: Deferred set of attr (id=%d) failed.\n",
>>+                   dev->name, aw->attr.id);
>>+      }
>>+      rtnl_unlock();
>>+
>>+      kfree(work);
>>+}
>>+
>>+static int swdev_port_attr_set_defer(struct net_device *dev,
>>+                                   struct swdev_attr *attr)
>>+{
>>+      struct swdev_attr_set_defer *aw;
>
> swdev_attr_set_defer and "aw"? How about rather:
> PREFIX_port_attr_set_work and "asw"?

done in v5

>>+
>>+      aw = kmalloc(sizeof(*aw), GFP_ATOMIC);
>>+      if (!aw)
>>+              return -ENOMEM;
>>+
>>+      INIT_WORK(&aw->work, swdev_port_attr_set_defer_work);
>>+
>>+      aw->net = dev_net(dev);
>>+      aw->ifindex = dev->ifindex;
>>+      memcpy(&aw->attr, attr, sizeof(aw->attr));
>>+
>>+      schedule_work(&aw->work);
>>+
>>+      return 0;
>>+}
>>+
>>+/**
>>+ *    swdev_port_attr_set - Set port attribute
>>+ *
>>+ *    @dev: port device
>>+ *    @attr: attribute to set
>>+ *
>>+ *    Use a 2-phase prepare-commit transaction model to ensure
>>+ *    system is not left in a partially updated state due to
>>+ *    failure from driver/device.
>>+ *
>>+ *    rtnl_lock must be held.
>
> Not true.

updated comment in v5.


>>+ */
>>+int swdev_port_attr_set(struct net_device *dev, struct swdev_attr *attr)
>>+{
>>+      int err;
>>+
>>+      if (!rtnl_is_locked()) {
>>+              /* Running prepare-commit transaction across stacked
>>+               * devices requires nothing moves, so if rtnl_lock is
>>+               * not held, schedule a worker thread to hold rtnl_lock
>>+               * while setting attr.
>>+               */
>>+
>>+              return swdev_port_attr_set_defer(dev, attr);
>>+      }
>>+
>>+      /* Phase I: prepare for attr set. Driver/device should fail
>>+       * here if there are going to be issues in the commit phase,
>>+       * such as lack of resources or support.  The driver/device
>>+       * should reserve resources needed for the commit phase here,
>>+       * but should not commit the attr.
>>+       */
>>+
>>+      attr->trans = SWDEV_TRANS_PREPARE;
>>+      err = __swdev_port_attr_set(dev, attr);
>
>
> Hmm. This looks odd having the type of action as a field in struct. I
> understand that it remover the code duplication. But how about to make
> it a param of __swdev_port_attr_set and there, use different ndo for
> different action? The "switch-case" has to be somewhere, so why don't
> have it in common code instead of every driver.

You'll end up with duplicate code in driver if using a ndo op for each
action because prepare and commit actions typically want the same code
path in the driver.

>
>
>
>>+      if (err) {
>>+              /* Prepare phase failed: abort the transaction.  Any
>>+               * resources reserved in the prepare phase are
>>+               * released.
>>+               */
>>+
>>+              attr->trans = SWDEV_TRANS_ABORT;
>>+              __swdev_port_attr_set(dev, attr);
>>+
>>+              return err;
>>+      }
>>+
>>+      /* Phase II: commit attr set.  This cannot fail as a fault
>>+       * of driver/device.  If it does, it's a bug in the driver/device
>>+       * because the driver said everythings was OK in phase I.
>>+       */
>>+
>>+      attr->trans = SWDEV_TRANS_COMMIT;
>>+      err = __swdev_port_attr_set(dev, attr);
>>+      WARN(err, "%s: Commit of attr (id=%d) failed.\n", dev->name, attr->id);
>
> I would not be afraid to BUG it here...

Do we take down the system when we detect a driver/device bug?  I'll
change it to BUG_ON(err)
