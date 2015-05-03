From: Veaceslav Falico <vfalico@gmail.com>
Subject: Re: [PATCH] core: Correct an over-stringent device loop detection.
Date: Sun, 3 May 2015 20:07:54 +0200
Message-ID: <20150503180754.GA7318@vps.falico.eu>
References: <1430616824-9006-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, jpirko@redhat.com,
	Vladislav Yasevich <vyasevic@redhat.com>
To: Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:33340 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750989AbbECSH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 May 2015 14:07:58 -0400
Received: by igbpi8 with SMTP id pi8so54429359igb.0
        for <netdev@vger.kernel.org>; Sun, 03 May 2015 11:07:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1430616824-9006-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 02, 2015 at 09:33:44PM -0400, Vladislav Yasevich wrote:
>The code in __netdev_upper_dev_link() has an over-stringent
>loop detection logic that actually prevents valid configurations
>from working correctly.
>
>In particular, the logic returns an error if an upper device
>is already in the list of all upper devices for a given dev.
>This particular check seems to be a overzealous as it disallows
>perfectly valid configurations.  For example:
>  # ip l a link eth0 name eth0.10 type vlan id 10
>  # ip l a dev br0 typ bridge
>  # ip l s eth0.10 master br0
>  # ip l s eth0 master br0  <--- Will fail
>
>If you switch the last two commands (add eth0 first), then both
>will succeed.  If after that, you remove eth0 and try to re-add
>it, it will fail!
>
>It appears to be enough to simply check adj_list to keeps things
>safe.
>
>I've tried stacking multiple devices multiple times in all different
>combinations, and either rx_handler registration prevented the stacking
>of the device linking cought the error.
>
>Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>

Good catch.

Acked-by: Veaceslav Falico <vfalico@gmail.com>

>---
> net/core/dev.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
>diff --git a/net/core/dev.c b/net/core/dev.c
>index c7ba038..2c1c67f 100644
>--- a/net/core/dev.c
>+++ b/net/core/dev.c
>@@ -5209,7 +5209,7 @@ static int __netdev_upper_dev_link(struct net_device *dev,
> 	if (__netdev_find_adj(upper_dev, dev, &upper_dev->all_adj_list.upper))
> 		return -EBUSY;
>
>-	if (__netdev_find_adj(dev, upper_dev, &dev->all_adj_list.upper))
>+	if (__netdev_find_adj(dev, upper_dev, &dev->adj_list.upper))
> 		return -EEXIST;
>
> 	if (master && netdev_master_upper_dev_get(dev))
>-- 
>1.9.3
>
