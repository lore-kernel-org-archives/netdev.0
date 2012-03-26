From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: Re: [PATCH] net/garp: avoid infinite loop if attribute already exists
Date: Mon, 26 Mar 2012 13:23:34 +0200
Message-ID: <4F7051B6.1030205@dti2.net>
References: <1332715437-16278-1-git-send-email-david.ward@ll.mit.edu>
Reply-To: jorge@dti2.net
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040200040201000403030906"
Cc: netdev@vger.kernel.org
To: david.ward@ll.mit.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from alcalazamora.dti2.net ([81.24.162.8]:56925 "EHLO
	alcalazamora.dti2.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932092Ab2CZL2u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 07:28:50 -0400
Received: from [172.16.16.6] ([81.24.161.20])
	(authenticated user jorge@dti2.net)
	by alcalazamora.dti2.net (alcalazamora.dti2.net [81.24.162.8])
	(MDaemon PRO v12.5.2)
	with ESMTP id md50021704769.msg
	for <netdev@vger.kernel.org>; Mon, 26 Mar 2012 13:23:36 +0200
In-Reply-To: <1332715437-16278-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040200040201000403030906
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit

El 26/03/2012 0:43, David Ward escribi�:
> An infinite loop occurred if garp_attr_create was called with the
> values of an existing attribute. Return -EEXIST instead.

	I should have sent this some months ago but others things keep me from doing it.
	Anyway, I think that the right thing to do it's reuse the attribute to not
disturb the switch/network. Also, returning an error it's pointless because
nobody checks vlan_gvrp_request_join() return and you'll end up in a state where
the VLAN device has the GVRP flag but it's not announcing the attribute.

 	Please take a look at the conversation I had with Patrick in the patch commit log.

	If you agree, I'm fine with you redoing your patch or David using mine if he
thinks it's ok.

	Regards,
		Jorge

> 
> Signed-off-by: David Ward <david.ward@ll.mit.edu>
> ---
>  net/802/garp.c |   18 +++++++++++++-----
>  1 files changed, 13 insertions(+), 5 deletions(-)
> 
> diff --git a/net/802/garp.c b/net/802/garp.c
> index 8e21b6d..bb5015e 100644
> --- a/net/802/garp.c
> +++ b/net/802/garp.c
> @@ -167,7 +167,7 @@ static struct garp_attr *garp_attr_lookup(const struct garp_applicant *app,
>  	return NULL;
>  }
>  
> -static void garp_attr_insert(struct garp_applicant *app, struct garp_attr *new)
> +static int garp_attr_insert(struct garp_applicant *app, struct garp_attr *new)
>  {
>  	struct rb_node *parent = NULL, **p = &app->gid.rb_node;
>  	struct garp_attr *attr;
> @@ -181,24 +181,32 @@ static void garp_attr_insert(struct garp_applicant *app, struct garp_attr *new)
>  			p = &parent->rb_left;
>  		else if (d > 0)
>  			p = &parent->rb_right;
> +		else
> +			return -EEXIST;
>  	}
>  	rb_link_node(&new->node, parent, p);
>  	rb_insert_color(&new->node, &app->gid);
> +	return 0;
>  }
>  
>  static struct garp_attr *garp_attr_create(struct garp_applicant *app,
>  					  const void *data, u8 len, u8 type)
>  {
>  	struct garp_attr *attr;
> +	int err;
>  
>  	attr = kmalloc(sizeof(*attr) + len, GFP_ATOMIC);
>  	if (!attr)
> -		return attr;
> +		return PTR_ERR(-ENOMEM);
>  	attr->state = GARP_APPLICANT_VO;
>  	attr->type  = type;
>  	attr->dlen  = len;
>  	memcpy(attr->data, data, len);
> -	garp_attr_insert(app, attr);
> +	err = garp_attr_insert(app, attr);
> +	if (err < 0) {
> +		kfree(attr);
> +		return PTR_ERR(err);
> +	}
>  	return attr;
>  }
>  
> @@ -353,9 +361,9 @@ int garp_request_join(const struct net_device *dev,
>  
>  	spin_lock_bh(&app->lock);
>  	attr = garp_attr_create(app, data, len, type);
> -	if (!attr) {
> +	if (IS_ERR(attr)) {
>  		spin_unlock_bh(&app->lock);
> -		return -ENOMEM;
> +		return ERR_PTR(attr);
>  	}
>  	garp_attr_event(app, attr, GARP_EVENT_REQ_JOIN);
>  	spin_unlock_bh(&app->lock);


--------------040200040201000403030906
Content-Type: text/x-patch;
 name="0001-PATCH-garp-fix-livelock-on-link-bouncing.patch"
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment;
 filename="0001-PATCH-garp-fix-livelock-on-link-bouncing.patch"

>From 9570dd1bd728399bf47722a9e966ace42d6441fa Mon Sep 17 00:00:00 2001
From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Date: Mon, 26 Mar 2012 12:52:13 +0200
Subject: [PATCH] [PATCH] garp: fix livelock on link bouncing
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

    Fixes a bug in the GARP code when a VLAN interface changes from down
to up state quickly.

    The tree insertion routine doesn't check that the attr it's still on
the tree and enters and infinite loop (livelocks).

    Instead of returning an error we just reuse the existing attr to not
disturb the switch in front of us.

    Conversation with Patrick follows...

El 30/11/2011 14:02, Patrick McHardy escribió:
> On 11/29/2011 06:01 PM, Jorge Boncompte [DTI2] wrote:
>> El 29/11/2011 14:50, Patrick McHardy escribió:
>>> On 11/28/2011 04:39 PM, Jorge Boncompte [DTI2] wrote:
>>>> El 28/11/2011 16:11, Patrick McHardy escribió:
>>>>> On 25.11.2011 18:13, Jorge Boncompte [DTI2] wrote:
>>>>>>      Patrick, could you take a look at the attached patch? It fixes
>>>>>> a bug in the GARP code when you put a VLAN interface down/up in a
>>>>>> quick sucession. I've noticed it because some of my boxes where
>>>>>> hanging when moving interfaces between netns's.
>>>>> I'm not sure I understand the condition leading to this.
>>>>> Basically the GVRP join should only happen under the
>>>>> RTNL mutex, so I don't see how we can race during that.
>>>>      It has nothing to do with the RTNL, the problem is that
>>>> garp_request_leave() arms the timer and the leave packet it's not sent
>>>> inmediately and the attribute it's still on the tree when the new
>>>> garp_request_join() happens, for example moving a VLAN interface from
>>>> netns or by a quick down/up sucession.
>>>> garp_attr_insert() doesn't handle the condition that the attr exists
>>>> already and livelocks in the while loop.
>>>>
>>>>      So, instead of sending the leave packet synchronously from the
>>>> leave path I have opted for reinitializing the already existing
>>>> attribute that should not disturb the switch where we're attached.
>>> Yes, that seems like the better option. But I don't think this is fully
>>> correct (might be missing something though, it has been quite a while
>>> since I last worked on this code). If the applicant is in
>>> GARP_APPLICANT_LA state and a GARP_EVENT_TRANSMIT_PDU event is
>>> generated, the action will be GARP_ACTION_S_LEAVE_EMPTY, after which
>>> the attribute is destroyed immediately. Since we skip insertion with
>>> your patch, the attribute will incorrectly be gone. So I think what we
>>> need is either refcounting on the attribute to handle this case or
>>> alternatively send the message immediately.
>>>
>>> Does that make sense?
>>     What you describe happens from the timer, after garp_request_leave()
>> has moved the applicant to _LA state and _REQ_LEAVE event. That's what
>> happens in the normal case when you put the interface down for example.
>>
>>     In the case I describe the garp_request_join() comes betweeen the
>> call to garp_request_leave() and before the timer fires. The attr is
>> still on the tree so without my fix you livelock. With my changes
>> garp_request_join() calls garp_attr_create() that founds and return the
>> existing attr, and then calls garp_attr_event() with the _REQ_JOIN event.
>> This moves the attr from the _LA state to the _VA one. After that the
>> timer fires and founds the attr in the _VA state instead of _LA and so
>> the attr is not destroyed (and no need to refcount it).
>>
>>     All this happens under the app->lock so the timer sees the attr on
>> the _LA state or on the VA state and in either case it does the right
>> thing from my POV. I am no expert on GARP but I've researched a bit the
>> protocol and the state transition from _LA to _VA looks ok to me.
>>
>>     Here you have some output of a my patch with some test printk()'s
>> in case you can understand it better that my non-native english :)
>
> OK, this seems fine to me. If you change the WARN_ON to a
> WARN_ON(err) with err = garp_attr_insert(...) you can add
> my Acked-by: Patrick McHardy <kaber@trash.net>.
>
> Thanks!

Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
Acked-by: Patrick McHardy <kaber@trash.net>
---
 net/802/garp.c |   16 ++++++++++++++--
 1 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/net/802/garp.c b/net/802/garp.c
index 8e21b6d..ad72ac4 100644
--- a/net/802/garp.c
+++ b/net/802/garp.c
@@ -167,7 +167,7 @@ static struct garp_attr *garp_attr_lookup(const struct garp_applicant *app,
 	return NULL;
 }
 
-static void garp_attr_insert(struct garp_applicant *app, struct garp_attr *new)
+static int garp_attr_insert(struct garp_applicant *app, struct garp_attr *new)
 {
 	struct rb_node *parent = NULL, **p = &app->gid.rb_node;
 	struct garp_attr *attr;
@@ -181,15 +181,24 @@ static void garp_attr_insert(struct garp_applicant *app, struct garp_attr *new)
 			p = &parent->rb_left;
 		else if (d > 0)
 			p = &parent->rb_right;
+		else
+			return -EEXIST;
 	}
 	rb_link_node(&new->node, parent, p);
 	rb_insert_color(&new->node, &app->gid);
+
+	return 0;
 }
 
 static struct garp_attr *garp_attr_create(struct garp_applicant *app,
 					  const void *data, u8 len, u8 type)
 {
 	struct garp_attr *attr;
+	int err;
+
+	attr = garp_attr_lookup(app, data, len, type);
+	if (attr)
+		return attr;
 
 	attr = kmalloc(sizeof(*attr) + len, GFP_ATOMIC);
 	if (!attr)
@@ -198,7 +207,10 @@ static struct garp_attr *garp_attr_create(struct garp_applicant *app,
 	attr->type  = type;
 	attr->dlen  = len;
 	memcpy(attr->data, data, len);
-	garp_attr_insert(app, attr);
+	err = garp_attr_insert(app, attr);
+
+	WARN_ON(err);
+
 	return attr;
 }
 
-- 
1.7.8.3


--------------040200040201000403030906--
