From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next v1 5/9] bonding: convert bond_has_this_ip() to
 use upper devices
Date: Tue, 27 Aug 2013 13:16:48 +0200
Message-ID: <20130827111648.GB24836@redhat.com>
References: <1377549162-7522-1-git-send-email-vfalico@redhat.com>
 <1377549162-7522-6-git-send-email-vfalico@redhat.com>
 <20130826205338.GA3723@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4921 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753031Ab3H0LSU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Aug 2013 07:18:20 -0400
Content-Disposition: inline
In-Reply-To: <20130826205338.GA3723@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 26, 2013 at 10:53:38PM +0200, Jiri Pirko wrote:
>Mon, Aug 26, 2013 at 10:32:38PM CEST, vfalico@redhat.com wrote:
...snip...
>>+	rcu_read_lock();
>>+	netdev_for_each_upper_dev(bond->dev, upper, iter) {
>>+		if (ip == bond_confirm_addr(upper, 0, ip)) {
>>+			ret = true;
>>+			break;
>>+		}
>
>You need the same recursion __vlan_find_dev_deep() is doing. If you do
>not do that, you will miss anything over the first upper level.

Good point, and it's true for other uses also - bond_arp_send_all(), for
example, will also miss anything that's higher than the first upper level.

I can't think of a use case scenario when we would need only the first
upper level - so maybe we should either make netdev_for_each_upper_dev()
recursive by default (I don't know how it can be done easily, tbh, without
modifying the existing code), or add something like:

diff --git a/net/core/dev.c b/net/core/dev.c
index 566e99a..4a4468f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4387,6 +4387,31 @@ static void __append_search_uppers(struct list_head *search_list,
  	}
  }
  
+struct net_device *netdev_upper_recursive_do_rcu(struct net_device *dev,
+						 struct net_device *orig_dev,
+						 bool (*f)(struct net_device *,
+							   struct net_device *))
+{
+	struct netdev_upper *upper;
+	struct net_device *ret = NULL;
+
+	list_for_each_entry_rcu(upper, &dev->upper_dev_list, list) {
+		if (f(orig_dev, upper->dev)) {
+			ret = upper->dev;
+			break;
+		}
+
+		if (!list_empty(&upper->dev->upper_dev_list)) {
+			ret = netdev_upper_recursive_do_rcu(upper->dev,
+							    orig_dev, f);
+			if (ret)
+				break;
+		}
+	}
+
+	return ret;
+}
+
  static bool __netdev_search_upper_dev(struct net_device *dev,
  				      struct net_device *upper_dev)
  {

How do you think?
