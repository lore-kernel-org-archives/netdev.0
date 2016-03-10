From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Thu, 10 Mar 2016 13:01:38 -0500 (EST)
Message-ID: <20160310.130138.1302349043066531127.davem@davemloft.net>
References: <20160310102018.GA21154@uranus.lan>
	<20160310110324.GB21154@uranus.lan>
	<20160310150920.GC21154@uranus.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, solar@openwall.com, vvs@virtuozzo.com,
	avagin@virtuozzo.com, xemul@virtuozzo.com, vdavydov@virtuozzo.com,
	khorenko@virtuozzo.com, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org
To: gorcunov@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20160310150920.GC21154@uranus.lan>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cyrill Gorcunov <gorcunov@gmail.com>
Date: Thu, 10 Mar 2016 18:09:20 +0300

> On Thu, Mar 10, 2016 at 02:03:24PM +0300, Cyrill Gorcunov wrote:
>> On Thu, Mar 10, 2016 at 01:20:18PM +0300, Cyrill Gorcunov wrote:
>> > On Thu, Mar 10, 2016 at 12:16:29AM +0300, Cyrill Gorcunov wrote:
>> > > 
>> > > Thanks for explanation, Dave! I'll continue on this task tomorrow
>> > > tryin to implement optimization you proposed.
>> > 
>> > OK, here are the results for the preliminary patch with conntrack running
>> ...
>> >  net/ipv4/devinet.c |   13 ++++++++++++-
>> >  1 file changed, 12 insertions(+), 1 deletion(-)
>> > 
>> > Index: linux-ml.git/net/ipv4/devinet.c
>> > ===================================================================
>> > --- linux-ml.git.orig/net/ipv4/devinet.c
>> > +++ linux-ml.git/net/ipv4/devinet.c
>> > @@ -403,7 +403,18 @@ no_promotions:
>> >  	   So that, this order is correct.
>> >  	 */
>> 
>> This patch is wrong, so drop it please. I'll do another.
> 
> Here I think is a better variant. The resulst are good
> enough -- 1 sec for cleanup. Does the patch look sane?

I'm tempted to say that we should provide these notifier handlers with
the information they need, explicitly, to handle this case.

Most intdev notifiers actually want to know the individual addresses
that get removed, one by one.  That's handled by the existing
NETDEV_DOWN event and the ifa we pass to that.

But some, like this netfilter masq case, would be satisfied with a
single event that tells them the whole inetdev instance is being torn
down.  Which is the case we care about here.

We currently don't use NETDEV_UNREGISTER for inetdev notifiers, so
maybe we could use that.

And that is consistent with the core netdev notifier that triggers
this call chain in the first place.

Roughly, something like this:

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 8c3df2c..6eee5cb 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -292,6 +292,11 @@ static void inetdev_destroy(struct in_device *in_dev)
 
 	in_dev->dead = 1;
 
+	if (in_dev->ifa_list)
+		blocking_notifier_call_chain(&inetaddr_chain,
+					     NETDEV_UNREGISTER,
+					     in_dev->ifa_list);
+
 	ip_mc_destroy_dev(in_dev);
 
 	while ((ifa = in_dev->ifa_list) != NULL) {
diff --git a/net/ipv4/netfilter/nf_nat_masquerade_ipv4.c b/net/ipv4/netfilter/nf_nat_masquerade_ipv4.c
index c6eb421..1bb8026 100644
--- a/net/ipv4/netfilter/nf_nat_masquerade_ipv4.c
+++ b/net/ipv4/netfilter/nf_nat_masquerade_ipv4.c
@@ -111,6 +111,10 @@ static int masq_inet_event(struct notifier_block *this,
 	struct net_device *dev = ((struct in_ifaddr *)ptr)->ifa_dev->dev;
 	struct netdev_notifier_info info;
 
+	if (event != NETDEV_UNREGISTER)
+		return NOTIFY_DONE;
+	event = NETDEV_DOWN;
+
 	netdev_notifier_info_init(&info, dev);
 	return masq_device_event(this, event, &info);
 }




