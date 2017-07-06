From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: net: Fix inconsistent teardown and release of private netdev
 state.
Date: Thu, 6 Jul 2017 16:24:29 +0200
Message-ID: <20170706142427.GA32086@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:46037 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751070AbdGFOYf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Jul 2017 10:24:35 -0400
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTP id 4ebb80e9
        for <netdev@vger.kernel.org>;
        Thu, 6 Jul 2017 14:20:26 +0000 (UTC)
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTPSA id a1a314b5 (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256:NO)
        for <netdev@vger.kernel.org>;
        Thu, 6 Jul 2017 14:20:25 +0000 (UTC)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey guys,

I see why this priv_destructor patch is an acceptable bandaid for
certain drivers, but I'm not exactly sure on the cleanest way of using
it in new drivers. Check out the following psuedocode.

Here's how error handling in newlink used to work before this patch:

static void destruct(struct net_device *dev)
{
	struct private *priv = netdev_priv(dev);

	rtnl_lock();
	list_del(&priv->list);
	rtnl_unlock();
	stop_anotherweirdthing(&priv->wow);
	put_can_in_garbage(priv->burrito);
	kfree(priv->cheese);
	stop_something(&priv->something);
	put_whatever(priv->whatever);
}

static int newlink(struct net *src_net, struct net_device *dev, ...)
{
	int ret;
	struct private *priv = netdev_priv(dev);

	priv->whatever = get_whatever(src_net); // never fails

	ret = do_something(&private);
	if (ret < 0)
		goto error_1;

	ret = -ENOMEM;
	priv->cheese = kmalloc(128, GFP_KERNEL);
	if (!priv->cheese)
		goto error_2;

	priv->burrito = allocate_bean_can(&init_net);
	if (IS_ERR(priv->burrito)) {
		ret = PTR_ERR(priv->burrito);
		goto error_3;
	}

	do_anotherweirdthing(&priv->wow); // never fails

	ret = register_netdevice();
	if (ret < 0)
		goto error_4;

	list_add(&priv->list, &list_of_things);
	pr_info("Yay it worked!\n");
	
	return ret;

error_4:
	stop_anotherweirdthing(&priv->wow);
	put_can_in_garbage(priv->burrito);
error_3:
	kfree(priv->cheese);
error_2:
	stop_something(&priv->something);
error_1:
	put_whatever(priv->whatever);

	return ret;
}

Here's what it must look like now, which introduces a weird race with
list_add, and doesn't really have a consistent clean-up section. Having
to remember that register_netdevice will call destruct() when it fails
is quite confusing. Observe:

static int newlink(struct net *src_net, struct net_device *dev, ...)
{
	int ret;
	struct private *priv = netdev_priv(dev);

	priv->whatever = get_whatever(src_net); // never fails

	ret = do_something(&private);
	if (ret < 0)
		goto error_1;

	ret = -ENOMEM;
	priv->cheese = kmalloc(128, GFP_KERNEL);
	if (!priv->cheese)
		goto error_2;

	priv->burrito = allocate_bean_can(&init_net);
	if (IS_ERR(priv->burrito)) {
		ret = PTR_ERR(priv->burrito);
		goto error_3;
	}

	do_anotherweirdthing(&priv->wow); // never fails

	list_add(&priv->list, &list_of_things);

	ret = register_netdevice(); // if ret is < 0, then destruct above is automatically called

	// RACE WITH LIST_ADD/LIST_DEL!! It's impossible to call list_add only after
	// things are brought up successfully. This is problematic.

	if (!ret)
		pr_info("Yay it worked!\n");

	return 0;

error_3:
	kfree(priv->cheese);
error_2:
	stop_something(&priv->something);
error_1:
	put_whatever(priv->whatever);

	return ret;
}

Something we just have to live with? Any cleaner way of approaching
this?

Regards,
Jason
