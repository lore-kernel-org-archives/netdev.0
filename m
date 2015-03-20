From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 0/3] net: introduce IFF_PROTO_DOWN flag.
Date: Fri, 20 Mar 2015 11:50:44 -0700
Message-ID: <CAADnVQL=4UUs495s7Ddcs53nctj_bLiXUCHdPfcTxTXecBO0NA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Wilson Kok <wkok@cumulusnetworks.com>
To: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:34331 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750999AbbCTSvF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 14:51:05 -0400
Received: by qgh62 with SMTP id 62so100978402qgh.1
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 11:51:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2015 at 9:45 AM, Anuradha Karuppiah
<anuradhak@cumulusnetworks.com> wrote:
> On Fri, Mar 20, 2015 at 9:13 AM, Alexei Starovoitov
> <alexei.starovoitov@gmail.com> wrote:
>> On Fri, Mar 20, 2015 at 8:11 AM,  <anuradhak@cumulusnetworks.com> wr=
ote:
>>> From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
>>>
>>> Applications can detect errors in the network that would require
>>> disabling the device independent of the admin state. In the presenc=
e of
>>> these errors traffic could be black holed or looped resulting in a
>>> network meltdown. Clearing the IFF_UP flag for error disabling the
>>> device can be problematic because -
>>>
>>> 1. The administrator cannot distinguish between a user space daemon=
=E2=80=99s
>>> error-disable and a regular device disable.
>>> 2. Applications can monitor the error state and enable the device o=
nce
>>> the error is removed. If IFF_UP is used for this purpose the applic=
ation
>>> may end up enabling a device that the administrator has intentional=
ly
>>> disabled for other reasons. This could result in network changes no=
t
>>> expected by the admin.
>>>
>>
>> Both reasons look like workaround for user space issues.
>> Just keep this fake-down state in userspace.
>> What's the point pushing it to kernel?
>
> Applications can deal with IFF_UP being cleared and they can certainl=
y
> clear IFF_UP as well on detecting errors. However an application
> cannot know the reason for the !IFF_UP notification. So if an
> application detected a device error being cleared it would have to
> unconditionally enable the device as a part of recovery handling
> thereby ignoring the administrator=E2=80=99s request to keep the devi=
ce
> disabled. Separating error-disable (IFF_PROTO_DOWN) from admin-disabl=
e
> (!IFF_UP) lets the administrator have a say in keeping a device
> disabled.
>
>> looking at 3rd patch:
>> + * @IF_LINK_PROTO_DOWN_MLAG: proto_down by a multi-chassis LAG appl=
ication.
>> + * @IF_LINK_PROTO_DOWN_STP: proto_down by an STP application.
>>
>> so there will be new flag for every application that cannot deal wit=
h
>> normal down?
>
> These applications can clear the error state independent of each
> other. Say for e.g.  both STP-BPDU guard and MLAG error-disabled a
> device. When the MLAG split-brain error is resolved the MLAG
> application could clear IFF_PROTO_DOWN but the BPDU guard error would
> still exist. This will create problem windows that could aggressively
> affect the network.
>

if I understand this correctly you have implementation of
stp-bpdu guard in user space instead of bridge stp core and
that is causing these issues. If you move this feature into
the kernel you won't have to add this special down state, right?
