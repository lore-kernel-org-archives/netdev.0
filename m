From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Subject: Re: [RFC PATCH net-next v3 1/4] net core: Add IFF_PROTO_DOWN support.
Date: Wed, 29 Apr 2015 16:07:58 -0700
Message-ID: <CACcJQnTYa-TuVzOi7B7cYFqht_KPbi9EB+_L0TuaPxWjPZ6oKg@mail.gmail.com>
References: <1430156304-13187-2-git-send-email-anuradhak@cumulusnetworks.com>
	<20150429151336.0d6d8aab@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Wilson Kok <wkok@cumulusnetworks.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:35764 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751306AbbD2XIA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 19:08:00 -0400
Received: by labbd9 with SMTP id bd9so31589726lab.2
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 16:07:58 -0700 (PDT)
In-Reply-To: <20150429151336.0d6d8aab@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 29, 2015 at 3:13 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Mon, 27 Apr 2015 10:38:21 -0700
> anuradhak@cumulusnetworks.com wrote:
>
>> From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
>>
>> This patch introduces an IFF_PROTO_DOWN flag that can be used by
>> user space applications to notify drivers that errors have been
>> detected on the device.
>>
>> Signed-off-by: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
>> Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>> Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
>
> I worry that adding another bit to an already complex state API
> will break userspace.
>
> There are lots of things besides iproute2 which look at those
> flags including routing daemons (quagga), network manager, netplugd,
> and switch controllers.

Yes, I understand your concerns here. And tried to work around introduc=
ing
a separate error flag by clearing IFF_UP on proto_down/detecting errors=
 (as
Scott also brought up earlier).

That implementation failed because of the following reasons -
1. There is no way to disambiguate between admin_down (!IFF_UP) and an
APP/driver enforced error_down (IFF_PROTO_DOWN). Administrator or
automation-scripts that monitor the config assumed that switch-port
configuration had somehow fallen out of sync (and attempted to reinstat=
e the
admin_up repeatedly).

2. Automatic error recovery was not possible; consider the following sc=
enario
for e.g.
   a. The MLAG peer-link is down so the MLAG app on the secondary switc=
h has
      proto_down=E2=80=99ed all the MLAG ports (including switch-port s=
wp1) by clearing
      IFF_UP.
   b. At the same time the administrator is in the process of making so=
me
      changes on the network connected to swp1. To avoid doing it live =
he would
      admin_disable swp1 (!IFF_UP) by doing an "ip link set swp1 down" =
(this
      is a no-op as event #a has already cleared IFF_UP on swp1).
   c. If the MLAG peer-link recovers at this point the MLAG app on the
      secondary switch would try to automatically recover the MLAG port=
s
      by clearing proto_down (i.e. setting IFF_UP); including on swp1. =
Doing
      that overrides the administrator=E2=80=99s directive to keep swp1=
 admin_down.
      Overriding an admin-down in a live network can be very dangerous =
so it
      is not possible to do auto-error-recovery unless we have a way to
      disambiguate between the admin and error states.
