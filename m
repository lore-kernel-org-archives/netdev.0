From: "Ward, David - 0663 - MITLL" <david.ward@ll.mit.edu>
Subject: Re: [PATCH] net/garp: avoid infinite loop if attribute already
 exists
Date: Mon, 26 Mar 2012 10:11:35 -0400
Message-ID: <4F707917.4020003@ll.mit.edu>
References: <1332715437-16278-1-git-send-email-david.ward@ll.mit.edu>
 <4F7051B6.1030205@dti2.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pkcs7-signature";
	micalg=sha1; boundary="------------ms050007060305010800090003"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "jorge@dti2.net" <jorge@dti2.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:40532 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757403Ab2CZOLk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Mar 2012 10:11:40 -0400
In-Reply-To: <4F7051B6.1030205@dti2.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--------------ms050007060305010800090003
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

On 26/03/12 07:23, Jorge Boncompte [DTI2] wrote:
> El 26/03/2012 0:43, David Ward escribi=F3:
>> An infinite loop occurred if garp_attr_create was called with the
>> values of an existing attribute. Return -EEXIST instead.
> 	I should have sent this some months ago but others things keep me from=
 doing it.
> 	Anyway, I think that the right thing to do it's reuse the attribute to=
 not
> disturb the switch/network. Also, returning an error it's pointless bec=
ause
> nobody checks vlan_gvrp_request_join() return and you'll end up in a st=
ate where
> the VLAN device has the GVRP flag but it's not announcing the attribute=
=2E

I think what you are saying is that if we try to create an attribute=20
that already exists, we should leave the old attribute alone.  I agree=20
with that, and the patch I sent does that.  I also think the fact that=20
the attribute existed would likely indicate a bug in the GARP=20
application, in which we are not withdrawing an existing attribute when=20
we should.  Your patch warns on this condition.

Our patches are mostly the same.  One thing I notice with your patch is=20
that for new attributes, it now traverses the RB tree twice.  And it=20
doesn't free the memory for a new attribute if it wasn't inserted into=20
the RB tree.  So, what if instead I modified my patch to add=20
"WARN_ON(err)" to either garp_request_join or vlan_gvrp_request_join? =20
This would also warn us on -ENOMEM.

David

>
>   	Please take a look at the conversation I had with Patrick in the pat=
ch commit log.
>
> 	If you agree, I'm fine with you redoing your patch or David using mine=
 if he
> thinks it's ok.
>
> 	Regards,
> 		Jorge
>
>> Signed-off-by: David Ward<david.ward@ll.mit.edu>
>> ---
>>   net/802/garp.c |   18 +++++++++++++-----
>>   1 files changed, 13 insertions(+), 5 deletions(-)
>>
>> diff --git a/net/802/garp.c b/net/802/garp.c
>> index 8e21b6d..bb5015e 100644
>> --- a/net/802/garp.c
>> +++ b/net/802/garp.c
>> @@ -167,7 +167,7 @@ static struct garp_attr *garp_attr_lookup(const st=
ruct garp_applicant *app,
>>   	return NULL;
>>   }
>>
>> -static void garp_attr_insert(struct garp_applicant *app, struct garp_=
attr *new)
>> +static int garp_attr_insert(struct garp_applicant *app, struct garp_a=
ttr *new)
>>   {
>>   	struct rb_node *parent =3D NULL, **p =3D&app->gid.rb_node;
>>   	struct garp_attr *attr;
>> @@ -181,24 +181,32 @@ static void garp_attr_insert(struct garp_applica=
nt *app, struct garp_attr *new)
>>   			p =3D&parent->rb_left;
>>   		else if (d>  0)
>>   			p =3D&parent->rb_right;
>> +		else
>> +			return -EEXIST;
>>   	}
>>   	rb_link_node(&new->node, parent, p);
>>   	rb_insert_color(&new->node,&app->gid);
>> +	return 0;
>>   }
>>
>>   static struct garp_attr *garp_attr_create(struct garp_applicant *app=
,
>>   					  const void *data, u8 len, u8 type)
>>   {
>>   	struct garp_attr *attr;
>> +	int err;
>>
>>   	attr =3D kmalloc(sizeof(*attr) + len, GFP_ATOMIC);
>>   	if (!attr)
>> -		return attr;
>> +		return PTR_ERR(-ENOMEM);
>>   	attr->state =3D GARP_APPLICANT_VO;
>>   	attr->type  =3D type;
>>   	attr->dlen  =3D len;
>>   	memcpy(attr->data, data, len);
>> -	garp_attr_insert(app, attr);
>> +	err =3D garp_attr_insert(app, attr);
>> +	if (err<  0) {
>> +		kfree(attr);
>> +		return PTR_ERR(err);
>> +	}
>>   	return attr;
>>   }
>>
>> @@ -353,9 +361,9 @@ int garp_request_join(const struct net_device *dev=
,
>>
>>   	spin_lock_bh(&app->lock);
>>   	attr =3D garp_attr_create(app, data, len, type);
>> -	if (!attr) {
>> +	if (IS_ERR(attr)) {
>>   		spin_unlock_bh(&app->lock);
>> -		return -ENOMEM;
>> +		return ERR_PTR(attr);
>>   	}
>>   	garp_attr_event(app, attr, GARP_EVENT_REQ_JOIN);
>>   	spin_unlock_bh(&app->lock);


--------------ms050007060305010800090003
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

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
h4HfOoHsBGFUMYQGMnL48b9p9mXwrJXo/WKFGe8l9+dLoOWMdZ+dvKQva9kEAAOnbIZ2xXSi
7EAz0AD/QPSwUnf8MYIDKjCCAyYCAQEwXzBRMQswCQYDVQQGEwJVUzEfMB0GA1UEChMWTUlU
IExpbmNvbG4gTGFib3JhdG9yeTEMMAoGA1UECxMDUEtJMRMwEQYDVQQDEwpNSVRMTCBDQS0y
Agodmr+JAAAAACaLMAkGBSsOAwIaBQCgggGgMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEw
HAYJKoZIhvcNAQkFMQ8XDTEyMDMyNjE0MTEzNVowIwYJKoZIhvcNAQkEMRYEFNEgfSg5ltfC
2ybKDgq4OidydO4eMF8GCSqGSIb3DQEJDzFSMFAwCwYJYIZIAWUDBAECMAoGCCqGSIb3DQMH
MA4GCCqGSIb3DQMCAgIAgDANBggqhkiG9w0DAgIBQDAHBgUrDgMCBzANBggqhkiG9w0DAgIB
KDBuBgkrBgEEAYI3EAQxYTBfMFExCzAJBgNVBAYTAlVTMR8wHQYDVQQKExZNSVQgTGluY29s
biBMYWJvcmF0b3J5MQwwCgYDVQQLEwNQS0kxEzARBgNVBAMTCk1JVExMIENBLTICCh2aFRcA
AAAAJoowcAYLKoZIhvcNAQkQAgsxYaBfMFExCzAJBgNVBAYTAlVTMR8wHQYDVQQKExZNSVQg
TGluY29sbiBMYWJvcmF0b3J5MQwwCgYDVQQLEwNQS0kxEzARBgNVBAMTCk1JVExMIENBLTIC
Ch2aFRcAAAAAJoowDQYJKoZIhvcNAQEBBQAEggEAQECUunPyy53ki97WNx1388WRkuklX/R+
As0xQzPHHLOyOzofIL2FbOVXuACDe8tYifbz3h7zfcXMkkylkONhrTP3JA+dJa7P0Oq5aJQM
KGSMKpDxxpfX/Zaun7pPDauy67Qq9rm1Sz7dfdr4u8xEyf1H13SdaoEnXJwq1X1TePLJZf3U
/yLtXIZuYz6xLA4i4wfFpB7BdZQPx/Tz65JE0tp6AdU0BiueTnDyVRHQte5J5P1mhhUtqJC+
nEQswBE7xHHPYIdnYHqAEEqzMmkoKXI0NH9Nds/GU5HBBYF2x86qPWm2V6ILlYc+PxrbNQ2c
VVw7EocYEs/svcLA7emWpwAAAAAAAA==
--------------ms050007060305010800090003--
