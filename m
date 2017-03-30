From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next] rtnl: Add support for netdev event to link messages
Date: Thu, 30 Mar 2017 11:21:16 -0400
Message-ID: <1490887276-25158-1-git-send-email-vyasevic@redhat.com>
References: <91c304f6-659f-01d7-a899-171142075276@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
        netdev@vger.kernel.org, Vladislav Yasevich <vyasevic@redhat.com>
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:35254 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933048AbdC3PVw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 11:21:52 -0400
Received: by mail-qt0-f194.google.com with SMTP id r5so6649041qtb.2
        for <netdev@vger.kernel.org>; Thu, 30 Mar 2017 08:21:51 -0700 (PDT)
In-Reply-To: <91c304f6-659f-01d7-a899-171142075276@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/30/2017 10:11 AM, David Ahern wrote:
> On 3/30/17 7:47 AM, Vlad Yasevich wrote:
>>>>>> But, NETDEV_PRECHANGEMTU will be a unnecessary notification to userspace without
>>>>>> changes. There are already enough notifications generated for links (I know you are not
>>>>>> suggesting adding it here)
>>>>>
>>>>> Actually, this one already triggers a link notification to userspace.  It just has
>>>>> no event data in it to tell you that. :)
>>>>
>>>> Is it intentional or unintentional? perhaps rtnetlink_event should be a
>>>> whitelist -- events that userspace should be notified about. Seems like
>>>> NETDEV_ events have been added without rtnetlink_event getting updated.
>>>
>>> I think a 'whitelist' was attempted, but as you mentioned, it hasn't been updated...
>>> I'll defer the definitive answer to someone else.  It seems Patrick added a comment
>>> in commit a2835763 to update the white list and it's been a few times.
>>>
>>
>> This is actually an interesting point.  Looking at some commits that have added
>> events to black list in rtnetlink-event, it might have been much easier to debug
>> those issues if we had the 'event' encoding in the netlink message.
>>
>> I think it might be worthwhile to add all allowed event types to this new encoding
>> so we can userspace can see just what's its getting.
>>
> 
> My point is that it is easy to add NETDEV events; takes extra effort to
> update rtnetlink_event to say "don't send a notification to userspace".
> 
> A number of those events are for kernel processing, so why send anything
> to userspace? In that case a default of don't notify userspace and then
> having a list of events that should send the notification makes the
> intent explicit.
> 
> Looking at git commit logs for NETDEV_PRECHANGEMTU, it seems that it was
> added for bonding and teaming to simplify kernel processing; userspace
> does not need to be notified so no intention there.
> 

So, something like the patch below would be better in your opinion as a
starting point.  It'll can at least get the discussion strarted on whether
an event would usefull to user space or not.

However, that's really a separate point from what I was originally try to do.
I would like to provide the event type itself to the user, so the user may
perform some action based on that event.

-- >8 --

From: Vladislav Yasevich <vyasevic@redhat.com>
Date: Thu, 30 Mar 2017 10:42:53 -0400
Subject: [PATCH] rtnetlink: Convert rtnetlink_event to white list

The rtnetlink_event currently functions as a blacklist where
we block cerntain netdev events from being sent to user space.
As a result, events have been added to the system that userspace
probably doesn't care about.

This patch converts the implementation to the white list so that
newly events would have to be specifically added to the list to
be sent to userspace.  This would force new event implementers to
consider whether a given event is usefull to user space or if it's
just a kernel event.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 net/core/rtnetlink.c | 29 +++++++++++++++--------------
 1 file changed, 15 insertions(+), 14 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 9c3947a..f48a60d 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -4116,22 +4116,23 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
 
 	switch (event) {
-	case NETDEV_UP:
-	case NETDEV_DOWN:
-	case NETDEV_PRE_UP:
-	case NETDEV_POST_INIT:
-	case NETDEV_REGISTER:
-	case NETDEV_CHANGE:
-	case NETDEV_PRE_TYPE_CHANGE:
-	case NETDEV_GOING_DOWN:
-	case NETDEV_UNREGISTER:
-	case NETDEV_UNREGISTER_FINAL:
-	case NETDEV_RELEASE:
-	case NETDEV_JOIN:
-	case NETDEV_BONDING_INFO:
+	case NETDEV_REBOOT:
+	case NETDEV_CHANGEMTU:
+	case NETDEV_CHANGENAME:
+	case NETDEV_FEAT_CHANGE:
+	case NETDEV_BONDING_FAILOVER:
+	case NETDEV_NOTIFY_PEERS:
+	case NETDEV_CHANGEUPPER:
+	case NETDEV_RESEND_IGMP:
+	case NETDEV_PRECHANGEMTU:
+	case NETDEV_CHANGEINFODATA:
+	case NETDEV_PRECHANGEUPPER:
+	case NETDEV_CHANGELOWERSTATE:
+	case NETDEV_UDP_TUNNEL_PUSH_INFO:
+	case NETDEV_CHANGE_TX_QUEUE_LEN:
+		rtmsg_ifinfo(RTM_NEWLINK, dev, 0, GFP_KERNEL);
 		break;
 	default:
-		rtmsg_ifinfo(RTM_NEWLINK, dev, 0, GFP_KERNEL);
 		break;
 	}
 	return NOTIFY_DONE;
-- 
2.7.4
