From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/3] net: introduce IFF_PROTO_DOWN flag.
Date: Fri, 20 Mar 2015 13:23:55 -0700
Message-ID: <CACcJQnQd0WuDc_PGLwCem-HVni9bmObky3qhOBv+2Uc4mSLtsA@mail.gmail.com>
References: <CAADnVQL=4UUs495s7Ddcs53nctj_bLiXUCHdPfcTxTXecBO0NA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Wilson Kok <wkok@cumulusnetworks.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f44.google.com ([209.85.213.44]:33299 "EHLO
	mail-yh0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751877AbbCTUX4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 16:23:56 -0400
Received: by yhpt93 with SMTP id t93so44981962yhp.0
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 13:23:55 -0700 (PDT)
In-Reply-To: <CAADnVQL=4UUs495s7Ddcs53nctj_bLiXUCHdPfcTxTXecBO0NA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2015 at 11:50 AM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Fri, Mar 20, 2015 at 9:45 AM, Anuradha Karuppiah
> <anuradhak@cumulusnetworks.com> wrote:
>> On Fri, Mar 20, 2015 at 9:13 AM, Alexei Starovoitov
>> <alexei.starovoitov@gmail.com> wrote:
>>> On Fri, Mar 20, 2015 at 8:11 AM,  <anuradhak@cumulusnetworks.com> w=
rote:
>>>> From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
>>>>
>>>> Applications can detect errors in the network that would require
>>>> disabling the device independent of the admin state. In the presen=
ce of
>>>> these errors traffic could be black holed or looped resulting in a
>>>> network meltdown. Clearing the IFF_UP flag for error disabling the
>>>> device can be problematic because -
>>>>
>>>> 1. The administrator cannot distinguish between a user space daemo=
n=E2=80=99s
>>>> error-disable and a regular device disable.
>>>> 2. Applications can monitor the error state and enable the device =
once
>>>> the error is removed. If IFF_UP is used for this purpose the appli=
cation
>>>> may end up enabling a device that the administrator has intentiona=
lly
>>>> disabled for other reasons. This could result in network changes n=
ot
>>>> expected by the admin.
>>>>
>>>
>>> Both reasons look like workaround for user space issues.
>>> Just keep this fake-down state in userspace.
>>> What's the point pushing it to kernel?
>>
>> Applications can deal with IFF_UP being cleared and they can certain=
ly
>> clear IFF_UP as well on detecting errors. However an application
>> cannot know the reason for the !IFF_UP notification. So if an
>> application detected a device error being cleared it would have to
>> unconditionally enable the device as a part of recovery handling
>> thereby ignoring the administrator=E2=80=99s request to keep the dev=
ice
>> disabled. Separating error-disable (IFF_PROTO_DOWN) from admin-disab=
le
>> (!IFF_UP) lets the administrator have a say in keeping a device
>> disabled.
>>
>>> looking at 3rd patch:
>>> + * @IF_LINK_PROTO_DOWN_MLAG: proto_down by a multi-chassis LAG app=
lication.
>>> + * @IF_LINK_PROTO_DOWN_STP: proto_down by an STP application.
>>>
>>> so there will be new flag for every application that cannot deal wi=
th
>>> normal down?
>>
>> These applications can clear the error state independent of each
>> other. Say for e.g.  both STP-BPDU guard and MLAG error-disabled a
>> device. When the MLAG split-brain error is resolved the MLAG
>> application could clear IFF_PROTO_DOWN but the BPDU guard error woul=
d
>> still exist. This will create problem windows that could aggressivel=
y
>> affect the network.
>>
>
> if I understand this correctly you have implementation of
> stp-bpdu guard in user space instead of bridge stp core and
> that is causing these issues. If you move this feature into
> the kernel you won't have to add this special down state, right?

IFF_PROTO_DOWN is needed to distinguish between admin and error
disable states. Even if a kernel driver was setting or clearing the
error-disable state via dev_close/open it could still end up
overriding the administrator=E2=80=99s need to keep a device DOWN as a =
part of
its error recovery handling. To avoid that problem the kernel STP
BPDU-guard could also use dev_set_proto_down(=E2=80=A6,IF_LINK_PROTO_DO=
WN_STP)
to disable misbehaving access ports.
