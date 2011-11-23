From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v3 05/10] bql: Byte queue limits
Date: Wed, 23 Nov 2011 14:22:03 -0800
Message-ID: <20111123142203.6ab17c25@nehalam.linuxnetplumber.net>
References: <alpine.DEB.2.00.1111222140410.15246@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57117 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752411Ab1KWWWH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Nov 2011 17:22:07 -0500
In-Reply-To: <alpine.DEB.2.00.1111222140410.15246@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This introduces a leak of kobj if kobject_init_and_add() fails:

Incorrect code:

static int netdev_queue_add_kobject(struct net_device *net, int index)
{
	struct netdev_queue *queue = net->_tx + index;
	struct kobject *kobj = &queue->kobj;
	int error = 0;

	kobj->kset = net->queues_kset;
	error = kobject_init_and_add(kobj, &netdev_queue_ktype, NULL,
	    "tx-%u", index);
	if (error)
		goto exit;

#ifdef CONFIG_BQL
	error = sysfs_create_group(kobj, &dql_group);
        if (error) {
 		kobject_put(kobj);
		goto exit;
 	}
#endif
 
 	kobject_uevent(kobj, KOBJ_ADD);
 	dev_hold(queue->dev);
 
	return 0;
exit:
 	return error;
}


Correct code:

static int netdev_queue_add_kobject(struct net_device *net, int index)
{
	struct netdev_queue *queue = net->_tx + index;
	struct kobject *kobj = &queue->kobj;
	int error = 0;

	kobj->kset = net->queues_kset;
	error = kobject_init_and_add(kobj, &netdev_queue_ktype, NULL,
	    "tx-%u", index);
	if (error)
		goto exit;

#ifdef CONFIG_BQL
	error = sysfs_create_group(kobj, &dql_group);
	if (error)
		goto exit;
#endif
 
 	kobject_uevent(kobj, KOBJ_ADD);
 	dev_hold(queue->dev);
 
	return 0;
exit:
	kobject_put(kobj);
 	return error;
}
