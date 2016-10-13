From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 02/11] net: Introduce new api for walking upper
 and lower devices
Date: Thu, 13 Oct 2016 09:30:29 +0200
Message-ID: <20161013073029.GA1816@nanopsycho.orion>
References: <1476305519-28833-1-git-send-email-dsa@cumulusnetworks.com>
 <1476305519-28833-3-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jiri@mellanox.com, netdev@vger.kernel.org, davem@davemloft.net,
        dledford@redhat.com, sean.hefty@intel.com,
        hal.rosenstock@gmail.com, linux-rdma@vger.kernel.org,
        j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
        jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:34891 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751288AbcJMHbS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 03:31:18 -0400
Received: by mail-lf0-f68.google.com with SMTP id x79so11189572lff.2
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 00:30:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1476305519-28833-3-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Oct 12, 2016 at 10:51:50PM CEST, dsa@cumulusnetworks.com wrote:
>This patch introduces netdev_walk_all_upper_dev_rcu,
>netdev_walk_all_lower_dev and netdev_walk_all_lower_dev_rcu. These
>functions recursively walk the adj_list of devices to determine all upper
>and lower devices.
>
>The functions take a callback function that is invoked for each device
>in the list. If the callback returns non-0, the walk is terminated and
>the functions return that code back to callers.
>
>Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

[...]

>+int netdev_walk_all_lower_dev(struct net_device *dev,
>+			      int (*fn)(struct net_device *dev,
>+					void *data),
>+			      void *data)
>+{
>+	struct list_head *iter;
>+	struct net_device *ldev;
>+	int ret;
>+
>+	for (iter = &(dev)->adj_list.lower,
>+	     ldev = netdev_next_lower_dev(dev, &(iter));
>+	     ldev;
>+	     ldev = netdev_next_lower_dev(dev, &(iter))) {
>+		/* first is the lower device itself */
>+		ret = fn(ldev, data);
>+		if (ret)
>+			return ret;
>+
>+		/* then look at all of its lower devices */
>+		ret = netdev_walk_all_lower_dev(ldev, fn, data);

I believe that Veaceslav's reason to collapse the upper/lower trees was
to avoid this recursivity. I also believe that the recursivity was a big
issue for DaveM and BenH. Something changed?
