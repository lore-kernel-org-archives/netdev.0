From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: Re: [PATCH] net/garp: avoid infinite loop if attribute already exists
Date: Mon, 26 Mar 2012 17:26:18 +0200
Message-ID: <4F708A9A.8040705@dti2.net>
References: <1332715437-16278-1-git-send-email-david.ward@ll.mit.edu> <4F7051B6.1030205@dti2.net> <4F707917.4020003@ll.mit.edu>
Reply-To: jorge@dti2.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: david.ward@ll.mit.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from alcalazamora.dti2.net ([81.24.162.8]:50260 "EHLO
	alcalazamora.dti2.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932659Ab2CZP0z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 11:26:55 -0400
Received: from [172.16.16.6] ([81.24.161.20])
	(authenticated user jorge@dti2.net)
	by alcalazamora.dti2.net (alcalazamora.dti2.net [81.24.162.8])
	(MDaemon PRO v12.5.2)
	with ESMTP id md50021710214.msg
	for <netdev@vger.kernel.org>; Mon, 26 Mar 2012 17:26:27 +0200
In-Reply-To: <4F707917.4020003@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

El 26/03/2012 16:11, Ward, David - 0663 - MITLL escribi=F3:
> On 26/03/12 07:23, Jorge Boncompte [DTI2] wrote:
>> El 26/03/2012 0:43, David Ward escribi=F3:
>>> An infinite loop occurred if garp_attr_create was called with the
>>> values of an existing attribute. Return -EEXIST instead.
>>     I should have sent this some months ago but others things keep m=
e from
>> doing it.
>>     Anyway, I think that the right thing to do it's reuse the attrib=
ute to not
>> disturb the switch/network. Also, returning an error it's pointless =
because
>> nobody checks vlan_gvrp_request_join() return and you'll end up in a=
 state where
>> the VLAN device has the GVRP flag but it's not announcing the attrib=
ute.
>=20
> I think what you are saying is that if we try to create an attribute =
that
> already exists, we should leave the old attribute alone.  I agree wit=
h that, and
> the patch I sent does that.  I also think the fact that the attribute=
 existed
> would likely indicate a bug in the GARP application, in which we are =
not
> withdrawing an existing attribute when we should.  Your patch warns o=
n this
> condition.

	The attribute it's still on the tree because the leave path it's calle=
d
asynchronously from a timer. As far as I could see there's no other cod=
e path
that can put an attribute on the tree twice and that's why I put the WA=
RN_ON().

> Our patches are mostly the same.  One thing I notice with your patch =
is that for
> new attributes, it now traverses the RB tree twice.  And it doesn't f=
ree the
> memory for a new attribute if it wasn't inserted into the RB tree.  S=
o, what if
> instead I modified my patch to add "WARN_ON(err)" to either garp_requ=
est_join or
> vlan_gvrp_request_join?  This would also warn us on -ENOMEM.
>=20
> David
>=20
>>
>>       Please take a look at the conversation I had with Patrick in t=
he patch
>> commit log.
>>
>>     If you agree, I'm fine with you redoing your patch or David usin=
g mine if he
>> thinks it's ok.
>>
>>     Regards,
>>         Jorge
>>
>>> Signed-off-by: David Ward<david.ward@ll.mit.edu>
>>> ---
>>>   net/802/garp.c |   18 +++++++++++++-----
>>>   1 files changed, 13 insertions(+), 5 deletions(-)
>>>
>>> diff --git a/net/802/garp.c b/net/802/garp.c
>>> index 8e21b6d..bb5015e 100644
>>> --- a/net/802/garp.c
>>> +++ b/net/802/garp.c
>>> @@ -167,7 +167,7 @@ static struct garp_attr *garp_attr_lookup(const=
 struct
>>> garp_applicant *app,
>>>       return NULL;
>>>   }
>>>
>>> -static void garp_attr_insert(struct garp_applicant *app, struct ga=
rp_attr *new)
>>> +static int garp_attr_insert(struct garp_applicant *app, struct gar=
p_attr *new)
>>>   {
>>>       struct rb_node *parent =3D NULL, **p =3D&app->gid.rb_node;
>>>       struct garp_attr *attr;
>>> @@ -181,24 +181,32 @@ static void garp_attr_insert(struct garp_appl=
icant
>>> *app, struct garp_attr *new)
>>>               p =3D&parent->rb_left;
>>>           else if (d>  0)
>>>               p =3D&parent->rb_right;
>>> +        else
>>> +            return -EEXIST;
>>>       }
>>>       rb_link_node(&new->node, parent, p);
>>>       rb_insert_color(&new->node,&app->gid);
>>> +    return 0;
>>>   }
>>>
>>>   static struct garp_attr *garp_attr_create(struct garp_applicant *=
app,
>>>                         const void *data, u8 len, u8 type)
>>>   {
>>>       struct garp_attr *attr;
>>> +    int err;
>>>
>>>       attr =3D kmalloc(sizeof(*attr) + len, GFP_ATOMIC);
>>>       if (!attr)
>>> -        return attr;
>>> +        return PTR_ERR(-ENOMEM);
>>>       attr->state =3D GARP_APPLICANT_VO;
>>>       attr->type  =3D type;
>>>       attr->dlen  =3D len;
>>>       memcpy(attr->data, data, len);
>>> -    garp_attr_insert(app, attr);
>>> +    err =3D garp_attr_insert(app, attr);
>>> +    if (err<  0) {
>>> +        kfree(attr);
>>> +        return PTR_ERR(err);
>>> +    }
>>>       return attr;
>>>   }
>>>
>>> @@ -353,9 +361,9 @@ int garp_request_join(const struct net_device *=
dev,
>>>
>>>       spin_lock_bh(&app->lock);
>>>       attr =3D garp_attr_create(app, data, len, type);
>>> -    if (!attr) {
>>> +    if (IS_ERR(attr)) {
>>>           spin_unlock_bh(&app->lock);
>>> -        return -ENOMEM;
>>> +        return ERR_PTR(attr);
>>>       }
>>>       garp_attr_event(app, attr, GARP_EVENT_REQ_JOIN);
>>>       spin_unlock_bh(&app->lock);
>=20
