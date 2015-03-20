From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/3] net: introduce IFF_PROTO_DOWN flag.
Date: Fri, 20 Mar 2015 09:45:51 -0700
Message-ID: <CACcJQnRBE4sU6HNvALNdNvr8H-QSo6f41qBXPyTg1qKnmehDPw@mail.gmail.com>
References: <1426864318-25132-1-git-send-email-anuradhak@cumulusnetworks.com>
	<CAADnVQKyOA7QADk9KOz_-ZFO+WJs2bbRsXZyXXr0sWag4jpOBw@mail.gmail.com>
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
Received: from mail-yh0-f49.google.com ([209.85.213.49]:35783 "EHLO
	mail-yh0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751077AbbCTQpw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 12:45:52 -0400
Received: by yhim52 with SMTP id m52so14029688yhi.2
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 09:45:51 -0700 (PDT)
In-Reply-To: <CAADnVQKyOA7QADk9KOz_-ZFO+WJs2bbRsXZyXXr0sWag4jpOBw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2015 at 9:13 AM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Fri, Mar 20, 2015 at 8:11 AM,  <anuradhak@cumulusnetworks.com> wro=
te:
>> From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
>>
>> Applications can detect errors in the network that would require
>> disabling the device independent of the admin state. In the presence=
 of
>> these errors traffic could be black holed or looped resulting in a
>> network meltdown. Clearing the IFF_UP flag for error disabling the
>> device can be problematic because -
>>
>> 1. The administrator cannot distinguish between a user space daemon=E2=
=80=99s
>> error-disable and a regular device disable.
>> 2. Applications can monitor the error state and enable the device on=
ce
>> the error is removed. If IFF_UP is used for this purpose the applica=
tion
>> may end up enabling a device that the administrator has intentionall=
y
>> disabled for other reasons. This could result in network changes not
>> expected by the admin.
>>
>
> Both reasons look like workaround for user space issues.
> Just keep this fake-down state in userspace.
> What's the point pushing it to kernel?

Applications can deal with IFF_UP being cleared and they can certainly
clear IFF_UP as well on detecting errors. However an application
cannot know the reason for the !IFF_UP notification. So if an
application detected a device error being cleared it would have to
unconditionally enable the device as a part of recovery handling
thereby ignoring the administrator=E2=80=99s request to keep the device
disabled. Separating error-disable (IFF_PROTO_DOWN) from admin-disable
(!IFF_UP) lets the administrator have a say in keeping a device
disabled.

> looking at 3rd patch:
> + * @IF_LINK_PROTO_DOWN_MLAG: proto_down by a multi-chassis LAG appli=
cation.
> + * @IF_LINK_PROTO_DOWN_STP: proto_down by an STP application.
>
> so there will be new flag for every application that cannot deal with
> normal down?

These applications can clear the error state independent of each
other. Say for e.g.  both STP-BPDU guard and MLAG error-disabled a
device. When the MLAG split-brain error is resolved the MLAG
application could clear IFF_PROTO_DOWN but the BPDU guard error would
still exist. This will create problem windows that could aggressively
affect the network.

New bits only need to be added if there are new errors that need to be
cleared independent of other applications that can error-disable a
device.
