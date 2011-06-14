From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH] sky2: avoid using uninitialized variable
Date: Mon, 13 Jun 2011 17:34:00 -0700
Message-ID: <BANLkTi=jw5=9LcwxnXW6xNkF4RbFhHaB55Au=oDhn1yYWf53dA@mail.gmail.com>
References: <xr93vcw9s9zc.fsf@gthelen.mtv.corp.google.com> <20110613181212.571f8e76@s6510.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:37429 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753187Ab1FNAeX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2011 20:34:23 -0400
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id p5E0YL5k031135
	for <netdev@vger.kernel.org>; Mon, 13 Jun 2011 17:34:21 -0700
Received: from qyk29 (qyk29.prod.google.com [10.241.83.157])
	by hpaq14.eem.corp.google.com with ESMTP id p5E0XkmQ006752
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 13 Jun 2011 17:34:20 -0700
Received: by qyk29 with SMTP id 29so1278194qyk.17
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2011 17:34:20 -0700 (PDT)
In-Reply-To: <20110613181212.571f8e76@s6510.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 13, 2011 at 3:12 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Mon, 13 Jun 2011 14:21:59 -0700
> Greg Thelen <gthelen@google.com> wrote:
>
>> I am not sure if 0 or ~0 would be a better choice in the gm_phy_read=
()
>> error case. =A0I used 0. =A0A more complete solution might be to plu=
mb up
>> error handling to the callers of gm_phy_read().
>>
>> =3D=3D
>> From 37486219a3d93881f3b2619a4b2bb21be62db7d4 Mon Sep 17 00:00:00 20=
01
>> From: Greg Thelen <gthelen@google.com>
>> Date: Mon, 13 Jun 2011 14:09:07 -0700
>> Subject: [PATCH] sky2: avoid using uninitialized variable
>>
>> Prior to this change gm_phy_read() could return an uninitialized
>> variable if __gm_phy_read() failed.
>>
>> This change returns zero in the failure case.
>>
>> Signed-off-by: Greg Thelen <gthelen@google.com>
>
> Shouldn't the callers be changed to check rather than just returning
> 0 and masking the problem.

I agree that the right long term solution is to plumb the error
handling up through the callers.  This would involve deleting the
error-free gm_phy_read() routine and replacing all calls to it with
calls to error-capable __gm_phy_read().  This would require converting
several routines from returning void to returning int allowing errors
to propagate upwards.  Notable affected routines include:
sky2_phy_power_up(), sky2_wol_init(), sky2_phy_power_down(),
sky2_hw_down(), sky2_mac_init(), sky2_hw_up(), sky2_phy_intr(),
sky2_led().  sky2_restart() would likely have to re-queue the work
item in the case of failure.  Presumably sky2_poll() would return 0 if
error is seen.  On a related note, it also seems that gm_phy_write()
callers should be checking its return value to also handle the same
class of I/O errors.  Testing these changes would involve injecting
error values or access to certain kinds of broken hardware.

=46or the short term I figured that not consuming random data was a ste=
p
in right direction.  But I understand if you prefer to hold out for
the complete solution.  Unfortunately, I do not currently have time to
contribute to the complete solution.
